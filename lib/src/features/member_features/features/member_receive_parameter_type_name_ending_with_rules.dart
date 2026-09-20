import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/core/behavior_rule/heimdall_rule.dart';
import 'package:heimdall_test/src/core/heimdall_condition.dart';
import 'package:heimdall_test/src/core/heimdall_predicate.dart';
import 'package:heimdall_test/src/core/member_rules/member_predicate_builder.dart';
import 'package:heimdall_test/src/core/member_rules/member_should_builder.dart';
import 'package:heimdall_test/src/core/non_empty_iterable.dart';
import 'package:heimdall_test/src/features/member_features/helpers/member_parameter_type_name_rule_helpers.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for parameter type-name suffix rules.
extension MemberReceiveParameterTypeNameEndingWithPredicateRules on MemberPredicateBuilder {
  /// Selects executable members that receive a parameter type name ending with [suffix].
  MemberPredicateBuilder receiveParameterTypeNameEndingWith(String suffix) {
    return satisfy(_memberParameterTypeNameEndsWith(suffix));
  }

  /// Selects members that do not satisfy `receiveParameterTypeNameEndingWith`.
  MemberPredicateBuilder noReceiveParameterTypeNameEndingWith(String suffix) {
    return satisfy(_memberDoesNotReceiveParameterTypeNameEndingWith(suffix));
  }

  /// Selects executable members that receive a parameter type name ending with any value in [suffixes].
  MemberPredicateBuilder receiveParameterTypeNameEndingWithAny(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        valueList.map(_memberParameterTypeNameEndsWith),
        description: 'receive any parameter type name ending with ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects executable members that receive parameter type names ending with every value in [suffixes].
  MemberPredicateBuilder receiveParameterTypeNameEndingWithAll(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.allOf(
        valueList.map(_memberParameterTypeNameEndsWith),
        description: 'receive all parameter type names ending with ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects executable members that receive no parameter type name ending with values in [suffixes].
  MemberPredicateBuilder receiveParameterTypeNameEndingWithNone(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        valueList.map(_memberParameterTypeNameEndsWith),
        description: 'receive no parameter type names ending with ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for parameter type-name suffix rules.
extension MemberReceiveParameterTypeNameEndingWithShouldRules on MemberShouldBuilder {
  /// Requires executable members to receive a parameter type name ending with [suffix].
  HeimdallRule<ClassMember> receiveParameterTypeNameEndingWith(String suffix) {
    return satisfy(_memberShouldReceiveParameterTypeNameEndingWith(suffix));
  }

  /// Requires members not to satisfy `receiveParameterTypeNameEndingWith`.
  HeimdallRule<ClassMember> noReceiveParameterTypeNameEndingWith(String suffix) {
    return satisfy(_memberShouldNotReceiveParameterTypeNameEndingWith(suffix));
  }

  /// Requires executable members to receive a parameter type name ending with any value in [suffixes].
  HeimdallRule<ClassMember> receiveParameterTypeNameEndingWithAny(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_memberShouldReceiveParameterTypeNameEndingWith),
        description: 'receive any parameter type name ending with ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires executable members to receive parameter type names ending with every value in [suffixes].
  HeimdallRule<ClassMember> receiveParameterTypeNameEndingWithAll(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_memberShouldReceiveParameterTypeNameEndingWith),
        description: 'receive all parameter type names ending with ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires executable members to receive no parameter type name ending with values in [suffixes].
  HeimdallRule<ClassMember> receiveParameterTypeNameEndingWithNone(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(_memberShouldReceiveParameterTypeNameEndingWith),
        description: 'receive no parameter type names ending with ${valueList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<ClassMember> _memberParameterTypeNameEndsWith(String suffix) {
  return HeimdallPredicate(
    'receive parameter type name ending with $suffix',
    (item, project) => memberReceivesResolvedParameterTypeNameWhere(
      item,
      project,
      (typeName) => typeName.endsWith(suffix),
    ),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotReceiveParameterTypeNameEndingWith(String suffix) {
  return HeimdallPredicate(
    'not receive parameter type name ending with $suffix',
    (item, project) => !memberReceivesResolvedParameterTypeNameWhere(
      item,
      project,
      (typeName) => typeName.endsWith(suffix),
    ),
  );
}

HeimdallCondition<ClassMember> _memberShouldReceiveParameterTypeNameEndingWith(String suffix) {
  return memberCondition(
    'receive parameter type name ending with $suffix',
    (item, project) => memberReceivesResolvedParameterTypeNameWhere(
      item,
      project,
      (typeName) => typeName.endsWith(suffix),
    ),
  );
}

HeimdallCondition<ClassMember> _memberShouldNotReceiveParameterTypeNameEndingWith(String suffix) {
  return prohibitedMemberCondition(
    'receive parameter type name ending with $suffix',
    (item, project) => memberReceivesResolvedParameterTypeNameWhere(
      item,
      project,
      (typeName) => typeName.endsWith(suffix),
    ),
  );
}
