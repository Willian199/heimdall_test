import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/class_features/helpers/declaration_condition.dart';

/// Predicate-side DSL for class method-count rules.
extension ClassMethodCountPredicateRules on ClassPredicateBuilder {
  /// Selects classes that declare exactly [count] methods.
  ClassPredicateBuilder haveMethodCount(int count) {
    return satisfy(
      HeimdallPredicate(
        'have method count $count',
        (item, _) => item.methods.length == count,
      ),
    );
  }

  /// Selects classes that do not declare exactly [count] methods.
  ClassPredicateBuilder haveMethodCountOtherThan(int count) {
    return satisfy(
      HeimdallPredicate(
        'not have method count $count',
        (item, _) => item.methods.length != count,
      ),
    );
  }

  /// Selects classes that declare more than [count] methods.
  ClassPredicateBuilder haveMoreThanMethods(int count) {
    return satisfy(
      HeimdallPredicate(
        'have more than $count methods',
        (item, _) => item.methods.length > count,
      ),
    );
  }

  /// Selects classes that declare [count] or fewer methods.
  ClassPredicateBuilder haveAtMostMethods(int count) {
    return satisfy(
      HeimdallPredicate(
        'have at most $count methods',
        (item, _) => item.methods.length <= count,
      ),
    );
  }
}

/// Condition-side DSL for class method-count rules.
extension ClassMethodCountShouldRules on ClassShouldBuilder {
  /// Requires classes to declare exactly [count] methods.
  HeimdallRule<CompilationUnitMember> haveMethodCount(int count) {
    return satisfy(
      declarationCondition(
        'have method count $count',
        (item) => item.methods.length == count,
      ),
    );
  }

  /// Requires classes not to declare exactly [count] methods.
  HeimdallRule<CompilationUnitMember> haveMethodCountOtherThan(int count) {
    return satisfy(
      declarationCondition(
        'not have method count $count',
        (item) => item.methods.length != count,
      ),
    );
  }

  /// Requires classes to declare more than [count] methods.
  HeimdallRule<CompilationUnitMember> haveMoreThanMethods(int count) {
    return satisfy(
      declarationCondition(
        'have more than $count methods',
        (item) => item.methods.length > count,
      ),
    );
  }

  /// Requires classes to declare [count] or fewer methods.
  HeimdallRule<CompilationUnitMember> haveAtMostMethods(int count) {
    return satisfy(
      declarationCondition(
        'have at most $count methods',
        (item) => item.methods.length <= count,
      ),
    );
  }
}
