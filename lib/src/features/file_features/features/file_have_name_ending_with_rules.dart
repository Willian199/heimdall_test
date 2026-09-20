import 'package:heimdall_test/heimdall_test.dart';
import 'package:path/path.dart' as p;

/// Predicate-side DSL for file name suffix rules.
extension FileHaveNameEndingWithPredicateRules on FilePredicateBuilder {
  /// Selects files whose basenames end with [suffix].
  FilePredicateBuilder haveNameEndingWith(String suffix) {
    return satisfy(_fileNameEndsWith(suffix));
  }

  /// Selects files whose basenames do not end with [suffix].
  FilePredicateBuilder noHaveNameEndingWith(String suffix) {
    return satisfy(_fileNameDoesNotEndWith(suffix));
  }

  /// Selects files whose basenames end with at least one suffix in [suffixes].
  FilePredicateBuilder haveNameEndingWithAny(Iterable<String> suffixes) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        suffixList.map(_fileNameEndsWith),
        description: 'have name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects files whose basenames end with every suffix in [suffixes].
  FilePredicateBuilder haveNameEndingWithAll(Iterable<String> suffixes) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.allOf(
        suffixList.map(_fileNameEndsWith),
        description: 'have name ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects files whose basenames end with none of [suffixes].
  FilePredicateBuilder haveNameEndingWithNone(Iterable<String> suffixes) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        suffixList.map(_fileNameEndsWith),
        description: 'have name ending with none of ${suffixList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for file name suffix rules.
extension FileHaveNameEndingWithShouldRules on FileShouldBuilder {
  /// Requires matching file names to end with [suffix].
  HeimdallRule<HeimdallSourceFile> haveNameEndingWith(String suffix) {
    return satisfy(_fileShouldHaveNameEndingWith(suffix));
  }

  /// Requires matching file names to not end with [suffix].
  HeimdallRule<HeimdallSourceFile> noHaveNameEndingWith(String suffix) {
    return satisfy(_fileShouldNotHaveNameEndingWith(suffix));
  }

  /// Requires matching file names to end with at least one suffix in [suffixes].
  HeimdallRule<HeimdallSourceFile> haveNameEndingWithAny(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.anyOf(
        suffixList.map(_fileShouldHaveNameEndingWith),
        description: 'have name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires matching file names to end with every suffix in [suffixes].
  HeimdallRule<HeimdallSourceFile> haveNameEndingWithAll(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.allOf(
        suffixList.map(_fileShouldHaveNameEndingWith),
        description: 'have name ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires matching file names to end with none of [suffixes].
  HeimdallRule<HeimdallSourceFile> haveNameEndingWithNone(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.noneOf(
        suffixList.map(_fileShouldHaveNameEndingWith),
        description: 'have name ending with none of ${suffixList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<HeimdallSourceFile> _fileNameEndsWith(String suffix) {
  return HeimdallPredicate(
    'have name ending with $suffix',
    (item, _) => p.basename(item.relativePath).endsWith(suffix),
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldHaveNameEndingWith(
  String suffix,
) {
  return HeimdallCondition('have name ending with $suffix', (item, _) {
    final findings = p.basename(item.relativePath).endsWith(suffix)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              message: 'should end with $suffix',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<HeimdallSourceFile> _fileNameDoesNotEndWith(String suffix) {
  return HeimdallPredicate(
    'not have name ending with $suffix',
    (item, _) => !p.basename(item.relativePath).endsWith(suffix),
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldNotHaveNameEndingWith(
  String suffix,
) {
  return HeimdallCondition('not have name ending with $suffix', (item, _) {
    final findings = !p.basename(item.relativePath).endsWith(suffix)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              line: 1,
              column: 1,
              message: 'ends with forbidden suffix $suffix',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
