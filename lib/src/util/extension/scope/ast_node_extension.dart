import 'package:heimdall_test/src/core.dart';
import 'package:heimdall_test/src/util/extension/ast_node_extension.dart';
import 'package:heimdall_test/src/util/extension/extension_type_declaration_extension.dart';
import 'package:heimdall_test/src/util/extension/lookup/compilation_unit_member_extension.dart';
import 'package:heimdall_test/src/util/extension/named_type_extension.dart';

/// Scope queries for [AstNode] nodes.
extension AstNodeScopeExtension on AstNode {
  /// Whether a local binding, member, or library value hides [targetType].
  ///
  /// Shared by constructor, static-call and imported-value queries so these
  /// analyses agree on lexical scope and inherited members.
  bool hasValueReceiver(String targetType, HeimdallProject project) {
    final name = targetType.split('.').first;
    if (isShadowedValueName(name)) {
      return true;
    }
    for (var ancestor = parent; ancestor != null; ancestor = ancestor.parent) {
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

  /// Whether a lexical binding hides [name] at this node.
  bool isShadowedValueName(String name) {
    for (var ancestor = parent; ancestor != null; ancestor = ancestor.parent) {
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
          if (statement.offset >= offset) {
            break;
          }
          if (statement is VariableDeclarationStatement && statement.variables.variables.any((variable) => variable.name.lexeme == name)) {
            return true;
          }
          if (statement is PatternVariableDeclarationStatement && statement.declaration.pattern.declaresName(name)) {
            return true;
          }
        }
      }
      if (ancestor is ForStatement && !_insideForEachIterable(ancestor.forLoopParts, this) && _loopDeclaresName(ancestor.forLoopParts, name)) {
        return true;
      }
      if (ancestor is ForElement && !_insideForEachIterable(ancestor.forLoopParts, this) && _loopDeclaresName(ancestor.forLoopParts, name)) {
        return true;
      }
      if (ancestor is IfStatement &&
          ancestor.caseClause != null &&
          (ancestor.thenStatement.containsNode(this) || (ancestor.caseClause!).containsNode(this)) &&
          (ancestor.caseClause!).declaresName(name)) {
        return true;
      }
      if (ancestor is IfElement &&
          ancestor.caseClause != null &&
          (ancestor.thenElement.containsNode(this) || (ancestor.caseClause!).containsNode(this)) &&
          (ancestor.caseClause!).declaresName(name)) {
        return true;
      }
      if (ancestor is CatchClause && (ancestor.exceptionParameter?.name.lexeme == name || ancestor.stackTraceParameter?.name.lexeme == name)) {
        return true;
      }
      if (ancestor is SwitchPatternCase && ancestor.guardedPattern.pattern.declaresName(name)) {
        return true;
      }
      if (ancestor is SwitchExpressionCase && ancestor.guardedPattern.pattern.declaresName(name)) {
        return true;
      }
    }
    return false;
  }
}

bool _parametersDeclare(FormalParameterList? parameters, String name) =>
    parameters?.parameters.any((parameter) => parameter.name?.lexeme == name) ?? false;

bool _insideForEachIterable(ForLoopParts parts, AstNode node) => parts is ForEachParts && parts.iterable.containsNode(node);

bool _loopDeclaresName(ForLoopParts parts, String name) => switch (parts) {
  ForEachPartsWithDeclaration(:final loopVariable) => loopVariable.name.lexeme == name,
  ForEachPartsWithPattern(:final pattern) => pattern.declaresName(name),
  ForPartsWithDeclarations(:final variables) => variables.variables.any((variable) => variable.name.lexeme == name),
  ForPartsWithPattern(:final variables) => variables.pattern.declaresName(name),
  _ => false,
};

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
  if (owner is ExtensionTypeDeclaration &&
      owner.extensionTypePrimaryConstructor.formalParameters.parameters.any((parameter) => parameter.name?.lexeme == name)) {
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
    final inherited = owner.declarationNamed(project, type.referenceName);
    if (inherited != null && _valueMembersDeclareInHierarchy(inherited, name, project, visited, inherited: true)) {
      return true;
    }
  }
  return false;
}
