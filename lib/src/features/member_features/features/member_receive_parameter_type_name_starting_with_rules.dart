import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/core/behavior_rule/heimdall_rule.dart';
import 'package:heimdall_test/src/core/heimdall_condition.dart';
import 'package:heimdall_test/src/core/heimdall_predicate.dart';
import 'package:heimdall_test/src/core/member_rules/member_predicate_builder.dart';
import 'package:heimdall_test/src/core/member_rules/member_should_builder.dart';
import 'package:heimdall_test/src/core/non_empty_iterable.dart';
import 'package:heimdall_test/src/features/member_features/helpers/member_parameter_type_name_rule_helpers.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for parameter type-name prefix rules.
extension MemberReceiveParameterTypeNameStartingWithPredicateRules on MemberPredicateBuilder {
  /// Selects executable members that receive a parameter type name starting with [prefix].
  MemberPredicateBuilder receiveParameterTypeNameStartingWith(String prefix) {
    return satisfy(_memberParameterTypeNameStartsWith(prefix));
  }

  /// Selects members that do not satisfy `receiveParameterTypeNameStartingWith`.
  MemberPredicateBuilder notReceiveParameterTypeNameStartingWith(String prefix) {
    return satisfy(_memberDoesNotReceiveParameterTypeNameStartingWith(prefix));
  }

  /// Selects executable members that receive a parameter type name starting with any value in [prefixes].
  MemberPredicateBuilder receiveParameterTypeNameStartingWithAnyOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        valueList.map(_memberParameterTypeNameStartsWith),
        description: 'receive any parameter type name starting with ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects executable members that receive parameter type names starting with every value in [prefixes].
  MemberPredicateBuilder receiveParameterTypeNameStartingWithAllOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.allOf(
        valueList.map(_memberParameterTypeNameStartsWith),
        description: 'receive all parameter type names starting with ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects executable members that receive no parameter type name starting with values in [prefixes].
  MemberPredicateBuilder receiveParameterTypeNameStartingWithNoneOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        valueList.map(_memberParameterTypeNameStartsWith),
        description: 'receive no parameter type names starting with ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for parameter type-name prefix rules.
extension MemberReceiveParameterTypeNameStartingWithShouldRules on MemberShouldBuilder {
  /// Requires executable members to receive a parameter type name starting with [prefix].
  HeimdallRule<ClassMember> receiveParameterTypeNameStartingWith(String prefix) {
    return satisfy(_memberShouldReceiveParameterTypeNameStartingWith(prefix));
  }

  /// Requires members not to satisfy `receiveParameterTypeNameStartingWith`.
  HeimdallRule<ClassMember> notReceiveParameterTypeNameStartingWith(String prefix) {
    return satisfy(_memberShouldNotReceiveParameterTypeNameStartingWith(prefix));
  }

  /// Requires executable members to receive a parameter type name starting with any value in [prefixes].
  HeimdallRule<ClassMember> receiveParameterTypeNameStartingWithAnyOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_memberShouldReceiveParameterTypeNameStartingWith),
        description: 'receive any parameter type name starting with ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires executable members to receive parameter type names starting with every value in [prefixes].
  HeimdallRule<ClassMember> receiveParameterTypeNameStartingWithAllOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_memberShouldReceiveParameterTypeNameStartingWith),
        description: 'receive all parameter type names starting with ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires executable members to receive no parameter type name starting with values in [prefixes].
  HeimdallRule<ClassMember> receiveParameterTypeNameStartingWithNoneOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(_memberShouldReceiveParameterTypeNameStartingWith),
        description: 'receive no parameter type names starting with ${valueList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<ClassMember> _memberParameterTypeNameStartsWith(String prefix) {
  return HeimdallPredicate(
    'receive parameter type name starting with $prefix',
    (item, project) => memberReceivesResolvedParameterTypeNameWhere(
      item,
      project,
      (typeName) => typeName.startsWith(prefix),
    ),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotReceiveParameterTypeNameStartingWith(String prefix) {
  return HeimdallPredicate(
    'not receive parameter type name starting with $prefix',
    (item, project) => !memberReceivesResolvedParameterTypeNameWhere(
      item,
      project,
      (typeName) => typeName.startsWith(prefix),
    ),
  );
}

HeimdallCondition<ClassMember> _memberShouldReceiveParameterTypeNameStartingWith(String prefix) {
  return memberCondition(
    'receive parameter type name starting with $prefix',
    (item, project) => memberReceivesResolvedParameterTypeNameWhere(
      item,
      project,
      (typeName) => typeName.startsWith(prefix),
    ),
  );
}

HeimdallCondition<ClassMember> _memberShouldNotReceiveParameterTypeNameStartingWith(String prefix) {
  return prohibitedMemberCondition(
    'receive parameter type name starting with $prefix',
    (item, project) => memberReceivesResolvedParameterTypeNameWhere(
      item,
      project,
      (typeName) => typeName.startsWith(prefix),
    ),
  );
}
