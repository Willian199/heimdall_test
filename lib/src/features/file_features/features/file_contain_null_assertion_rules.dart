import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/executable_syntax_queries.dart';

/// Predicate-side DSL for scoped executable syntax.
///
/// Matches `!` regardless of the operand's declared type. It does not resolve
/// types or prove that a value is non-null.
extension FileContainNullAssertionPredicateRules on FilePredicateBuilder {
  /// Selects files that match this syntax.
  /// Includes nested closures; no control-flow safety inference is performed.
  FilePredicateBuilder containNullAssertion() {
    const match = isNullAssertion;
    return satisfy(HeimdallPredicate('contain a null assertion', (item, _) => scopedExpressions(item).any(match)));
  }

  /// Selects files that do not match this syntax.
  /// Includes nested closures; no control-flow safety inference is performed.
  FilePredicateBuilder notContainNullAssertion() {
    const match = isNullAssertion;
    return satisfy(HeimdallPredicate('not contain a null assertion', (item, _) => !scopedExpressions(item).any(match)));
  }
}

/// Should-side DSL for scoped executable syntax.
///
/// Matches `!` regardless of the operand's declared type. It does not resolve
/// types or prove that a value is non-null.
extension FileContainNullAssertionShouldRules on FileShouldBuilder {
  /// Requires files that match this syntax.
  /// Includes nested closures; no control-flow safety inference is performed.
  HeimdallRule<HeimdallSourceFile> containNullAssertion() {
    const match = isNullAssertion;
    return satisfy(syntaxCondition('contain a null assertion', match));
  }

  /// Requires files that do not match this syntax.
  /// Includes nested closures; no control-flow safety inference is performed.
  HeimdallRule<HeimdallSourceFile> notContainNullAssertion() {
    const match = isNullAssertion;
    return satisfy(syntaxCondition('not contain a null assertion', match, prohibited: true));
  }
}
