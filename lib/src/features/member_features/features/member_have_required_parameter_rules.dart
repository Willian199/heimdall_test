import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/core/behavior_rule/heimdall_rule.dart';
import 'package:heimdall_test/src/core/heimdall_condition.dart';
import 'package:heimdall_test/src/core/heimdall_predicate.dart';
import 'package:heimdall_test/src/core/member_rules/member_predicate_builder.dart';
import 'package:heimdall_test/src/core/member_rules/member_should_builder.dart';
import 'package:heimdall_test/src/core/non_empty_iterable.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_member.dart';

/// Predicate-side DSL for executable parameter rules.
extension MemberHaveRequiredParameterPredicateRules on MemberPredicateBuilder {
  /// Selects executable members that have required parameter [parameterName].
  MemberPredicateBuilder haveRequiredParameter(String parameterName) {
    return satisfy(_hasRequiredParameterPredicate(parameterName));
  }

  /// Selects members that do not satisfy `haveRequiredParameter`.
  MemberPredicateBuilder haveNoRequiredParameter(String parameterName) {
    return satisfy(
      HeimdallPredicate(
        'not have required parameter $parameterName',
        (item, project) => !_memberHasRequiredParameter(item, parameterName),
      ),
    );
  }

  /// Selects executable members that have required parameter every value in [parameterNames].
  MemberPredicateBuilder haveRequiredParameterAllOf(Iterable<String> parameterNames) {
    final valueList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallPredicate.allOf(
        valueList.map(_hasRequiredParameterPredicate),
        description: 'have required parameter all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects executable members that have required parameter at least one value in [parameterNames].
  MemberPredicateBuilder haveRequiredParameterAnyOf(Iterable<String> parameterNames) {
    final valueList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        valueList.map(_hasRequiredParameterPredicate),
        description: 'have required parameter any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects executable members that have required parameter none of [parameterNames].
  MemberPredicateBuilder haveRequiredParameterNoneOf(Iterable<String> parameterNames) {
    final valueList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        valueList.map(_hasRequiredParameterPredicate),
        description: 'have required parameter none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for executable parameter rules.
extension MemberHaveRequiredParameterShouldRules on MemberShouldBuilder {
  /// Requires executable members to have required parameter [parameterName].
  HeimdallRule<ClassMember> haveRequiredParameter(String parameterName) {
    return satisfy(_hasRequiredParameterCondition(parameterName));
  }

  /// Requires members not to satisfy `haveRequiredParameter`.
  HeimdallRule<ClassMember> haveNoRequiredParameter(String parameterName) {
    return satisfy(
      prohibitedMemberCondition(
        'have required parameter $parameterName',
        (item, _) => _memberHasRequiredParameter(item, parameterName),
      ),
    );
  }

  /// Requires executable members to have required parameter every value in [parameterNames].
  HeimdallRule<ClassMember> haveRequiredParameterAllOf(Iterable<String> parameterNames) {
    final valueList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_hasRequiredParameterCondition),
        description: 'have required parameter all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires executable members to have required parameter at least one value in [parameterNames].
  HeimdallRule<ClassMember> haveRequiredParameterAnyOf(Iterable<String> parameterNames) {
    final valueList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_hasRequiredParameterCondition),
        description: 'have required parameter any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires executable members to have required parameter none of [parameterNames].
  HeimdallRule<ClassMember> haveRequiredParameterNoneOf(Iterable<String> parameterNames) {
    final valueList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(_hasRequiredParameterCondition),
        description: 'have required parameter none of ${valueList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _hasRequiredParameterCondition(String value) {
  return memberCondition(
    'have required parameter $value',
    (item, _) => _memberHasRequiredParameter(item, value),
  );
}

HeimdallPredicate<ClassMember> _hasRequiredParameterPredicate(String value) {
  return HeimdallPredicate(
    'have required parameter $value',
    (item, project) => _memberHasRequiredParameter(item, value),
  );
}

/// Returns `true` when [member] declares a required positional or required named parameter.
bool _memberHasRequiredParameter(ClassMember member, String parameterName) {
  return member.parameters.any(
    (parameter) => _isRequiredParameter(parameter, parameterName),
  );
}

bool _isRequiredParameter(FormalParameter parameter, String name) {
  if (parameter.name?.lexeme != name) return false;
  if (parameter is! DefaultFormalParameter) return true;
  return parameter.isRequiredNamed;
}
