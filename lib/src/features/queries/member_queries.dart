import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:heimdall_test/src/core/heimdall_condition.dart';
import 'package:heimdall_test/src/core/heimdall_validation_info.dart';
import 'package:heimdall_test/src/features/queries/declaration_lookup_queries.dart';
import 'package:heimdall_test/src/features/queries/static_method_queries.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_declaration.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_member.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_project.dart';

/// Returns the first matching method invocation inside [member].
MethodInvocation? memberMethodInvocationWhere(
  ClassMember member,
  bool Function(String methodName) test,
) {
  final visitor = _MethodCallVisitor(test);
  for (final root in member.executableRoots) {
    root.accept(visitor);
    if (visitor.foundNode != null) {
      return visitor.foundNode;
    }
  }
  return null;
}

/// Returns whether [member] contains a matching method invocation.
bool memberHasMethodInvocationWhere(
  ClassMember member,
  bool Function(String methodName) test,
) {
  final visitor = _HasMethodCallVisitor(test);
  for (final root in member.executableRoots) {
    root.accept(visitor);
    if (visitor.found) {
      return true;
    }
  }
  return false;
}

/// Returns the first matching constructor-like call inside [member].
AstNode? memberConstructorCallWhere(
  ClassMember member,
  HeimdallProject project,
  bool Function(String typeName) test,
) {
  final visitor = _ConstructorCallVisitor(member, project, test);
  for (final root in member.executableRoots) {
    root.accept(visitor);
    if (visitor.foundNode != null) {
      return visitor.foundNode;
    }
  }
  return null;
}

/// Returns whether [member] contains a matching constructor-like call.
bool memberHasConstructorCallWhere(
  ClassMember member,
  HeimdallProject project,
  bool Function(String typeName) test,
) {
  return memberConstructorCallWhere(member, project, test) != null;
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
  _HasMethodCallVisitor(this.test);

  final bool Function(String methodName) test;
  bool found = false;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (found) {
      return;
    }
    if (test(node.methodName.name)) {
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
    final declaration = declarationNamedFrom(member.owner, project, reference);
    if (declaration == null) {
      return null;
    }
    if (constructorName != null && !declaration.constructors.any((constructor) => constructor.name?.lexeme == constructorName)) {
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
    if (node.isCascaded || hasValueReceiver(node, target?.toSource() ?? node.methodName.name, project)) {
      super.visitMethodInvocation(node);
      return;
    }
    final targetName = switch (target) {
      SimpleIdentifier(:final name) => name,
      PrefixedIdentifier(:final prefix, :final identifier) => '${prefix.name}.${identifier.name}',
      _ => null,
    };
    final name = target == null
        ? node.methodName.name
        : targetName == null
        ? null
        : _declaredConstructorType('$targetName.${node.methodName.name}', null) ?? _declaredConstructorType(targetName, node.methodName.name);
    if (name != null && test(name)) {
      foundNode = node;
      return;
    }
    super.visitMethodInvocation(node);
  }
}

/// Creates a member condition from a boolean [test].
HeimdallCondition<ClassMember> memberCondition(
  String description,
  bool Function(ClassMember item, HeimdallProject project) test,
) {
  return HeimdallCondition(description, (item, project) {
    final passed = test(item, project);
    final location = item.location;
    final findings = [
      HeimdallValidationInfo(
        filePath: item.sourcePath,
        line: item.line,
        column: location.columnNumber,
        message: passed ? '${item.ownerName}.${item.name} matches $description' : '${item.ownerName}.${item.name} should $description',
      ),
    ];
    return HeimdallFindings(
      subject: item,
      passed: passed,
      findings: findings,
    );
  });
}

/// Creates a member condition that fails when a prohibited structure is found.
HeimdallCondition<ClassMember> prohibitedMemberCondition(
  String description,
  bool Function(ClassMember item, HeimdallProject project) test, {
  int Function(ClassMember item)? offset,
}) {
  return HeimdallCondition(description, (item, project) {
    if (!test(item, project)) {
      return HeimdallFindings(
        subject: item,
        passed: true,
      );
    }

    final sourceOffset = offset?.call(item);

    final location = sourceOffset == null
        ? (
            line: item.location.lineNumber,
            column: item.location.columnNumber,
          )
        : item.sourceLocationAt(sourceOffset);

    final findings = [
      HeimdallValidationInfo(
        filePath: item.sourcePath,
        line: location.line,
        column: location.column,
        message: '${item.ownerName}.${item.name} must not $description',
      ),
    ];

    return HeimdallFindings(
      subject: item,
      passed: false,
      findings: findings,
    );
  });
}
