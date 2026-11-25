import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/util/extension/ast_node_extension.dart';

abstract final class _RegexPatterns {
  static final nullableSuffix = RegExp(r'\?$');
}

/// Conservative local type promotions over one cached expression snapshot.
///
/// Only lexical bindings and dominating `is`/null guards are used. A write
/// between the guard and the reference invalidates that guard's information.
final class FlowPromotionIndex {
  /// Collects writes without revisiting the source AST.
  FlowPromotionIndex(Iterable<Expression> expressions) {
    for (final expression in expressions) {
      final target = switch (expression) {
        AssignmentExpression(:final leftHandSide) => leftHandSide,
        PrefixExpression(:final operand, :final operator) ||
        PostfixExpression(:final operand, :final operator) when operator.lexeme == '++' || operator.lexeme == '--' => operand,
        _ => null,
      };
      if (target is SimpleIdentifier) {
        (_writes[target.name] ??= []).add(expression.offset);
      }
    }
  }

  final _writes = <String, List<int>>{};

  /// Applies known guards within the lexical scope of [binding].
  ({String name, TypeAnnotation? annotation}) promotedType(SimpleIdentifier reference, String declaredType, AstNode binding) {
    final assumptions = <({Expression condition, bool truth})>[];
    final scope = binding is FormalParameter
        ? binding.thisOrAncestorMatching((node) => node is MethodDeclaration || node is ConstructorDeclaration || node is FunctionExpression)
        : binding.thisOrAncestorMatching((node) => node is Block || node is ForStatement || node is ForElement);
    for (var ancestor = reference.parent; ancestor != null; ancestor = ancestor.parent) {
      if (ancestor is IfStatement) {
        if (ancestor.thenStatement.containsNode(reference)) {
          assumptions.add((condition: ancestor.expression, truth: true));
        } else if (ancestor.elseStatement case final branch? when branch.containsNode(reference)) {
          assumptions.add((condition: ancestor.expression, truth: false));
        }
      } else if (ancestor is Block) {
        for (final statement in ancestor.statements) {
          if (statement.offset >= reference.offset || statement.containsNode(reference)) {
            break;
          }
          if (statement.offset < binding.end || statement is! IfStatement) {
            continue;
          }
          final thenExits = _exits(statement.thenStatement);
          final elseExits = statement.elseStatement != null && _exits(statement.elseStatement!);
          if (thenExits != elseExits) {
            assumptions.add((condition: statement.expression, truth: elseExits));
          }
        }
      }
      if (ancestor == scope) {
        break;
      }
    }
    assumptions.sort((a, b) => a.condition.offset.compareTo(b.condition.offset));
    ({String name, TypeAnnotation? annotation}) type = (name: declaredType, annotation: null);
    for (final assumption in assumptions) {
      final written = (_writes[reference.name] ?? const []).any(
        (offset) => offset >= assumption.condition.end && offset < reference.offset,
      );
      if (!written) {
        type = _underCondition(assumption.condition, assumption.truth, reference.name, type);
      }
    }
    return type;
  }

  bool _exits(Statement statement) => switch (statement) {
    ReturnStatement() => true,
    ExpressionStatement(:final expression) => expression is ThrowExpression || expression is RethrowExpression,
    Block(:final statements) => statements.isNotEmpty && _exits(statements.last),
    IfStatement(:final thenStatement, :final elseStatement) => elseStatement != null && _exits(thenStatement) && _exits(elseStatement),
    _ => false,
  };

  ({String name, TypeAnnotation? annotation}) _underCondition(
    Expression condition,
    bool truth,
    String name,
    ({String name, TypeAnnotation? annotation}) current,
  ) {
    switch (condition) {
      case ParenthesizedExpression(:final expression):
        return _underCondition(expression, truth, name, current);
      case PrefixExpression(:final operator, :final operand) when operator.lexeme == '!':
        return _underCondition(operand, !truth, name, current);
      case IsExpression(:final expression, :final notOperator, :final type)
          when expression is SimpleIdentifier && expression.name == name && truth == (notOperator == null):
        return (name: type.toSource(), annotation: type);
      case BinaryExpression(:final leftOperand, :final rightOperand, :final operator):
        final token = operator.lexeme;
        if (token == '&&' && truth || token == '||' && !truth) {
          return _underCondition(rightOperand, truth, name, _underCondition(leftOperand, truth, name, current));
        }
        final comparedToNull =
            leftOperand is SimpleIdentifier && leftOperand.name == name && rightOperand is NullLiteral ||
            rightOperand is SimpleIdentifier && rightOperand.name == name && leftOperand is NullLiteral;
        if ((token == '==' || token == '!=') && comparedToNull) {
          final nonNull = truth == (token == '!=');
          return (name: nonNull ? current.name.replaceFirst(_RegexPatterns.nullableSuffix, '') : 'Null', annotation: current.annotation);
        }
      default:
        break;
    }
    return current;
  }
}
