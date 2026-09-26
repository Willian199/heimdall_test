import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/executable_syntax_queries.dart';

/// Predicate-side contain expression rules.
extension MemberContainExpressionPredicateRules on MemberPredicateBuilder {
  /// Matches the specified syntax.
  MemberPredicateBuilder containExpression(String expression) => satisfy(_matches(expression));

  /// Rejects the specified syntax.
  MemberPredicateBuilder notContainExpression(String expression) => satisfy(_matches(expression, prohibited: true));

  /// Matches all of [expressions].
  MemberPredicateBuilder containAllExpressions(Iterable<String> expressions) {
    final values = expressions.toNonEmptyList('expressions');
    return satisfy(HeimdallPredicate.allOf(values.map(_matches)));
  }

  /// Matches any of [expressions].
  MemberPredicateBuilder containAnyExpression(Iterable<String> expressions) {
    final values = expressions.toNonEmptyList('expressions');
    return satisfy(HeimdallPredicate.anyOf(values.map(_matches)));
  }

  /// Matches none of [expressions].
  MemberPredicateBuilder containNoExpressions(Iterable<String> expressions) {
    final values = expressions.toNonEmptyList('expressions');
    return satisfy(HeimdallPredicate.noneOf(values.map(_matches)));
  }
}

/// Should-side contain expression rules.
extension MemberContainExpressionShouldRules on MemberShouldBuilder {
  /// Matches the specified syntax.
  HeimdallRule<ClassMember> containExpression(String expression) => satisfy(_requires(expression));

  /// Rejects the specified syntax.
  HeimdallRule<ClassMember> notContainExpression(String expression) => satisfy(_requires(expression, prohibited: true));

  /// Matches all of [expressions].
  HeimdallRule<ClassMember> containAllExpressions(Iterable<String> expressions) {
    final values = expressions.toNonEmptyList('expressions');
    return satisfy(HeimdallCondition.allOf(values.map(_requires)));
  }

  /// Matches any of [expressions].
  HeimdallRule<ClassMember> containAnyExpression(Iterable<String> expressions) {
    final values = expressions.toNonEmptyList('expressions');
    return satisfy(HeimdallCondition.anyOf(values.map(_requires)));
  }

  /// Matches none of [expressions].
  HeimdallRule<ClassMember> containNoExpressions(Iterable<String> expressions) {
    final values = expressions.toNonEmptyList('expressions');
    return satisfy(HeimdallCondition.noneOf(values.map(_requires)));
  }
}

HeimdallPredicate<ClassMember> _matches(
  String expression, {
  bool prohibited = false,
}) {
  final match = expressionMatcher(expression);
  return HeimdallPredicate(
    '${prohibited ? 'not ' : ''}contain expression $expression',
    (item, project) => prohibited ? !hasSyntaxMatch(item, project, match) : hasSyntaxMatch(item, project, match),
  );
}

HeimdallCondition<ClassMember> _requires(
  String expression, {
  bool prohibited = false,
}) {
  final match = expressionMatcher(expression);
  return syntaxCondition('${prohibited ? 'not ' : ''}contain expression $expression', match, prohibited: prohibited);
}
