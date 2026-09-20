import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for file path rules.
extension FileResideInPathPredicateRules on FilePredicateBuilder {
  /// Selects files whose relative path matches [pattern].
  FilePredicateBuilder resideInPath(String pattern) {
    return satisfy(_fileResideInPath(pattern));
  }

  /// Selects files whose relative path does not match [pattern].
  FilePredicateBuilder noResideInPath(String pattern) {
    return satisfy(_fileDoesNotResideInPath(pattern));
  }

  /// Selects files that reside in at least one path matching [patterns].
  FilePredicateBuilder resideInAnyPath(Iterable<String> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.anyOf(
        patternList.map(_fileResideInPath),
        description: 'reside in any path ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects files that reside in every path matching [patterns].
  FilePredicateBuilder resideInAllPaths(Iterable<String> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.allOf(
        patternList.map(_fileResideInPath),
        description: 'reside in all paths ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects files that reside in none of the paths matching [patterns].
  FilePredicateBuilder resideInNoPaths(Iterable<String> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.noneOf(
        patternList.map(_fileResideInPath),
        description: 'reside in no paths ${patternList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for file path rules.
extension FileResideInPathShouldRules on FileShouldBuilder {
  /// Requires matching files to reside in a path matching [pattern].
  HeimdallRule<HeimdallSourceFile> resideInPath(String pattern) {
    return satisfy(_fileShouldResideInPath(pattern));
  }

  /// Requires matching files to not reside in a path matching [pattern].
  HeimdallRule<HeimdallSourceFile> noResideInPath(String pattern) {
    return satisfy(_fileShouldNotResideInPath(pattern));
  }

  /// Requires matching files to reside in at least one path matching [patterns].
  HeimdallRule<HeimdallSourceFile> resideInAnyPath(Iterable<String> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        patternList.map(_fileShouldResideInPath),
        description: 'reside in any path ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to reside in every path matching [patterns].
  HeimdallRule<HeimdallSourceFile> resideInAllPaths(
    Iterable<String> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        patternList.map(_fileShouldResideInPath),
        description: 'reside in all paths ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to reside in none of the paths matching [patterns].
  HeimdallRule<HeimdallSourceFile> resideInNoPaths(Iterable<String> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.noneOf(
        patternList.map(_fileShouldResideInPath),
        description: 'reside in no paths ${patternList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<HeimdallSourceFile> _fileResideInPath(String pattern) {
  return HeimdallPredicate(
    'reside in path $pattern',
    (item, _) => pathMatches(item.relativePath, pattern),
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldResideInPath(String pattern) {
  return HeimdallCondition('reside in path $pattern', (item, _) {
    final findings = pathMatches(item.relativePath, pattern)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              message: 'should reside in path $pattern',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<HeimdallSourceFile> _fileDoesNotResideInPath(
  String pattern,
) {
  return HeimdallPredicate(
    'not reside in path $pattern',
    (item, _) => !pathMatches(item.relativePath, pattern),
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldNotResideInPath(
  String pattern,
) {
  return HeimdallCondition('not reside in path $pattern', (item, _) {
    final findings = !pathMatches(item.relativePath, pattern)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              line: 1,
              column: 1,
              message: 'must not reside in path $pattern',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
