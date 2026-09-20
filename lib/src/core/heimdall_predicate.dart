import 'package:heimdall_test/heimdall_test.dart';

/// Predicate used to select items before a rule condition is evaluated.
///
/// Predicates return `true` for items that should remain in the rule selection.
/// Use [HeimdallPredicate.allOf], [HeimdallPredicate.anyOf],
/// [HeimdallPredicate.noneOf], [and], [or], and [not] to compose reusable
/// selections outside the fluent builder chain.
final class HeimdallPredicate<T> {
  /// Creates a predicate with a readable [description].
  const HeimdallPredicate(this.description, this.test);

  /// Creates a predicate that requires every predicate in [predicates].
  ///
  /// Throws [ArgumentError] when [predicates] is empty.
  factory HeimdallPredicate.allOf(
    Iterable<HeimdallPredicate<T>> predicates, {
    String? description,
  }) {
    final predicateList = _nonEmptyPredicates(predicates);
    return HeimdallPredicate(
      description ?? predicateList.map((p) => p.description).join(' and '),
      (item, project) => predicateList.every((p) => p.test(item, project)),
    );
  }

  /// Creates a predicate that accepts any predicate in [predicates].
  ///
  /// Throws [ArgumentError] when [predicates] is empty.
  factory HeimdallPredicate.anyOf(
    Iterable<HeimdallPredicate<T>> predicates, {
    String? description,
  }) {
    final predicateList = _nonEmptyPredicates(predicates);
    return HeimdallPredicate(
      description ?? predicateList.map((p) => p.description).join(' or '),
      (item, project) => predicateList.any((p) => p.test(item, project)),
    );
  }

  /// Creates a predicate that rejects every predicate in [predicates].
  ///
  /// Throws [ArgumentError] when [predicates] is empty.
  factory HeimdallPredicate.noneOf(
    Iterable<HeimdallPredicate<T>> predicates, {
    String? description,
  }) {
    final predicateList = _nonEmptyPredicates(predicates);
    return HeimdallPredicate(
      description ?? 'none of ${predicateList.map((p) => p.description).join(', ')}',
      (item, project) => predicateList.every((p) => !p.test(item, project)),
    );
  }

  /// Text used in generated rule descriptions.
  final String description;

  /// Selection callback.
  ///
  /// Return `true` to keep the item selected for the rule.
  final bool Function(T item, HeimdallProject project) test;

  /// Returns a predicate that requires both predicates to match.
  HeimdallPredicate<T> and(HeimdallPredicate<T> other) {
    return HeimdallPredicate(
      '($description and ${other.description})',
      (item, project) => test(item, project) && other.test(item, project),
    );
  }

  /// Returns a predicate that accepts either predicate.
  HeimdallPredicate<T> or(HeimdallPredicate<T> other) {
    return HeimdallPredicate(
      '($description or ${other.description})',
      (item, project) => test(item, project) || other.test(item, project),
    );
  }

  /// Returns a reusable predicate object with this predicate's result inverted.
  ///
  /// This differs from builder `.not()` methods, which only mark the next
  /// fluent DSL predicate call as negated.
  HeimdallPredicate<T> not() {
    return HeimdallPredicate(
      'not ($description)',
      (item, project) => !test(item, project),
    );
  }
}

List<HeimdallPredicate<T>> _nonEmptyPredicates<T>(
  Iterable<HeimdallPredicate<T>> predicates,
) {
  final predicateList = predicates.toList();
  if (predicateList.isEmpty) {
    throw ArgumentError.value(predicates, 'predicates', 'must not be empty');
  }
  return predicateList;
}
