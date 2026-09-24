import 'package:analyzer/dart/ast/visitor.dart';
import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_lookup_queries.dart';
import 'package:heimdall_test/src/features/queries/type_annotation_queries.dart';

/// Returns calls shaped as `Target.method()` inside [node].
List<AstNode> astNodeStaticMethodInvocations(
  AstNode node,
  String targetType,
  String methodName,
  HeimdallProject project,
) {
  final visitor = StaticMethodInvocationVisitor(targetType, methodName, project);
  node.accept(visitor);
  return visitor.matches;
}

/// Returns whether [node] contains a call shaped as `Target.method()`.
bool astNodeHasStaticMethodInvocation(
  AstNode node,
  String targetType,
  String methodName,
  HeimdallProject project,
) {
  final visitor = _HasStaticMethodInvocationVisitor(targetType, methodName, project);
  node.accept(visitor);
  return visitor.found;
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
    if (found) return;
    if (_matchesStaticMethodInvocation(node, targetType, methodName, project)) {
      found = true;
      return;
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    if (found) return;
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
      _qualifiedName(node.target) == targetType &&
      !_hasValueReceiver(node, targetType, project) &&
      !_isNamedConstructorReference(node, targetType, methodName, project);
}

bool _matchesStaticFunctionInvocation(
  FunctionExpressionInvocation node,
  String targetType,
  String methodName,
  HeimdallProject project,
) {
  return _qualifiedName(node.function) == '$targetType.$methodName' &&
      !_hasValueReceiver(node, targetType, project) &&
      !_isNamedConstructorReference(node, targetType, methodName, project);
}

bool _hasValueReceiver(AstNode node, String targetType, HeimdallProject project) {
  final receiverName = targetType.split('.').first;
  for (var ancestor = node.parent; ancestor != null; ancestor = ancestor.parent) {
    if (ancestor is MethodDeclaration && _parametersDeclare(ancestor.parameters, receiverName)) return true;
    if (ancestor is ConstructorDeclaration && _parametersDeclare(ancestor.parameters, receiverName)) return true;
    if (ancestor is FunctionExpression && _parametersDeclare(ancestor.parameters, receiverName)) return true;
    if (ancestor is Block) {
      for (final statement in ancestor.statements) {
        if (statement.offset >= node.offset) break;
        if (statement is VariableDeclarationStatement && statement.variables.variables.any((variable) => variable.name.lexeme == receiverName)) {
          return true;
        }
        if (statement is PatternVariableDeclarationStatement && _declaresName(statement.declaration.pattern, receiverName)) return true;
      }
    }
    if (ancestor is ForStatement) {
      final parts = ancestor.forLoopParts;
      if (parts is ForEachParts && _containsNode(parts.iterable, node)) continue;
      if (_forLoopDeclaresName(parts, receiverName)) return true;
    }
    if (ancestor is CatchClause &&
        (ancestor.exceptionParameter?.name.lexeme == receiverName || ancestor.stackTraceParameter?.name.lexeme == receiverName)) {
      return true;
    }
    if (ancestor is IfStatement &&
        ancestor.caseClause != null &&
        (_containsNode(ancestor.thenStatement, node) || _containsNode(ancestor.caseClause!, node)) &&
        _declaresName(ancestor.caseClause!, receiverName)) {
      return true;
    }
    if (ancestor is SwitchPatternCase && _declaresName(ancestor.guardedPattern.pattern, receiverName)) return true;
    if (ancestor is CompilationUnitMember && _valueMembersDeclareInHierarchy(ancestor, receiverName, project, <String>{})) return true;
    if (ancestor is CompilationUnit &&
        ancestor.declarations.whereType<TopLevelVariableDeclaration>().any(
          (declaration) => declaration.variables.variables.any((variable) => variable.name.lexeme == receiverName),
        )) {
      return true;
    }
  }
  return false;
}

bool _containsNode(AstNode scope, AstNode node) => scope.offset <= node.offset && node.end <= scope.end;

bool _forLoopDeclaresName(ForLoopParts parts, String name) => switch (parts) {
  ForEachPartsWithDeclaration(:final loopVariable) => loopVariable.name.lexeme == name,
  ForEachPartsWithPattern(:final pattern) => _declaresName(pattern, name),
  ForPartsWithDeclarations(:final variables) => variables.variables.any((variable) => variable.name.lexeme == name),
  ForPartsWithPattern(:final variables) => _declaresName(variables.pattern, name),
  _ => false,
};

bool _parametersDeclare(FormalParameterList? parameters, String name) =>
    parameters?.parameters.any((parameter) => parameter.name?.lexeme == name) ?? false;

bool _valueMembersDeclare(CompilationUnitMember owner, String name, {bool inherited = false}) => owner.members.any(
  (member) => switch (member) {
    FieldDeclaration(:final fields) => (!inherited || !member.isStatic) && fields.variables.any((variable) => variable.name.lexeme == name),
    MethodDeclaration() when member.isGetter => (!inherited || !member.isStatic) && member.name.lexeme == name,
    _ => false,
  },
);

bool _valueMembersDeclareInHierarchy(
  CompilationUnitMember owner,
  String name,
  HeimdallProject project,
  Set<String> visited, {
  bool inherited = false,
}) {
  if (!visited.add('${owner.sourcePath}:${owner.name}')) return false;
  if (_valueMembersDeclare(owner, name, inherited: inherited)) return true;

  final inheritedTypes = switch (owner) {
    ClassDeclaration(:final extendsClause, :final withClause) => [
      if (extendsClause != null) extendsClause.superclass,
      ...?withClause?.mixinTypes,
    ],
    EnumDeclaration(:final withClause) => [...?withClause?.mixinTypes],
    _ => <NamedType>[],
  };
  for (final type in inheritedTypes) {
    final inherited = declarationNamedFrom(owner, project, namedTypeReferenceName(type));
    if (inherited != null && _valueMembersDeclareInHierarchy(inherited, name, project, visited, inherited: true)) return true;
  }
  return false;
}

bool _declaresName(AstNode node, String name) {
  if (node is VariableDeclaration && node.name.lexeme == name) return true;
  if (node is DeclaredIdentifier && node.name.lexeme == name) return true;
  if (node is DeclaredVariablePattern && node.name.lexeme == name) return true;
  return node.childEntities.whereType<AstNode>().any((child) => _declaresName(child, name));
}

bool _isNamedConstructorReference(
  AstNode node,
  String targetType,
  String methodName,
  HeimdallProject project,
) {
  for (var ancestor = node.parent; ancestor != null; ancestor = ancestor.parent) {
    if (ancestor is CompilationUnitMember) {
      final declaration = declarationNamedFrom(ancestor, project, targetType);
      return declaration is ClassDeclaration && declaration.constructors.any((constructor) => constructor.name?.lexeme == methodName);
    }
  }
  return false;
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
