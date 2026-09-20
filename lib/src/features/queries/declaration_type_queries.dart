import 'package:heimdall_test/src/core.dart';
import 'package:heimdall_test/src/features/queries/declaration_lookup_queries.dart';
import 'package:heimdall_test/src/features/queries/type_annotation_queries.dart';

/// Returns `true` when [item] is the named type or inherits/implements it.
bool isAssignableTo(
  CompilationUnitMember item,
  String typeName,
  HeimdallProject project,
) {
  return _isAssignableTo(item, typeName, project, <String>{});
}

/// Returns `true` when [item] extends [typeName], directly or through its
/// superclass chain.
bool extendsType(
  CompilationUnitMember item,
  String typeName,
  HeimdallProject project,
) {
  return _extendsType(item, typeName, project, <String>{});
}

/// Returns `true` when [item] implements [typeName], directly, through an
/// implemented interface, or through its superclass chain.
bool implementsType(
  CompilationUnitMember item,
  String typeName,
  HeimdallProject project,
) {
  return _implementsType(item, typeName, project, <String>{});
}

/// Returns `true` when [item] mixes in [typeName], directly or through its
/// superclass chain.
bool mixesInType(
  CompilationUnitMember item,
  String typeName,
  HeimdallProject project,
) {
  return _mixesInType(item, typeName, project, <String>{});
}

/// Returns `true` when [item] is assignable to a type whose name matches [test].
bool isAssignableToTypeNamedWhere(
  CompilationUnitMember item,
  HeimdallProject project,
  bool Function(String typeName) test,
) {
  return _isAssignableToTypeNamedWhere(item, project, test, <String>{});
}

/// Returns `true` when [item] extends a type whose name matches [test].
bool extendsTypeNamedWhere(
  CompilationUnitMember item,
  HeimdallProject project,
  bool Function(String typeName) test,
) {
  return _extendsTypeNamedWhere(item, project, test, <String>{});
}

/// Returns `true` when [item] implements a type whose name matches [test].
bool implementsTypeNamedWhere(
  CompilationUnitMember item,
  HeimdallProject project,
  bool Function(String typeName) test,
) {
  return _implementsTypeNamedWhere(item, project, test, <String>{});
}

/// Returns `true` when [item] mixes in a type whose name matches [test].
bool mixesInTypeNamedWhere(
  CompilationUnitMember item,
  HeimdallProject project,
  bool Function(String typeName) test,
) {
  return _mixesInTypeNamedWhere(item, project, test, <String>{});
}

bool _isAssignableTo(
  CompilationUnitMember item,
  String typeName,
  HeimdallProject project,
  Set<String> visited,
) {
  if (typeNamesMatchFrom(item, item.name, typeName, project)) return true;
  if (!visited.add('${item.sourcePath}:${item.name}')) return false;

  final directTypes = _directAssignableTypes(item);

  if (directTypes.any((type) => typeNamesMatchFrom(item, type, typeName, project))) {
    return true;
  }

  final candidateNames = _expandedTypeNamesFrom(item, directTypes, project);
  if (candidateNames.isEmpty) return false;

  for (final candidateName in candidateNames) {
    final target = declarationNamedFrom(item, project, candidateName);
    if (target != null && _isAssignableTo(target, typeName, project, visited)) {
      return true;
    }
  }

  return false;
}

bool _isAssignableToTypeNamedWhere(
  CompilationUnitMember item,
  HeimdallProject project,
  bool Function(String typeName) test,
  Set<String> visited,
) {
  if (typeNameMatchesWhereFrom(item, item.name, project, test)) return true;
  if (!visited.add('${item.sourcePath}:${item.name}:assignableWhere')) {
    return false;
  }

  final directTypes = _directAssignableTypes(item);
  if (directTypes.any((type) => typeNameMatchesWhereFrom(item, type, project, test))) {
    return true;
  }

  for (final typeName in _expandedTypeNamesFrom(item, directTypes, project)) {
    final target = declarationNamedFrom(item, project, typeName);
    if (target != null && _isAssignableToTypeNamedWhere(target, project, test, visited)) {
      return true;
    }
  }

  return false;
}

bool _extendsType(
  CompilationUnitMember item,
  String typeName,
  HeimdallProject project,
  Set<String> visited,
) {
  if (item is! ClassDeclaration) return false;
  if (!visited.add('${item.sourcePath}:${item.name}:extends')) {
    return false;
  }

  final superclass = item.extendsClause?.superclass;
  if (superclass == null) return false;
  final superclassName = namedTypeReferenceName(superclass);
  if (typeNamesMatchFrom(item, superclassName, typeName, project)) return true;

  final target = declarationNamedFrom(item, project, superclassName);
  return target != null && _extendsType(target, typeName, project, visited);
}

bool _extendsTypeNamedWhere(
  CompilationUnitMember item,
  HeimdallProject project,
  bool Function(String typeName) test,
  Set<String> visited,
) {
  if (item is! ClassDeclaration) return false;
  if (!visited.add('${item.sourcePath}:${item.name}:extendsWhere')) {
    return false;
  }

  final superclass = item.extendsClause?.superclass;
  if (superclass == null) return false;
  final superclassName = namedTypeReferenceName(superclass);
  if (typeNameMatchesWhereFrom(item, superclassName, project, test)) return true;

  final target = declarationNamedFrom(item, project, superclassName);
  return target != null && _extendsTypeNamedWhere(target, project, test, visited);
}

bool _implementsType(
  CompilationUnitMember item,
  String typeName,
  HeimdallProject project,
  Set<String> visited,
) {
  if (!visited.add('${item.sourcePath}:${item.name}:implements')) {
    return false;
  }

  final interfaces = _directImplementedTypes(item);
  if (interfaces.any((interface) => typeNamesMatchFrom(item, interface, typeName, project))) {
    return true;
  }

  for (final interface in interfaces) {
    final target = declarationNamedFrom(item, project, interface);
    if (target != null && _isAssignableTo(target, typeName, project, <String>{})) {
      return true;
    }
  }

  final superclass = item is ClassDeclaration ? item.extendsClause?.superclass : null;
  if (superclass == null) return false;
  final target = declarationNamedFrom(item, project, namedTypeReferenceName(superclass));
  return target != null && _implementsType(target, typeName, project, visited);
}

bool _implementsTypeNamedWhere(
  CompilationUnitMember item,
  HeimdallProject project,
  bool Function(String typeName) test,
  Set<String> visited,
) {
  if (!visited.add('${item.sourcePath}:${item.name}:implementsWhere')) {
    return false;
  }

  final interfaces = _directImplementedTypes(item);
  if (interfaces.any((interface) => typeNameMatchesWhereFrom(item, interface, project, test))) {
    return true;
  }

  for (final interface in interfaces) {
    final target = declarationNamedFrom(item, project, interface);
    if (target != null && _isAssignableToTypeNamedWhere(target, project, test, <String>{})) {
      return true;
    }
  }

  final superclass = item is ClassDeclaration ? item.extendsClause?.superclass : null;
  if (superclass == null) return false;
  final target = declarationNamedFrom(item, project, namedTypeReferenceName(superclass));
  return target != null && _implementsTypeNamedWhere(target, project, test, visited);
}

bool _mixesInType(
  CompilationUnitMember item,
  String typeName,
  HeimdallProject project,
  Set<String> visited,
) {
  if (!visited.add('${item.sourcePath}:${item.name}:mixins')) return false;

  final mixins = _directMixedInTypes(item);
  if (mixins.any((mixin) => typeNamesMatchFrom(item, mixin, typeName, project))) {
    return true;
  }

  final superclass = item is ClassDeclaration ? item.extendsClause?.superclass : null;
  if (superclass == null) return false;
  final target = declarationNamedFrom(item, project, namedTypeReferenceName(superclass));
  return target != null && _mixesInType(target, typeName, project, visited);
}

bool _mixesInTypeNamedWhere(
  CompilationUnitMember item,
  HeimdallProject project,
  bool Function(String typeName) test,
  Set<String> visited,
) {
  if (!visited.add('${item.sourcePath}:${item.name}:mixinsWhere')) return false;

  final mixins = _directMixedInTypes(item);
  if (mixins.any((mixin) => typeNameMatchesWhereFrom(item, mixin, project, test))) {
    return true;
  }

  final superclass = item is ClassDeclaration ? item.extendsClause?.superclass : null;
  if (superclass == null) return false;
  final target = declarationNamedFrom(item, project, namedTypeReferenceName(superclass));
  return target != null && _mixesInTypeNamedWhere(target, project, test, visited);
}

List<String> _directAssignableTypes(CompilationUnitMember item) {
  return [
    ..._directExtendedTypes(item),
    ..._directImplementedTypes(item),
    ..._directMixedInTypes(item),
  ];
}

List<String> _directExtendedTypes(CompilationUnitMember item) {
  return [
    if (item is ClassDeclaration && item.extendsClause != null) namedTypeReferenceName(item.extendsClause!.superclass),
  ];
}

List<String> _directImplementedTypes(CompilationUnitMember item) {
  return [
    if (item is ClassDeclaration)
      ...?item.implementsClause?.interfaces.map(
        namedTypeReferenceName,
      ),
    if (item is MixinDeclaration)
      ...?item.implementsClause?.interfaces.map(
        namedTypeReferenceName,
      ),
    if (item is EnumDeclaration)
      ...?item.implementsClause?.interfaces.map(
        namedTypeReferenceName,
      ),
  ];
}

List<String> _directMixedInTypes(CompilationUnitMember item) {
  return [
    if (item is ClassDeclaration) ...?item.withClause?.mixinTypes.map(namedTypeReferenceName),
    if (item is EnumDeclaration) ...?item.withClause?.mixinTypes.map(namedTypeReferenceName),
  ];
}

Set<String> _expandedTypeNamesFrom(
  CompilationUnitMember item,
  Iterable<String> typeNames,
  HeimdallProject project,
) {
  return {
    for (final typeName in typeNames) ...[
      typeName,
      canonicalTypeNameFrom(item, typeName, project),
    ],
  };
}
