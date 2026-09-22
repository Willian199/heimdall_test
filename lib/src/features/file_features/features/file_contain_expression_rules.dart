import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/executable_syntax_queries.dart';

/// Predicate-side contain expression rules.
extension FileContainExpressionPredicateRules on FilePredicateBuilder {
  /// Matches the specified syntax.
  FilePredicateBuilder containExpression(String expression) => satisfy(_matches(expression));

  /// Rejects the specified syntax.
  FilePredicateBuilder notContainExpression(String expression) => satisfy(_matches(expression, prohibited: true));

  /// Matches all of [expressions].
  FilePredicateBuilder containAllExpressions(Iterable<String> expressions) {
    final values = expressions.toNonEmptyList('expressions');
    return satisfy(HeimdallPredicate.allOf(values.map(_matches)));
  }

  /// Matches any of [expressions].
  FilePredicateBuilder containAnyExpression(Iterable<String> expressions) {
    final values = expressions.toNonEmptyList('expressions');
    return satisfy(HeimdallPredicate.anyOf(values.map(_matches)));
  }

  /// Matches none of [expressions].
  FilePredicateBuilder containNoExpressions(Iterable<String> expressions) {
    final values = expressions.toNonEmptyList('expressions');
    return satisfy(HeimdallPredicate.noneOf(values.map(_matches)));
  }
}

/// Should-side contain expression rules.
extension FileContainExpressionShouldRules on FileShouldBuilder {
  /// Matches the specified syntax.
  HeimdallRule<HeimdallSourceFile> containExpression(String expression) => satisfy(_requires(expression));

  /// Rejects the specified syntax.
  HeimdallRule<HeimdallSourceFile> notContainExpression(String expression) => satisfy(_requires(expression, prohibited: true));

  /// Matches all of [expressions].
  HeimdallRule<HeimdallSourceFile> containAllExpressions(Iterable<String> expressions) {
    final values = expressions.toNonEmptyList('expressions');
    return satisfy(HeimdallCondition.allOf(values.map(_requires)));
  }

  /// Matches any of [expressions].
  HeimdallRule<HeimdallSourceFile> containAnyExpression(Iterable<String> expressions) {
    final values = expressions.toNonEmptyList('expressions');
    return satisfy(HeimdallCondition.anyOf(values.map(_requires)));
  }

  /// Matches none of [expressions].
  HeimdallRule<HeimdallSourceFile> containNoExpressions(Iterable<String> expressions) {
    final values = expressions.toNonEmptyList('expressions');
    return satisfy(HeimdallCondition.noneOf(values.map(_requires)));
  }
}

HeimdallPredicate<HeimdallSourceFile> _matches(
  String expression, {
  bool prohibited = false,
}) {
  final match = expressionMatcher(expression);
  return HeimdallPredicate(
    '${prohibited ? 'not ' : ''}contain expression $expression',
    (item, _) => prohibited ? !scopedExpressions(item).any(match) : scopedExpressions(item).any(match),
  );
}

HeimdallCondition<HeimdallSourceFile> _requires(
  String expression, {
  bool prohibited = false,
}) {
  final match = expressionMatcher(expression);
  return syntaxCondition('${prohibited ? 'not ' : ''}contain expression $expression', match, prohibited: prohibited);
}
