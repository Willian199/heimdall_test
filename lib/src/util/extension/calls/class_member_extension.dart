import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_declaration.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_member.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_project.dart';
import 'package:heimdall_test/src/util/extension/lookup/compilation_unit_member_extension.dart';
import 'package:heimdall_test/src/util/extension/scope/ast_node_extension.dart';
import 'package:heimdall_test/src/util/extension/sdk/compilation_unit_member_extension.dart';

/// Calls queries for [ClassMember] nodes.
extension ClassMemberCallsExtension on ClassMember {
  /// Returns the first matching method invocation inside this node.
  MethodInvocation? methodInvocationWhere(
    bool Function(String methodName) test,
  ) {
    final visitor = _MethodCallVisitor(test);
    for (final root in executableRoots) {
      root.accept(visitor);
      if (visitor.foundNode != null) {
        return visitor.foundNode;
      }
    }
    return null;
  }

  /// Returns whether this node contains a matching method invocation.
  bool hasMethodInvocationWhere(
    bool Function(String methodName) test, {
    HeimdallProject? project,
  }) {
    final visitor = _HasMethodCallVisitor(test, this, project);
    for (final root in executableRoots) {
      root.accept(visitor);
      if (visitor.found) {
        return true;
      }
    }
    return false;
  }

  /// Returns the first matching constructor-like call inside this node.
  AstNode? constructorCallWhere(
    HeimdallProject project,
    bool Function(String typeName) test,
  ) {
    final visitor = _ConstructorCallVisitor(this, project, test);
    for (final root in executableRoots) {
      root.accept(visitor);
      if (visitor.foundNode != null) {
        return visitor.foundNode;
      }
    }
    return null;
  }

  /// Returns whether this node contains a matching constructor-like call.
  bool hasConstructorCallWhere(
    HeimdallProject project,
    bool Function(String typeName) test,
  ) {
    return constructorCallWhere(project, test) != null;
  }
}

final class _MethodCallVisitor extends RecursiveAstVisitor<void> {
  _MethodCallVisitor(this.test);

  final bool Function(String methodName) test;
  MethodInvocation? foundNode;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (foundNode != null) {
      return;
    }
    if (test(node.methodName.name)) {
      foundNode = node;
      return;
    }
    super.visitMethodInvocation(node);
  }
}

final class _HasMethodCallVisitor extends RecursiveAstVisitor<void> {
  _HasMethodCallVisitor(this.test, this.member, this.project);

  final ClassMember member;
  final HeimdallProject? project;

  final bool Function(String methodName) test;
  bool found = false;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (found) {
      return;
    }
    final constructors = project == null ? null : _ConstructorCallVisitor(member, project!, (_) => true);
    constructors?.visitMethodInvocation(node);
    if (test(node.methodName.name) && !identical(constructors?.foundNode, node)) {
      found = true;
      return;
    }
    super.visitMethodInvocation(node);
  }
}

final class _ConstructorCallVisitor extends RecursiveAstVisitor<void> {
  _ConstructorCallVisitor(this.member, this.project, this.test);

  final ClassMember member;
  final HeimdallProject project;
  final bool Function(String typeName) test;
  AstNode? foundNode;

  String? _declaredConstructorType(String reference, String? constructorName) {
    final declaration = member.owner.declarationNamed(project, reference);
    if (declaration == null) {
      return member.owner.sdkTypeName(reference, project);
    }
    if (!declaration.isTypeDeclaration) {
      return null;
    }
    if (constructorName != null &&
        constructorName != 'new' &&
        !declaration.constructors.any((constructor) => constructor.name?.lexeme == constructorName)) {
      return null;
    }
    return reference.split('.').last;
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (foundNode != null) {
      return;
    }
    final constructor = node.constructorName;
    final type = constructor.type;
    final prefix = type.importPrefix?.name.lexeme;
    // Parsing can read `new Product.named()` as the type `Product.named`.
    final reference = prefix == null ? type.name.lexeme : '$prefix.${type.name.lexeme}';
    final name =
        _declaredConstructorType(reference, constructor.name?.name) ??
        (prefix != null && constructor.name == null ? _declaredConstructorType(prefix, type.name.lexeme) : null) ??
        type.name.lexeme;
    if (test(name)) {
      foundNode = node;
      return;
    }
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (foundNode != null) {
      return;
    }
    final target = node.target;
    if (target == null && !node.isCascaded) {
      final storedType = _storedConstructorType(node);
      if (storedType != null && test(storedType)) {
        foundNode = node;
        return;
      }
    }
    if (node.isCascaded || node.hasValueReceiver(target?.toSource() ?? node.methodName.name, project)) {
      super.visitMethodInvocation(node);
      return;
    }
    final targetName = switch (target) {
      SimpleIdentifier(:final name) => name,
      PrefixedIdentifier(:final prefix, :final identifier) => '${prefix.name}.${identifier.name}',
      _ => null,
    };
    final name = target == null
        ? _declaredConstructorType(node.methodName.name, null)
        : targetName == null
        ? null
        : _declaredConstructorType('$targetName.${node.methodName.name}', null) ?? _declaredConstructorType(targetName, node.methodName.name);
    if (name != null && test(name)) {
      foundNode = node;
      return;
    }
    super.visitMethodInvocation(node);
  }

  // Follow an immutable local binding in the same block. Mutable variables and
  // arbitrary callback flows need data-flow resolution and remain unknown.
  String? _storedConstructorType(MethodInvocation invocation) {
    final block = invocation.thisOrAncestorOfType<Block>();
    if (block == null) {
      return null;
    }
    for (var scope = invocation.parent; scope != null && !identical(scope, block); scope = scope.parent) {
      // A binding introduced inside these scopes may hide the block local.
      if (scope is FunctionExpression || scope is ForStatement || scope is ForElement || scope is IfStatement || scope is SwitchExpressionCase) {
        return null;
      }
    }
    for (final statement in block.statements) {
      if (statement.offset >= invocation.offset) {
        break;
      }
      if (statement is! VariableDeclarationStatement) {
        continue;
      }
      final variables = statement.variables;
      final variable = variables.variables.where((variable) => variable.name.lexeme == invocation.methodName.name).firstOrNull;
      if (variable == null) {
        continue;
      }
      if (!variables.isFinal && !variables.isConst) {
        return null;
      }
      final initializer = variable.initializer;
      final (reference, constructor) = switch (initializer) {
        ConstructorReference(:final constructorName) => (constructorName.type.toSource(), constructorName.name?.name),
        PrefixedIdentifier(:final prefix, :final identifier) => (prefix.name, identifier.name),
        _ => (null, null),
      };
      if (reference == null || initializer == null || initializer.hasValueReceiver(reference, project)) {
        return null;
      }
      return _declaredConstructorType(reference, constructor);
    }
    return null;
  }

  @override
  void visitSuperConstructorInvocation(SuperConstructorInvocation node) {
    final owner = member.owner;
    final type = owner is ClassDeclaration ? owner.extendsClause?.superclass : null;
    if (type != null && test(type.name.lexeme)) {
      foundNode = node;
    }
    if (foundNode == null) {
      super.visitSuperConstructorInvocation(node);
    }
  }

  @override
  void visitRedirectingConstructorInvocation(RedirectingConstructorInvocation node) {
    if (test(member.owner.name)) {
      foundNode = node;
    }
    if (foundNode == null) {
      super.visitRedirectingConstructorInvocation(node);
    }
  }
}
