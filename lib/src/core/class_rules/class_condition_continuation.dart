import 'package:heimdall_test/heimdall_test.dart';

/// Continues a class condition chain after a rule condition was added.
extension ClassConditionChain on HeimdallRule<CompilationUnitMember> {
  /// Combines the next class condition with logical `and`.
  ClassShouldBuilder and() {
    return ClassShouldBuilder.fromRule(this, useOr: false);
  }

  /// Combines the next class condition with logical `or`.
  ClassShouldBuilder or() {
    return ClassShouldBuilder.fromRule(this, useOr: true);
  }
}
