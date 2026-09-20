import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member name prefix rules.
extension MemberHaveNameStartingWithPredicateRules on MemberPredicateBuilder {
  /// Selects members whose names start with [prefix].
  MemberPredicateBuilder haveNameStartingWith(String prefix) {
    return satisfy(_memberNameStartsWith(prefix));
  }

  /// Selects members that do not satisfy `haveNameStartingWith`.
  MemberPredicateBuilder noHaveNameStartingWith(String prefix) {
    return satisfy(_memberDoesNotHaveNameStartingWith(prefix));
  }

  /// Selects members whose names start with at least one prefix in [prefixes].
  MemberPredicateBuilder haveNameStartingWithAny(Iterable<String> prefixes) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        prefixList.map(_memberNameStartsWith),
        description: 'have name starting with any of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Selects members whose names start with every prefix in [prefixes].
  MemberPredicateBuilder haveNameStartingWithAll(Iterable<String> prefixes) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.allOf(
        prefixList.map(_memberNameStartsWith),
        description: 'have name starting with all of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Selects members whose names start with none of [prefixes].
  MemberPredicateBuilder haveNameStartingWithNone(Iterable<String> prefixes) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        prefixList.map(_memberNameStartsWith),
        description: 'have name starting with none of ${prefixList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member name prefix rules.
extension MemberHaveNameStartingWithShouldRules on MemberShouldBuilder {
  /// Requires member names to start with [prefix].
  HeimdallRule<ClassMember> haveNameStartingWith(String prefix) {
    return satisfy(_memberShouldHaveNameStartingWith(prefix));
  }

  /// Requires members not to satisfy `haveNameStartingWith`.
  HeimdallRule<ClassMember> noHaveNameStartingWith(String prefix) {
    return satisfy(_memberShouldNotHaveNameStartingWith(prefix));
  }

  /// Requires member names to start with at least one prefix in [prefixes].
  HeimdallRule<ClassMember> haveNameStartingWithAny(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.anyOf(
        prefixList.map(_memberShouldHaveNameStartingWith),
        description: 'have name starting with any of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Requires member names to start with every prefix in [prefixes].
  HeimdallRule<ClassMember> haveNameStartingWithAll(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.allOf(
        prefixList.map(_memberShouldHaveNameStartingWith),
        description: 'have name starting with all of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Requires member names to start with none of [prefixes].
  HeimdallRule<ClassMember> haveNameStartingWithNone(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.noneOf(
        prefixList.map(_memberShouldHaveNameStartingWith),
        description: 'have name starting with none of ${prefixList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<ClassMember> _memberNameStartsWith(String prefix) {
  return HeimdallPredicate(
    'have name starting with $prefix',
    (item, _) => item.name.startsWith(prefix),
  );
}

HeimdallCondition<ClassMember> _memberShouldHaveNameStartingWith(
  String prefix,
) {
  return HeimdallCondition('have name starting with $prefix', (item, _) {
    final findings = item.name.startsWith(prefix)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.ownerName}.${item.name} should start with $prefix',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<ClassMember> _memberShouldNotHaveNameStartingWith(String prefix) {
  return prohibitedMemberCondition(
    'have name starting with $prefix',
    (item, project) => item.name.startsWith(prefix),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotHaveNameStartingWith(String prefix) {
  return HeimdallPredicate(
    'not have name starting with $prefix',
    (item, project) => !item.name.startsWith(prefix),
  );
}
