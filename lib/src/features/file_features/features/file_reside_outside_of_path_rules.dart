import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for file path exclusion rules.
extension FileResideOutsideOfPathPredicateRules on FilePredicateBuilder {
  /// Selects files that reside outside a path matching [pattern].
  FilePredicateBuilder resideOutsideOfPath(String pattern) {
    return satisfy(_fileResideOutsideOfPath(pattern));
  }

  /// Selects files that reside outside at least one path matching [patterns].
  FilePredicateBuilder resideOutsideOfAtLeastOnePath(Iterable<String> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.anyOf(
        patternList.map(_fileResideOutsideOfPath),
        description: 'reside outside of any path ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects files that reside outside every path matching [patterns].
  FilePredicateBuilder resideOutsideOfAllPaths(Iterable<String> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.allOf(
        patternList.map(_fileResideOutsideOfPath),
        description: 'reside outside of all paths ${patternList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for file path exclusion rules.
extension FileResideOutsideOfPathShouldRules on FileShouldBuilder {
  /// Requires matching files to reside outside a path matching [pattern].
  HeimdallRule<HeimdallSourceFile> resideOutsideOfPath(String pattern) {
    return satisfy(_fileShouldResideOutsideOfPath(pattern));
  }

  /// Requires matching files to reside outside at least one path matching [patterns].
  HeimdallRule<HeimdallSourceFile> resideOutsideOfAtLeastOnePath(
    Iterable<String> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        patternList.map(_fileShouldResideOutsideOfPath),
        description: 'reside outside of any path ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to reside outside every path matching [patterns].
  HeimdallRule<HeimdallSourceFile> resideOutsideOfAllPaths(
    Iterable<String> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        patternList.map(_fileShouldResideOutsideOfPath),
        description: 'reside outside of all paths ${patternList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<HeimdallSourceFile> _fileResideOutsideOfPath(String pattern) {
  return HeimdallPredicate(
    'reside outside of path $pattern',
    (item, _) => !pathMatches(item.relativePath, pattern),
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldResideOutsideOfPath(
  String pattern,
) {
  return HeimdallCondition('reside outside of path $pattern', (item, _) {
    final findings = !pathMatches(item.relativePath, pattern)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              message: 'should reside outside of path $pattern',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
