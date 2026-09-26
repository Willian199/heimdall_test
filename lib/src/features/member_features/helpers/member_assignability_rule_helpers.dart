import 'package:heimdall_test/src/core.dart';
import 'package:heimdall_test/src/features/queries/declaration_lookup_queries.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';

/// Returns whether [actualTypeName] is assignable to [expectedTypeName] from [source].
bool typeNameIsAssignableToFrom(
  CompilationUnitMember source,
  String actualTypeName,
  String expectedTypeName,
  HeimdallProject project,
) {
  final actualName = actualTypeName.trim();
  final expectedName = expectedTypeName.trim();
  final expectedAcceptsNull = expectedName.endsWith('?') || expectedName == 'dynamic' || expectedName == 'Null';
  if ((actualName.endsWith('?') || actualName == 'Null') && !expectedAcceptsNull) {
    return false;
  }
  if (actualName == 'Null' && expectedAcceptsNull) {
    return true;
  }
  final actual = _normalizeAssignableTypeName(actualTypeName);
  final expected = _normalizeAssignableTypeName(expectedTypeName);

  if (typeNamesMatchFrom(source, actual, expected, project)) {
    return true;
  }
  if (_isTopLikeType(expected)) {
    return actual != 'void';
  }
  if (actual == 'Never') {
    return expected != 'void';
  }
  if (actual == 'dynamic') {
    return expected != 'void';
  }
  if (actual == 'void') {
    return false;
  }

  // Type arguments belong to the instance, not to the declaration's name.
  // Preserve them above for exact comparisons, but omit them for hierarchy lookup.
  final genericStart = actual.indexOf('<');
  final declarationName = genericStart < 0 ? actual : actual.substring(0, genericStart);
  if (typeNamesMatchFrom(source, declarationName, expected, project)) {
    return true;
  }
  final declaration = declarationNamedFrom(source, project, declarationName);
  return declaration != null && isAssignableTo(declaration, expected, project);
}

bool _isTopLikeType(String typeName) {
  return typeName == 'Object' || typeName == 'dynamic';
}

String _normalizeAssignableTypeName(String typeName) {
  var normalized = typeName.trim();
  while (normalized.endsWith('?')) {
    normalized = normalized.substring(0, normalized.length - 1);
  }
  return normalized;
}
