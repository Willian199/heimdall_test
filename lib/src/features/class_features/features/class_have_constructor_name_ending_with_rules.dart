import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/core/behavior_rule/heimdall_rule.dart';
import 'package:heimdall_test/src/core/class_rules/class_predicate_builder.dart';
import 'package:heimdall_test/src/core/class_rules/class_should_builder.dart';
import 'package:heimdall_test/src/core/heimdall_condition.dart';
import 'package:heimdall_test/src/core/heimdall_predicate.dart';
import 'package:heimdall_test/src/core/non_empty_iterable.dart';
import 'package:heimdall_test/src/features/class_features/helpers/class_constructor_name_rule_helpers.dart';

/// Predicate-side DSL for constructor name suffix rules.
extension ClassHaveConstructorNameEndingWithPredicateRules on ClassPredicateBuilder {
  /// Selects classes that declare a constructor name ending with [suffix].
  ClassPredicateBuilder haveConstructorNameEndingWith(String suffix) {
    return satisfy(classHasConstructorName('ends with $suffix', (item) => item.endsWith(suffix)));
  }

  /// Selects classes that do not declare a constructor name ending with [suffix].
  ClassPredicateBuilder noHaveConstructorNameEndingWith(String suffix) {
    return satisfy(classDoesNotHaveConstructorName('ends with $suffix', (item) => item.endsWith(suffix)));
  }

  /// Selects classes that declare constructor names ending with every suffix in [suffixes].
  ClassPredicateBuilder haveConstructorNameEndingWithAll(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.allOf(
        suffixList.map((suffix) => classHasConstructorName('ends with $suffix', (item) => item.endsWith(suffix))),
        description: 'have all constructor names ending with ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects classes that declare at least one constructor name ending with [suffixes].
  ClassPredicateBuilder haveConstructorNameEndingWithAny(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        suffixList.map((suffix) => classHasConstructorName('ends with $suffix', (item) => item.endsWith(suffix))),
        description: 'have any constructor name ending with ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects classes that declare no constructor name ending with [suffixes].
  ClassPredicateBuilder haveConstructorNameEndingWithNone(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        suffixList.map((suffix) => classHasConstructorName('ends with $suffix', (item) => item.endsWith(suffix))),
        description: 'have no constructor name ending with ${suffixList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for constructor name suffix rules.
extension ClassHaveConstructorNameEndingWithShouldRules on ClassShouldBuilder {
  /// Requires matching classes to declare a constructor name ending with [suffix].
  HeimdallRule<CompilationUnitMember> haveConstructorNameEndingWith(
    String suffix,
  ) {
    return satisfy(classShouldHaveConstructorName('ends with $suffix', (item) => item.endsWith(suffix)));
  }

  /// Requires matching classes to not declare a constructor name ending with [suffix].
  HeimdallRule<CompilationUnitMember> noHaveConstructorNameEndingWith(
    String suffix,
  ) {
    return satisfy(classShouldNotHaveConstructorName('ends with $suffix', (item) => item.endsWith(suffix)));
  }

  /// Requires matching classes to declare constructor names ending with every suffix in [suffixes].
  HeimdallRule<CompilationUnitMember> haveConstructorNameEndingWithAll(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.allOf(
        suffixList.map((suffix) => classShouldHaveConstructorName('ends with $suffix', (item) => item.endsWith(suffix))),
        description: 'have all constructor names ending with ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to declare at least one constructor name ending with [suffixes].
  HeimdallRule<CompilationUnitMember> haveConstructorNameEndingWithAny(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.anyOf(
        suffixList.map((suffix) => classShouldHaveConstructorName('ends with $suffix', (item) => item.endsWith(suffix))),
        description: 'have any constructor name ending with ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to declare no constructor name ending with [suffixes].
  HeimdallRule<CompilationUnitMember> haveConstructorNameEndingWithNone(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.noneOf(
        suffixList.map((suffix) => classShouldHaveConstructorName('ends with $suffix', (item) => item.endsWith(suffix))),
        description: 'have no constructor name ending with ${suffixList.join(', ')}',
      ),
    );
  }
}
