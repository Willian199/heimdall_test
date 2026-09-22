import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/executable_syntax_queries.dart';

/// Predicate-side DSL for scoped executable syntax.
///
/// Matches `!` regardless of the operand's declared type. It does not resolve
/// types or prove that a value is non-null.
extension MemberContainNullAssertionPredicateRules on MemberPredicateBuilder {
  /// Selects members that match this syntax.
  /// Includes nested closures; no control-flow safety inference is performed.
  MemberPredicateBuilder containNullAssertion() {
    const match = isNullAssertion;
    return satisfy(HeimdallPredicate('contain a null assertion', (item, _) => scopedExpressions(item).any(match)));
  }

  /// Selects members that do not match this syntax.
  /// Includes nested closures; no control-flow safety inference is performed.
  MemberPredicateBuilder notContainNullAssertion() {
    const match = isNullAssertion;
    return satisfy(HeimdallPredicate('not contain a null assertion', (item, _) => !scopedExpressions(item).any(match)));
  }
}

/// Should-side DSL for scoped executable syntax.
///
/// Matches `!` regardless of the operand's declared type. It does not resolve
/// types or prove that a value is non-null.
extension MemberContainNullAssertionShouldRules on MemberShouldBuilder {
  /// Requires members that match this syntax.
  /// Includes nested closures; no control-flow safety inference is performed.
  HeimdallRule<ClassMember> containNullAssertion() {
    const match = isNullAssertion;
    return satisfy(syntaxCondition('contain a null assertion', match));
  }

  /// Requires members that do not match this syntax.
  /// Includes nested closures; no control-flow safety inference is performed.
  HeimdallRule<ClassMember> notContainNullAssertion() {
    const match = isNullAssertion;
    return satisfy(syntaxCondition('not contain a null assertion', match, prohibited: true));
  }
}
