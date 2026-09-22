import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for textual source pattern rules.
///
/// Patterns are applied to the whole file, including comments and strings.
/// Use executable syntax rules for calls, arguments, and expressions.
extension FileContainSourceMatchingPredicateRules on FilePredicateBuilder {
  /// Selects files that contain source matching [pattern].
  FilePredicateBuilder containSourceMatching(RegExp pattern) {
    return satisfy(_fileContainsSourceMatching(pattern));
  }

  /// Selects files that do not contain source matching [pattern].
  FilePredicateBuilder notContainSourceMatching(RegExp pattern) {
    return satisfy(_fileDoesNotContainSourceMatching(pattern));
  }

  /// Selects files that contain source matching every pattern in [patterns].
  FilePredicateBuilder containAllSourceMatching(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.allOf(
        patternList.map(_fileContainsSourceMatching),
        description: 'contain source matching all of ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects files that contain source matching at least one pattern in [patterns].
  FilePredicateBuilder containAnySourceMatching(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.anyOf(
        patternList.map(_fileContainsSourceMatching),
        description: 'contain source matching any of ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects files that contain source matching none of [patterns].
  FilePredicateBuilder containNoSourceMatching(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.noneOf(
        patternList.map(_fileContainsSourceMatching),
        description: 'contain source matching none of ${patternList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for textual source pattern rules.
///
/// Patterns are applied to the whole file, including comments and strings.
/// Use executable syntax rules for calls, arguments, and expressions.
extension FileContainSourceMatchingShouldRules on FileShouldBuilder {
  /// Requires matching files to contain source matching [pattern].
  HeimdallRule<HeimdallSourceFile> containSourceMatching(RegExp pattern) {
    return satisfy(_fileShouldContainSourceMatching(pattern));
  }

  /// Requires matching files to not contain source matching [pattern].
  HeimdallRule<HeimdallSourceFile> notContainSourceMatching(RegExp pattern) {
    return satisfy(_fileShouldNotContainSourceMatching(pattern));
  }

  /// Requires matching files to contain source matching every pattern in [patterns].
  HeimdallRule<HeimdallSourceFile> containAllSourceMatching(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        patternList.map(_fileShouldContainSourceMatching),
        description: 'contain source matching all of ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to contain source matching at least one pattern in [patterns].
  HeimdallRule<HeimdallSourceFile> containAnySourceMatching(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        patternList.map(_fileShouldContainSourceMatching),
        description: 'contain source matching any of ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to contain source matching none of [patterns].
  HeimdallRule<HeimdallSourceFile> containNoSourceMatching(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.noneOf(
        patternList.map(_fileShouldContainSourceMatching),
        description: 'contain source matching none of ${patternList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<HeimdallSourceFile> _fileShouldContainSourceMatching(
  RegExp pattern,
) {
  return HeimdallCondition('contain source matching $pattern', (item, _) {
    final match = pattern.firstMatch(item.content);
    final findings = <HeimdallValidationInfo>[];
    if (match != null) {
      final location = item.sourceLocationAt(match.start);
      findings.add(
        HeimdallValidationInfo(
          filePath: item.absolutePath,
          line: location.lineNumber,
          column: location.columnNumber,
          message: 'contains source matching $pattern',
        ),
      );
    } else {
      findings.add(
        HeimdallValidationInfo(
          filePath: item.absolutePath,
          message: 'does not contain source matching $pattern',
        ),
      );
    }
    return HeimdallFindings(
      subject: item,
      passed: match != null,
      findings: findings,
    );
  });
}

HeimdallPredicate<HeimdallSourceFile> _fileContainsSourceMatching(
  RegExp pattern,
) {
  return HeimdallPredicate(
    'contain source matching $pattern',
    (item, _) => pattern.hasMatch(item.content),
  );
}

HeimdallPredicate<HeimdallSourceFile> _fileDoesNotContainSourceMatching(
  RegExp pattern,
) {
  return HeimdallPredicate(
    'not contain source matching $pattern',
    (item, _) => !pattern.hasMatch(item.content),
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldNotContainSourceMatching(
  RegExp pattern,
) {
  return HeimdallCondition('not contain source matching $pattern', (item, _) {
    final match = pattern.firstMatch(item.content);
    final findings = <HeimdallValidationInfo>[];
    if (match != null) {
      final location = item.sourceLocationAt(match.start);
      findings.add(
        HeimdallValidationInfo(
          filePath: item.absolutePath,
          line: location.lineNumber,
          column: location.columnNumber,
          message: 'contains forbidden source matching $pattern',
        ),
      );
    }
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
