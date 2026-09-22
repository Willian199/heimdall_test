import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/core/behavior_rule/heimdall_rule.dart';
import 'package:heimdall_test/src/core/class_rules/class_predicate_builder.dart';
import 'package:heimdall_test/src/core/class_rules/class_should_builder.dart';
import 'package:heimdall_test/src/core/heimdall_condition.dart';
import 'package:heimdall_test/src/core/heimdall_predicate.dart';
import 'package:heimdall_test/src/core/non_empty_iterable.dart';
import 'package:heimdall_test/src/features/class_features/helpers/class_constructor_name_rule_helpers.dart';

/// Predicate-side DSL for constructor name regex rules.
extension ClassHaveConstructorNameMatchingPredicateRules on ClassPredicateBuilder {
  /// Selects classes that declare a constructor name matching [pattern].
  ClassPredicateBuilder declareConstructorWithNameMatching(RegExp pattern) {
    return satisfy(classHasConstructorName('matches ${pattern.pattern}', pattern.hasMatch));
  }

  /// Selects classes that do not declare a constructor name matching [pattern].
  ClassPredicateBuilder notDeclareConstructorWithNameMatching(RegExp pattern) {
    return satisfy(classDoesNotHaveConstructorName('matches ${pattern.pattern}', pattern.hasMatch));
  }

  /// Selects classes that declare constructor names matching every regex in [patterns].
  ClassPredicateBuilder declareConstructorWithNameMatchingAllOf(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.allOf(
        patternList.map((pattern) => classHasConstructorName('matches ${pattern.pattern}', pattern.hasMatch)),
        description: 'have all constructor names matching ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects classes that declare at least one constructor name matching [patterns].
  ClassPredicateBuilder declareConstructorWithNameMatchingAnyOf(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.anyOf(
        patternList.map((pattern) => classHasConstructorName('matches ${pattern.pattern}', pattern.hasMatch)),
        description: 'have any constructor name matching ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects classes that declare no constructor name matching [patterns].
  ClassPredicateBuilder declareConstructorWithNameMatchingNoneOf(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.noneOf(
        patternList.map((pattern) => classHasConstructorName('matches ${pattern.pattern}', pattern.hasMatch)),
        description: 'have no constructor name matching ${patternList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for constructor name regex rules.
extension ClassHaveConstructorNameMatchingShouldRules on ClassShouldBuilder {
  /// Requires matching classes to declare a constructor name matching [pattern].
  HeimdallRule<CompilationUnitMember> declareConstructorWithNameMatching(
    RegExp pattern,
  ) {
    return satisfy(classShouldHaveConstructorName('matches ${pattern.pattern}', pattern.hasMatch));
  }

  /// Requires matching classes to not declare a constructor name matching [pattern].
  HeimdallRule<CompilationUnitMember> notDeclareConstructorWithNameMatching(
    RegExp pattern,
  ) {
    return satisfy(classShouldNotHaveConstructorName('matches ${pattern.pattern}', pattern.hasMatch));
  }

  /// Requires matching classes to declare constructor names matching every regex in [patterns].
  HeimdallRule<CompilationUnitMember> declareConstructorWithNameMatchingAllOf(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        patternList.map((pattern) => classShouldHaveConstructorName('matches ${pattern.pattern}', pattern.hasMatch)),
        description: 'have all constructor names matching ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to declare at least one constructor name matching [patterns].
  HeimdallRule<CompilationUnitMember> declareConstructorWithNameMatchingAnyOf(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        patternList.map((pattern) => classShouldHaveConstructorName('matches ${pattern.pattern}', pattern.hasMatch)),
        description: 'have any constructor name matching ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to declare no constructor name matching [patterns].
  HeimdallRule<CompilationUnitMember> declareConstructorWithNameMatchingNoneOf(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.noneOf(
        patternList.map((pattern) => classShouldHaveConstructorName('matches ${pattern.pattern}', pattern.hasMatch)),
        description: 'have no constructor name matching ${patternList.join(', ')}',
      ),
    );
  }
}
