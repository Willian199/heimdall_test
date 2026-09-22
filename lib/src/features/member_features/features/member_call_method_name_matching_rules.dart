import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member pattern rules.
extension MemberCallMethodNameMatchingPredicateRules on MemberPredicateBuilder {
  /// Selects members that call method name matching [pattern].
  MemberPredicateBuilder callMethodNameMatching(RegExp pattern) {
    return satisfy(_callMethodNameMatchingPredicate(pattern));
  }

  /// Selects members that do not satisfy `callMethodNameMatching`.
  MemberPredicateBuilder notCallMethodNameMatching(RegExp pattern) {
    return satisfy(_memberDoesNotCallMethodNameMatching(pattern));
  }

  /// Selects members that call method name matching every value in [patterns].
  MemberPredicateBuilder callMethodNameMatchingAllOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.allOf(
        valueList.map(_callMethodNameMatchingPredicate),
        description: 'call method name matching all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members that call method name matching at least one value in [patterns].
  MemberPredicateBuilder callMethodNameMatchingAnyOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.anyOf(
        valueList.map(_callMethodNameMatchingPredicate),
        description: 'call method name matching any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members that call method name matching none of [patterns].
  MemberPredicateBuilder callMethodNameMatchingNoneOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.noneOf(
        valueList.map(_callMethodNameMatchingPredicate),
        description: 'call method name matching none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member pattern rules.
extension MemberCallMethodNameMatchingShouldRules on MemberShouldBuilder {
  /// Requires members to call method name matching [pattern].
  HeimdallRule<ClassMember> callMethodNameMatching(RegExp pattern) {
    return satisfy(_callMethodNameMatchingCondition(pattern));
  }

  /// Requires members not to satisfy `callMethodNameMatching`.
  HeimdallRule<ClassMember> notCallMethodNameMatching(RegExp pattern) {
    return satisfy(_memberShouldNotCallMethodNameMatching(pattern));
  }

  /// Requires members to call method name matching every value in [patterns].
  HeimdallRule<ClassMember> callMethodNameMatchingAllOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_callMethodNameMatchingCondition),
        description: 'call method name matching all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to call method name matching at least one value in [patterns].
  HeimdallRule<ClassMember> callMethodNameMatchingAnyOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_callMethodNameMatchingCondition),
        description: 'call method name matching any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to call method name matching none of [patterns].
  HeimdallRule<ClassMember> callMethodNameMatchingNoneOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(_callMethodNameMatchingCondition),
        description: 'call method name matching none of ${valueList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _callMethodNameMatchingCondition(RegExp pattern) {
  return HeimdallCondition('call method name matching $pattern', (item, _) {
    final invocation = memberMethodInvocationWhere(item, (methodName) => pattern.hasMatch(methodName));
    final passed = invocation != null;
    final location = invocation == null
        ? (
            line: item.location.lineNumber,
            column: item.location.columnNumber,
          )
        : item.sourceLocationAt(invocation.methodName.offset);
    return HeimdallFindings(
      subject: item,
      passed: passed,
      findings: [
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: location.line,
          column: location.column,
          message: passed
              ? '${item.ownerName}.${item.name} calls method name matching ${pattern.pattern}'
              : '${item.ownerName}.${item.name} should call method name matching ${pattern.pattern}',
        ),
      ],
    );
  });
}

bool _memberCallsMethodName(ClassMember item, RegExp pattern) {
  return memberHasMethodInvocationWhere(item, (methodName) => pattern.hasMatch(methodName));
}

HeimdallCondition<ClassMember> _memberShouldNotCallMethodNameMatching(RegExp pattern) {
  return prohibitedMemberCondition(
    'call method name matching ${pattern.pattern}',
    (item, project) => _memberCallsMethodName(item, pattern),
  );
}

HeimdallPredicate<ClassMember> _callMethodNameMatchingPredicate(RegExp pattern) {
  return HeimdallPredicate(
    'call method name matching ${pattern.pattern}',
    (item, project) => _memberCallsMethodName(item, pattern),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotCallMethodNameMatching(RegExp pattern) {
  return HeimdallPredicate(
    'not call method name matching ${pattern.pattern}',
    (item, project) => !_memberCallsMethodName(item, pattern),
  );
}
