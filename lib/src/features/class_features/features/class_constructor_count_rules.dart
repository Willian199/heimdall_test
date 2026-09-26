import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/class_features/helpers/declaration_condition.dart';

/// Predicate-side DSL for class constructor-count rules.
extension ClassConstructorCountPredicateRules on ClassPredicateBuilder {
  /// Selects classes that declare exactly [count] constructors.
  ClassPredicateBuilder haveConstructorCount(int count) {
    return satisfy(
      HeimdallPredicate(
        'have constructor count $count',
        (item, _) => item.constructorCount == count,
      ),
    );
  }

  /// Selects classes that do not declare exactly [count] constructors.
  ClassPredicateBuilder haveConstructorCountOtherThan(int count) {
    return satisfy(
      HeimdallPredicate(
        'not have constructor count $count',
        (item, _) => item.constructorCount != count,
      ),
    );
  }

  /// Selects classes that declare more than [count] constructors.
  ClassPredicateBuilder haveMoreThanConstructors(int count) {
    return satisfy(
      HeimdallPredicate(
        'have more than $count constructors',
        (item, _) => item.constructorCount > count,
      ),
    );
  }

  /// Selects classes that declare [count] or fewer constructors.
  ClassPredicateBuilder haveAtMostConstructors(int count) {
    return satisfy(
      HeimdallPredicate(
        'have at most $count constructors',
        (item, _) => item.constructorCount <= count,
      ),
    );
  }
}

/// Condition-side DSL for class constructor-count rules.
extension ClassConstructorCountShouldRules on ClassShouldBuilder {
  /// Requires classes to declare exactly [count] constructors.
  HeimdallRule<CompilationUnitMember> haveConstructorCount(int count) {
    return satisfy(
      declarationCondition(
        'have constructor count $count',
        (item) => item.constructorCount == count,
      ),
    );
  }

  /// Requires classes not to declare exactly [count] constructors.
  HeimdallRule<CompilationUnitMember> haveConstructorCountOtherThan(int count) {
    return satisfy(
      declarationCondition(
        'not have constructor count $count',
        (item) => item.constructorCount != count,
      ),
    );
  }

  /// Requires classes to declare more than [count] constructors.
  HeimdallRule<CompilationUnitMember> haveMoreThanConstructors(int count) {
    return satisfy(
      declarationCondition(
        'have more than $count constructors',
        (item) => item.constructorCount > count,
      ),
    );
  }

  /// Requires classes to declare [count] or fewer constructors.
  HeimdallRule<CompilationUnitMember> haveAtMostConstructors(int count) {
    return satisfy(
      declarationCondition(
        'have at most $count constructors',
        (item) => item.constructorCount <= count,
      ),
    );
  }
}
