import 'package:heimdall_test/src/core.dart';
import 'package:heimdall_test/src/util/type_assignability.dart';

/// Assignability queries for [CompilationUnitMember] nodes.
extension CompilationUnitMemberAssignabilityExtension on CompilationUnitMember {
  /// Checks instantiated types while carrying substitutions over hierarchy edges.
  bool instantiatedTypeIsAssignableTo(
    String actual,
    String expected,
    HeimdallProject project, {
    CompilationUnitMember? actualSource,
  }) => TypeAssignability.isAssignableTo(this, actual, expected, project, actualSource: actualSource);

  /// Follows a declared relationship while preserving type arguments and scopes.
  bool instantiatedTypeHasRelationship(String expected, HeimdallProject project, {required String relationship}) =>
      TypeAssignability.hasRelationship(this, expected, project, relationship: relationship);
}
