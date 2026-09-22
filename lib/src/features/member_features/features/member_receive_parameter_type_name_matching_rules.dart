import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/core/behavior_rule/heimdall_rule.dart';
import 'package:heimdall_test/src/core/heimdall_condition.dart';
import 'package:heimdall_test/src/core/heimdall_predicate.dart';
import 'package:heimdall_test/src/core/member_rules/member_predicate_builder.dart';
import 'package:heimdall_test/src/core/member_rules/member_should_builder.dart';
import 'package:heimdall_test/src/core/non_empty_iterable.dart';
import 'package:heimdall_test/src/features/member_features/helpers/member_parameter_type_name_rule_helpers.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for parameter type-name pattern rules.
extension MemberReceiveParameterTypeNameMatchingPredicateRules on MemberPredicateBuilder {
  /// Selects executable members that receive a parameter type name matching [pattern].
  MemberPredicateBuilder receiveParameterTypeNameMatching(RegExp pattern) {
    return satisfy(_memberParameterTypeNameMatches(pattern));
  }

  /// Selects members that do not satisfy `receiveParameterTypeNameMatching`.
  MemberPredicateBuilder notReceiveParameterTypeNameMatching(RegExp pattern) {
    return satisfy(_memberDoesNotReceiveParameterTypeNameMatching(pattern));
  }

  /// Selects executable members that receive a parameter type name matching any pattern in [patterns].
  MemberPredicateBuilder receiveParameterTypeNameMatchingAnyOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.anyOf(
        valueList.map(_memberParameterTypeNameMatches),
        description: 'receive any parameter type name matching ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects executable members that receive parameter type names matching every pattern in [patterns].
  MemberPredicateBuilder receiveParameterTypeNameMatchingAllOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.allOf(
        valueList.map(_memberParameterTypeNameMatches),
        description: 'receive all parameter type names matching ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects executable members that receive no parameter type name matching [patterns].
  MemberPredicateBuilder receiveParameterTypeNameMatchingNoneOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.noneOf(
        valueList.map(_memberParameterTypeNameMatches),
        description: 'receive no parameter type names matching ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for parameter type-name pattern rules.
extension MemberReceiveParameterTypeNameMatchingShouldRules on MemberShouldBuilder {
  /// Requires executable members to receive a parameter type name matching [pattern].
  HeimdallRule<ClassMember> receiveParameterTypeNameMatching(RegExp pattern) {
    return satisfy(_memberShouldReceiveParameterTypeNameMatching(pattern));
  }

  /// Requires members not to satisfy `receiveParameterTypeNameMatching`.
  HeimdallRule<ClassMember> notReceiveParameterTypeNameMatching(RegExp pattern) {
    return satisfy(_memberShouldNotReceiveParameterTypeNameMatching(pattern));
  }

  /// Requires executable members to receive a parameter type name matching any pattern in [patterns].
  HeimdallRule<ClassMember> receiveParameterTypeNameMatchingAnyOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_memberShouldReceiveParameterTypeNameMatching),
        description: 'receive any parameter type name matching ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires executable members to receive parameter type names matching every pattern in [patterns].
  HeimdallRule<ClassMember> receiveParameterTypeNameMatchingAllOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_memberShouldReceiveParameterTypeNameMatching),
        description: 'receive all parameter type names matching ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires executable members to receive no parameter type name matching [patterns].
  HeimdallRule<ClassMember> receiveParameterTypeNameMatchingNoneOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(_memberShouldReceiveParameterTypeNameMatching),
        description: 'receive no parameter type names matching ${valueList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<ClassMember> _memberParameterTypeNameMatches(RegExp pattern) {
  return HeimdallPredicate(
    'receive parameter type name matching $pattern',
    (item, project) => memberReceivesResolvedParameterTypeNameWhere(
      item,
      project,
      pattern.hasMatch,
    ),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotReceiveParameterTypeNameMatching(RegExp pattern) {
  return HeimdallPredicate(
    'not receive parameter type name matching $pattern',
    (item, project) => !memberReceivesResolvedParameterTypeNameWhere(
      item,
      project,
      pattern.hasMatch,
    ),
  );
}

HeimdallCondition<ClassMember> _memberShouldReceiveParameterTypeNameMatching(RegExp pattern) {
  return memberCondition(
    'receive parameter type name matching $pattern',
    (item, project) => memberReceivesResolvedParameterTypeNameWhere(
      item,
      project,
      pattern.hasMatch,
    ),
  );
}

HeimdallCondition<ClassMember> _memberShouldNotReceiveParameterTypeNameMatching(RegExp pattern) {
  return prohibitedMemberCondition(
    'receive parameter type name matching $pattern',
    (item, project) => memberReceivesResolvedParameterTypeNameWhere(
      item,
      project,
      pattern.hasMatch,
    ),
  );
}
