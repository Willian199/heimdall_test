import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// Internal field relationships for a method or getter.
final class MemberRelationshipIndex {
  /// Collects direct field entries in returned list literals.
  MemberRelationshipIndex(Iterable<AstNode> roots) {
    final visitor = _ReturnVisitor();
    for (final root in roots) {
      root.accept(visitor);
    }
    returnedListFields = Set.unmodifiable(visitor.fields);
    returnedListFieldsInEveryReturn = visitor.returnFields.isEmpty
        ? const {}
        : Set.unmodifiable(
            visitor.returnFields.skip(1).fold<Set<String>>({...visitor.returnFields.first}, (shared, fields) => shared..retainAll(fields)),
          );
  }

  /// Direct field names, excluding shadowed locals and other receivers.
  late final Set<String> returnedListFields;

  /// Direct fields present in every returned list literal. Unknown return
  /// expressions contribute no fields, so they cannot make this check pass.
  late final Set<String> returnedListFieldsInEveryReturn;
}

final class _ReturnVisitor extends RecursiveAstVisitor<void> {
  final fields = <String>{};
  final returnFields = <Set<String>>[];

  @override
  void visitExpressionFunctionBody(ExpressionFunctionBody node) => _collect(node.expression);

  @override
  void visitReturnStatement(ReturnStatement node) {
    final expression = node.expression;
    if (expression != null) {
      _collect(expression);
    } else {
      returnFields.add({});
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
    } else if (expression is ListLiteral) {
      final directFields = <String>{};
      for (final element in expression.elements) {
        directFields.addAll(_fieldsInElement(element));
      }
      fields.addAll(directFields);
      returnFields.add(directFields);
    } else {
      returnFields.add({});
    }
  }
}

Set<String> _fieldsInElement(CollectionElement element) {
  if (element is Expression) {
    final name = _fieldName(element);
    return name == null ? {} : {name};
  }
  if (element is IfElement) {
    return {
      ..._fieldsInElement(element.thenElement),
      if (element.elseElement != null) ..._fieldsInElement(element.elseElement!),
    };
  }
  if (element is ForElement) {
    return _fieldsInElement(element.body);
  }
  return {};
}

String? _fieldName(Expression expression) {
  if (expression is ParenthesizedExpression) {
    return _fieldName(expression.expression);
  }
  if (expression is PropertyAccess && expression.target is ThisExpression) {
    return expression.propertyName.name;
  }
  if (expression is! SimpleIdentifier || _isShadowed(expression)) {
    return null;
  }
  return expression.name;
}

bool _isShadowed(SimpleIdentifier identifier) {
  final name = identifier.name;
  for (var parent = identifier.parent; parent != null; parent = parent.parent) {
    if (parent is MethodDeclaration) {
      return parent.parameters?.parameters.any((parameter) => parameter.name?.lexeme == name) ?? false;
    }
    if (parent is Block) {
      for (final statement in parent.statements) {
        // A declaration later in the block cannot shadow this reference.
        if (statement.offset >= identifier.offset) {
          break;
        }
        if (statement is VariableDeclarationStatement && statement.variables.variables.any((variable) => variable.name.lexeme == name)) {
          return true;
        }
        if (statement is FunctionDeclarationStatement && statement.functionDeclaration.name.lexeme == name) {
          return true;
        }
        if (statement is PatternVariableDeclarationStatement && _declaresName(statement.declaration.pattern, name)) {
          return true;
        }
      }
    }
    if (parent is ForStatement &&
        !(parent.forLoopParts is ForEachParts && _contains((parent.forLoopParts as ForEachParts).iterable, identifier)) &&
        _declaresName(parent.forLoopParts, name)) {
      return true;
    }
    if (parent is ForElement && _declaresName(parent.forLoopParts, name)) {
      return true;
    }
    if (parent is CatchClause && (parent.exceptionParameter?.name.lexeme == name || parent.stackTraceParameter?.name.lexeme == name)) {
      return true;
    }
    if (parent is IfStatement &&
        parent.caseClause != null &&
        parent.thenStatement.offset <= identifier.offset &&
        identifier.end <= parent.thenStatement.end &&
        _declaresName(parent.caseClause!, name)) {
      return true;
    }
    if (parent is SwitchPatternCase && _declaresName(parent.guardedPattern.pattern, name)) {
      return true;
    }
    if (parent is IfElement &&
        parent.caseClause != null &&
        _contains(parent.thenElement, identifier) &&
        _declaresName(parent.caseClause!.guardedPattern.pattern, name)) {
      return true;
    }
    if (parent is SwitchExpressionCase && _declaresName(parent.guardedPattern.pattern, name)) {
      return true;
    }
  }
  return false;
}

bool _declaresName(AstNode node, String name) {
  if (node is VariableDeclaration && node.name.lexeme == name) {
    return true;
  }
  if (node is DeclaredIdentifier && node.name.lexeme == name) {
    return true;
  }
  if (node is DeclaredVariablePattern && node.name.lexeme == name) {
    return true;
  }
  return node.childEntities.whereType<AstNode>().any((child) => _declaresName(child, name));
}

bool _contains(AstNode scope, AstNode node) => scope.offset <= node.offset && node.end <= scope.end;
