import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';

/// Matches declarations assignable to [typeName], including inherited types.
HeimdallPredicate<CompilationUnitMember> classAssignableTo(String typeName) {
  return HeimdallPredicate(
    'are assignable to $typeName',
    (item, project) => isAssignableTo(item, typeName, project),
  );
}

/// Matches declarations assignable to a type whose name ends with [suffix].
HeimdallPredicate<CompilationUnitMember> classAssignableToTypeNameEndingWith(
  String suffix,
) {
  return HeimdallPredicate(
    'are assignable to type name ending with $suffix',
    (item, project) => isAssignableToTypeNamedWhere(
      item,
      project,
      (typeName) => typeName.endsWith(suffix),
    ),
  );
}

/// Matches declarations extending [typeName].
HeimdallPredicate<CompilationUnitMember> classExtends(String typeName) {
  return HeimdallPredicate(
    'extend $typeName',
    (item, project) => extendsType(item, typeName, project),
  );
}

/// Matches declarations extending a type whose name ends with [suffix].
HeimdallPredicate<CompilationUnitMember> classExtendsTypeNameEndingWith(
  String suffix,
) {
  return HeimdallPredicate(
    'extend type name ending with $suffix',
    (item, project) => extendsTypeNamedWhere(
      item,
      project,
      (typeName) => typeName.endsWith(suffix),
    ),
  );
}

/// Matches declarations extending a type whose name starts with [prefix].
HeimdallPredicate<CompilationUnitMember> classExtendsTypeNameStartingWith(
  String prefix,
) {
  return HeimdallPredicate(
    'extend type name starting with $prefix',
    (item, project) => extendsTypeNamedWhere(
      item,
      project,
      (typeName) => typeName.startsWith(prefix),
    ),
  );
}

/// Matches declarations implementing [typeName].
HeimdallPredicate<CompilationUnitMember> classImplements(String typeName) {
  return HeimdallPredicate(
    'implement $typeName',
    (item, project) => implementsType(item, typeName, project),
  );
}

/// Matches declarations implementing a type whose name ends with [suffix].
HeimdallPredicate<CompilationUnitMember> classImplementsTypeNameEndingWith(
  String suffix,
) {
  return HeimdallPredicate(
    'implement type name ending with $suffix',
    (item, project) => implementsTypeNamedWhere(
      item,
      project,
      (typeName) => typeName.endsWith(suffix),
    ),
  );
}

/// Matches declarations applying the mixin [typeName].
HeimdallPredicate<CompilationUnitMember> classMixesIn(String typeName) {
  return HeimdallPredicate(
    'mixin $typeName',
    (item, project) => mixesInType(item, typeName, project),
  );
}

/// Matches declarations applying a mixin whose name ends with [suffix].
HeimdallPredicate<CompilationUnitMember> classMixesInTypeNameEndingWith(
  String suffix,
) {
  return HeimdallPredicate(
    'mixin type name ending with $suffix',
    (item, project) => mixesInTypeNamedWhere(
      item,
      project,
      (typeName) => typeName.endsWith(suffix),
    ),
  );
}

/// Matches declarations applying a mixin whose name starts with [prefix].
HeimdallPredicate<CompilationUnitMember> classMixesInTypeNameStartingWith(
  String prefix,
) {
  return HeimdallPredicate(
    'mixin type name starting with $prefix',
    (item, project) => mixesInTypeNamedWhere(
      item,
      project,
      (typeName) => typeName.startsWith(prefix),
    ),
  );
}
