import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for declaration path regex rules.
extension ClassResideInPathMatchingPredicateRules on ClassPredicateBuilder {
  /// Selects declarations whose relative path matches [pattern].
  ClassPredicateBuilder resideInPathMatching(RegExp pattern) {
    return satisfy(_classResideInPathMatching(pattern));
  }

  /// Selects declarations whose relative path does not match [pattern].
  ClassPredicateBuilder resideOutsideOfPathMatching(RegExp pattern) {
    return satisfy(_classDoesNotResideInPathMatching(pattern));
  }

  /// Selects declarations whose relative path matches at least one regex in [patterns].
  ClassPredicateBuilder resideInAnyPathMatching(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.anyOf(
        patternList.map(_classResideInPathMatching),
        description: 'reside in any path matching ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects declarations whose relative path matches every regex in [patterns].
  ClassPredicateBuilder resideInAllPathsMatching(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.allOf(
        patternList.map(_classResideInPathMatching),
        description: 'reside in all paths matching ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects declarations whose relative path matches none of [patterns].
  ClassPredicateBuilder resideOutsideOfAllPathsMatching(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.noneOf(
        patternList.map(_classResideInPathMatching),
        description: 'reside in no paths matching ${patternList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for declaration path regex rules.
extension ClassResideInPathMatchingShouldRules on ClassShouldBuilder {
  /// Requires matching classes to reside in a path matching [pattern].
  HeimdallRule<CompilationUnitMember> resideInPathMatching(RegExp pattern) {
    return satisfy(_classShouldResideInPathMatching(pattern));
  }

  /// Requires matching classes to not reside in a path matching [pattern].
  HeimdallRule<CompilationUnitMember> resideOutsideOfPathMatching(RegExp pattern) {
    return satisfy(_classShouldNotResideInPathMatching(pattern));
  }

  /// Requires matching classes to reside in a path matching at least one regex in [patterns].
  HeimdallRule<CompilationUnitMember> resideInAnyPathMatching(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        patternList.map(_classShouldResideInPathMatching),
        description: 'reside in any path matching ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to reside in a path matching every regex in [patterns].
  HeimdallRule<CompilationUnitMember> resideInAllPathsMatching(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        patternList.map(_classShouldResideInPathMatching),
        description: 'reside in all paths matching ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to reside in a path matching none of [patterns].
  HeimdallRule<CompilationUnitMember> resideOutsideOfAllPathsMatching(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.noneOf(
        patternList.map(_classShouldResideInPathMatching),
        description: 'reside in no paths matching ${patternList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _classResideInPathMatching(
  RegExp pattern,
) {
  return HeimdallPredicate(
    'reside in path matching ${pattern.pattern}',
    (item, _) => pattern.hasMatch(item.relativePath),
  );
}

HeimdallPredicate<CompilationUnitMember> _classDoesNotResideInPathMatching(
  RegExp pattern,
) {
  return HeimdallPredicate(
    'not reside in path matching ${pattern.pattern}',
    (item, _) => !pattern.hasMatch(item.relativePath),
  );
}

HeimdallCondition<CompilationUnitMember> _classShouldResideInPathMatching(
  RegExp pattern,
) {
  return HeimdallCondition('reside in path matching ${pattern.pattern}', (item, _) {
    final matches = pattern.hasMatch(item.relativePath);
    final findings = [
      if (matches)
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: item.line,
          message: '${item.name} resides in path matching ${pattern.pattern} (actual: ${item.relativePath})',
        )
      else
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: item.line,
          message: '${item.name} should reside in path matching ${pattern.pattern} (actual: ${item.relativePath})',
        ),
    ];

    return HeimdallFindings(
      subject: item,
      passed: matches,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotResideInPathMatching(
  RegExp pattern,
) {
  return HeimdallCondition('not reside in path matching ${pattern.pattern}', (item, _) {
    final matches = pattern.hasMatch(item.relativePath);
    final findings = [
      if (matches)
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: item.line,
          message: '${item.name} must not reside in path matching ${pattern.pattern} (actual: ${item.relativePath})',
        ),
    ];

    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
