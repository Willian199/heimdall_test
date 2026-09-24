// Lookup helpers are shared by query files but are not exported as package API.
// ignore_for_file: public_member_api_docs

import 'package:heimdall_test/src/core.dart';
import 'package:heimdall_test/src/features/queries/declaration_dependency_queries.dart';
import 'package:heimdall_test/src/features/queries/type_annotation_queries.dart';

String canonicalTypeNameFrom(
  CompilationUnitMember item,
  String typeName,
  HeimdallProject project,
) {
  var current = typeName;
  var source = item;
  final seen = <String>{};
  while (seen.add('${source.sourcePath}:$current')) {
    final alias = _typeAliasNamedFrom(source, project, current);
    final target = _typeAliasTargetName(alias);
    if (target == null) return current;
    current = target;
    source = alias!;
  }
  return current;
}

String? _typeAliasTargetName(TypeAlias? alias) {
  if (alias is GenericTypeAlias) {
    final type = alias.type;
    if (type is NamedType) return namedTypeReferenceName(type);
  }
  return null;
}

TypeAlias? _typeAliasNamedFrom(
  CompilationUnitMember item,
  HeimdallProject project,
  String typeName,
) {
  final reference = _TypeReference.parse(typeName);
  for (final declaration in visibleTypeReferenceDeclarationsFrom(
    item,
    project,
    importPrefix: reference.prefix,
  )) {
    if (declaration is TypeAlias && declaration.name.lexeme == reference.name) {
      return declaration;
    }
  }
  return null;
}

CompilationUnitMember? declarationNamedFrom(
  CompilationUnitMember item,
  HeimdallProject project,
  String typeName,
) {
  return _declarationNamedFrom(item, project, typeName, <String>{});
}

CompilationUnitMember? _declarationNamedFrom(
  CompilationUnitMember item,
  HeimdallProject project,
  String typeName,
  Set<String> visited,
) {
  final key = '${item.sourcePath}:$typeName';
  if (!visited.add(key)) return null;

  final alias = _typeAliasNamedFrom(item, project, typeName);
  final aliasTarget = _typeAliasTargetName(alias);
  if (alias != null && aliasTarget != null) {
    return _declarationNamedFrom(alias, project, aliasTarget, visited);
  }

  final reference = _TypeReference.parse(typeName);
  for (final declaration in visibleTypeReferenceDeclarationsFrom(
    item,
    project,
    importPrefix: reference.prefix,
  )) {
    if (declaration is TypeAlias) continue;
    if (declaration.name == reference.name) {
      return declaration;
    }
  }
  return null;
}

/// Returns the declarations that can be referenced by [item] with [importPrefix].
///
/// This helper intentionally does not retain results. Callers that need several
/// lookups in the same scope can build a short-lived index for that operation.
List<CompilationUnitMember> visibleTypeReferenceDeclarationsFrom(
  CompilationUnitMember item,
  HeimdallProject project, {
  required String? importPrefix,
}) {
  final file = project.filesByPath[item.sourcePath];
  if (file == null) return [...project.typeDeclarations, ...project.typeAliases];
  return _dedupeDeclarations([
    if (importPrefix == null)
      for (final libraryFile in libraryFilesFrom(item, project)) ...[
        ...libraryFile.typeDeclarations,
        ...libraryFile.typeAliases,
      ],
    for (final dependency in dependenciesFrom(item, project))
      if (_dependencyMatchesImportPrefix(dependency, importPrefix)) ...project.visibleTypeDeclarationsThrough(dependency),
  ]);
}

bool _dependencyMatchesImportPrefix(Directive dependency, String? prefix) {
  if (dependency is ImportDirective) {
    return dependency.prefix?.name == prefix;
  }
  return prefix == null;
}

List<CompilationUnitMember> _dedupeDeclarations(
  Iterable<CompilationUnitMember> declarations,
) {
  final seen = <String>{};
  return [
    for (final declaration in declarations)
      if (seen.add('${declaration.sourcePath}:${declaration.name}')) declaration,
  ];
}

bool typeNamesMatchFrom(
  CompilationUnitMember item,
  String actual,
  String expected,
  HeimdallProject project,
) {
  return _typeReferenceNamesMatch(actual, expected) ||
      _typeReferenceNamesMatch(
        canonicalTypeNameFrom(item, actual, project),
        canonicalTypeNameFrom(item, expected, project),
      );
}

bool typeNameMatchesWhereFrom(
  CompilationUnitMember item,
  String typeName,
  HeimdallProject project,
  bool Function(String typeName) test,
) {
  final canonicalName = canonicalTypeNameFrom(item, typeName, project);
  return test(typeName) || test(_TypeReference.parse(typeName).name) || test(canonicalName) || test(_TypeReference.parse(canonicalName).name);
}

bool _typeReferenceNamesMatch(String actual, String expected) {
  if (actual == expected) return true;
  final actualReference = _TypeReference.parse(actual);
  final expectedReference = _TypeReference.parse(expected);
  return expectedReference.prefix == null && actualReference.name == expectedReference.name;
}

final class _TypeReference {
  const _TypeReference({required this.prefix, required this.name});

  factory _TypeReference.parse(String value) {
    final separator = value.indexOf('.');
    if (separator < 0) return _TypeReference(prefix: null, name: value);
    return _TypeReference(
      prefix: value.substring(0, separator),
      name: value.substring(separator + 1),
    );
  }

  final String? prefix;
  final String name;
}
