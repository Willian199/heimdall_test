import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/core/behavior_rule/heimdall_rule.dart';
import 'package:heimdall_test/src/core/class_rules/class_predicate_builder.dart';
import 'package:heimdall_test/src/core/class_rules/class_should_builder.dart';
import 'package:heimdall_test/src/core/heimdall_condition.dart';
import 'package:heimdall_test/src/core/heimdall_predicate.dart';
import 'package:heimdall_test/src/core/non_empty_iterable.dart';
import 'package:heimdall_test/src/features/class_features/helpers/class_constructor_name_rule_helpers.dart';

/// Predicate-side DSL for exact constructor name rules.
extension ClassHaveConstructorNamePredicateRules on ClassPredicateBuilder {
  /// Selects classes that declare a constructor named [name].
  ClassPredicateBuilder haveConstructorName(String name) {
    return satisfy(classHasConstructorName('equals $name', (item) => item == name));
  }

  /// Selects classes that do not declare a constructor named [name].
  ClassPredicateBuilder noHaveConstructorName(String name) {
    return satisfy(classDoesNotHaveConstructorName('equals $name', (item) => item == name));
  }

  /// Selects classes that declare constructors for every name in [names].
  ClassPredicateBuilder haveConstructorNameAll(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.allOf(
        nameList.map((name) => classHasConstructorName('equals $name', (item) => item == name)),
        description: 'have all constructor names ${nameList.join(', ')}',
      ),
    );
  }

  /// Selects classes that declare at least one constructor in [names].
  ClassPredicateBuilder haveConstructorNameAny(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.anyOf(
        nameList.map((name) => classHasConstructorName('equals $name', (item) => item == name)),
        description: 'have any constructor name ${nameList.join(', ')}',
      ),
    );
  }

  /// Selects classes that declare none of the constructors in [names].
  ClassPredicateBuilder haveConstructorNameNone(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.noneOf(
        nameList.map((name) => classHasConstructorName('equals $name', (item) => item == name)),
        description: 'have no constructor name ${nameList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for exact constructor name rules.
extension ClassHaveConstructorNameShouldRules on ClassShouldBuilder {
  /// Requires matching classes to declare a constructor named [name].
  HeimdallRule<CompilationUnitMember> haveConstructorName(String name) {
    return satisfy(classShouldHaveConstructorName('equals $name', (item) => item == name));
  }

  /// Requires matching classes to not declare a constructor named [name].
  HeimdallRule<CompilationUnitMember> noHaveConstructorName(String name) {
    return satisfy(classShouldNotHaveConstructorName('equals $name', (item) => item == name));
  }

  /// Requires matching classes to declare constructors for every name in [names].
  HeimdallRule<CompilationUnitMember> haveConstructorNameAll(
    Iterable<String> names,
  ) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.allOf(
        nameList.map((name) => classShouldHaveConstructorName('equals $name', (item) => item == name)),
        description: 'have all constructor names ${nameList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to declare at least one constructor in [names].
  HeimdallRule<CompilationUnitMember> haveConstructorNameAny(
    Iterable<String> names,
  ) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.anyOf(
        nameList.map((name) => classShouldHaveConstructorName('equals $name', (item) => item == name)),
        description: 'have any constructor name ${nameList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to declare none of the constructors in [names].
  HeimdallRule<CompilationUnitMember> haveConstructorNameNone(
    Iterable<String> names,
  ) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.noneOf(
        nameList.map((name) => classShouldHaveConstructorName('equals $name', (item) => item == name)),
        description: 'have no constructor name ${nameList.join(', ')}',
      ),
    );
  }
}
