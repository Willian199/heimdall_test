import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/core/behavior_rule/heimdall_rule.dart';
import 'package:heimdall_test/src/core/heimdall_condition.dart';
import 'package:heimdall_test/src/core/heimdall_predicate.dart';
import 'package:heimdall_test/src/core/member_rules/member_predicate_builder.dart';
import 'package:heimdall_test/src/core/member_rules/member_should_builder.dart';
import 'package:heimdall_test/src/core/non_empty_iterable.dart';
import 'package:heimdall_test/src/features/member_features/helpers/member_parameter_type_name_rule_helpers.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for executable parameter assignability rules.
extension MemberReceiveParameterAssignableToPredicateRules on MemberPredicateBuilder {
  /// Selects executable members that receive a parameter assignable to [typeName].
  MemberPredicateBuilder receiveParameterAssignableTo(String typeName) {
    return satisfy(_memberReceivesParameterAssignableTo(typeName));
  }

  /// Selects members that do not satisfy `receiveParameterAssignableTo`.
  MemberPredicateBuilder notReceiveParameterAssignableTo(String typeName) {
    return satisfy(_memberDoesNotReceiveParameterAssignableTo(typeName));
  }

  /// Selects executable members that receive a parameter assignable to at least one value in [typeNames].
  MemberPredicateBuilder receiveParameterAssignableToAnyOf(Iterable<String> typeNames) {
    final valueList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        valueList.map(_memberReceivesParameterAssignableTo),
        description: 'receive parameter assignable to any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects executable members that receive parameters assignable to every value in [typeNames].
  MemberPredicateBuilder receiveParameterAssignableToAllOf(Iterable<String> typeNames) {
    final valueList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.allOf(
        valueList.map(_memberReceivesParameterAssignableTo),
        description: 'receive parameter assignable to all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects executable members that receive no parameter assignable to [typeNames].
  MemberPredicateBuilder receiveParameterAssignableToNoneOf(Iterable<String> typeNames) {
    final valueList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        valueList.map(_memberReceivesParameterAssignableTo),
        description: 'receive parameter assignable to none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for executable parameter assignability rules.
extension MemberReceiveParameterAssignableToShouldRules on MemberShouldBuilder {
  /// Requires executable members to receive a parameter assignable to [typeName].
  HeimdallRule<ClassMember> receiveParameterAssignableTo(String typeName) {
    return satisfy(_memberShouldReceiveParameterAssignableTo(typeName));
  }

  /// Requires members not to satisfy `receiveParameterAssignableTo`.
  HeimdallRule<ClassMember> notReceiveParameterAssignableTo(String typeName) {
    return satisfy(_memberShouldNotReceiveParameterAssignableTo(typeName));
  }

  /// Requires executable members to receive a parameter assignable to at least one value in [typeNames].
  HeimdallRule<ClassMember> receiveParameterAssignableToAnyOf(Iterable<String> typeNames) {
    final valueList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_memberShouldReceiveParameterAssignableTo),
        description: 'receive parameter assignable to any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires executable members to receive parameters assignable to every value in [typeNames].
  HeimdallRule<ClassMember> receiveParameterAssignableToAllOf(Iterable<String> typeNames) {
    final valueList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_memberShouldReceiveParameterAssignableTo),
        description: 'receive parameter assignable to all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires executable members to receive no parameter assignable to [typeNames].
  HeimdallRule<ClassMember> receiveParameterAssignableToNoneOf(Iterable<String> typeNames) {
    final valueList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(_memberShouldReceiveParameterAssignableTo),
        description: 'receive parameter assignable to none of ${valueList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<ClassMember> _memberReceivesParameterAssignableTo(String typeName) {
  return HeimdallPredicate(
    'receive parameter assignable to $typeName',
    (item, project) => memberReceivesParameterAssignableTo(item, project, typeName),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotReceiveParameterAssignableTo(String typeName) {
  return HeimdallPredicate(
    'not receive parameter assignable to $typeName',
    (item, project) => !memberReceivesParameterAssignableTo(item, project, typeName),
  );
}

HeimdallCondition<ClassMember> _memberShouldReceiveParameterAssignableTo(String typeName) {
  return memberCondition(
    'receive parameter assignable to $typeName',
    (item, project) => memberReceivesParameterAssignableTo(item, project, typeName),
  );
}

HeimdallCondition<ClassMember> _memberShouldNotReceiveParameterAssignableTo(String typeName) {
  return prohibitedMemberCondition(
    'receive parameter assignable to $typeName',
    (item, project) => memberReceivesParameterAssignableTo(item, project, typeName),
  );
}
