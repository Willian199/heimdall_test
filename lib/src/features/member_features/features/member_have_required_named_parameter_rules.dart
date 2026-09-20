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
extension MemberHaveRequiredNamedParameterPredicateRules on MemberPredicateBuilder {
  /// Selects executable members that have required named parameter [parameterName].
  MemberPredicateBuilder haveRequiredNamedParameter(String parameterName) {
    return satisfy(_hasRequiredNamedParameterPredicate(parameterName));
  }

  /// Selects members that do not satisfy `haveRequiredNamedParameter`.
  MemberPredicateBuilder noHaveRequiredNamedParameter(String parameterName) {
    return satisfy(_memberDoesNotHaveRequiredNamedParameter(parameterName));
  }

  /// Selects executable members that have required named parameter every value in [parameterNames].
  MemberPredicateBuilder haveRequiredNamedParameterAll(Iterable<String> parameterNames) {
    final valueList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallPredicate.allOf(
        valueList.map(_hasRequiredNamedParameterPredicate),
        description: 'have required named parameter all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects executable members that have required named parameter at least one value in [parameterNames].
  MemberPredicateBuilder haveRequiredNamedParameterAny(Iterable<String> parameterNames) {
    final valueList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        valueList.map(_hasRequiredNamedParameterPredicate),
        description: 'have required named parameter any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects executable members that have required named parameter none of [parameterNames].
  MemberPredicateBuilder haveRequiredNamedParameterNone(Iterable<String> parameterNames) {
    final valueList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        valueList.map(_hasRequiredNamedParameterPredicate),
        description: 'have required named parameter none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for executable parameter rules.
extension MemberHaveRequiredNamedParameterShouldRules on MemberShouldBuilder {
  /// Requires executable members to have required named parameter [parameterName].
  HeimdallRule<ClassMember> haveRequiredNamedParameter(String parameterName) {
    return satisfy(_hasRequiredNamedParameterCondition(parameterName));
  }

  /// Requires members not to satisfy `haveRequiredNamedParameter`.
  HeimdallRule<ClassMember> noHaveRequiredNamedParameter(String parameterName) {
    return satisfy(_memberShouldNotHaveRequiredNamedParameter(parameterName));
  }

  /// Requires executable members to have required named parameter every value in [parameterNames].
  HeimdallRule<ClassMember> haveRequiredNamedParameterAll(Iterable<String> parameterNames) {
    final valueList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_hasRequiredNamedParameterCondition),
        description: 'have required named parameter all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires executable members to have required named parameter at least one value in [parameterNames].
  HeimdallRule<ClassMember> haveRequiredNamedParameterAny(Iterable<String> parameterNames) {
    final valueList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_hasRequiredNamedParameterCondition),
        description: 'have required named parameter any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires executable members to have required named parameter none of [parameterNames].
  HeimdallRule<ClassMember> haveRequiredNamedParameterNone(Iterable<String> parameterNames) {
    final valueList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(_hasRequiredNamedParameterCondition),
        description: 'have required named parameter none of ${valueList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _hasRequiredNamedParameterCondition(String value) {
  return memberCondition(
    'have required named parameter $value',
    (item, _) => _memberHasRequiredNamedParameter(item, value),
  );
}

HeimdallCondition<ClassMember> _memberShouldNotHaveRequiredNamedParameter(String parameterName) {
  return prohibitedMemberCondition(
    'have required named parameter $parameterName',
    (item, _) => _memberHasRequiredNamedParameter(item, parameterName),
  );
}

HeimdallPredicate<ClassMember> _hasRequiredNamedParameterPredicate(String value) {
  return HeimdallPredicate(
    'have required named parameter $value',
    (item, project) => _memberHasRequiredNamedParameter(item, value),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotHaveRequiredNamedParameter(String parameterName) {
  return HeimdallPredicate(
    'not have required named parameter $parameterName',
    (item, project) => !_memberHasRequiredNamedParameter(item, parameterName),
  );
}

/// Returns `true` when [member] declares a required named parameter.
bool _memberHasRequiredNamedParameter(
  ClassMember member,
  String parameterName,
) {
  return member.parameters.any(
    (parameter) => parameter.name?.lexeme == parameterName && parameter is DefaultFormalParameter && parameter.isNamed && parameter.isRequiredNamed,
  );
}
