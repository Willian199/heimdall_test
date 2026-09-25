import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// Names forwarded from matching parameters to named arguments of a returned
/// constructor of the owning class.
final class ReturnedConstructorParameterIndex {
  /// Collects supported constructor returns from [roots].
  ReturnedConstructorParameterIndex(Iterable<AstNode> roots, {required String ownerName, required Set<String> parameterNames}) {
    final visitor = _ReturnVisitor(ownerName, parameterNames);
    for (final root in roots) {
      root.accept(visitor);
    }
    fieldsUpdatedInEveryReturn = visitor.returns.isEmpty
        ? const {}
        : Set.unmodifiable(visitor.returns.skip(1).fold<Set<String>>({...visitor.returns.first}, (shared, fields) => shared..retainAll(fields)));
  }

  /// Field names forwarded in every return. Unsupported return expressions
  /// contribute an empty set so they cannot produce a false pass.
  late final Set<String> fieldsUpdatedInEveryReturn;
}

final class _ReturnVisitor extends RecursiveAstVisitor<void> {
  _ReturnVisitor(this.ownerName, this.parameterNames);

  final String ownerName;
  final Set<String> parameterNames;
  final returns = <Set<String>>[];

  @override
  void visitExpressionFunctionBody(ExpressionFunctionBody node) => _collect(node.expression);

  @override
  void visitReturnStatement(ReturnStatement node) {
    final expression = node.expression;
    if (expression == null) {
      returns.add({});
    } else {
      _collect(expression);
    }
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {}

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {}

  void _collect(Expression expression) {
    if (expression is ParenthesizedExpression) {
      _collect(expression.expression);
    } else if (expression is ConditionalExpression) {
      _collect(expression.thenExpression);
      _collect(expression.elseExpression);
    } else if (expression is SwitchExpression) {
      for (final branch in expression.cases) {
        _collect(branch.expression);
      }
    } else {
      final arguments = switch (expression) {
        InstanceCreationExpression(:final constructorName, :final argumentList)
            when constructorName.type.name.lexeme == ownerName && constructorName.type.importPrefix == null =>
          argumentList,
        MethodInvocation(:final target, :final methodName, :final argumentList) when target == null && methodName.name == ownerName => argumentList,
        _ => null,
      };
      if (arguments == null) {
        returns.add({});
        return;
      }
      final forwarded = <String>{};
      for (final argument in arguments.arguments.whereType<NamedExpression>()) {
        final name = argument.name.label.name;
        if (parameterNames.contains(name) && _forwardsParameter(argument.expression, name)) {
          forwarded.add(name);
        }
      }
      returns.add(forwarded);
    }
  }
}

bool _forwardsParameter(Expression expression, String name) {
  if (expression is ParenthesizedExpression) return _forwardsParameter(expression.expression, name);
  if (expression is SimpleIdentifier) return expression.name == name && !_hasLocalShadow(expression);
  if (expression is BinaryExpression && expression.operator.lexeme == '??') {
    return _forwardsParameter(expression.leftOperand, name) && _isCurrentField(expression.rightOperand, name);
  }
  return false;
}

bool _isCurrentField(Expression expression, String name) {
  if (expression is ParenthesizedExpression) return _isCurrentField(expression.expression, name);
  return expression is PropertyAccess && expression.target is ThisExpression && expression.propertyName.name == name;
}

bool _hasLocalShadow(SimpleIdentifier identifier) {
  for (var parent = identifier.parent; parent != null; parent = parent.parent) {
    if (parent is MethodDeclaration) return false;
    if (parent is Block) {
      for (final statement in parent.statements) {
        if (statement.offset >= identifier.offset) break;
        if (statement is VariableDeclarationStatement && statement.variables.variables.any((variable) => variable.name.lexeme == identifier.name)) {
          return true;
        }
        if (statement is FunctionDeclarationStatement && statement.functionDeclaration.name.lexeme == identifier.name) {
          return true;
        }
        if (statement is PatternVariableDeclarationStatement && _declaresName(statement.declaration.pattern, identifier.name)) {
          return true;
        }
      }
    }
    if (parent is ForStatement && _declaresName(parent.forLoopParts, identifier.name)) return true;
    if (parent is CatchClause &&
        (parent.exceptionParameter?.name.lexeme == identifier.name || parent.stackTraceParameter?.name.lexeme == identifier.name)) {
      return true;
    }
    if (parent is IfStatement &&
        parent.caseClause != null &&
        parent.thenStatement.offset <= identifier.offset &&
        identifier.end <= parent.thenStatement.end &&
        _declaresName(parent.caseClause!, identifier.name)) {
      return true;
    }
    if (parent is SwitchPatternCase && _declaresName(parent.guardedPattern.pattern, identifier.name)) return true;
  }
  return false;
}

bool _declaresName(AstNode node, String name) {
  if (node is VariableDeclaration && node.name.lexeme == name) return true;
  if (node is DeclaredIdentifier && node.name.lexeme == name) return true;
  if (node is DeclaredVariablePattern && node.name.lexeme == name) return true;
  return node.childEntities.whereType<AstNode>().any((child) => _declaresName(child, name));
}
