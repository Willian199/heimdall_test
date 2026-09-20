import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/core/behavior_rule/heimdall_rule.dart';
import 'package:heimdall_test/src/core/heimdall_condition.dart';
import 'package:heimdall_test/src/core/heimdall_predicate.dart';
import 'package:heimdall_test/src/core/member_rules/member_predicate_builder.dart';
import 'package:heimdall_test/src/core/member_rules/member_should_builder.dart';
import 'package:heimdall_test/src/core/non_empty_iterable.dart';
import 'package:heimdall_test/src/features/member_features/helpers/member_declared_type_name_rule_helpers.dart';

/// Predicate-side DSL for field declared type-name pattern rules.
extension MemberHaveDeclaredTypeNameMatchingPredicateRules on MemberPredicateBuilder {
  /// Selects fields whose declared type name matches [pattern].
  MemberPredicateBuilder haveDeclaredTypeNameMatching(RegExp pattern) {
    return satisfy(
      memberDeclaredTypeNamePredicate(
        'have declared type name matching $pattern',
        pattern.hasMatch,
      ),
    );
  }

  /// Selects members that do not satisfy `haveDeclaredTypeNameMatching`.
  MemberPredicateBuilder noHaveDeclaredTypeNameMatching(RegExp pattern) {
    return satisfy(
      memberDoesNotHaveDeclaredTypeNamePredicate(
        'have declared type name matching $pattern',
        pattern.hasMatch,
      ),
    );
  }

  /// Selects fields whose declared type name matches any value in [patterns].
  MemberPredicateBuilder haveDeclaredTypeNameMatchingAny(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.anyOf(
        valueList.map(
          (pattern) => memberDeclaredTypeNamePredicate(
            'have declared type name matching $pattern',
            pattern.hasMatch,
          ),
        ),
        description: 'have declared type name matching any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects fields whose declared type name matches every value in [patterns].
  MemberPredicateBuilder haveDeclaredTypeNameMatchingAll(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.allOf(
        valueList.map(
          (pattern) => memberDeclaredTypeNamePredicate(
            'have declared type name matching $pattern',
            pattern.hasMatch,
          ),
        ),
        description: 'have declared type name matching all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects fields whose declared type name matches none of [patterns].
  MemberPredicateBuilder haveDeclaredTypeNameMatchingNone(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.noneOf(
        valueList.map(
          (pattern) => memberDeclaredTypeNamePredicate(
            'have declared type name matching $pattern',
            pattern.hasMatch,
          ),
        ),
        description: 'have declared type name matching none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for field declared type-name pattern rules.
extension MemberHaveDeclaredTypeNameMatchingShouldRules on MemberShouldBuilder {
  /// Requires fields to have a declared type name matching [pattern].
  HeimdallRule<ClassMember> haveDeclaredTypeNameMatching(RegExp pattern) {
    return satisfy(
      memberDeclaredTypeNameCondition(
        'have declared type name matching $pattern',
        pattern.hasMatch,
      ),
    );
  }

  /// Requires members not to satisfy `haveDeclaredTypeNameMatching`.
  HeimdallRule<ClassMember> noHaveDeclaredTypeNameMatching(RegExp pattern) {
    return satisfy(
      memberMustNotHaveDeclaredTypeNameCondition(
        'have declared type name matching $pattern',
        pattern.hasMatch,
      ),
    );
  }

  /// Requires fields to have a declared type name matching any value in [patterns].
  HeimdallRule<ClassMember> haveDeclaredTypeNameMatchingAny(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(
          (pattern) => memberDeclaredTypeNameCondition(
            'have declared type name matching $pattern',
            pattern.hasMatch,
          ),
        ),
        description: 'have declared type name matching any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires fields to have a declared type name matching every value in [patterns].
  HeimdallRule<ClassMember> haveDeclaredTypeNameMatchingAll(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(
          (pattern) => memberDeclaredTypeNameCondition(
            'have declared type name matching $pattern',
            pattern.hasMatch,
          ),
        ),
        description: 'have declared type name matching all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires fields to have a declared type name matching none of [patterns].
  HeimdallRule<ClassMember> haveDeclaredTypeNameMatchingNone(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(
          (pattern) => memberDeclaredTypeNameCondition(
            'have declared type name matching $pattern',
            pattern.hasMatch,
          ),
        ),
        description: 'have declared type name matching none of ${valueList.join(', ')}',
      ),
    );
  }
}
