import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for executable method call rules.
extension MemberCallMethodPredicateRules on MemberPredicateBuilder {
  /// Selects executable members that call [methodName].
  MemberPredicateBuilder callMethod(String methodName) {
    return satisfy(_memberMatchesCallMethod(methodName));
  }

  /// Selects members that do not satisfy `callMethod`.
  MemberPredicateBuilder notCallMethod(String methodName) {
    return satisfy(
      HeimdallPredicate(
        'not call method $methodName',
        (item, project) => !_memberCallsMethod(item, methodName),
      ),
    );
  }

  /// Selects executable members that call every method in [methodNames].
  MemberPredicateBuilder callAllMethods(Iterable<String> methodNames) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallPredicate.allOf(
        methodList.map(_memberMatchesCallMethod),
        description: 'call all methods ${methodList.join(', ')}',
      ),
    );
  }

  /// Selects executable members that call at least one method in [methodNames].
  MemberPredicateBuilder callAnyMethod(Iterable<String> methodNames) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        methodList.map(_memberMatchesCallMethod),
        description: 'call any method ${methodList.join(', ')}',
      ),
    );
  }

  /// Selects executable members that call none of [methodNames].
  MemberPredicateBuilder callNoMethods(Iterable<String> methodNames) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        methodList.map(_memberMatchesCallMethod),
        description: 'call no methods ${methodList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for executable method call rules.
extension MemberCallMethodShouldRules on MemberShouldBuilder {
  /// Requires executable members to call [methodName].
  HeimdallRule<ClassMember> callMethod(String methodName) => satisfy(_memberShouldCallMethod(methodName));

  /// Requires members not to satisfy `callMethod`.
  HeimdallRule<ClassMember> notCallMethod(String methodName) {
    return satisfy(
      prohibitedMemberCondition(
        'call method $methodName',
        (item, project) => _memberCallsMethod(item, methodName),
      ),
    );
  }

  /// Requires executable members to call every method in [methodNames].
  HeimdallRule<ClassMember> callAllMethods(Iterable<String> methodNames) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallCondition.allOf(
        methodList.map(_memberShouldCallMethod),
        description: 'call all methods ${methodList.join(', ')}',
      ),
    );
  }

  /// Requires executable members to call at least one method in [methodNames].
  HeimdallRule<ClassMember> callAnyMethod(Iterable<String> methodNames) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallCondition.anyOf(
        methodList.map(_memberShouldCallMethod),
        description: 'call any method ${methodList.join(', ')}',
      ),
    );
  }

  /// Requires executable members to call none of [methodNames].
  HeimdallRule<ClassMember> callNoMethods(Iterable<String> methodNames) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallCondition.noneOf(
        methodList.map(_memberShouldCallMethod),
        description: 'call no methods ${methodList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _memberShouldCallMethod(String methodName) {
  return HeimdallCondition('call method $methodName', (item, _) {
    final findings = _memberCallsMethod(item, methodName)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.ownerName}.${item.name} does not call $methodName',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<ClassMember> _memberMatchesCallMethod(String methodName) {
  return HeimdallPredicate(
    'call method $methodName',
    (item, project) => _memberCallsMethod(item, methodName),
  );
}

/// Returns `true` when [member] calls [methodName].
bool _memberCallsMethod(ClassMember member, String methodName) {
  return memberHasMethodInvocationWhere(member, (name) => name == methodName);
}
