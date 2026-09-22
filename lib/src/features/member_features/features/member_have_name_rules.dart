import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for exact member name rules.
extension MemberHaveNamePredicateRules on MemberPredicateBuilder {
  /// Selects members with exactly [name].
  MemberPredicateBuilder haveName(String name) => satisfy(_memberHasName(name));

  /// Selects members that do not satisfy `haveName`.
  MemberPredicateBuilder haveNameDifferentFrom(String name) {
    return satisfy(
      HeimdallPredicate(
        'not have name $name',
        (item, project) => item.name != name,
      ),
    );
  }

  /// Selects members with any name in [names].
  MemberPredicateBuilder haveNameEqualToAnyOf(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.anyOf(
        nameList.map(_memberHasName),
        description: 'have any name ${nameList.join(', ')}',
      ),
    );
  }

  /// Selects members with every name in [names].
  MemberPredicateBuilder haveNameEqualToAllOf(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.allOf(
        nameList.map(_memberHasName),
        description: 'have all names ${nameList.join(', ')}',
      ),
    );
  }

  /// Selects members with none of [names].
  MemberPredicateBuilder haveNameEqualToNoneOf(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.noneOf(
        nameList.map(_memberHasName),
        description: 'have no names ${nameList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for exact member name rules.
extension MemberHaveNameShouldRules on MemberShouldBuilder {
  /// Requires member names to equal [name].
  HeimdallRule<ClassMember> haveName(String name) {
    return satisfy(_memberShouldHaveName(name));
  }

  /// Requires members not to satisfy `haveName`.
  HeimdallRule<ClassMember> haveNameDifferentFrom(String name) {
    return satisfy(
      prohibitedMemberCondition(
        'have name $name',
        (item, project) => item.name == name,
      ),
    );
  }

  /// Requires member names to equal at least one name in [names].
  HeimdallRule<ClassMember> haveNameEqualToAnyOf(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.anyOf(
        nameList.map(_memberShouldHaveName),
        description: 'have any name ${nameList.join(', ')}',
      ),
    );
  }

  /// Requires member names to equal every name in [names].
  HeimdallRule<ClassMember> haveNameEqualToAllOf(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.allOf(
        nameList.map(_memberShouldHaveName),
        description: 'have all names ${nameList.join(', ')}',
      ),
    );
  }

  /// Requires member names to equal none of [names].
  HeimdallRule<ClassMember> haveNameEqualToNoneOf(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.noneOf(
        nameList.map(_memberShouldHaveName),
        description: 'have no names ${nameList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<ClassMember> _memberHasName(String name) {
  return HeimdallPredicate('have name $name', (item, _) => item.name == name);
}

HeimdallCondition<ClassMember> _memberShouldHaveName(String name) {
  return HeimdallCondition('have name $name', (item, _) {
    final findings = item.name == name
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.ownerName}.${item.name} should have name $name',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
