import 'package:analyzer/dart/ast/ast.dart';

/// Whether [node] is a value read or write, rather than a declaration or label.
bool isValueReference(SimpleIdentifier node) {
  final parent = node.parent;
  if (parent is VariableDeclaration && identical(parent.name, node) ||
      parent is DeclaredIdentifier && identical(parent.name, node) ||
      parent is DeclaredVariablePattern && identical(parent.name, node) ||
      parent is MethodInvocation && identical(parent.methodName, node) ||
      parent is NamedExpression && identical(parent.name.label, node) ||
      parent is Label ||
      parent is FormalParameter ||
      parent is MethodDeclaration ||
      parent is FunctionDeclaration) {
    return false;
  }
  for (var ancestor = parent; ancestor != null; ancestor = ancestor.parent) {
    if (ancestor is DartPattern) {
      return false;
    }
    if (ancestor is RecordLiteral || ancestor is NamedExpression) {
      break;
    }
  }
  return true;
}

/// Whether a lexical binding hides a value with the same name at [reference].
bool isShadowedValue(SimpleIdentifier reference) {
  final name = reference.name;
  for (var ancestor = reference.parent; ancestor != null; ancestor = ancestor.parent) {
    if (ancestor is MethodDeclaration && _parametersDeclare(ancestor.parameters, name) ||
        ancestor is ConstructorDeclaration && _parametersDeclare(ancestor.parameters, name) ||
        ancestor is FunctionExpression && _parametersDeclare(ancestor.parameters, name)) {
      return true;
    }
    if (ancestor is Block) {
      for (final statement in ancestor.statements) {
        if (statement.offset >= reference.offset) {
          break;
        }
        if (statement is VariableDeclarationStatement && statement.variables.variables.any((variable) => variable.name.lexeme == name)) {
          return true;
        }
        if (statement is PatternVariableDeclarationStatement && _declaresName(statement.declaration.pattern, name)) {
          return true;
        }
        if (statement is FunctionDeclarationStatement && statement.functionDeclaration.name.lexeme == name) {
          return true;
        }
      }
    }
    if (ancestor is ForStatement && !_insideForEachIterable(ancestor.forLoopParts, reference) && _declaresName(ancestor.forLoopParts, name)) {
      return true;
    }
    if (ancestor is ForElement && !_insideForEachIterable(ancestor.forLoopParts, reference) && _declaresName(ancestor.forLoopParts, name)) {
      return true;
    }
    if (ancestor is IfStatement &&
        ancestor.caseClause != null &&
        _contains(ancestor.thenStatement, reference) &&
        _declaresName(ancestor.caseClause!, name)) {
      return true;
    }
    if (ancestor is IfElement &&
        ancestor.caseClause != null &&
        _contains(ancestor.thenElement, reference) &&
        _declaresName(ancestor.caseClause!, name)) {
      return true;
    }
    if (ancestor is CatchClause && (ancestor.exceptionParameter?.name.lexeme == name || ancestor.stackTraceParameter?.name.lexeme == name)) {
      return true;
    }
    if (ancestor is SwitchPatternCase && _declaresName(ancestor.guardedPattern.pattern, name)) {
      return true;
    }
    if (ancestor is SwitchExpressionCase && _declaresName(ancestor.guardedPattern.pattern, name)) {
      return true;
    }
  }
  return false;
}

bool _parametersDeclare(FormalParameterList? parameters, String name) =>
    parameters?.parameters.any((parameter) => parameter.name?.lexeme == name) ?? false;

bool _insideForEachIterable(ForLoopParts parts, AstNode node) => parts is ForEachParts && _contains(parts.iterable, node);

bool _contains(AstNode scope, AstNode node) => scope.offset <= node.offset && node.end <= scope.end;

bool _declaresName(AstNode node, String name) {
  if (node is VariableDeclaration && node.name.lexeme == name ||
      node is DeclaredIdentifier && node.name.lexeme == name ||
      node is DeclaredVariablePattern && node.name.lexeme == name) {
    return true;
  }
  return node.childEntities.whereType<AstNode>().any((child) => _declaresName(child, name));
}
