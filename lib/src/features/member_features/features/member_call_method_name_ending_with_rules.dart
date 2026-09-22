import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/core/behavior_rule/heimdall_rule.dart';
import 'package:heimdall_test/src/core/heimdall_condition.dart';
import 'package:heimdall_test/src/core/heimdall_predicate.dart';
import 'package:heimdall_test/src/core/member_rules/member_predicate_builder.dart';
import 'package:heimdall_test/src/core/member_rules/member_should_builder.dart';
import 'package:heimdall_test/src/core/non_empty_iterable.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member pattern rules.
extension MemberCallMethodNameEndingWithPredicateRules on MemberPredicateBuilder {
  /// Selects members that call method name ending with [suffix].
  MemberPredicateBuilder callMethodNameEndingWith(String suffix) {
    return satisfy(_callMethodNameEndingWithPredicate(suffix));
  }

  /// Selects members that do not satisfy `callMethodNameEndingWith`.
  MemberPredicateBuilder notCallMethodNameEndingWith(String suffix) {
    return satisfy(
      HeimdallPredicate(
        'not call method name ending with $suffix',
        (item, project) => !_memberCallsMethodName(item, suffix),
      ),
    );
  }

  /// Selects members that call method name ending with every value in [suffixes].
  MemberPredicateBuilder callMethodNameEndingWithAllOf(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.allOf(
        valueList.map(_callMethodNameEndingWithPredicate),
        description: 'call method name ending with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members that call method name ending with at least one value in [suffixes].
  MemberPredicateBuilder callMethodNameEndingWithAnyOf(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        valueList.map(_callMethodNameEndingWithPredicate),
        description: 'call method name ending with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members that call method name ending with none of [suffixes].
  MemberPredicateBuilder callMethodNameEndingWithNoneOf(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        valueList.map(_callMethodNameEndingWithPredicate),
        description: 'call method name ending with none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member pattern rules.
extension MemberCallMethodNameEndingWithShouldRules on MemberShouldBuilder {
  /// Requires members to call method name ending with [suffix].
  HeimdallRule<ClassMember> callMethodNameEndingWith(String suffix) {
    return satisfy(_callMethodNameEndingWithCondition(suffix));
  }

  /// Requires members not to satisfy `callMethodNameEndingWith`.
  HeimdallRule<ClassMember> notCallMethodNameEndingWith(String suffix) {
    return satisfy(
      prohibitedMemberCondition(
        'call method name ending with $suffix',
        (item, project) => _memberCallsMethodName(item, suffix),
      ),
    );
  }

  /// Requires members to call method name ending with every value in [suffixes].
  HeimdallRule<ClassMember> callMethodNameEndingWithAllOf(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_callMethodNameEndingWithCondition),
        description: 'call method name ending with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to call method name ending with at least one value in [suffixes].
  HeimdallRule<ClassMember> callMethodNameEndingWithAnyOf(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_callMethodNameEndingWithCondition),
        description: 'call method name ending with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to call method name ending with none of [suffixes].
  HeimdallRule<ClassMember> callMethodNameEndingWithNoneOf(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(_callMethodNameEndingWithCondition),
        description: 'call method name ending with none of ${valueList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _callMethodNameEndingWithCondition(String suffix) {
  return memberCondition(
    'call method name ending with $suffix',
    (item, _) => _memberCallsMethodName(item, suffix),
  );
}

bool _memberCallsMethodName(ClassMember item, String suffix) {
  return memberHasMethodInvocationWhere(item, (methodName) => methodName.endsWith(suffix));
}

HeimdallPredicate<ClassMember> _callMethodNameEndingWithPredicate(String suffix) {
  return HeimdallPredicate(
    'call method name ending with $suffix',
    (item, project) => _memberCallsMethodName(item, suffix),
  );
}
