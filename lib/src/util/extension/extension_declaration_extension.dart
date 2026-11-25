import 'package:heimdall_test/src/core.dart';
import 'package:heimdall_test/src/util/extension_applicability.dart';
import 'package:heimdall_test/src/util/type_assignability.dart';

/// Shared queries for [ExtensionDeclaration] nodes.
extension ExtensionDeclarationExtension on ExtensionDeclaration {
  /// Infers extension arguments using the same nominal types, substitutions and
  /// assignability rules as class relationship queries. Unknown inference fails
  /// conservatively instead of treating unbound parameters as arbitrary types.
  ExtensionApplicability? applicabilityFor(
    CompilationUnitMember actualSource,
    String actual,
    HeimdallProject project,
  ) => TypeAssignability.applicabilityFor(this, actualSource, actual, project);
}
