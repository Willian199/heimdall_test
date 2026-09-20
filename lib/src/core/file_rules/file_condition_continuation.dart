import 'package:heimdall_test/heimdall_test.dart';

/// Continues a file condition chain after a rule condition was added.
extension FileConditionChain on HeimdallRule<HeimdallSourceFile> {
  /// Combines the next file condition with logical `and`.
  FileShouldBuilder and() {
    return FileShouldBuilder.fromRule(this, useOr: false);
  }

  /// Combines the next file condition with logical `or`.
  FileShouldBuilder or() {
    return FileShouldBuilder.fromRule(this, useOr: true);
  }
}
