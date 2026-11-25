import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/util/extension/assignability/compilation_unit_member_extension.dart';
import 'package:heimdall_test/src/util/extension/relationships/compilation_unit_member_extension.dart';

/// Matches declarations assignable to [typeName], including inherited types.
HeimdallPredicate<CompilationUnitMember> classAssignableTo(String typeName) {
  return HeimdallPredicate(
    'are assignable to $typeName',
    (item, project) => item.instantiatedTypeIsAssignableTo(item.name, typeName, project),
  );
}

/// Matches declarations assignable to a type whose name ends with [suffix].
HeimdallPredicate<CompilationUnitMember> classAssignableToTypeNameEndingWith(
  String suffix,
) {
  return HeimdallPredicate(
    'are assignable to type name ending with $suffix',
    (item, project) => item.isAssignableToTypeNamedWhere(project, (typeName) => typeName.endsWith(suffix)),
  );
}

/// Matches declarations extending [typeName].
HeimdallPredicate<CompilationUnitMember> classExtends(String typeName) {
  return HeimdallPredicate(
    'extend $typeName',
    (item, project) => item.instantiatedTypeHasRelationship(typeName, project, relationship: 'extends'),
  );
}

/// Matches declarations extending a type whose name ends with [suffix].
HeimdallPredicate<CompilationUnitMember> classExtendsTypeNameEndingWith(
  String suffix,
) {
  return HeimdallPredicate(
    'extend type name ending with $suffix',
    (item, project) => item.extendsTypeNamedWhere(project, (typeName) => typeName.endsWith(suffix)),
  );
}

/// Matches declarations extending a type whose name starts with [prefix].
HeimdallPredicate<CompilationUnitMember> classExtendsTypeNameStartingWith(
  String prefix,
) {
  return HeimdallPredicate(
    'extend type name starting with $prefix',
    (item, project) => item.extendsTypeNamedWhere(project, (typeName) => typeName.startsWith(prefix)),
  );
}

/// Matches declarations implementing [typeName].
HeimdallPredicate<CompilationUnitMember> classImplements(String typeName) {
  return HeimdallPredicate(
    'implement $typeName',
    (item, project) => item.instantiatedTypeHasRelationship(typeName, project, relationship: 'implements'),
  );
}

/// Matches declarations implementing a type whose name ends with [suffix].
HeimdallPredicate<CompilationUnitMember> classImplementsTypeNameEndingWith(
  String suffix,
) {
  return HeimdallPredicate(
    'implement type name ending with $suffix',
    (item, project) => item.implementsTypeNamedWhere(project, (typeName) => typeName.endsWith(suffix)),
  );
}

/// Matches declarations applying the mixin [typeName].
HeimdallPredicate<CompilationUnitMember> classMixesIn(String typeName) {
  return HeimdallPredicate(
    'mixin $typeName',
    (item, project) => item.instantiatedTypeHasRelationship(typeName, project, relationship: 'mixins'),
  );
}

/// Matches declarations applying a mixin whose name ends with [suffix].
HeimdallPredicate<CompilationUnitMember> classMixesInTypeNameEndingWith(
  String suffix,
) {
  return HeimdallPredicate(
    'mixin type name ending with $suffix',
    (item, project) => item.mixesInTypeNamedWhere(project, (typeName) => typeName.endsWith(suffix)),
  );
}

/// Matches declarations applying a mixin whose name starts with [prefix].
HeimdallPredicate<CompilationUnitMember> classMixesInTypeNameStartingWith(
  String prefix,
) {
  return HeimdallPredicate(
    'mixin type name starting with $prefix',
    (item, project) => item.mixesInTypeNamedWhere(project, (typeName) => typeName.startsWith(prefix)),
  );
}
