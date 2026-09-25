import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/class_features/helpers/declaration_condition.dart';

/// Predicate-side DSL for class executable code-unit count rules.
extension ClassCodeUnitCountPredicateRules on ClassPredicateBuilder {
  /// Selects classes that declare exactly [count] executable code units.
  ClassPredicateBuilder haveCodeUnitCount(int count) {
    return satisfy(
      HeimdallPredicate(
        'have code unit count $count',
        (item, _) => _codeUnitCount(item) == count,
      ),
    );
  }

  /// Selects classes that do not declare exactly [count] executable code units.
  ClassPredicateBuilder haveCodeUnitCountOtherThan(int count) {
    return satisfy(
      HeimdallPredicate(
        'not have code unit count $count',
        (item, _) => _codeUnitCount(item) != count,
      ),
    );
  }

  /// Selects classes that declare more than [count] executable code units.
  ClassPredicateBuilder haveMoreThanCodeUnits(int count) {
    return satisfy(
      HeimdallPredicate(
        'have more than $count code units',
        (item, _) => _codeUnitCount(item) > count,
      ),
    );
  }

  /// Selects classes that declare [count] or fewer executable code units.
  ClassPredicateBuilder haveAtMostCodeUnits(int count) {
    return satisfy(
      HeimdallPredicate(
        'have at most $count code units',
        (item, _) => _codeUnitCount(item) <= count,
      ),
    );
  }
}

/// Condition-side DSL for class executable code-unit count rules.
extension ClassCodeUnitCountShouldRules on ClassShouldBuilder {
  /// Requires classes to declare exactly [count] executable code units.
  HeimdallRule<CompilationUnitMember> haveCodeUnitCount(int count) {
    return satisfy(
      declarationCondition(
        'have code unit count $count',
        (item) => _codeUnitCount(item) == count,
      ),
    );
  }

  /// Requires classes not to declare exactly [count] executable code units.
  HeimdallRule<CompilationUnitMember> haveCodeUnitCountOtherThan(int count) {
    return satisfy(
      declarationCondition(
        'not have code unit count $count',
        (item) => _codeUnitCount(item) != count,
      ),
    );
  }

  /// Requires classes to declare more than [count] executable code units.
  HeimdallRule<CompilationUnitMember> haveMoreThanCodeUnits(int count) {
    return satisfy(
      declarationCondition(
        'have more than $count code units',
        (item) => _codeUnitCount(item) > count,
      ),
    );
  }

  /// Requires classes to declare [count] or fewer executable code units.
  HeimdallRule<CompilationUnitMember> haveAtMostCodeUnits(int count) {
    return satisfy(
      declarationCondition(
        'have at most $count code units',
        (item) => _codeUnitCount(item) <= count,
      ),
    );
  }
}

int _codeUnitCount(CompilationUnitMember item) {
  return item.methods.length + item.constructorCount;
}
