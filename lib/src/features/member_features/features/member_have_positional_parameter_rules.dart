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
extension MemberHavePositionalParameterPredicateRules on MemberPredicateBuilder {
  /// Selects executable members that have positional parameter [parameterName].
  MemberPredicateBuilder havePositionalParameter(String parameterName) {
    return satisfy(_hasPositionalParameterPredicate(parameterName));
  }

  /// Selects members that do not satisfy `havePositionalParameter`.
  MemberPredicateBuilder haveNoPositionalParameter(String parameterName) {
    return satisfy(_memberDoesNotHavePositionalParameter(parameterName));
  }

  /// Selects executable members that have positional parameter every value in [parameterNames].
  MemberPredicateBuilder havePositionalParameterAllOf(Iterable<String> parameterNames) {
    final valueList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallPredicate.allOf(
        valueList.map(_hasPositionalParameterPredicate),
        description: 'have positional parameter all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects executable members that have positional parameter at least one value in [parameterNames].
  MemberPredicateBuilder havePositionalParameterAnyOf(Iterable<String> parameterNames) {
    final valueList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        valueList.map(_hasPositionalParameterPredicate),
        description: 'have positional parameter any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects executable members that have positional parameter none of [parameterNames].
  MemberPredicateBuilder havePositionalParameterNoneOf(Iterable<String> parameterNames) {
    final valueList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        valueList.map(_hasPositionalParameterPredicate),
        description: 'have positional parameter none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for executable parameter rules.
extension MemberHavePositionalParameterShouldRules on MemberShouldBuilder {
  /// Requires executable members to have positional parameter [parameterName].
  HeimdallRule<ClassMember> havePositionalParameter(String parameterName) {
    return satisfy(_hasPositionalParameterCondition(parameterName));
  }

  /// Requires members not to satisfy `havePositionalParameter`.
  HeimdallRule<ClassMember> haveNoPositionalParameter(String parameterName) {
    return satisfy(_memberShouldNotHavePositionalParameter(parameterName));
  }

  /// Requires executable members to have positional parameter every value in [parameterNames].
  HeimdallRule<ClassMember> havePositionalParameterAllOf(Iterable<String> parameterNames) {
    final valueList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_hasPositionalParameterCondition),
        description: 'have positional parameter all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires executable members to have positional parameter at least one value in [parameterNames].
  HeimdallRule<ClassMember> havePositionalParameterAnyOf(Iterable<String> parameterNames) {
    final valueList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_hasPositionalParameterCondition),
        description: 'have positional parameter any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires executable members to have positional parameter none of [parameterNames].
  HeimdallRule<ClassMember> havePositionalParameterNoneOf(Iterable<String> parameterNames) {
    final valueList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(_hasPositionalParameterCondition),
        description: 'have positional parameter none of ${valueList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _hasPositionalParameterCondition(String value) {
  return memberCondition(
    'have positional parameter $value',
    (item, _) => _memberHasPositionalParameter(item, value),
  );
}

HeimdallCondition<ClassMember> _memberShouldNotHavePositionalParameter(String parameterName) {
  return prohibitedMemberCondition(
    'have positional parameter $parameterName',
    (item, _) => _memberHasPositionalParameter(item, parameterName),
  );
}

HeimdallPredicate<ClassMember> _hasPositionalParameterPredicate(String value) {
  return HeimdallPredicate(
    'have positional parameter $value',
    (item, project) => _memberHasPositionalParameter(item, value),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotHavePositionalParameter(String parameterName) {
  return HeimdallPredicate(
    'not have positional parameter $parameterName',
    (item, project) => !_memberHasPositionalParameter(item, parameterName),
  );
}

/// Returns `true` when [member] declares a positional parameter.
bool _memberHasPositionalParameter(ClassMember member, String parameterName) {
  return member.parameters.any(
    (parameter) => _isPositionalParameter(parameter, parameterName),
  );
}

bool _isPositionalParameter(FormalParameter parameter, String name) {
  if (parameter.name?.lexeme != name) {
    return false;
  }
  if (parameter is! DefaultFormalParameter) {
    return true;
  }
  return !parameter.isNamed;
}
