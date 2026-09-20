import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// Returns calls shaped as `Target.method()` inside [node].
List<AstNode> astNodeStaticMethodInvocations(
  AstNode node,
  String targetType,
  String methodName,
) {
  final visitor = StaticMethodInvocationVisitor(targetType, methodName);
  node.accept(visitor);
  return visitor.matches;
}

/// Returns whether [node] contains a call shaped as `Target.method()`.
bool astNodeHasStaticMethodInvocation(
  AstNode node,
  String targetType,
  String methodName,
) {
  final visitor = _HasStaticMethodInvocationVisitor(targetType, methodName);
  node.accept(visitor);
  return visitor.found;
}

/// AST visitor that finds calls shaped as `Target.method()`.
final class StaticMethodInvocationVisitor extends RecursiveAstVisitor<void> {
  /// Creates a visitor that finds [methodName] calls on [targetType].
  StaticMethodInvocationVisitor(this.targetType, this.methodName);

  /// Expected invocation target, such as `HeimdallPredicate`.
  final String targetType;

  /// Expected static method name.
  final String methodName;

  /// Matching invocations.
  final List<AstNode> matches = [];

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (_matchesStaticMethodInvocation(node, targetType, methodName)) {
      matches.add(node);
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    if (_matchesStaticFunctionInvocation(node, targetType, methodName)) {
      matches.add(node);
    }
    super.visitFunctionExpressionInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (_matchesNamedConstructorInvocation(node, targetType, methodName)) {
      matches.add(node);
    }
    super.visitInstanceCreationExpression(node);
  }
}

final class _HasStaticMethodInvocationVisitor extends RecursiveAstVisitor<void> {
  _HasStaticMethodInvocationVisitor(this.targetType, this.methodName);

  final String targetType;
  final String methodName;
  bool found = false;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (found) return;
    if (_matchesStaticMethodInvocation(node, targetType, methodName)) {
      found = true;
      return;
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    if (found) return;
    if (_matchesStaticFunctionInvocation(node, targetType, methodName)) {
      found = true;
      return;
    }
    super.visitFunctionExpressionInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (found) return;
    if (_matchesNamedConstructorInvocation(node, targetType, methodName)) {
      found = true;
      return;
    }
    super.visitInstanceCreationExpression(node);
  }
}

bool _matchesStaticMethodInvocation(
  MethodInvocation node,
  String targetType,
  String methodName,
) {
  return node.methodName.name == methodName && _qualifiedName(node.target) == targetType;
}

bool _matchesStaticFunctionInvocation(
  FunctionExpressionInvocation node,
  String targetType,
  String methodName,
) {
  return _qualifiedName(node.function) == '$targetType.$methodName';
}

bool _matchesNamedConstructorInvocation(
  InstanceCreationExpression node,
  String targetType,
  String methodName,
) {
  final constructor = node.constructorName;
  return _namedTypeName(constructor.type) == targetType && constructor.name?.name == methodName;
}

String _namedTypeName(NamedType type) {
  final prefix = type.importPrefix?.name.lexeme;
  return prefix == null ? type.name.lexeme : '$prefix.${type.name.lexeme}';
}

/// Returns the source offset of the static method name in [node].
int staticMethodInvocationNameOffset(AstNode node) {
  return switch (node) {
    MethodInvocation(:final methodName) => methodName.offset,
    FunctionExpressionInvocation(:final function) => switch (function) {
      PrefixedIdentifier(:final identifier) => identifier.offset,
      PropertyAccess(:final propertyName) => propertyName.offset,
      _ => function.offset,
    },
    InstanceCreationExpression(:final constructorName) => constructorName.name?.offset ?? constructorName.offset,
    _ => node.offset,
  };
}

String? _qualifiedName(Expression? expression) {
  return switch (expression) {
    SimpleIdentifier(:final name) => name,
    PrefixedIdentifier(:final prefix, :final identifier) => '${prefix.name}.${identifier.name}',
    PropertyAccess(:final target, :final propertyName) => switch (_qualifiedName(target)) {
      final targetName? => '$targetName.${propertyName.name}',
      null => null,
    },
    ParenthesizedExpression(:final expression) => _qualifiedName(expression),
    _ => null,
  };
}
