import 'package:heimdall_test/heimdall_test.dart';

/// Assertion applied to an item selected by a Heimdall rule.
///
/// Each condition returns a [HeimdallFindings] that always carries the
/// evaluated subject, so source location is available even when the
/// condition passed (needed by [not] to invert the result with location).
///
/// Conditions pass when [check] returns an empty list. They fail when one or
/// more [HeimdallValidationInfo] values are returned.
final class HeimdallCondition<T> {
  /// Creates a condition with a readable [description] and evaluation callback.
  ///
  /// The [_evaluate] callback must always return a [HeimdallFindings] with
  /// the correct subject reference. Conditions may populate
  /// [HeimdallFindings.findings] for both passing and failing results when
  /// they can provide a more precise location than the subject itself.
  const HeimdallCondition(
    this.description,
    this._evaluate,
  );

  /// Combines conditions and reports findings from all of them.
  ///
  /// Fails when any child condition fails. All failing children report their
  /// findings individually so every violation is visible in the output.
  ///
  /// Throws [ArgumentError] when [conditions] is empty.
  factory HeimdallCondition.allOf(
    Iterable<HeimdallCondition<T>> conditions, {
    String? description,
  }) {
    final conditionList = _nonEmptyConditions(conditions);
    final desc = description ?? conditionList.map((c) => c.description).join(' and ');
    return HeimdallCondition(
      desc,
      (item, project) {
        final failedFindings = <HeimdallValidationInfo>[];
        final passedFindings = <HeimdallValidationInfo>[];
        for (final condition in conditionList) {
          final result = condition.evaluate(item, project);
          if (result.passed) {
            passedFindings.addAll(result.findings);
          } else {
            failedFindings.addAll(condition.findingsFrom(result));
          }
        }
        return HeimdallFindings(
          subject: item,
          passed: failedFindings.isEmpty,
          findings: failedFindings.isEmpty ? passedFindings : failedFindings,
        );
      },
    );
  }

  /// Combines alternative conditions.
  ///
  /// Passes when any child condition produces no findings. When all children
  /// fail, reports findings from every child so the user sees all violations.
  ///
  /// Throws [ArgumentError] when [conditions] is empty.
  factory HeimdallCondition.anyOf(
    Iterable<HeimdallCondition<T>> conditions, {
    String? description,
  }) {
    final conditionList = _nonEmptyConditions(conditions);
    final desc = description ?? conditionList.map((c) => c.description).join(' or ');
    return HeimdallCondition(
      desc,
      (item, project) {
        final findings = <HeimdallValidationInfo>[];
        for (final condition in conditionList) {
          final result = condition.evaluate(item, project);
          if (result.passed) {
            return HeimdallFindings(
              subject: item,
              passed: true,
              findings: result.findings,
            );
          }
          findings.addAll(condition.findingsFrom(result));
        }
        // All children failed — report all findings so every violation is visible.
        return HeimdallFindings(
          subject: item,
          passed: false,
          findings: findings,
        );
      },
    );
  }

  /// Combines prohibited conditions.
  ///
  /// Passes when every child condition fails. Reports one finding per child
  /// that unexpectedly passed, so every violation is visible in the output.
  ///
  /// Throws [ArgumentError] when [conditions] is empty.
  factory HeimdallCondition.noneOf(
    Iterable<HeimdallCondition<T>> conditions, {
    String? description,
  }) {
    final conditionList = _nonEmptyConditions(conditions);
    final desc = description ?? 'none of ${conditionList.map((c) => c.description).join(', ')}';
    return HeimdallCondition(
      desc,
      (item, project) {
        final violations = <HeimdallValidationInfo>[];
        for (final condition in conditionList) {
          final result = condition.evaluate(item, project);
          if (result.passed) {
            // Child passed but should not have; preserve child match location.
            violations.addAll(
              condition.unexpectedPassFindingsFrom(
                result,
                'should not ${condition.description}',
              ),
            );
          }
        }
        return HeimdallFindings(
          subject: item,
          passed: violations.isEmpty,
          findings: violations,
        );
      },
    );
  }

  /// Text used in report descriptions.
  final String description;

  final HeimdallFindings<T> Function(T item, HeimdallProject project) _evaluate;

  /// Evaluates this condition and preserves details for both outcomes.
  HeimdallFindings<T> evaluate(T item, HeimdallProject project) {
    return _evaluate(item, project);
  }

  /// Evaluates this condition for [item] in [project] and returns any findings.
  ///
  /// Returns an empty list when the condition passes.
  ///
  /// When the condition fails, returns findings in this order of preference:
  /// 1. Detailed findings from [HeimdallFindings.findings] when populated.
  ///    Used by composite conditions (allOf, anyOf, noneOf, and, or, not) to
  ///    preserve per-item detail from children.
  /// 2. A single generic finding built from [HeimdallFindings.subject] and
  ///    this condition's [description]. The subject always carries the source
  ///    location, so the finding always has file, line and column.
  List<HeimdallValidationInfo> check(T item, HeimdallProject project) {
    final result = evaluate(item, project);
    return findingsFrom(result);
  }

  /// Converts an evaluation result into findings for a normal positive rule.
  List<HeimdallValidationInfo> findingsFrom(HeimdallFindings<T> result) {
    if (result.passed) {
      return const [];
    }
    // Prefer detailed findings from children; fall back to generic with location.
    if (result.findings.isNotEmpty) {
      return result.findings;
    }
    return [
      HeimdallValidationInfo.forSubject(
        result.subject,
        'should $description',
      ),
    ];
  }

  /// Converts a passing result into findings for an inverted rule.
  List<HeimdallValidationInfo> unexpectedPassFindingsFrom(
    HeimdallFindings<T> result,
    String message,
  ) {
    if (!result.passed) {
      return const [];
    }
    if (result.findings.isNotEmpty) {
      return [
        for (final finding in result.findings) finding.withMessage(message),
      ];
    }
    return [
      HeimdallValidationInfo.forSubject(
        result.subject,
        message,
      ),
    ];
  }

  /// Combines two conditions and reports findings from both.
  HeimdallCondition<T> and(HeimdallCondition<T> other) {
    return HeimdallCondition(
      '($description and ${other.description})',
      (item, project) {
        final result = evaluate(item, project);
        final otherResult = other.evaluate(item, project);
        final failedFindings = [
          ...findingsFrom(result),
          ...other.findingsFrom(otherResult),
        ];
        final passedFindings = [
          if (result.passed) ...result.findings,
          if (otherResult.passed) ...otherResult.findings,
        ];
        return HeimdallFindings(
          subject: item,
          passed: failedFindings.isEmpty,
          findings: failedFindings.isEmpty ? passedFindings : failedFindings,
        );
      },
    );
  }

  /// Combines two alternative conditions.
  ///
  /// Passes when either side produces no findings. When both fail, reports
  /// findings from both sides so every violation is visible.
  HeimdallCondition<T> or(HeimdallCondition<T> other) {
    return HeimdallCondition(
      '($description or ${other.description})',
      (item, project) {
        final first = evaluate(item, project);
        if (first.passed) {
          return HeimdallFindings(
            subject: item,
            passed: true,
            findings: first.findings,
          );
        }
        final second = other.evaluate(item, project);
        if (second.passed) {
          return HeimdallFindings(
            subject: item,
            passed: true,
            findings: second.findings,
          );
        }
        return HeimdallFindings(
          subject: item,
          passed: false,
          findings: [...findingsFrom(first), ...other.findingsFrom(second)],
        );
      },
    );
  }

  /// Returns a reusable condition object with this condition's result inverted.
  ///
  /// - When this condition fails → [not] passes (no findings).
  /// - When this condition passes → [not] fails with a finding that includes
  ///   the source location from [HeimdallFindings.subject], which is always
  ///   available even when the original condition produced no findings.
  ///
  /// This differs from builder `.not()` methods, which only mark the next
  /// fluent DSL condition call as negated.
  HeimdallCondition<T> not() {
    return HeimdallCondition('not ($description)', (item, project) {
      final result = evaluate(item, project);
      if (!result.passed) {
        // Original failed → not() passes.
        return HeimdallFindings(
          subject: item,
          passed: true,
        );
      }
      // Original passed → not() fails. Subject always has location here.
      return HeimdallFindings(
        subject: item,
        passed: false,
        findings: unexpectedPassFindingsFrom(
          result,
          'should not $description',
        ),
      );
    });
  }
}

List<HeimdallCondition<T>> _nonEmptyConditions<T>(
  Iterable<HeimdallCondition<T>> conditions,
) {
  final conditionList = conditions.toList();
  if (conditionList.isEmpty) {
    throw ArgumentError.value(conditions, 'conditions', 'must not be empty');
  }
  return conditionList;
}
