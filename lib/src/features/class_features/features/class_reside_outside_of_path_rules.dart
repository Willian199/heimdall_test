import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for declaration path exclusion rules.
extension ClassResideOutsideOfPathPredicateRules on ClassPredicateBuilder {
  /// Selects declarations whose relative path does not match [pattern].
  ClassPredicateBuilder resideOutsideOfPath(String pattern) {
    return satisfy(_classResideOutsideOfPath(pattern));
  }

  /// Selects declarations that reside outside at least one path matching [patterns].
  ClassPredicateBuilder resideOutsideOfAtLeastOnePath(Iterable<String> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.anyOf(
        patternList.map(_classResideOutsideOfPath),
        description: 'reside outside of any path ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects declarations that reside outside every path matching [patterns].
  ClassPredicateBuilder resideOutsideOfAllPaths(Iterable<String> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.allOf(
        patternList.map(_classResideOutsideOfPath),
        description: 'reside outside of all paths ${patternList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for declaration path exclusion rules.
extension ClassResideOutsideOfPathShouldRules on ClassShouldBuilder {
  /// Requires matching classes to reside outside paths matching [pattern].
  HeimdallRule<CompilationUnitMember> resideOutsideOfPath(String pattern) {
    return satisfy(_classShouldResideOutsideOfPath(pattern));
  }

  /// Requires matching classes to reside outside at least one path matching [patterns].
  HeimdallRule<CompilationUnitMember> resideOutsideOfAtLeastOnePath(
    Iterable<String> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        patternList.map(_classShouldResideOutsideOfPath),
        description: 'reside outside of any path ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to reside outside every path matching [patterns].
  HeimdallRule<CompilationUnitMember> resideOutsideOfAllPaths(
    Iterable<String> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        patternList.map(_classShouldResideOutsideOfPath),
        description: 'reside outside of all paths ${patternList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _classResideOutsideOfPath(String pattern) {
  return HeimdallPredicate(
    'reside outside of path $pattern',
    (item, _) => !pathMatches(item.relativePath, pattern),
  );
}

HeimdallCondition<CompilationUnitMember> _classShouldResideOutsideOfPath(
  String pattern,
) {
  return HeimdallCondition('reside outside of path $pattern', (item, _) {
    final findings = !pathMatches(item.relativePath, pattern)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} should reside outside of path $pattern (actual: ${item.relativePath})',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
