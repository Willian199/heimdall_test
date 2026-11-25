import 'package:heimdall_test/src/core.dart';
import 'package:heimdall_test/src/util/extension/lookup/compilation_unit_member_extension.dart';
import 'package:heimdall_test/src/util/extension/named_type_extension.dart';

/// Relationships queries for [CompilationUnitMember] nodes.
extension CompilationUnitMemberRelationshipsExtension on CompilationUnitMember {
  /// Returns `true` when this node is assignable to a type whose name matches [test].
  bool isAssignableToTypeNamedWhere(
    HeimdallProject project,
    bool Function(String typeName) test,
  ) {
    if (this is ExtensionDeclaration) {
      return false;
    }
    final visited = <String>{};
    bool visit(CompilationUnitMember item) {
      if (item.typeNameMatchesWhere(item.name, project, test)) {
        return true;
      }
      if (!visited.add('${item.sourcePath}:${item.name}:assignableWhere')) {
        return false;
      }

      final directTypes = _directAssignableTypes(item);
      if (directTypes.any((type) => item.typeNameMatchesWhere(type, project, test))) {
        return true;
      }

      for (final typeName in _expandedTypeNamesFrom(item, directTypes, project)) {
        final target = item.declarationNamed(project, typeName);
        if (target != null && visit(target)) {
          return true;
        }
      }

      return false;
    }

    return visit(this);
  }

  /// Returns `true` when this node extends a type whose name matches [test].
  bool extendsTypeNamedWhere(
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
      if (item.typeNameMatchesWhere(superclassName, project, test)) {
        return true;
      }

      final target = item.declarationNamed(project, superclassName);
      return target != null && visit(target);
    }

    return visit(this);
  }

  /// Returns `true` when this node implements a type whose name matches [test].
  bool implementsTypeNamedWhere(
    HeimdallProject project,
    bool Function(String typeName) test,
  ) {
    final visited = <String>{};
    bool visit(CompilationUnitMember item) {
      if (!visited.add('${item.sourcePath}:${item.name}:implementsWhere')) {
        return false;
      }

      final interfaces = [..._directImplementedTypes(item), ..._directMixedInTypes(item)];
      if (interfaces.any((interface) => item.typeNameMatchesWhere(interface, project, test))) {
        return true;
      }

      for (final interface in interfaces) {
        final target = item.declarationNamed(project, interface);
        if (target != null && target.isAssignableToTypeNamedWhere(project, test)) {
          return true;
        }
      }

      final superclass = _superclassOf(item);
      if (superclass == null) {
        return false;
      }
      final target = item.declarationNamed(project, superclass.referenceName);
      return target != null && visit(target);
    }

    return visit(this);
  }

  /// Returns `true` when this node mixes in a type whose name matches [test].
  bool mixesInTypeNamedWhere(
    HeimdallProject project,
    bool Function(String typeName) test,
  ) {
    final visited = <String>{};
    bool visit(CompilationUnitMember item) {
      if (!visited.add('${item.sourcePath}:${item.name}:mixinsWhere')) {
        return false;
      }

      final mixins = _directMixedInTypes(item);
      if (mixins.any((mixin) => item.typeNameMatchesWhere(mixin, project, test))) {
        return true;
      }

      final superclass = _superclassOf(item);
      if (superclass == null) {
        return false;
      }
      final target = item.declarationNamed(project, superclass.referenceName);
      return target != null && visit(target);
    }

    return visit(this);
  }
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
    if (_superclassOf(item) case final superclass?) superclass.referenceName,
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
      item.canonicalTypeName(typeName, project),
    ],
  };
}

NamedType? _superclassOf(CompilationUnitMember item) => switch (item) {
  ClassDeclaration() => item.extendsClause?.superclass,
  ClassTypeAlias() => item.superclass,
  _ => null,
};
