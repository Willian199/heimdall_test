import 'package:heimdall_test/heimdall_test.dart';
import 'package:path/path.dart' as p;

/// Predicate-side DSL for file name pattern rules.
extension FileHaveNameMatchingPredicateRules on FilePredicateBuilder {
  /// Selects files whose basenames match [pattern].
  FilePredicateBuilder haveNameMatching(RegExp pattern) {
    return satisfy(_fileNameMatches(pattern));
  }

  /// Selects files whose basenames do not match [pattern].
  FilePredicateBuilder noHaveNameMatching(RegExp pattern) {
    return satisfy(_fileNameDoesNotMatch(pattern));
  }

  /// Selects files whose basenames match at least one pattern in [patterns].
  FilePredicateBuilder haveNameMatchingAny(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.anyOf(
        patternList.map(_fileNameMatches),
        description: 'have name matching any of ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects files whose basenames match every pattern in [patterns].
  FilePredicateBuilder haveNameMatchingAll(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.allOf(
        patternList.map(_fileNameMatches),
        description: 'have name matching all of ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects files whose basenames match none of [patterns].
  FilePredicateBuilder haveNameMatchingNone(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.noneOf(
        patternList.map(_fileNameMatches),
        description: 'have name matching none of ${patternList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for file name pattern rules.
extension FileHaveNameMatchingShouldRules on FileShouldBuilder {
  /// Requires matching file names to match [pattern].
  HeimdallRule<HeimdallSourceFile> haveNameMatching(RegExp pattern) {
    return satisfy(_fileShouldHaveNameMatching(pattern));
  }

  /// Requires matching file names to not match [pattern].
  HeimdallRule<HeimdallSourceFile> noHaveNameMatching(RegExp pattern) {
    return satisfy(_fileShouldNotHaveNameMatching(pattern));
  }

  /// Requires matching file names to match at least one pattern in [patterns].
  HeimdallRule<HeimdallSourceFile> haveNameMatchingAny(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        patternList.map(_fileShouldHaveNameMatching),
        description: 'have name matching any of ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching file names to match every pattern in [patterns].
  HeimdallRule<HeimdallSourceFile> haveNameMatchingAll(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        patternList.map(_fileShouldHaveNameMatching),
        description: 'have name matching all of ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching file names to match none of [patterns].
  HeimdallRule<HeimdallSourceFile> haveNameMatchingNone(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.noneOf(
        patternList.map(_fileShouldHaveNameMatching),
        description: 'have name matching none of ${patternList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<HeimdallSourceFile> _fileNameMatches(RegExp pattern) {
  return HeimdallPredicate(
    'have name matching ${pattern.pattern}',
    (item, _) => pattern.hasMatch(p.basename(item.relativePath)),
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldHaveNameMatching(
  RegExp pattern,
) {
  return HeimdallCondition('have name matching ${pattern.pattern}', (item, _) {
    final basename = p.basename(item.relativePath);
    final matches = pattern.hasMatch(basename);
    final findings = <HeimdallValidationInfo>[];
    if (matches) {
      findings.add(
        HeimdallValidationInfo(
          filePath: item.absolutePath,
          line: 1,
          column: 1,
          message: 'matches ${pattern.pattern}',
        ),
      );
    } else {
      findings.add(
        HeimdallValidationInfo(
          filePath: item.absolutePath,
          message: 'should match ${pattern.pattern}',
        ),
      );
    }
    return HeimdallFindings(
      subject: item,
      passed: matches,
      findings: findings,
    );
  });
}

HeimdallPredicate<HeimdallSourceFile> _fileNameDoesNotMatch(RegExp pattern) {
  return HeimdallPredicate(
    'not have name matching ${pattern.pattern}',
    (item, _) => !pattern.hasMatch(p.basename(item.relativePath)),
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldNotHaveNameMatching(
  RegExp pattern,
) {
  return HeimdallCondition('not have name matching ${pattern.pattern}', (
    item,
    _,
  ) {
    final findings = <HeimdallValidationInfo>[];
    if (pattern.hasMatch(p.basename(item.relativePath))) {
      findings.add(
        HeimdallValidationInfo(
          filePath: item.absolutePath,
          line: 1,
          column: 1,
          message: 'matches forbidden pattern ${pattern.pattern}',
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
