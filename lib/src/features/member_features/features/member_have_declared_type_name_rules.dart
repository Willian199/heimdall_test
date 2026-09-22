import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/core/behavior_rule/heimdall_rule.dart';
import 'package:heimdall_test/src/core/heimdall_condition.dart';
import 'package:heimdall_test/src/core/heimdall_predicate.dart';
import 'package:heimdall_test/src/core/member_rules/member_predicate_builder.dart';
import 'package:heimdall_test/src/core/member_rules/member_should_builder.dart';
import 'package:heimdall_test/src/core/non_empty_iterable.dart';
import 'package:heimdall_test/src/features/member_features/helpers/member_declared_type_name_rule_helpers.dart';

/// Predicate-side DSL for exact field declared type-name rules.
extension MemberHaveDeclaredTypeNamePredicateRules on MemberPredicateBuilder {
  /// Selects fields whose declared type name equals [typeName].
  MemberPredicateBuilder haveDeclaredFieldTypeName(String typeName) {
    return satisfy(
      memberDeclaredTypeNamePredicate(
        'have declared type name $typeName',
        (actual) => actual == typeName,
      ),
    );
  }

  /// Selects members that do not satisfy `haveDeclaredFieldTypeName`.
  MemberPredicateBuilder notHaveDeclaredFieldTypeName(String typeName) {
    return satisfy(
      memberDoesNotHaveDeclaredTypeNamePredicate(
        'have declared type name $typeName',
        (actual) => actual == typeName,
      ),
    );
  }

  /// Selects fields whose declared type name equals at least one value in [typeNames].
  MemberPredicateBuilder haveDeclaredFieldTypeNameEqualToAnyOf(Iterable<String> typeNames) {
    final valueList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        valueList.map(
          (typeName) => memberDeclaredTypeNamePredicate(
            'have declared type name $typeName',
            (actual) => actual == typeName,
          ),
        ),
        description: 'have any declared type name ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects fields whose declared type name equals every value in [typeNames].
  MemberPredicateBuilder haveDeclaredFieldTypeNameEqualToAllOf(Iterable<String> typeNames) {
    final valueList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.allOf(
        valueList.map(
          (typeName) => memberDeclaredTypeNamePredicate(
            'have declared type name $typeName',
            (actual) => actual == typeName,
          ),
        ),
        description: 'have all declared type names ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects fields whose declared type name equals none of [typeNames].
  MemberPredicateBuilder haveDeclaredFieldTypeNameEqualToNoneOf(Iterable<String> typeNames) {
    final valueList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        valueList.map(
          (typeName) => memberDeclaredTypeNamePredicate(
            'have declared type name $typeName',
            (actual) => actual == typeName,
          ),
        ),
        description: 'have no declared type names ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for exact field declared type-name rules.
extension MemberHaveDeclaredTypeNameShouldRules on MemberShouldBuilder {
  /// Requires fields to have a declared type name equal to [typeName].
  HeimdallRule<ClassMember> haveDeclaredFieldTypeName(String typeName) {
    return satisfy(
      memberDeclaredTypeNameCondition(
        'have declared type name $typeName',
        (actual) => actual == typeName,
      ),
    );
  }

  /// Requires members not to satisfy `haveDeclaredFieldTypeName`.
  HeimdallRule<ClassMember> notHaveDeclaredFieldTypeName(String typeName) {
    return satisfy(
      memberMustNotHaveDeclaredTypeNameCondition(
        'have declared type name $typeName',
        (actual) => actual == typeName,
      ),
    );
  }

  /// Requires fields to have a declared type name equal to at least one value in [typeNames].
  HeimdallRule<ClassMember> haveDeclaredFieldTypeNameEqualToAnyOf(Iterable<String> typeNames) {
    final valueList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(
          (typeName) => memberDeclaredTypeNameCondition(
            'have declared type name $typeName',
            (actual) => actual == typeName,
          ),
        ),
        description: 'have any declared type name ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires fields to have a declared type name equal to every value in [typeNames].
  HeimdallRule<ClassMember> haveDeclaredFieldTypeNameEqualToAllOf(Iterable<String> typeNames) {
    final valueList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(
          (typeName) => memberDeclaredTypeNameCondition(
            'have declared type name $typeName',
            (actual) => actual == typeName,
          ),
        ),
        description: 'have all declared type names ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires fields to have a declared type name equal to none of [typeNames].
  HeimdallRule<ClassMember> haveDeclaredFieldTypeNameEqualToNoneOf(Iterable<String> typeNames) {
    final valueList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(
          (typeName) => memberDeclaredTypeNameCondition(
            'have declared type name $typeName',
            (actual) => actual == typeName,
          ),
        ),
        description: 'have no declared type names ${valueList.join(', ')}',
      ),
    );
  }
}
