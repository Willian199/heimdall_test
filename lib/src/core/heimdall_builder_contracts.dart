import 'package:heimdall_test/heimdall_test.dart';

/// Common contract for DSL entry points such as class, file, and member rules.
abstract interface class HeimdallRules<TPredicateBuilder, TShouldBuilder> {
  /// Starts a predicate selection chain.
  ///
  /// Predicates filter the rule scope before conditions are evaluated.
  TPredicateBuilder that();

  /// Starts a condition chain over every item in this rule family.
  ///
  /// Call this directly when no additional `.that()` filtering is needed.
  TShouldBuilder should();
}

/// Common contract for DSL builders that select items.
abstract interface class HeimdallPredicateBuilder<TItem, TSelf, TShouldBuilder> {
  /// Combines the next predicate with logical `and`.
  TSelf and();

  /// Combines the next predicate with logical `or`.
  TSelf or();

  /// Negates only the next predicate added to this fluent chain.
  ///
  /// This is builder state for inline DSL usage. Use [HeimdallPredicate.not]
  /// when composing a reusable predicate object outside the builder.
  TSelf not();

  /// Adds a custom predicate to the selection.
  ///
  /// The predicate is combined with the previously selected predicates using
  /// the current builder operator, which defaults to `and`.
  TSelf satisfy(HeimdallPredicate<TItem> predicate);

  /// Starts the condition chain.
  TShouldBuilder should();
}

/// Common contract for DSL builders that assert conditions.
abstract interface class HeimdallShouldBuilder<TItem, TSelf> {
  /// Combines the next condition with logical `and`.
  TSelf andShould();

  /// Combines the next condition with logical `or`.
  TSelf orShould();

  /// Negates only the next condition added to this fluent chain.
  ///
  /// This is builder state for inline DSL usage. Use [HeimdallCondition.not]
  /// when composing a reusable condition object outside the builder.
  TSelf not();

  /// Adds a custom condition and builds the executable rule.
  ///
  /// Conditions validate items selected by the scope and predicate chain.
  HeimdallRule<TItem> satisfy(HeimdallCondition<TItem> condition);
}
