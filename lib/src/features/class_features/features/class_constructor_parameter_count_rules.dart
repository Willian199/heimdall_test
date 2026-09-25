import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/class_features/helpers/declaration_condition.dart';

/// Predicate-side DSL for class constructor-parameter count rules.
extension ClassConstructorParameterCountPredicateRules on ClassPredicateBuilder {
  /// Selects classes whose constructors declare exactly [count] total parameters.
  ClassPredicateBuilder haveConstructorParameterCount(int count) {
    return satisfy(
      HeimdallPredicate(
        'have constructor parameter count $count',
        (item, _) => _constructorParameterCount(item) == count,
      ),
    );
  }

  /// Selects classes whose constructors do not declare exactly [count] total parameters.
  ClassPredicateBuilder haveConstructorParameterCountOtherThan(int count) {
    return satisfy(
      HeimdallPredicate(
        'not have constructor parameter count $count',
        (item, _) => _constructorParameterCount(item) != count,
      ),
    );
  }

  /// Selects classes whose constructors declare more than [count] total parameters.
  ClassPredicateBuilder haveMoreThanConstructorParameters(int count) {
    return satisfy(
      HeimdallPredicate(
        'have more than $count constructor parameters',
        (item, _) => _constructorParameterCount(item) > count,
      ),
    );
  }

  /// Selects classes whose constructors declare [count] or fewer total parameters.
  ClassPredicateBuilder haveAtMostConstructorParameters(int count) {
    return satisfy(
      HeimdallPredicate(
        'have at most $count constructor parameters',
        (item, _) => _constructorParameterCount(item) <= count,
      ),
    );
  }
}

/// Condition-side DSL for class constructor-parameter count rules.
extension ClassConstructorParameterCountShouldRules on ClassShouldBuilder {
  /// Requires classes whose constructors declare exactly [count] total parameters.
  HeimdallRule<CompilationUnitMember> haveConstructorParameterCount(int count) {
    return satisfy(
      declarationCondition(
        'have constructor parameter count $count',
        (item) => _constructorParameterCount(item) == count,
      ),
    );
  }

  /// Requires classes whose constructors do not declare exactly [count] total parameters.
  HeimdallRule<CompilationUnitMember> haveConstructorParameterCountOtherThan(
    int count,
  ) {
    return satisfy(
      declarationCondition(
        'not have constructor parameter count $count',
        (item) => _constructorParameterCount(item) != count,
      ),
    );
  }

  /// Requires classes whose constructors declare more than [count] total parameters.
  HeimdallRule<CompilationUnitMember> haveMoreThanConstructorParameters(
    int count,
  ) {
    return satisfy(
      declarationCondition(
        'have more than $count constructor parameters',
        (item) => _constructorParameterCount(item) > count,
      ),
    );
  }

  /// Requires classes whose constructors declare [count] or fewer total parameters.
  HeimdallRule<CompilationUnitMember> haveAtMostConstructorParameters(
    int count,
  ) {
    return satisfy(
      declarationCondition(
        'have at most $count constructor parameters',
        (item) => _constructorParameterCount(item) <= count,
      ),
    );
  }
}

int _constructorParameterCount(CompilationUnitMember item) {
  return item.constructorParameterCount;
}
