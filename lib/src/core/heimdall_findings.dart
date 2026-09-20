import 'package:heimdall_test/heimdall_test.dart';

/// Findings produced by a condition evaluation.
///
/// Always carries the [subject] so that [HeimdallValidationInfo.forSubject] can
/// extract the source location regardless of whether the condition passed or
/// failed. This is the key invariant that guarantees every finding — including
/// those produced by [HeimdallCondition.not] — always has a location.
final class HeimdallFindings<T> {
  /// Creates the evaluation findings for [subject].
  const HeimdallFindings({
    required this.subject,
    required this.passed,
    this.findings = const [],
  });

  /// Evaluated subject — always present, used for location extraction.
  final T subject;

  /// Whether the condition passed.
  final bool passed;

  /// Findings already produced by the condition or its children.
  ///
  /// A passing condition may still populate this list to describe where it
  /// matched. Normal positive rules ignore those findings, while inverted
  /// rules reuse their file, line, and column for precise diagnostics.
  final List<HeimdallValidationInfo> findings;
}
