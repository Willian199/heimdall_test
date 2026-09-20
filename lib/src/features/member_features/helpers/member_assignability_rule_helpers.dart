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
  final actual = _normalizeAssignableTypeName(actualTypeName);
  final expected = _normalizeAssignableTypeName(expectedTypeName);

  if (typeNamesMatchFrom(source, actual, expected, project)) return true;
  if (_isTopLikeType(expected)) return actual != 'void';
  if (actual == 'Never') return expected != 'void';
  if (actual == 'dynamic') return expected != 'void';
  if (actual == 'void') return false;

  final declaration = declarationNamedFrom(source, project, actual);
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
