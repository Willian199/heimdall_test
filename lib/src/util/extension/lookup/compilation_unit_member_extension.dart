import 'package:heimdall_test/src/core.dart';
import 'package:heimdall_test/src/util/extension/named_type_extension.dart';

/// Lookup queries for [CompilationUnitMember] nodes.
extension CompilationUnitMemberLookupExtension on CompilationUnitMember {
  /// Follows visible type aliases to their canonical name.
  String canonicalTypeName(
    String typeName,
    HeimdallProject project,
  ) {
    var current = typeName;
    var source = this;
    final seen = <String>{};
    while (seen.add('${source.sourcePath}:$current')) {
      final alias = _typeAliasNamedFrom(source, project, current);
      final target = _typeAliasTargetName(alias);
      if (target == null) {
        return current;
      }
      current = target;
      source = alias!;
    }
    return current;
  }

  /// Resolves a visible declaration, following type aliases.
  CompilationUnitMember? declarationNamed(
    HeimdallProject project,
    String typeName,
  ) {
    final visited = <String>{};
    CompilationUnitMember? visit(CompilationUnitMember item, String typeName) {
      final key = '${item.sourcePath}:$typeName';
      if (!visited.add(key)) {
        return null;
      }

      final alias = _typeAliasNamedFrom(item, project, typeName);
      final aliasTarget = _typeAliasTargetName(alias);
      if (alias != null && aliasTarget != null) {
        return visit(alias, aliasTarget);
      }

      final reference = _TypeReference.parse(typeName);
      for (final declaration in item.visibleTypeReferenceDeclarations(project, importPrefix: reference.prefix)) {
        if (declaration is TypeAlias) {
          continue;
        }
        if (declaration.name == reference.name) {
          return declaration;
        }
      }
      return null;
    }

    return visit(this, typeName);
  }

  /// Returns the declarations that can be referenced by this node with [importPrefix].
  ///
  /// This helper intentionally does not retain results. Callers that need several
  /// lookups in the same scope can build a short-lived index for that operation.
  List<CompilationUnitMember> visibleTypeReferenceDeclarations(
    HeimdallProject project, {
    required String? importPrefix,
  }) {
    final file = project.filesByPath[sourcePath];
    if (file == null) {
      return [...project.typeDeclarations, ...project.typeAliases];
    }
    final scope = project.libraryScopes.scopeOf(this);
    return _dedupeDeclarations([
      if (importPrefix == null)
        for (final libraryFile in scope.files) ...[
          ...libraryFile.typeDeclarations,
          ...libraryFile.typeAliases,
        ],
      for (final dependency in scope.dependencies)
        if (_dependencyMatchesImportPrefix(dependency, importPrefix)) ...project.visibleTypeDeclarationsThrough(dependency),
    ]);
  }

  /// Compares type names using aliases visible in this declaration.
  bool typeNamesMatch(
    String actual,
    String expected,
    HeimdallProject project,
  ) {
    return _typeReferenceNamesMatch(actual, expected) ||
        _typeReferenceNamesMatch(
          canonicalTypeName(actual, project),
          canonicalTypeName(expected, project),
        );
  }

  /// Tests visible, unqualified and canonical forms of a type name.
  bool typeNameMatchesWhere(
    String typeName,
    HeimdallProject project,
    bool Function(String typeName) test,
  ) {
    final canonicalName = canonicalTypeName(typeName, project);
    return test(typeName) || test(_TypeReference.parse(typeName).name) || test(canonicalName) || test(_TypeReference.parse(canonicalName).name);
  }
}

String? _typeAliasTargetName(TypeAlias? alias) {
  if (alias is GenericTypeAlias) {
    final type = alias.type;
    if (type is NamedType) {
      return type.referenceName;
    }
  }
  return null;
}

TypeAlias? _typeAliasNamedFrom(
  CompilationUnitMember item,
  HeimdallProject project,
  String typeName,
) {
  final reference = _TypeReference.parse(typeName);
  for (final declaration in item.visibleTypeReferenceDeclarations(project, importPrefix: reference.prefix)) {
    if (declaration is TypeAlias && declaration.name.lexeme == reference.name) {
      return declaration;
    }
  }
  return null;
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

bool _typeReferenceNamesMatch(String actual, String expected) {
  if (actual == expected) {
    return true;
  }
  final actualReference = _TypeReference.parse(actual);
  final expectedReference = _TypeReference.parse(expected);
  return !expected.contains('<') && expectedReference.prefix == null && actualReference.name == expectedReference.name;
}

final class _TypeReference {
  const _TypeReference({required this.prefix, required this.name});

  factory _TypeReference.parse(String text) {
    final value = text.split('<').first;
    final separator = value.indexOf('.');
    if (separator < 0) {
      return _TypeReference(prefix: null, name: value);
    }
    return _TypeReference(
      prefix: value.substring(0, separator),
      name: value.substring(separator + 1),
    );
  }

  final String? prefix;
  final String name;
}
