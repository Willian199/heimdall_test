import 'package:heimdall_test/src/core.dart';
import 'package:heimdall_test/src/features/queries/declaration_lookup_queries.dart';
import 'package:heimdall_test/src/features/queries/type_annotation_queries.dart';

/// Returns `true` when [item] is assignable to a type whose name matches [test].
bool isAssignableToTypeNamedWhere(
  CompilationUnitMember item,
  HeimdallProject project,
  bool Function(String typeName) test,
) {
  if (item is ExtensionDeclaration) {
    return false;
  }
  final visited = <String>{};
  bool visit(CompilationUnitMember item) {
    if (typeNameMatchesWhereFrom(item, item.name, project, test)) {
      return true;
    }
    if (!visited.add('${item.sourcePath}:${item.name}:assignableWhere')) {
      return false;
    }

    final directTypes = _directAssignableTypes(item);
    if (directTypes.any((type) => typeNameMatchesWhereFrom(item, type, project, test))) {
      return true;
    }

    for (final typeName in _expandedTypeNamesFrom(item, directTypes, project)) {
      final target = declarationNamedFrom(item, project, typeName);
      if (target != null && visit(target)) {
        return true;
      }
    }

    return false;
  }

  return visit(item);
}

/// Returns `true` when [item] extends a type whose name matches [test].
bool extendsTypeNamedWhere(
  CompilationUnitMember item,
  HeimdallProject project,
  bool Function(String typeName) test,
) {
  final visited = <String>{};
  bool visit(CompilationUnitMember item) {
    if (item is! ClassDeclaration && item is! ClassTypeAlias) {
      return false;
    }
    if (!visited.add('${item.sourcePath}:${item.name}:extendsWhere')) {
      return false;
    }

    final superclass = _superclassOf(item);
    if (superclass == null) {
      return false;
    }
    final superclassName = superclass.toSource();
    if (typeNameMatchesWhereFrom(item, superclassName, project, test)) {
      return true;
    }

    final target = declarationNamedFrom(item, project, superclassName);
    return target != null && visit(target);
  }

  return visit(item);
}

/// Returns `true` when [item] implements a type whose name matches [test].
bool implementsTypeNamedWhere(
  CompilationUnitMember item,
  HeimdallProject project,
  bool Function(String typeName) test,
) {
  final visited = <String>{};
  bool visit(CompilationUnitMember item) {
    if (!visited.add('${item.sourcePath}:${item.name}:implementsWhere')) {
      return false;
    }

    final interfaces = [..._directImplementedTypes(item), ..._directMixedInTypes(item)];
    if (interfaces.any((interface) => typeNameMatchesWhereFrom(item, interface, project, test))) {
      return true;
    }

    for (final interface in interfaces) {
      final target = declarationNamedFrom(item, project, interface);
      if (target != null && isAssignableToTypeNamedWhere(target, project, test)) {
        return true;
      }
    }

    final superclass = _superclassOf(item);
    if (superclass == null) {
      return false;
    }
    final target = declarationNamedFrom(item, project, namedTypeReferenceName(superclass));
    return target != null && visit(target);
  }

  return visit(item);
}

/// Returns `true` when [item] mixes in a type whose name matches [test].
bool mixesInTypeNamedWhere(
  CompilationUnitMember item,
  HeimdallProject project,
  bool Function(String typeName) test,
) {
  final visited = <String>{};
  bool visit(CompilationUnitMember item) {
    if (!visited.add('${item.sourcePath}:${item.name}:mixinsWhere')) {
      return false;
    }

    final mixins = _directMixedInTypes(item);
    if (mixins.any((mixin) => typeNameMatchesWhereFrom(item, mixin, project, test))) {
      return true;
    }

    final superclass = _superclassOf(item);
    if (superclass == null) {
      return false;
    }
    final target = declarationNamedFrom(item, project, namedTypeReferenceName(superclass));
    return target != null && visit(target);
  }

  return visit(item);
}

List<String> _directAssignableTypes(CompilationUnitMember item) {
  return [
    if (item is ClassDeclaration || item is MixinDeclaration || item is EnumDeclaration) 'Object',
    if (item is EnumDeclaration) 'Enum',
    if (item is MixinDeclaration) ...?item.onClause?.superclassConstraints.map((type) => type.toSource()),
    ..._directExtendedTypes(item),
    ..._directImplementedTypes(item),
    ..._directMixedInTypes(item),
  ];
}

List<String> _directExtendedTypes(CompilationUnitMember item) {
  return [
    if (_superclassOf(item) case final superclass?) namedTypeReferenceName(superclass),
  ];
}

List<String> _directImplementedTypes(CompilationUnitMember item) {
  return [
    if (item is ClassDeclaration)
      ...?item.implementsClause?.interfaces.map(
        (type) => type.toSource(),
      ),
    if (item is MixinDeclaration)
      ...?item.implementsClause?.interfaces.map(
        (type) => type.toSource(),
      ),
    if (item is EnumDeclaration)
      ...?item.implementsClause?.interfaces.map(
        (type) => type.toSource(),
      ),
    if (item is ExtensionTypeDeclaration) ...?item.implementsClause?.interfaces.map((type) => type.toSource()),
    if (item is ClassTypeAlias) ...?item.implementsClause?.interfaces.map((type) => type.toSource()),
  ];
}

List<String> _directMixedInTypes(CompilationUnitMember item) {
  return [
    if (item is ClassDeclaration) ...?item.withClause?.mixinTypes.map((type) => type.toSource()),
    if (item is EnumDeclaration) ...?item.withClause?.mixinTypes.map((type) => type.toSource()),
    if (item is ClassTypeAlias) ...item.withClause.mixinTypes.map((type) => type.toSource()),
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

NamedType? _superclassOf(CompilationUnitMember item) => switch (item) {
  ClassDeclaration() => item.extendsClause?.superclass,
  ClassTypeAlias() => item.superclass,
  _ => null,
};
