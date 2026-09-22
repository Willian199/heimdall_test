import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/class_features/helpers/declaration_condition.dart';

/// Predicate-side DSL for class method-parameter count rules.
extension ClassMethodParameterCountPredicateRules on ClassPredicateBuilder {
  /// Selects classes whose methods declare exactly [count] total parameters.
  ClassPredicateBuilder haveMethodParameterCount(int count) {
    return satisfy(
      HeimdallPredicate(
        'have method parameter count $count',
        (item, _) => _methodParameterCount(item) == count,
      ),
    );
  }

  /// Selects classes whose methods do not declare exactly [count] total parameters.
  ClassPredicateBuilder haveMethodParameterCountOtherThan(int count) {
    return satisfy(
      HeimdallPredicate(
        'not have method parameter count $count',
        (item, _) => _methodParameterCount(item) != count,
      ),
    );
  }

  /// Selects classes whose methods declare more than [count] total parameters.
  ClassPredicateBuilder haveMoreThanMethodParameters(int count) {
    return satisfy(
      HeimdallPredicate(
        'have more than $count method parameters',
        (item, _) => _methodParameterCount(item) > count,
      ),
    );
  }

  /// Selects classes whose methods declare [count] or fewer total parameters.
  ClassPredicateBuilder haveAtMostMethodParameters(int count) {
    return satisfy(
      HeimdallPredicate(
        'have at most $count method parameters',
        (item, _) => _methodParameterCount(item) <= count,
      ),
    );
  }
}

/// Condition-side DSL for class method-parameter count rules.
extension ClassMethodParameterCountShouldRules on ClassShouldBuilder {
  /// Requires classes whose methods declare exactly [count] total parameters.
  HeimdallRule<CompilationUnitMember> haveMethodParameterCount(int count) {
    return satisfy(
      declarationCondition(
        'have method parameter count $count',
        (item) => _methodParameterCount(item) == count,
      ),
    );
  }

  /// Requires classes whose methods do not declare exactly [count] total parameters.
  HeimdallRule<CompilationUnitMember> haveMethodParameterCountOtherThan(int count) {
    return satisfy(
      declarationCondition(
        'not have method parameter count $count',
        (item) => _methodParameterCount(item) != count,
      ),
    );
  }

  /// Requires classes whose methods declare more than [count] total parameters.
  HeimdallRule<CompilationUnitMember> haveMoreThanMethodParameters(int count) {
    return satisfy(
      declarationCondition(
        'have more than $count method parameters',
        (item) => _methodParameterCount(item) > count,
      ),
    );
  }

  /// Requires classes whose methods declare [count] or fewer total parameters.
  HeimdallRule<CompilationUnitMember> haveAtMostMethodParameters(
    int count,
  ) {
    return satisfy(
      declarationCondition(
        'have at most $count method parameters',
        (item) => _methodParameterCount(item) <= count,
      ),
    );
  }
}

int _methodParameterCount(CompilationUnitMember item) {
  return item.methods.fold<int>(
    0,
    (count, method) => count + (method.parameters?.parameters.length ?? 0),
  );
}
