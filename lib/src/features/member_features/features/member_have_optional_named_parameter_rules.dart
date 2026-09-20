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
extension MemberHaveOptionalNamedParameterPredicateRules on MemberPredicateBuilder {
  /// Selects executable members that have optional named parameter [parameterName].
  MemberPredicateBuilder haveOptionalNamedParameter(String parameterName) {
    return satisfy(_hasOptionalNamedParameterPredicate(parameterName));
  }

  /// Selects members that do not satisfy `haveOptionalNamedParameter`.
  MemberPredicateBuilder noHaveOptionalNamedParameter(String parameterName) {
    return satisfy(_memberDoesNotHaveOptionalNamedParameter(parameterName));
  }

  /// Selects executable members that have optional named parameter every value in [parameterNames].
  MemberPredicateBuilder haveOptionalNamedParameterAll(Iterable<String> parameterNames) {
    final valueList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallPredicate.allOf(
        valueList.map(_hasOptionalNamedParameterPredicate),
        description: 'have optional named parameter all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects executable members that have optional named parameter at least one value in [parameterNames].
  MemberPredicateBuilder haveOptionalNamedParameterAny(Iterable<String> parameterNames) {
    final valueList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        valueList.map(_hasOptionalNamedParameterPredicate),
        description: 'have optional named parameter any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects executable members that have optional named parameter none of [parameterNames].
  MemberPredicateBuilder haveOptionalNamedParameterNone(Iterable<String> parameterNames) {
    final valueList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        valueList.map(_hasOptionalNamedParameterPredicate),
        description: 'have optional named parameter none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for executable parameter rules.
extension MemberHaveOptionalNamedParameterShouldRules on MemberShouldBuilder {
  /// Requires executable members to have optional named parameter [parameterName].
  HeimdallRule<ClassMember> haveOptionalNamedParameter(String parameterName) {
    return satisfy(_hasOptionalNamedParameterCondition(parameterName));
  }

  /// Requires members not to satisfy `haveOptionalNamedParameter`.
  HeimdallRule<ClassMember> noHaveOptionalNamedParameter(String parameterName) {
    return satisfy(_memberShouldNotHaveOptionalNamedParameter(parameterName));
  }

  /// Requires executable members to have optional named parameter every value in [parameterNames].
  HeimdallRule<ClassMember> haveOptionalNamedParameterAll(Iterable<String> parameterNames) {
    final valueList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_hasOptionalNamedParameterCondition),
        description: 'have optional named parameter all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires executable members to have optional named parameter at least one value in [parameterNames].
  HeimdallRule<ClassMember> haveOptionalNamedParameterAny(Iterable<String> parameterNames) {
    final valueList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_hasOptionalNamedParameterCondition),
        description: 'have optional named parameter any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires executable members to have optional named parameter none of [parameterNames].
  HeimdallRule<ClassMember> haveOptionalNamedParameterNone(Iterable<String> parameterNames) {
    final valueList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(_hasOptionalNamedParameterCondition),
        description: 'have optional named parameter none of ${valueList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _hasOptionalNamedParameterCondition(String value) {
  return memberCondition(
    'have optional named parameter $value',
    (item, _) => _memberHasOptionalNamedParameter(item, value),
  );
}

HeimdallCondition<ClassMember> _memberShouldNotHaveOptionalNamedParameter(String parameterName) {
  return prohibitedMemberCondition(
    'have optional named parameter $parameterName',
    (item, _) => _memberHasOptionalNamedParameter(item, parameterName),
  );
}

HeimdallPredicate<ClassMember> _hasOptionalNamedParameterPredicate(String value) {
  return HeimdallPredicate(
    'have optional named parameter $value',
    (item, project) => _memberHasOptionalNamedParameter(item, value),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotHaveOptionalNamedParameter(String parameterName) {
  return HeimdallPredicate(
    'not have optional named parameter $parameterName',
    (item, project) => !_memberHasOptionalNamedParameter(item, parameterName),
  );
}

/// Returns `true` when [member] declares an optional named parameter.
bool _memberHasOptionalNamedParameter(
  ClassMember member,
  String parameterName,
) {
  return member.parameters.any(
    (parameter) => parameter.name?.lexeme == parameterName && parameter is DefaultFormalParameter && parameter.isNamed && !parameter.isRequiredNamed,
  );
}
