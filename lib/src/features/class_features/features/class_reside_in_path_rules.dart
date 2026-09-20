import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for declaration path rules.
extension ClassResideInPathPredicateRules on ClassPredicateBuilder {
  /// Selects declarations whose relative path matches [pattern].
  ClassPredicateBuilder resideInPath(String pattern) {
    return satisfy(_classResideInPath(pattern));
  }

  /// Selects declarations whose relative path does not match [pattern].
  ClassPredicateBuilder noResideInPath(String pattern) {
    return satisfy(_classDoesNotResideInPath(pattern));
  }

  /// Selects declarations that reside in at least one path matching [patterns].
  ClassPredicateBuilder resideInAnyPath(Iterable<String> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.anyOf(
        patternList.map(_classResideInPath),
        description: 'reside in any path ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects declarations that reside in every path matching [patterns].
  ClassPredicateBuilder resideInAllPaths(Iterable<String> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.allOf(
        patternList.map(_classResideInPath),
        description: 'reside in all paths ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects declarations that reside in none of the paths matching [patterns].
  ClassPredicateBuilder resideInNoPaths(Iterable<String> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.noneOf(
        patternList.map(_classResideInPath),
        description: 'reside in no paths ${patternList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for declaration path rules.
extension ClassResideInPathShouldRules on ClassShouldBuilder {
  /// Requires matching classes to reside in a path matching [pattern].
  HeimdallRule<CompilationUnitMember> resideInPath(String pattern) {
    return satisfy(_classShouldResideInPath(pattern));
  }

  /// Requires matching classes to not reside in a path matching [pattern].
  HeimdallRule<CompilationUnitMember> noResideInPath(String pattern) {
    return satisfy(_classShouldNotResideInPath(pattern));
  }

  /// Requires matching classes to reside in at least one path matching [patterns].
  HeimdallRule<CompilationUnitMember> resideInAnyPath(
    Iterable<String> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        patternList.map(_classShouldResideInPath),
        description: 'reside in any path ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to reside in every path matching [patterns].
  HeimdallRule<CompilationUnitMember> resideInAllPaths(
    Iterable<String> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        patternList.map(_classShouldResideInPath),
        description: 'reside in all paths ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to reside in none of the paths matching [patterns].
  HeimdallRule<CompilationUnitMember> resideInNoPaths(
    Iterable<String> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.noneOf(
        patternList.map(_classShouldResideInPath),
        description: 'reside in no paths ${patternList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _classResideInPath(String pattern) {
  return HeimdallPredicate(
    'reside in path $pattern',
    (item, _) => pathMatches(item.relativePath, pattern),
  );
}

HeimdallPredicate<CompilationUnitMember> _classDoesNotResideInPath(String pattern) {
  return HeimdallPredicate(
    'not reside in path $pattern',
    (item, _) => !pathMatches(item.relativePath, pattern),
  );
}

HeimdallCondition<CompilationUnitMember> _classShouldResideInPath(
  String pattern,
) {
  return HeimdallCondition('reside in path $pattern', (item, _) {
    final findings = pathMatches(item.relativePath, pattern)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} should reside in path $pattern (actual: ${item.relativePath})',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotResideInPath(
  String pattern,
) {
  return HeimdallCondition('not reside in path $pattern', (item, _) {
    final findings = !pathMatches(item.relativePath, pattern)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} must not reside in path $pattern (actual: ${item.relativePath})',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
