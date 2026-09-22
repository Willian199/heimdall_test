import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/core/behavior_rule/heimdall_rule.dart';
import 'package:heimdall_test/src/core/heimdall_condition.dart';
import 'package:heimdall_test/src/core/heimdall_predicate.dart';
import 'package:heimdall_test/src/core/member_rules/member_predicate_builder.dart';
import 'package:heimdall_test/src/core/member_rules/member_should_builder.dart';
import 'package:heimdall_test/src/core/non_empty_iterable.dart';
import 'package:heimdall_test/src/features/member_features/helpers/member_declared_type_name_rule_helpers.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for field declared type assignability rules.
extension MemberHaveDeclaredTypeAssignableToPredicateRules on MemberPredicateBuilder {
  /// Selects fields whose declared type is assignable to [typeName].
  MemberPredicateBuilder haveDeclaredFieldTypeAssignableTo(String typeName) {
    return satisfy(_memberDeclaredTypeAssignableTo(typeName));
  }

  /// Selects members that do not satisfy `haveDeclaredFieldTypeAssignableTo`.
  MemberPredicateBuilder notHaveDeclaredFieldTypeAssignableTo(String typeName) {
    return satisfy(_memberDeclaredTypeNotAssignableTo(typeName));
  }

  /// Selects fields whose declared type is assignable to at least one value in [typeNames].
  MemberPredicateBuilder haveDeclaredFieldTypeAssignableToAnyOf(Iterable<String> typeNames) {
    final valueList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        valueList.map(_memberDeclaredTypeAssignableTo),
        description: 'have declared type assignable to any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects fields whose declared type is assignable to every value in [typeNames].
  MemberPredicateBuilder haveDeclaredFieldTypeAssignableToAllOf(Iterable<String> typeNames) {
    final valueList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.allOf(
        valueList.map(_memberDeclaredTypeAssignableTo),
        description: 'have declared type assignable to all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects fields whose declared type is assignable to none of [typeNames].
  MemberPredicateBuilder haveDeclaredFieldTypeAssignableToNoneOf(Iterable<String> typeNames) {
    final valueList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        valueList.map(_memberDeclaredTypeAssignableTo),
        description: 'have declared type assignable to none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for field declared type assignability rules.
extension MemberHaveDeclaredTypeAssignableToShouldRules on MemberShouldBuilder {
  /// Requires fields to have a declared type assignable to [typeName].
  HeimdallRule<ClassMember> haveDeclaredFieldTypeAssignableTo(String typeName) {
    return satisfy(_memberShouldHaveDeclaredTypeAssignableTo(typeName));
  }

  /// Requires members not to satisfy `haveDeclaredFieldTypeAssignableTo`.
  HeimdallRule<ClassMember> notHaveDeclaredFieldTypeAssignableTo(String typeName) {
    return satisfy(_memberShouldNotHaveDeclaredTypeAssignableTo(typeName));
  }

  /// Requires fields to have a declared type assignable to at least one value in [typeNames].
  HeimdallRule<ClassMember> haveDeclaredFieldTypeAssignableToAnyOf(Iterable<String> typeNames) {
    final valueList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_memberShouldHaveDeclaredTypeAssignableTo),
        description: 'have declared type assignable to any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires fields to have a declared type assignable to every value in [typeNames].
  HeimdallRule<ClassMember> haveDeclaredFieldTypeAssignableToAllOf(Iterable<String> typeNames) {
    final valueList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_memberShouldHaveDeclaredTypeAssignableTo),
        description: 'have declared type assignable to all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires fields to have a declared type assignable to none of [typeNames].
  HeimdallRule<ClassMember> haveDeclaredFieldTypeAssignableToNoneOf(Iterable<String> typeNames) {
    final valueList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(_memberShouldHaveDeclaredTypeAssignableTo),
        description: 'have declared type assignable to none of ${valueList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<ClassMember> _memberDeclaredTypeAssignableTo(String typeName) {
  return HeimdallPredicate(
    'have declared type assignable to $typeName',
    (item, project) => memberDeclaredTypeIsAssignableTo(item, typeName, project),
  );
}

HeimdallPredicate<ClassMember> _memberDeclaredTypeNotAssignableTo(String typeName) {
  return HeimdallPredicate(
    'not have declared type assignable to $typeName',
    (item, project) => !memberDeclaredTypeIsAssignableTo(item, typeName, project),
  );
}

HeimdallCondition<ClassMember> _memberShouldHaveDeclaredTypeAssignableTo(String typeName) {
  return memberCondition(
    'have declared type assignable to $typeName',
    (item, project) => memberDeclaredTypeIsAssignableTo(item, typeName, project),
  );
}

HeimdallCondition<ClassMember> _memberShouldNotHaveDeclaredTypeAssignableTo(String typeName) {
  return prohibitedMemberCondition(
    'have declared type assignable to $typeName',
    (item, project) => memberDeclaredTypeIsAssignableTo(item, typeName, project),
  );
}
