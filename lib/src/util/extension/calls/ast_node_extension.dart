import 'package:analyzer/dart/ast/visitor.dart';
import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/util/extension/expression_extension.dart';
import 'package:heimdall_test/src/util/extension/lookup/compilation_unit_member_extension.dart';
import 'package:heimdall_test/src/util/extension/scope/ast_node_extension.dart';
import 'package:heimdall_test/src/util/extension/sdk/compilation_unit_member_extension.dart';

/// Calls queries for [AstNode] nodes.
extension AstNodeCallsExtension on AstNode {
  /// Returns calls shaped as `Target.method()` inside this node.
  List<AstNode> staticMethodInvocations(
    String targetType,
    String methodName,
    HeimdallProject project,
  ) {
    final visitor = StaticMethodInvocationVisitor(targetType, methodName, project);
    accept(visitor);
    return visitor.matches;
  }

  /// Returns whether this node contains a call shaped as `Target.method()`.
  bool hasStaticMethodInvocation(
    String targetType,
    String methodName,
    HeimdallProject project,
  ) {
    final visitor = _HasStaticMethodInvocationVisitor(targetType, methodName, project);
    accept(visitor);
    return visitor.found;
  }

  /// Returns the source offset of the static method name in this node.
  int get staticMethodInvocationNameOffset {
    return switch (this) {
      MethodInvocation(:final methodName) => methodName.offset,
      FunctionExpressionInvocation(:final function) => switch (function) {
        PrefixedIdentifier(:final identifier) => identifier.offset,
        PropertyAccess(:final propertyName) => propertyName.offset,
        _ => function.offset,
      },
      _ => offset,
    };
  }
}

/// AST visitor that finds calls shaped as `Target.method()`.
final class StaticMethodInvocationVisitor extends RecursiveAstVisitor<void> {
  /// Creates a visitor that finds [methodName] calls on [targetType].
  StaticMethodInvocationVisitor(this.targetType, this.methodName, this.project);

  /// Expected invocation target, such as `HeimdallPredicate`.
  final String targetType;

  /// Expected static method name.
  final String methodName;

  /// Imported project used to distinguish constructors from methods.
  final HeimdallProject project;

  /// Matching invocations.
  final List<AstNode> matches = [];

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (_matchesStaticMethodInvocation(node, targetType, methodName, project)) {
      matches.add(node);
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    if (_matchesStaticFunctionInvocation(node, targetType, methodName, project)) {
      matches.add(node);
    }
    super.visitFunctionExpressionInvocation(node);
  }
}

final class _HasStaticMethodInvocationVisitor extends RecursiveAstVisitor<void> {
  _HasStaticMethodInvocationVisitor(this.targetType, this.methodName, this.project);

  final String targetType;
  final String methodName;
  final HeimdallProject project;
  bool found = false;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (found) {
      return;
    }
    if (_matchesStaticMethodInvocation(node, targetType, methodName, project)) {
      found = true;
      return;
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    if (found) {
      return;
    }
    if (_matchesStaticFunctionInvocation(node, targetType, methodName, project)) {
      found = true;
      return;
    }
    super.visitFunctionExpressionInvocation(node);
  }
}

bool _matchesStaticMethodInvocation(
  MethodInvocation node,
  String targetType,
  String methodName,
  HeimdallProject project,
) {
  return node.methodName.name == methodName &&
      _matchesTargetType(node, node.target, targetType, project) &&
      !node.hasValueReceiver(targetType, project) &&
      _isStaticMethod(node, node.target.qualifiedName ?? targetType, methodName, project) &&
      !_isNamedConstructorReference(node, targetType, methodName, project);
}

bool _matchesStaticFunctionInvocation(
  FunctionExpressionInvocation node,
  String targetType,
  String methodName,
  HeimdallProject project,
) {
  return _matchesTargetType(node, node.function, '$targetType.$methodName', project) &&
      !node.hasValueReceiver(targetType, project) &&
      !_isNamedConstructorReference(node, targetType, methodName, project);
}

bool _matchesTargetType(AstNode invocation, Expression? target, String expected, HeimdallProject project) {
  final actual = target.qualifiedName;
  if (actual == expected) {
    return true;
  }
  if (actual == null || !actual.endsWith('.$expected')) {
    return false;
  }
  for (var ancestor = invocation.parent; ancestor != null; ancestor = ancestor.parent) {
    if (ancestor is CompilationUnitMember) {
      final typeReference = invocation is MethodInvocation ? actual : actual.substring(0, actual.lastIndexOf('.'));
      return ancestor.declarationNamed(project, typeReference) != null || ancestor.sdkTypeName(typeReference, project) != null;
    }
  }
  return false;
}

bool _isStaticMethod(AstNode node, String reference, String name, HeimdallProject project) {
  final owner = node.thisOrAncestorOfType<CompilationUnitMember>();
  if (owner == null) {
    return false;
  }
  final type = owner.declarationNamed(project, reference);
  return type == null || type.methods.any((method) => method.name.lexeme == name && method.isStatic && !method.isGetter && !method.isSetter);
}

bool _isNamedConstructorReference(
  AstNode node,
  String targetType,
  String methodName,
  HeimdallProject project,
) {
  for (var ancestor = node.parent; ancestor != null; ancestor = ancestor.parent) {
    if (ancestor is CompilationUnitMember) {
      final declaration = ancestor.declarationNamed(project, targetType);
      return declaration != null &&
          declaration.isTypeDeclaration &&
          declaration.constructors.any((constructor) => constructor.name?.lexeme == methodName);
    }
  }
  return false;
}
