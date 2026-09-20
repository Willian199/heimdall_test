import 'dart:async';

import 'package:heimdall_test/heimdall_test.dart';

/// Result of executing a Heimdall rule.
///
/// The report states how many items were checked and which findings were found.
/// Tests usually call [assertNoFindings] to fail when a rule reports anything.
///
/// Example:
/// ```dart
/// final report = Heimdall.classes().should().resideInPath('lib').check(project);
/// report.assertNoFindings();
/// ```
final class HeimdallReport {
  /// Creates a rule execution report.
  const HeimdallReport({
    required this.description,
    required this.checkedCount,
    required this.findings,
    this.failOnEmptySelection = true,
  });

  /// Human-readable description of the executed rule.
  final String description;

  /// Number of items evaluated by the rule.
  final int checkedCount;

  /// Findings reported by the rule.
  final List<HeimdallValidationInfo> findings;

  /// Whether empty selector or predicate results should be assertion failures.
  final bool failOnEmptySelection;

  /// `true` when at least one finding was reported.
  bool get hasFindings => findings.isNotEmpty;

  /// Throws [StateError] when findings are present.
  ///
  /// Useful in tests to turn Heimdall rules into assertions.
  void assertNoFindings({bool verbose = false}) {
    if (findings.isEmpty && !_isEmptySelectionFailure) {
      if (verbose) {
        Zone.current.print('$description: $checkedCount items checked');
      }
      return;
    }
    final buffer = StringBuffer()
      ..writeln('Heimdall saw rule breaches: $description')
      ..writeln('Checked items: $checkedCount');
    if (_isEmptySelectionFailure) {
      buffer.writeln('Rule selected no items before evaluating conditions.');
    }
    if (findings.isEmpty) {
      throw StateError(buffer.toString());
    }
    buffer.writeln('Findings:');
    for (final finding in findings) {
      buffer.writeln('- $finding');
    }
    throw StateError(buffer.toString());
  }

  bool get _isEmptySelectionFailure {
    return checkedCount == 0 && failOnEmptySelection && HeimdallConfiguration.failOnEmptySelection;
  }
}
