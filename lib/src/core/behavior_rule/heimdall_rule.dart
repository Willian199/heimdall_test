import 'package:heimdall_test/heimdall_test.dart';

/// Selects the items a rule evaluates from a project.
typedef Selector<T> = Iterable<T> Function(HeimdallProject project);

/// Executable Heimdall rule.
///
/// A rule selects items, filters them with a predicate, evaluates a condition,
/// and returns a [HeimdallReport]. Most users obtain rules from the fluent DSL
/// rather than constructing this class directly.
final class HeimdallRule<T> {
  /// Creates a rule from the selector, predicate, and condition pieces.
  HeimdallRule({
    required this.selector,
    required this.predicate,
    required this.condition,
    String? customDescription,
    String? descriptionPrefix,
    this.continuationContext,
    this.inverted = false,
    this.failOnEmptySelection = true,
  }) : description = customDescription ?? _ruleDescription(descriptionPrefix, condition),
       descriptionPrefix = descriptionPrefix ?? customDescription;

  /// Human-readable rule description.
  final String description;

  /// Description prefix used when this rule is continued with another condition.
  final String? descriptionPrefix;

  /// Internal context used by condition-chain builders.
  final MemberSelection? continuationContext;

  /// Selects candidate items from a project.
  final Selector<T> selector;

  /// Filters selected candidates.
  final HeimdallPredicate<T> predicate;

  /// Checks each matching item.
  final HeimdallCondition<T> condition;

  /// When `true`, satisfying the condition is considered a failure.
  ///
  /// This is how `Heimdall.noFiles()`, `noClasses()`, and related entry points
  /// express "no selected item should match this condition".
  final bool inverted;

  /// Controls whether an empty selector or predicate result should fail.
  ///
  /// This local setting is also gated by
  /// [HeimdallConfiguration.failOnEmptySelection].
  final bool failOnEmptySelection;

  /// Runs this rule against [project].
  ///
  /// The returned report includes selected item count and all visible findings.
  /// Hidden findings are removed using
  /// [HeimdallConfiguration.ignoredViolationPatterns].
  HeimdallReport check(HeimdallProject project) {
    final findings = <HeimdallValidationInfo>[];
    var candidateCount = 0;
    var selectedCount = 0;

    for (final item in selector(project)) {
      candidateCount++;
      if (!predicate.test(item, project)) {
        continue;
      }

      selectedCount++;
      final result = condition.evaluate(item, project);
      if (inverted) {
        findings.addAll(
          condition.unexpectedPassFindingsFrom(
            result,
            'must not ${condition.description}',
          ),
        );
      } else {
        findings.addAll(condition.findingsFrom(result));
      }
    }

    if (selectedCount == 0 && failOnEmptySelection && HeimdallConfiguration.failOnEmptySelection) {
      findings.add(
        HeimdallValidationInfo(
          message: candidateCount == 0
              ? 'Rule selector returned no items.'
              : 'Rule .that() predicate matched no items. Predicate: ${predicate.description}',
        ),
      );
    }

    final visibleFindings = findings.where((finding) => !HeimdallConfiguration.ignores(finding.toString())).toList();

    return HeimdallReport(
      description: description,
      checkedCount: selectedCount,
      findings: visibleFindings,
      // An ignored empty-selection finding must not reappear at assertion time.
      failOnEmptySelection: failOnEmptySelection && (selectedCount != 0 || visibleFindings.isNotEmpty),
    );
  }

  /// Returns a copy with [reason] appended to its generated description.
  HeimdallRule<T> because(String reason) {
    return HeimdallRule(
      customDescription: '$description, because $reason',
      descriptionPrefix: descriptionPrefix,
      continuationContext: continuationContext,
      selector: selector,
      predicate: predicate,
      condition: condition,
      inverted: inverted,
      failOnEmptySelection: failOnEmptySelection,
    );
  }

  /// Returns a copy with a custom [description].
  HeimdallRule<T> as(String description) {
    return HeimdallRule(
      customDescription: description,
      descriptionPrefix: description,
      continuationContext: continuationContext,
      selector: selector,
      predicate: predicate,
      condition: condition,
      inverted: inverted,
      failOnEmptySelection: failOnEmptySelection,
    );
  }

  /// Returns a copy that allows this rule to select no items.
  HeimdallRule<T> allowEmpty() => failOnEmpty(false);

  /// Returns a copy with explicit empty-selection behavior.
  HeimdallRule<T> failOnEmpty(bool value) {
    return HeimdallRule(
      customDescription: description,
      descriptionPrefix: descriptionPrefix,
      continuationContext: continuationContext,
      selector: selector,
      predicate: predicate,
      condition: condition,
      inverted: inverted,
      failOnEmptySelection: value,
    );
  }
}

String _ruleDescription<T>(
  String? descriptionPrefix,
  HeimdallCondition<T> condition,
) {
  final prefix = descriptionPrefix ?? 'items';
  return '$prefix should ${condition.description}';
}
