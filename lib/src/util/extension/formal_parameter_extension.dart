import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/util/extension/type_annotation_extension.dart';

/// Shared queries for [FormalParameter] nodes.
extension FormalParameterExtension on FormalParameter {
  /// The declared type name, including legacy function parameter syntax.
  ///
  /// Returns `null` when the type is omitted and must be inferred.
  String? get declaredTypeName {
    final suffix = functionTypedSuffix;
    return suffix == null ? type.typeName : 'Function${suffix.question == null ? '' : '?'}';
  }

  /// Whether [parameterName] names a positional or required named parameter.
  ///
  /// Optional positional parameters match; optional named parameters do not.
  bool matchesPositionalOrRequiredNamedParameter(String parameterName) => name?.lexeme == parameterName && (isPositional || isRequiredNamed);
}
