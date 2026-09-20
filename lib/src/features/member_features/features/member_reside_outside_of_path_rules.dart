import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member source path exclusion rules.
extension MemberResideOutsideOfPathPredicateRules on MemberPredicateBuilder {
  /// Selects members that reside outside a path matching [pattern].
  MemberPredicateBuilder resideOutsideOfPath(String pattern) => satisfy(_memberResideOutsideOfPath(pattern));

  /// Selects members that do not satisfy `resideOutsideOfPath`.
  MemberPredicateBuilder noResideOutsideOfPath(String pattern) {
    return satisfy(_memberDoesNotResideOutsideOfPath(pattern));
  }

  /// Selects members that reside outside at least one path matching [patterns].
  MemberPredicateBuilder resideOutsideOfAnyPath(Iterable<String> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.anyOf(patternList.map(_memberResideOutsideOfPath), description: 'reside outside of any path ${patternList.join(', ')}'),
    );
  }

  /// Selects members that reside outside every path matching [patterns].
  MemberPredicateBuilder resideOutsideOfAllPaths(Iterable<String> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.allOf(patternList.map(_memberResideOutsideOfPath), description: 'reside outside of all paths ${patternList.join(', ')}'),
    );
  }

  /// Selects members that reside outside none of the paths matching [patterns].
  MemberPredicateBuilder resideOutsideOfNoPaths(Iterable<String> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.noneOf(patternList.map(_memberResideOutsideOfPath), description: 'reside outside of no paths ${patternList.join(', ')}'),
    );
  }
}

/// Condition-side DSL for member source path exclusion rules.
extension MemberResideOutsideOfPathShouldRules on MemberShouldBuilder {
  /// Requires members to reside outside a path matching [pattern].
  HeimdallRule<ClassMember> resideOutsideOfPath(String pattern) => satisfy(_memberShouldResideOutsideOfPath(pattern));

  /// Requires members not to satisfy `resideOutsideOfPath`.
  HeimdallRule<ClassMember> noResideOutsideOfPath(String pattern) {
    return satisfy(_memberShouldNotResideOutsideOfPath(pattern));
  }

  /// Requires members to reside outside at least one path matching [patterns].
  HeimdallRule<ClassMember> resideOutsideOfAnyPath(Iterable<String> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(patternList.map(_memberShouldResideOutsideOfPath), description: 'reside outside of any path ${patternList.join(', ')}'),
    );
  }

  /// Requires members to reside outside every path matching [patterns].
  HeimdallRule<ClassMember> resideOutsideOfAllPaths(Iterable<String> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        patternList.map(_memberShouldResideOutsideOfPath),
        description: 'reside outside of all paths ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires members to reside outside none of the paths matching [patterns].
  HeimdallRule<ClassMember> resideOutsideOfNoPaths(Iterable<String> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.noneOf(
        patternList.map(_memberShouldResideOutsideOfPath),
        description: 'reside outside of no paths ${patternList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<ClassMember> _memberResideOutsideOfPath(String pattern) {
  return HeimdallPredicate('reside outside of path $pattern', (item, _) => !pathMatches(item.relativePath, pattern));
}

HeimdallCondition<ClassMember> _memberShouldResideOutsideOfPath(String pattern) {
  return HeimdallCondition('reside outside of path $pattern', (item, _) {
    final findings = !pathMatches(item.relativePath, pattern)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.ownerName}.${item.name} should reside outside of path $pattern (actual: ${item.relativePath})',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<ClassMember> _memberShouldNotResideOutsideOfPath(String pattern) {
  return prohibitedMemberCondition(
    'reside outside of path $pattern',
    (item, project) => !pathMatches(item.relativePath, pattern),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotResideOutsideOfPath(String pattern) {
  return HeimdallPredicate(
    'not reside outside of path $pattern',
    (item, project) => pathMatches(item.relativePath, pattern),
  );
}
