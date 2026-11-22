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

  /// Requires every child condition to pass.
  ///
  /// Reports a single finding for the group when any child fails.
  ///
  /// Throws [ArgumentError] when [conditions] is empty.
  factory HeimdallCondition.allOf(
    Iterable<HeimdallCondition<T>> conditions, {
    String? description,
  }) {
    final conditionList = _nonEmptyConditions(conditions);
    final desc = description ?? _groupDescription(conditionList, quantifier: 'all');
    return HeimdallCondition(
      desc,
      (item, project) {
        final passedFindings = <HeimdallValidationInfo>[];
        final failures = <HeimdallValidationInfo>[];
        for (final condition in conditionList) {
          final result = condition.evaluate(item, project);
          if (!result.passed) {
            failures.addAll(condition.findingsFrom(result));
          } else if (failures.isEmpty) {
            passedFindings.addAll(result.findings);
          }
        }
        if (failures.isNotEmpty) {
          return _groupFailure(item, 'Required conditions were not met.', failures);
        }
        return HeimdallFindings(
          subject: item,
          passed: true,
          findings: passedFindings,
        );
      },
    );
  }

  /// Combines alternative conditions.
  ///
  /// Passes as soon as a child condition passes. Reports the alternatives in
  /// a single-line finding when all children fail.
  ///
  /// Throws [ArgumentError] when [conditions] is empty.
  factory HeimdallCondition.anyOf(
    Iterable<HeimdallCondition<T>> conditions, {
    String? description,
  }) {
    final conditionList = _nonEmptyConditions(conditions);
    final desc = description ?? _groupDescription(conditionList, quantifier: 'at least one');
    return HeimdallCondition(
      desc,
      (item, project) {
        final failedResults = <(HeimdallCondition<T>, HeimdallFindings<T>)>[];
        for (final condition in conditionList) {
          final result = condition.evaluate(item, project);
          if (result.passed) {
            return HeimdallFindings(
              subject: item,
              passed: true,
              findings: result.findings,
            );
          }
          failedResults.add((condition, result));
        }
        return _alternativesFailure(item, [
          for (final (condition, result) in failedResults) condition.findingsFrom(result),
        ]);
      },
    );
  }

  /// Combines prohibited conditions.
  ///
  /// Passes when every child condition fails. Reports a single finding for the
  /// group when any child passes.
  ///
  /// Throws [ArgumentError] when [conditions] is empty.
  factory HeimdallCondition.noneOf(
    Iterable<HeimdallCondition<T>> conditions, {
    String? description,
  }) {
    final conditionList = _nonEmptyConditions(conditions);
    final desc = description ?? _groupDescription(conditionList, quantifier: 'none', negated: true);
    return HeimdallCondition(
      desc,
      (item, project) {
        final violations = <HeimdallValidationInfo>[];
        for (final condition in conditionList) {
          final result = condition.evaluate(item, project);
          if (result.passed) {
            violations.addAll(condition.unexpectedPassFindingsFrom(result, 'should not ${condition.description}'));
          }
        }
        if (violations.isNotEmpty) {
          return _groupFailure(item, 'Prohibited conditions matched.', violations);
        }
        return HeimdallFindings(subject: item, passed: true);
      },
    );
  }
  static final _lineBreaks = RegExp(r'[\r\n]+[ \t]*');

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
  ///    Grouped conditions (`allOf`, `anyOf`, `noneOf`) return a single
  ///    finding listing the violations and their available locations.
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
      // Detailed expectations can name a variable within the evaluated subject.
      final expectation = ' should $description';
      return [
        for (final finding in result.findings)
          finding.withMessage(
            finding.message.endsWith(expectation)
                ? finding.message.replaceRange(finding.message.length - expectation.length, null, ' $message')
                : message,
          ),
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

String _groupDescription<T>(
  List<HeimdallCondition<T>> conditions, {
  required String quantifier,
  bool negated = false,
}) {
  if (conditions.length == 1) {
    return '${negated ? 'not ' : ''}${conditions.single.description}';
  }
  final descriptions = conditions.map((condition) => condition.description).join(', ');
  return 'satisfy $quantifier of these conditions ($descriptions)';
}

HeimdallValidationInfo _primaryProblem(Iterable<HeimdallValidationInfo> problems) {
  return problems.firstWhere(
    (problem) => problem.line != null,
    orElse: () => problems.firstWhere((problem) => problem.filePath != null, orElse: () => problems.first),
  );
}

HeimdallFindings<T> _alternativesFailure<T>(T item, List<List<HeimdallValidationInfo>> alternatives) {
  final problems = alternatives.expand((findings) => findings);
  final primary = _primaryProblem(problems);
  final sameFinding = alternatives.every(
    (findings) => findings.length == 1 && findings.single.message == primary.message && _sameLocation(findings.single, primary),
  );
  var message = primary.message;
  if (!sameFinding) {
    final distinctLocations = problems.any((problem) => !_sameLocation(problem, primary));
    final details = alternatives.map((findings) {
      final messages = findings.map((finding) => distinctLocations ? _describeAlternative(finding) : finding.message);
      return findings.length == 1 ? messages.single : '(${messages.join(' and ')})';
    });
    message = alternatives.length == 1 ? details.single : 'None of the alternatives matched (${details.join(' or ')}).';
  }
  return HeimdallFindings(
    subject: item,
    passed: false,
    findings: [primary.withMessage(message.replaceAll(HeimdallCondition._lineBreaks, ' '))],
  );
}

bool _sameLocation(HeimdallValidationInfo first, HeimdallValidationInfo second) =>
    first.filePath == second.filePath && first.line == second.line && first.column == second.column;

String _describeAlternative(HeimdallValidationInfo problem) {
  final location = problem.formattedLocation ?? _describeLine(problem);
  return location == null ? problem.message : '${problem.message} [$location]';
}

HeimdallFindings<T> _groupFailure<T>(T item, String heading, List<HeimdallValidationInfo> problems) {
  if (problems.length == 1) {
    return HeimdallFindings(subject: item, passed: false, findings: problems);
  }
  final primary = _primaryProblem(problems);
  return HeimdallFindings(
    subject: item,
    passed: false,
    findings: [
      primary.withMessage(
        [
          heading,
          for (final problem in problems) '  - ${_describeProblem(problem)}',
        ].join('\n'),
      ),
    ],
  );
}

String _describeProblem(HeimdallValidationInfo problem) {
  if (problem.filePath != null) {
    return problem.toString();
  }
  final location = _describeLine(problem);
  return location == null ? problem.message : '$location — ${problem.message}';
}

String? _describeLine(HeimdallValidationInfo problem) {
  final line = problem.line;
  if (line == null) {
    return null;
  }
  final column = problem.column;
  return column == null ? 'line $line' : 'line $line, column $column';
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
