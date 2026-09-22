import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/core/behavior_rule/heimdall_rule.dart';
import 'package:heimdall_test/src/core/heimdall_condition.dart';
import 'package:heimdall_test/src/core/heimdall_predicate.dart';
import 'package:heimdall_test/src/core/member_rules/member_predicate_builder.dart';
import 'package:heimdall_test/src/core/member_rules/member_should_builder.dart';
import 'package:heimdall_test/src/core/non_empty_iterable.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member pattern rules.
extension MemberCallMethodNameStartingWithPredicateRules on MemberPredicateBuilder {
  /// Selects members that call method name starting with [prefix].
  MemberPredicateBuilder callMethodNameStartingWith(String prefix) {
    return satisfy(_callMethodNameStartingWithPredicate(prefix));
  }

  /// Selects members that do not satisfy `callMethodNameStartingWith`.
  MemberPredicateBuilder notCallMethodNameStartingWith(String prefix) {
    return satisfy(_memberDoesNotCallMethodNameStartingWith(prefix));
  }

  /// Selects members that call method name starting with every value in [prefixes].
  MemberPredicateBuilder callMethodNameStartingWithAllOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.allOf(
        valueList.map(_callMethodNameStartingWithPredicate),
        description: 'call method name starting with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members that call method name starting with at least one value in [prefixes].
  MemberPredicateBuilder callMethodNameStartingWithAnyOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        valueList.map(_callMethodNameStartingWithPredicate),
        description: 'call method name starting with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members that call method name starting with none of [prefixes].
  MemberPredicateBuilder callMethodNameStartingWithNoneOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        valueList.map(_callMethodNameStartingWithPredicate),
        description: 'call method name starting with none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member pattern rules.
extension MemberCallMethodNameStartingWithShouldRules on MemberShouldBuilder {
  /// Requires members to call method name starting with [prefix].
  HeimdallRule<ClassMember> callMethodNameStartingWith(String prefix) {
    return satisfy(_callMethodNameStartingWithCondition(prefix));
  }

  /// Requires members not to satisfy `callMethodNameStartingWith`.
  HeimdallRule<ClassMember> notCallMethodNameStartingWith(String prefix) {
    return satisfy(_memberShouldNotCallMethodNameStartingWith(prefix));
  }

  /// Requires members to call method name starting with every value in [prefixes].
  HeimdallRule<ClassMember> callMethodNameStartingWithAllOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_callMethodNameStartingWithCondition),
        description: 'call method name starting with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to call method name starting with at least one value in [prefixes].
  HeimdallRule<ClassMember> callMethodNameStartingWithAnyOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_callMethodNameStartingWithCondition),
        description: 'call method name starting with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to call method name starting with none of [prefixes].
  HeimdallRule<ClassMember> callMethodNameStartingWithNoneOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(_callMethodNameStartingWithCondition),
        description: 'call method name starting with none of ${valueList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _callMethodNameStartingWithCondition(String prefix) {
  return memberCondition(
    'call method name starting with $prefix',
    (item, _) => _memberCallsMethodName(item, prefix),
  );
}

bool _memberCallsMethodName(ClassMember item, String prefix) {
  return memberHasMethodInvocationWhere(item, (methodName) => methodName.startsWith(prefix));
}

HeimdallCondition<ClassMember> _memberShouldNotCallMethodNameStartingWith(String prefix) {
  return prohibitedMemberCondition(
    'call method name starting with $prefix',
    (item, project) => _memberCallsMethodName(item, prefix),
  );
}

HeimdallPredicate<ClassMember> _callMethodNameStartingWithPredicate(String prefix) {
  return HeimdallPredicate(
    'call method name starting with $prefix',
    (item, project) => _memberCallsMethodName(item, prefix),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotCallMethodNameStartingWith(String prefix) {
  return HeimdallPredicate(
    'not call method name starting with $prefix',
    (item, project) => !_memberCallsMethodName(item, prefix),
  );
}
