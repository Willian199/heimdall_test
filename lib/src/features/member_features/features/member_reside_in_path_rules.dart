import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for member source path rules.
extension MemberResideInPathPredicateRules on MemberPredicateBuilder {
  /// Selects members whose relative source path matches [pattern].
  MemberPredicateBuilder resideInPath(String pattern) => satisfy(_memberResideInPath(pattern));

  /// Selects members that reside in at least one path matching [patterns].
  MemberPredicateBuilder resideInAnyPath(Iterable<String> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(HeimdallPredicate.anyOf(patternList.map(_memberResideInPath), description: 'reside in any path ${patternList.join(', ')}'));
  }

  /// Selects members that reside in every path matching [patterns].
  MemberPredicateBuilder resideInAllPaths(Iterable<String> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(HeimdallPredicate.allOf(patternList.map(_memberResideInPath), description: 'reside in all paths ${patternList.join(', ')}'));
  }
}

/// Condition-side DSL for member source path rules.
extension MemberResideInPathShouldRules on MemberShouldBuilder {
  /// Requires members to reside in a path matching [pattern].
  HeimdallRule<ClassMember> resideInPath(String pattern) => satisfy(_memberShouldResideInPath(pattern));

  /// Requires members to reside in at least one path matching [patterns].
  HeimdallRule<ClassMember> resideInAnyPath(Iterable<String> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(HeimdallCondition.anyOf(patternList.map(_memberShouldResideInPath), description: 'reside in any path ${patternList.join(', ')}'));
  }

  /// Requires members to reside in every path matching [patterns].
  HeimdallRule<ClassMember> resideInAllPaths(Iterable<String> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(HeimdallCondition.allOf(patternList.map(_memberShouldResideInPath), description: 'reside in all paths ${patternList.join(', ')}'));
  }
}

HeimdallPredicate<ClassMember> _memberResideInPath(String pattern) {
  return HeimdallPredicate('reside in path $pattern', (item, _) => pathMatches(item.relativePath, pattern));
}

HeimdallCondition<ClassMember> _memberShouldResideInPath(String pattern) {
  return HeimdallCondition('reside in path $pattern', (item, _) {
    final findings = pathMatches(item.relativePath, pattern)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.ownerName}.${item.name} should reside in path $pattern (actual: ${item.relativePath})',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
