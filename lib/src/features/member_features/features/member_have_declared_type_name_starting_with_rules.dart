import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/core/behavior_rule/heimdall_rule.dart';
import 'package:heimdall_test/src/core/heimdall_condition.dart';
import 'package:heimdall_test/src/core/heimdall_predicate.dart';
import 'package:heimdall_test/src/core/member_rules/member_predicate_builder.dart';
import 'package:heimdall_test/src/core/member_rules/member_should_builder.dart';
import 'package:heimdall_test/src/core/non_empty_iterable.dart';
import 'package:heimdall_test/src/features/member_features/helpers/member_declared_type_name_rule_helpers.dart';

/// Predicate-side DSL for field declared type-name prefix rules.
extension MemberHaveDeclaredTypeNameStartingWithPredicateRules on MemberPredicateBuilder {
  /// Selects fields whose declared type name starts with [prefix].
  MemberPredicateBuilder haveDeclaredFieldTypeNameStartingWith(String prefix) {
    return satisfy(
      memberDeclaredTypeNamePredicate(
        'have declared type name starting with $prefix',
        (typeName) => typeName.startsWith(prefix),
      ),
    );
  }

  /// Selects members that do not satisfy `haveDeclaredFieldTypeNameStartingWith`.
  MemberPredicateBuilder notHaveDeclaredFieldTypeNameStartingWith(String prefix) {
    return satisfy(
      memberDoesNotHaveDeclaredTypeNamePredicate(
        'have declared type name starting with $prefix',
        (typeName) => typeName.startsWith(prefix),
      ),
    );
  }

  /// Selects fields whose declared type name starts with any value in [prefixes].
  MemberPredicateBuilder haveDeclaredFieldTypeNameStartingWithAnyOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        valueList.map(
          (prefix) => memberDeclaredTypeNamePredicate(
            'have declared type name starting with $prefix',
            (typeName) => typeName.startsWith(prefix),
          ),
        ),
        description: 'have declared type name starting with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects fields whose declared type name starts with every value in [prefixes].
  MemberPredicateBuilder haveDeclaredFieldTypeNameStartingWithAllOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.allOf(
        valueList.map(
          (prefix) => memberDeclaredTypeNamePredicate(
            'have declared type name starting with $prefix',
            (typeName) => typeName.startsWith(prefix),
          ),
        ),
        description: 'have declared type name starting with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects fields whose declared type name starts with none of [prefixes].
  MemberPredicateBuilder haveDeclaredFieldTypeNameStartingWithNoneOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        valueList.map(
          (prefix) => memberDeclaredTypeNamePredicate(
            'have declared type name starting with $prefix',
            (typeName) => typeName.startsWith(prefix),
          ),
        ),
        description: 'have declared type name starting with none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for field declared type-name prefix rules.
extension MemberHaveDeclaredTypeNameStartingWithShouldRules on MemberShouldBuilder {
  /// Requires fields to have a declared type name starting with [prefix].
  HeimdallRule<ClassMember> haveDeclaredFieldTypeNameStartingWith(String prefix) {
    return satisfy(
      memberDeclaredTypeNameCondition(
        'have declared type name starting with $prefix',
        (typeName) => typeName.startsWith(prefix),
      ),
    );
  }

  /// Requires members not to satisfy `haveDeclaredFieldTypeNameStartingWith`.
  HeimdallRule<ClassMember> notHaveDeclaredFieldTypeNameStartingWith(String prefix) {
    return satisfy(
      memberMustNotHaveDeclaredTypeNameCondition(
        'have declared type name starting with $prefix',
        (typeName) => typeName.startsWith(prefix),
      ),
    );
  }

  /// Requires fields to have a declared type name starting with any value in [prefixes].
  HeimdallRule<ClassMember> haveDeclaredFieldTypeNameStartingWithAnyOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(
          (prefix) => memberDeclaredTypeNameCondition(
            'have declared type name starting with $prefix',
            (typeName) => typeName.startsWith(prefix),
          ),
        ),
        description: 'have declared type name starting with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires fields to have a declared type name starting with every value in [prefixes].
  HeimdallRule<ClassMember> haveDeclaredFieldTypeNameStartingWithAllOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(
          (prefix) => memberDeclaredTypeNameCondition(
            'have declared type name starting with $prefix',
            (typeName) => typeName.startsWith(prefix),
          ),
        ),
        description: 'have declared type name starting with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires fields to have a declared type name starting with none of [prefixes].
  HeimdallRule<ClassMember> haveDeclaredFieldTypeNameStartingWithNoneOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(
          (prefix) => memberDeclaredTypeNameCondition(
            'have declared type name starting with $prefix',
            (typeName) => typeName.startsWith(prefix),
          ),
        ),
        description: 'have declared type name starting with none of ${valueList.join(', ')}',
      ),
    );
  }
}
