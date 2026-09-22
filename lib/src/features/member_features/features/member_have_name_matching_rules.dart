import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member name pattern rules.
extension MemberHaveNameMatchingPredicateRules on MemberPredicateBuilder {
  /// Selects members whose names match [pattern].
  MemberPredicateBuilder haveNameMatching(RegExp pattern) {
    return satisfy(_memberNameMatches(pattern));
  }

  /// Selects members that do not satisfy `haveNameMatching`.
  MemberPredicateBuilder notHaveNameMatching(RegExp pattern) {
    return satisfy(_memberDoesNotHaveNameMatching(pattern));
  }

  /// Selects members whose names match at least one pattern in [patterns].
  MemberPredicateBuilder haveNameMatchingAnyOf(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.anyOf(
        patternList.map(_memberNameMatches),
        description: 'have name matching any of ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects members whose names match every pattern in [patterns].
  MemberPredicateBuilder haveNameMatchingAllOf(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.allOf(
        patternList.map(_memberNameMatches),
        description: 'have name matching all of ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects members whose names match none of [patterns].
  MemberPredicateBuilder haveNameMatchingNoneOf(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.noneOf(
        patternList.map(_memberNameMatches),
        description: 'have name matching none of ${patternList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member name pattern rules.
extension MemberHaveNameMatchingShouldRules on MemberShouldBuilder {
  /// Requires member names to match [pattern].
  HeimdallRule<ClassMember> haveNameMatching(RegExp pattern) {
    return satisfy(_memberShouldHaveNameMatching(pattern));
  }

  /// Requires members not to satisfy `haveNameMatching`.
  HeimdallRule<ClassMember> notHaveNameMatching(RegExp pattern) {
    return satisfy(_memberShouldNotHaveNameMatching(pattern));
  }

  /// Requires member names to match at least one pattern in [patterns].
  HeimdallRule<ClassMember> haveNameMatchingAnyOf(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        patternList.map(_memberShouldHaveNameMatching),
        description: 'have name matching any of ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires member names to match every pattern in [patterns].
  HeimdallRule<ClassMember> haveNameMatchingAllOf(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        patternList.map(_memberShouldHaveNameMatching),
        description: 'have name matching all of ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires member names to match none of [patterns].
  HeimdallRule<ClassMember> haveNameMatchingNoneOf(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.noneOf(
        patternList.map(_memberShouldHaveNameMatching),
        description: 'have name matching none of ${patternList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<ClassMember> _memberNameMatches(RegExp pattern) {
  return HeimdallPredicate(
    'have name matching ${pattern.pattern}',
    (item, _) => pattern.hasMatch(item.name),
  );
}

HeimdallCondition<ClassMember> _memberShouldHaveNameMatching(RegExp pattern) {
  return HeimdallCondition('have name matching ${pattern.pattern}', (item, _) {
    final matches = pattern.hasMatch(item.name);
    final location = item.location;
    final findings = [
      if (matches)
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: item.line,
          column: location.columnNumber,
          message: '${item.ownerName}.${item.name} matches ${pattern.pattern}',
        )
      else
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: item.line,
          message: '${item.ownerName}.${item.name} should match ${pattern.pattern}',
        ),
    ];

    return HeimdallFindings(
      subject: item,
      passed: matches,
      findings: findings,
    );
  });
}

HeimdallCondition<ClassMember> _memberShouldNotHaveNameMatching(RegExp pattern) {
  return prohibitedMemberCondition(
    'have name matching ${pattern.pattern}',
    (item, project) => pattern.hasMatch(item.name),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotHaveNameMatching(RegExp pattern) {
  return HeimdallPredicate(
    'not have name matching ${pattern.pattern}',
    (item, project) => !pattern.hasMatch(item.name),
  );
}
