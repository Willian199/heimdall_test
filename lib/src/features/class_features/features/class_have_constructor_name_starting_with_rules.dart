import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/core/behavior_rule/heimdall_rule.dart';
import 'package:heimdall_test/src/core/class_rules/class_predicate_builder.dart';
import 'package:heimdall_test/src/core/class_rules/class_should_builder.dart';
import 'package:heimdall_test/src/core/heimdall_condition.dart';
import 'package:heimdall_test/src/core/heimdall_predicate.dart';
import 'package:heimdall_test/src/core/non_empty_iterable.dart';
import 'package:heimdall_test/src/features/class_features/helpers/class_constructor_name_rule_helpers.dart';

/// Predicate-side DSL for constructor name prefix rules.
extension ClassHaveConstructorNameStartingWithPredicateRules on ClassPredicateBuilder {
  /// Selects classes that declare a constructor name starting with [prefix].
  ClassPredicateBuilder haveConstructorNameStartingWith(String prefix) {
    return satisfy(classHasConstructorName('starts with $prefix', (item) => item.startsWith(prefix)));
  }

  /// Selects classes that do not declare a constructor name starting with [prefix].
  ClassPredicateBuilder noHaveConstructorNameStartingWith(String prefix) {
    return satisfy(classDoesNotHaveConstructorName('starts with $prefix', (item) => item.startsWith(prefix)));
  }

  /// Selects classes that declare constructor names starting with every prefix in [prefixes].
  ClassPredicateBuilder haveConstructorNameStartingWithAll(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.allOf(
        prefixList.map((prefix) => classHasConstructorName('starts with $prefix', (item) => item.startsWith(prefix))),
        description: 'have all constructor names starting with ${prefixList.join(', ')}',
      ),
    );
  }

  /// Selects classes that declare at least one constructor name starting with [prefixes].
  ClassPredicateBuilder haveConstructorNameStartingWithAny(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        prefixList.map((prefix) => classHasConstructorName('starts with $prefix', (item) => item.startsWith(prefix))),
        description: 'have any constructor name starting with ${prefixList.join(', ')}',
      ),
    );
  }

  /// Selects classes that declare no constructor name starting with [prefixes].
  ClassPredicateBuilder haveConstructorNameStartingWithNone(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        prefixList.map((prefix) => classHasConstructorName('starts with $prefix', (item) => item.startsWith(prefix))),
        description: 'have no constructor name starting with ${prefixList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for constructor name prefix rules.
extension ClassHaveConstructorNameStartingWithShouldRules on ClassShouldBuilder {
  /// Requires matching classes to declare a constructor name starting with [prefix].
  HeimdallRule<CompilationUnitMember> haveConstructorNameStartingWith(
    String prefix,
  ) {
    return satisfy(classShouldHaveConstructorName('starts with $prefix', (item) => item.startsWith(prefix)));
  }

  /// Requires matching classes to not declare a constructor name starting with [prefix].
  HeimdallRule<CompilationUnitMember> noHaveConstructorNameStartingWith(
    String prefix,
  ) {
    return satisfy(classShouldNotHaveConstructorName('starts with $prefix', (item) => item.startsWith(prefix)));
  }

  /// Requires matching classes to declare constructor names starting with every prefix in [prefixes].
  HeimdallRule<CompilationUnitMember> haveConstructorNameStartingWithAll(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.allOf(
        prefixList.map((prefix) => classShouldHaveConstructorName('starts with $prefix', (item) => item.startsWith(prefix))),
        description: 'have all constructor names starting with ${prefixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to declare at least one constructor name starting with [prefixes].
  HeimdallRule<CompilationUnitMember> haveConstructorNameStartingWithAny(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.anyOf(
        prefixList.map((prefix) => classShouldHaveConstructorName('starts with $prefix', (item) => item.startsWith(prefix))),
        description: 'have any constructor name starting with ${prefixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to declare no constructor name starting with [prefixes].
  HeimdallRule<CompilationUnitMember> haveConstructorNameStartingWithNone(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.noneOf(
        prefixList.map((prefix) => classShouldHaveConstructorName('starts with $prefix', (item) => item.startsWith(prefix))),
        description: 'have no constructor name starting with ${prefixList.join(', ')}',
      ),
    );
  }
}
