import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for parse error message rules.
extension FileHaveNoParseErrorsPredicateRules on FilePredicateBuilder {
  /// Selects files that have no parse errors matching [pattern].
  FilePredicateBuilder haveNoParseErrorsMatching(RegExp pattern) {
    return satisfy(_fileHasNoParseErrorsMatching(pattern));
  }

  /// Selects files that have a parse error matching [pattern].
  FilePredicateBuilder haveParseErrorsMatching(RegExp pattern) {
    return satisfy(_fileHasParseErrorsMatching(pattern));
  }

  /// Selects files that have no parse errors matching at least one pattern in [patterns].
  FilePredicateBuilder haveNoParseErrorsMatchingAny(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.anyOf(
        patternList.map(_fileHasNoParseErrorsMatching),
        description: 'have no parse errors matching any of ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects files that have no parse errors matching every pattern in [patterns].
  FilePredicateBuilder haveNoParseErrorsMatchingAll(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.allOf(
        patternList.map(_fileHasNoParseErrorsMatching),
        description: 'have no parse errors matching all of ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects files that have no parse errors matching none of [patterns].
  FilePredicateBuilder haveNoParseErrorsMatchingNone(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.noneOf(
        patternList.map(_fileHasNoParseErrorsMatching),
        description: 'have no parse errors matching none of ${patternList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for parse error message rules.
extension FileHaveNoParseErrorsShouldRules on FileShouldBuilder {
  /// Requires matching files to have no parse errors matching [pattern].
  HeimdallRule<HeimdallSourceFile> haveNoParseErrorsMatching(RegExp pattern) {
    return satisfy(_fileShouldHaveNoParseErrorsMatching(pattern));
  }

  /// Requires matching files to have at least one parse error matching [pattern].
  HeimdallRule<HeimdallSourceFile> haveParseErrorsMatching(RegExp pattern) {
    return satisfy(_fileShouldHaveParseErrorsMatching(pattern));
  }

  /// Requires matching files to have no parse errors matching at least one pattern in [patterns].
  HeimdallRule<HeimdallSourceFile> haveNoParseErrorsMatchingAny(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        patternList.map(_fileShouldHaveNoParseErrorsMatching),
        description: 'have no parse errors matching any of ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to have no parse errors matching every pattern in [patterns].
  HeimdallRule<HeimdallSourceFile> haveNoParseErrorsMatchingAll(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        patternList.map(_fileShouldHaveNoParseErrorsMatching),
        description: 'have no parse errors matching all of ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to have no parse errors matching none of [patterns].
  HeimdallRule<HeimdallSourceFile> haveNoParseErrorsMatchingNone(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.noneOf(
        patternList.map(_fileShouldHaveNoParseErrorsMatching),
        description: 'have no parse errors matching none of ${patternList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<HeimdallSourceFile> _fileHasNoParseErrorsMatching(
  RegExp pattern,
) {
  return HeimdallPredicate(
    'have no parse errors matching $pattern',
    (item, _) => !_hasParseErrorMatching(item, pattern),
  );
}

bool _hasParseErrorMatching(HeimdallSourceFile item, RegExp pattern) {
  return item.parseErrors.any((error) => pattern.hasMatch(error.message));
}

HeimdallCondition<HeimdallSourceFile> _fileShouldHaveNoParseErrorsMatching(
  RegExp pattern,
) {
  return HeimdallCondition('have no parse errors matching $pattern', (
    item,
    _,
  ) {
    final findings = item.parseErrors
        .where((error) => pattern.hasMatch(error.message))
        .map(
          (error) => HeimdallValidationInfo(
            filePath: item.absolutePath,
            line: error.line,
            column: error.column,
            message: error.message,
          ),
        )
        .toList();
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<HeimdallSourceFile> _fileHasParseErrorsMatching(
  RegExp pattern,
) {
  return HeimdallPredicate(
    'have parse errors matching $pattern',
    (item, _) => _hasParseErrorMatching(item, pattern),
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldHaveParseErrorsMatching(
  RegExp pattern,
) {
  return HeimdallCondition('have parse errors matching $pattern', (
    item,
    _,
  ) {
    final findings = _hasParseErrorMatching(item, pattern)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              line: 1,
              column: 1,
              message: 'has no parse errors matching ${pattern.pattern}',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
