import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/class_features/helpers/declaration_condition.dart';

/// Predicate-side DSL for class field-count rules.
extension ClassFieldCountPredicateRules on ClassPredicateBuilder {
  /// Selects classes that declare exactly [count] instance fields.
  ClassPredicateBuilder haveFieldCount(int count) {
    return satisfy(
      HeimdallPredicate(
        'have field count $count',
        (item, _) => _fieldCount(item) == count,
      ),
    );
  }

  /// Selects classes that do not declare exactly [count] instance fields.
  ClassPredicateBuilder haveFieldCountOtherThan(int count) {
    return satisfy(
      HeimdallPredicate(
        'not have field count $count',
        (item, _) => _fieldCount(item) != count,
      ),
    );
  }

  /// Selects classes that declare more than [count] instance fields.
  ClassPredicateBuilder haveMoreThanFields(int count) {
    return satisfy(
      HeimdallPredicate(
        'have more than $count fields',
        (item, _) => _fieldCount(item) > count,
      ),
    );
  }

  /// Selects classes that declare [count] or fewer instance fields.
  ClassPredicateBuilder haveAtMostFields(int count) {
    return satisfy(
      HeimdallPredicate(
        'have at most $count fields',
        (item, _) => _fieldCount(item) <= count,
      ),
    );
  }
}

/// Condition-side DSL for class field-count rules.
extension ClassFieldCountShouldRules on ClassShouldBuilder {
  /// Requires classes to declare exactly [count] instance fields.
  HeimdallRule<CompilationUnitMember> haveFieldCount(int count) {
    return satisfy(
      declarationCondition(
        'have field count $count',
        (item) => _fieldCount(item) == count,
      ),
    );
  }

  /// Requires classes not to declare exactly [count] instance fields.
  HeimdallRule<CompilationUnitMember> haveFieldCountOtherThan(int count) {
    return satisfy(
      declarationCondition(
        'not have field count $count',
        (item) => _fieldCount(item) != count,
      ),
    );
  }

  /// Requires classes to declare more than [count] instance fields.
  HeimdallRule<CompilationUnitMember> haveMoreThanFields(int count) {
    return satisfy(
      declarationCondition(
        'have more than $count fields',
        (item) => _fieldCount(item) > count,
      ),
    );
  }

  /// Requires classes to declare [count] or fewer instance fields.
  HeimdallRule<CompilationUnitMember> haveAtMostFields(int count) {
    return satisfy(
      declarationCondition(
        'have at most $count fields',
        (item) => _fieldCount(item) <= count,
      ),
    );
  }
}

int _fieldCount(CompilationUnitMember item) {
  return item.fields
      .where((field) => !field.isStatic)
      .fold<int>(
        0,
        (count, field) => count + field.fields.variables.length,
      );
}
