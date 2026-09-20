import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for executable constructor call rules.
extension MemberCallConstructorPredicateRules on MemberPredicateBuilder {
  /// Selects executable members that call constructor [typeName].
  MemberPredicateBuilder callConstructor(String typeName) {
    return satisfy(_memberMatchesCallConstructor(typeName));
  }

  /// Selects members that do not satisfy `callConstructor`.
  MemberPredicateBuilder noCallConstructor(String typeName) {
    return satisfy(
      HeimdallPredicate(
        'not call constructor $typeName',
        (item, project) => !_memberCallsConstructor(item, typeName, project),
      ),
    );
  }

  /// Selects executable members that call every constructor in [typeNames].
  MemberPredicateBuilder callAllConstructors(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.allOf(
        typeList.map(_memberMatchesCallConstructor),
        description: 'call all constructors ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects executable members that call at least one constructor in [typeNames].
  MemberPredicateBuilder callAnyConstructor(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        typeList.map(_memberMatchesCallConstructor),
        description: 'call any constructor ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects executable members that call none of the constructors in [typeNames].
  MemberPredicateBuilder callNoConstructors(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        typeList.map(_memberMatchesCallConstructor),
        description: 'call no constructors ${typeList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for executable constructor call rules.
extension MemberCallConstructorShouldRules on MemberShouldBuilder {
  /// Requires executable members to call constructor [typeName].
  HeimdallRule<ClassMember> callConstructor(String typeName) => satisfy(_memberShouldCallConstructor(typeName));

  /// Requires members not to satisfy `callConstructor`.
  HeimdallRule<ClassMember> noCallConstructor(String typeName) {
    return satisfy(
      prohibitedMemberCondition(
        'call constructor $typeName',
        (item, project) => _memberCallsConstructor(item, typeName, project),
      ),
    );
  }

  /// Requires executable members to call every constructor in [typeNames].
  HeimdallRule<ClassMember> callAllConstructors(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.allOf(
        typeList.map(_memberShouldCallConstructor),
        description: 'call all constructors ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires executable members to call at least one constructor in [typeNames].
  HeimdallRule<ClassMember> callAnyConstructor(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.anyOf(
        typeList.map(_memberShouldCallConstructor),
        description: 'call any constructor ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires executable members to call none of the constructors in [typeNames].
  HeimdallRule<ClassMember> callNoConstructors(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.noneOf(
        typeList.map(_memberShouldCallConstructor),
        description: 'call no constructors ${typeList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _memberShouldCallConstructor(String typeName) {
  return HeimdallCondition('call constructor $typeName', (item, project) {
    final findings = _memberCallsConstructor(item, typeName, project)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.ownerName}.${item.name} does not call constructor $typeName',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<ClassMember> _memberMatchesCallConstructor(String typeName) {
  return HeimdallPredicate(
    'call constructor $typeName',
    (item, project) => _memberCallsConstructor(item, typeName, project),
  );
}

/// Returns `true` when [member] calls a constructor of [typeName].
bool _memberCallsConstructor(ClassMember member, String typeName, HeimdallProject project) {
  return memberHasConstructorCallWhere(member, project, (name) => name == typeName);
}
