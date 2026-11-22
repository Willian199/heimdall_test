import 'package:heimdall_test/src/core.dart';
import 'package:heimdall_test/src/features/queries/declaration_lookup_queries.dart';
import 'package:heimdall_test/src/features/queries/type_annotation_queries.dart';

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
  return true;
}

/// Whether a lexical binding hides a value with the same name at [reference].
bool isShadowedValue(SimpleIdentifier reference) => _isShadowedValueName(reference, reference.name);

bool _isShadowedValueName(AstNode reference, String name) {
  for (var ancestor = reference.parent; ancestor != null; ancestor = ancestor.parent) {
    if (ancestor is MethodDeclaration && ancestor.parameterNames.contains(name) ||
        ancestor is ConstructorDeclaration && ancestor.parameterNames.contains(name) ||
        ancestor is FunctionExpression && _parametersDeclare(ancestor.parameters, name)) {
      return true;
    }
    if (ancestor is Block) {
      for (final statement in ancestor.statements) {
        if (statement is FunctionDeclarationStatement && statement.functionDeclaration.name.lexeme == name) {
          return true;
        }
        if (statement.offset >= reference.offset) {
          break;
        }
        if (statement is VariableDeclarationStatement && statement.variables.variables.any((variable) => variable.name.lexeme == name)) {
          return true;
        }
        if (statement is PatternVariableDeclarationStatement && _declaresName(statement.declaration.pattern, name)) {
          return true;
        }
      }
    }
    if (ancestor is ForStatement && !_insideForEachIterable(ancestor.forLoopParts, reference) && _loopDeclaresName(ancestor.forLoopParts, name)) {
      return true;
    }
    if (ancestor is ForElement && !_insideForEachIterable(ancestor.forLoopParts, reference) && _loopDeclaresName(ancestor.forLoopParts, name)) {
      return true;
    }
    if (ancestor is IfStatement &&
        ancestor.caseClause != null &&
        (_contains(ancestor.thenStatement, reference) || _contains(ancestor.caseClause!, reference)) &&
        _declaresName(ancestor.caseClause!, name)) {
      return true;
    }
    if (ancestor is IfElement &&
        ancestor.caseClause != null &&
        (_contains(ancestor.thenElement, reference) || _contains(ancestor.caseClause!, reference)) &&
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

bool _loopDeclaresName(ForLoopParts parts, String name) => switch (parts) {
  ForEachPartsWithDeclaration(:final loopVariable) => loopVariable.name.lexeme == name,
  ForEachPartsWithPattern(:final pattern) => _declaresName(pattern, name),
  ForPartsWithDeclarations(:final variables) => variables.variables.any((variable) => variable.name.lexeme == name),
  ForPartsWithPattern(:final variables) => _declaresName(variables.pattern, name),
  _ => false,
};

bool _contains(AstNode scope, AstNode node) => scope.offset <= node.offset && node.end <= scope.end;

bool _declaresName(AstNode node, String name) {
  if (node is VariableDeclaration && node.name.lexeme == name ||
      node is DeclaredIdentifier && node.name.lexeme == name ||
      node is DeclaredVariablePattern && node.name.lexeme == name) {
    return true;
  }
  return node.childEntities.whereType<AstNode>().any((child) => _declaresName(child, name));
}

/// Whether a local binding, member, or library value hides [targetType].
///
/// Shared by constructor, static-call and imported-value queries so these
/// analyses agree on lexical scope and inherited members.
bool hasValueReceiver(AstNode node, String targetType, HeimdallProject project) {
  final name = targetType.split('.').first;
  if (_isShadowedValueName(node, name)) {
    return true;
  }
  for (var ancestor = node.parent; ancestor != null; ancestor = ancestor.parent) {
    // Local function nodes have no imported declaration metadata. Their lexical
    // bindings are handled above; only top-level types have member hierarchies.
    if (ancestor is CompilationUnitMember && ancestor.parent is CompilationUnit) {
      if (_valueMembersDeclareInHierarchy(ancestor, name, project, <String>{}) ||
          (project.filesByPath[ancestor.sourcePath]?.topLevelValueNames.contains(name) ?? false)) {
        return true;
      }
    }
  }
  return false;
}

bool _valueMembersDeclare(CompilationUnitMember owner, String name, {bool inherited = false}) =>
    owner.fields.any((field) => (!inherited || !field.isStatic) && field.fields.variables.any((variable) => variable.name.lexeme == name)) ||
    owner.methods.any((method) => (!inherited || !method.isStatic) && method.name.lexeme == name);

bool _valueMembersDeclareInHierarchy(
  CompilationUnitMember owner,
  String name,
  HeimdallProject project,
  Set<String> visited, {
  bool inherited = false,
}) {
  if (!visited.add('${owner.sourcePath}:${owner.name}')) {
    return false;
  }
  if (_valueMembersDeclare(owner, name, inherited: inherited)) {
    return true;
  }
  if (owner is ExtensionTypeDeclaration && owner.primaryConstructor.formalParameters.parameters.any((parameter) => parameter.name?.lexeme == name)) {
    return true;
  }

  final inheritedTypes = switch (owner) {
    ClassDeclaration(:final extendsClause, :final withClause) => [
      if (extendsClause != null) extendsClause.superclass,
      ...?withClause?.mixinTypes,
    ],
    EnumDeclaration(:final withClause) => [...?withClause?.mixinTypes],
    MixinDeclaration(:final onClause) => [...?onClause?.superclassConstraints],
    ClassTypeAlias(:final superclass, :final withClause) => [superclass, ...withClause.mixinTypes],
    _ => <NamedType>[],
  };
  for (final type in inheritedTypes) {
    final inherited = declarationNamedFrom(owner, project, namedTypeReferenceName(type));
    if (inherited != null && _valueMembersDeclareInHierarchy(inherited, name, project, visited, inherited: true)) {
      return true;
    }
  }
  return false;
}
