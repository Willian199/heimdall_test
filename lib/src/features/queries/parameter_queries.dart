import 'package:heimdall_test/heimdall_test.dart';

/// Matches [name] on positional parameters or required named parameters.
///
/// Optional positional parameters match; optional named parameters do not.
bool isPositionalOrRequiredNamedParameter(
  FormalParameter parameter,
  String name,
) {
  if (parameter.name?.lexeme != name) {
    return false;
  }
  if (parameter is! DefaultFormalParameter) {
    return true;
  }
  if (!parameter.isNamed) {
    return true;
  }
  return parameter.isRequiredNamed;
}
