import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';
import 'package:heimdall_test/src/features/queries/static_method_queries.dart';

/// Predicate-side DSL for static method invocation rules.
extension MemberCallStaticMethodPredicateRules on MemberPredicateBuilder {
  /// Selects executable members that call [methodName] on [targetType].
  MemberPredicateBuilder callStaticMethod(String targetType, String methodName) {
    return satisfy(_memberMatchesCallStaticMethod(targetType, methodName));
  }

  /// Selects members that do not satisfy `callStaticMethod`.
  MemberPredicateBuilder notCallStaticMethod(String targetType, String methodName) {
    return satisfy(_memberDoesNotCallStaticMethod(targetType, methodName));
  }

  /// Selects executable members that call every method in [methodNames] on [targetType].
  MemberPredicateBuilder callAllStaticMethods(
    String targetType,
    Iterable<String> methodNames,
  ) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallPredicate.allOf(
        methodList.map((name) => _memberMatchesCallStaticMethod(targetType, name)),
        description: 'call all static methods ${methodList.join(', ')} on $targetType',
      ),
    );
  }

  /// Selects executable members that call at least one method in [methodNames] on [targetType].
  MemberPredicateBuilder callAnyStaticMethod(
    String targetType,
    Iterable<String> methodNames,
  ) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        methodList.map((name) => _memberMatchesCallStaticMethod(targetType, name)),
        description: 'call any static method ${methodList.join(', ')} on $targetType',
      ),
    );
  }

  /// Selects executable members that call none of [methodNames] on [targetType].
  MemberPredicateBuilder callNoStaticMethods(
    String targetType,
    Iterable<String> methodNames,
  ) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        methodList.map((name) => _memberMatchesCallStaticMethod(targetType, name)),
        description: 'call no static methods ${methodList.join(', ')} on $targetType',
      ),
    );
  }
}

/// Condition-side DSL for static method invocation rules.
extension MemberCallStaticMethodShouldRules on MemberShouldBuilder {
  /// Requires executable members to call [methodName] on [targetType].
  HeimdallRule<ClassMember> callStaticMethod(
    String targetType,
    String methodName,
  ) {
    return satisfy(_memberShouldCallStaticMethod(targetType, methodName));
  }

  /// Requires members not to satisfy `callStaticMethod`.
  HeimdallRule<ClassMember> notCallStaticMethod(
    String targetType,
    String methodName,
  ) {
    return satisfy(_memberShouldNotCallStaticMethod(targetType, methodName));
  }

  /// Requires executable members to call every method in [methodNames] on [targetType].
  HeimdallRule<ClassMember> callAllStaticMethods(
    String targetType,
    Iterable<String> methodNames,
  ) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallCondition.allOf(
        methodList.map((name) => _memberShouldCallStaticMethod(targetType, name)),
        description: 'call all static methods ${methodList.join(', ')} on $targetType',
      ),
    );
  }

  /// Requires executable members to call at least one method in [methodNames] on [targetType].
  HeimdallRule<ClassMember> callAnyStaticMethod(
    String targetType,
    Iterable<String> methodNames,
  ) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallCondition.anyOf(
        methodList.map((name) => _memberShouldCallStaticMethod(targetType, name)),
        description: 'call any static method ${methodList.join(', ')} on $targetType',
      ),
    );
  }

  /// Requires executable members to call none of [methodNames] on [targetType].
  HeimdallRule<ClassMember> callNoStaticMethods(
    String targetType,
    Iterable<String> methodNames,
  ) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallCondition.noneOf(
        methodList.map((name) => _memberShouldCallStaticMethod(targetType, name)),
        description: 'call no static methods ${methodList.join(', ')} on $targetType',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _memberShouldCallStaticMethod(
  String targetType,
  String methodName,
) {
  return HeimdallCondition('call static method $targetType.$methodName', (
    item,
    project,
  ) {
    final findings = _memberCallsStaticMethod(item, targetType, methodName, project)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.ownerName}.${item.name} does not call static method $targetType.$methodName',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<ClassMember> _memberShouldNotCallStaticMethod(
  String targetType,
  String methodName,
) {
  return prohibitedMemberCondition(
    'call static method $targetType.$methodName',
    (item, project) => _memberCallsStaticMethod(item, targetType, methodName, project),
  );
}

HeimdallPredicate<ClassMember> _memberMatchesCallStaticMethod(
  String targetType,
  String methodName,
) {
  return HeimdallPredicate(
    'call static method $targetType.$methodName',
    (item, project) => _memberCallsStaticMethod(item, targetType, methodName, project),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotCallStaticMethod(
  String targetType,
  String methodName,
) {
  return HeimdallPredicate(
    'not call static method $targetType.$methodName',
    (item, project) => !_memberCallsStaticMethod(item, targetType, methodName, project),
  );
}

/// Returns `true` when [member] calls [methodName] on [targetType].
bool _memberCallsStaticMethod(
  ClassMember member,
  String targetType,
  String methodName,
  HeimdallProject project,
) {
  for (final root in member.executableRoots) {
    if (astNodeHasStaticMethodInvocation(root, targetType, methodName, project)) {
      return true;
    }
  }
  return false;
}
