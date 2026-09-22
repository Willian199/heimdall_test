import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for member source path exclusion rules.
extension MemberResideOutsideOfPathPredicateRules on MemberPredicateBuilder {
  /// Selects members that reside outside a path matching [pattern].
  MemberPredicateBuilder resideOutsideOfPath(String pattern) => satisfy(_memberResideOutsideOfPath(pattern));

  /// Selects members that reside outside at least one path matching [patterns].
  MemberPredicateBuilder resideOutsideOfAtLeastOnePath(Iterable<String> patterns) {
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
}

/// Condition-side DSL for member source path exclusion rules.
extension MemberResideOutsideOfPathShouldRules on MemberShouldBuilder {
  /// Requires members to reside outside a path matching [pattern].
  HeimdallRule<ClassMember> resideOutsideOfPath(String pattern) => satisfy(_memberShouldResideOutsideOfPath(pattern));

  /// Requires members to reside outside at least one path matching [patterns].
  HeimdallRule<ClassMember> resideOutsideOfAtLeastOnePath(Iterable<String> patterns) {
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
