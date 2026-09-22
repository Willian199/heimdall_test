import 'package:heimdall_test/heimdall_test.dart';
import 'package:path/path.dart' as p;

/// Predicate-side DSL for file name prefix rules.
extension FileHaveNameStartingWithPredicateRules on FilePredicateBuilder {
  /// Selects files whose basenames start with [prefix].
  FilePredicateBuilder haveNameStartingWith(String prefix) {
    return satisfy(_fileNameStartsWith(prefix));
  }

  /// Selects files whose basenames do not start with [prefix].
  FilePredicateBuilder notHaveNameStartingWith(String prefix) {
    return satisfy(_fileNameDoesNotStartWith(prefix));
  }

  /// Selects files whose basenames start with at least one prefix in [prefixes].
  FilePredicateBuilder haveNameStartingWithAnyOf(Iterable<String> prefixes) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        prefixList.map(_fileNameStartsWith),
        description: 'have name starting with any of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Selects files whose basenames start with every prefix in [prefixes].
  FilePredicateBuilder haveNameStartingWithAllOf(Iterable<String> prefixes) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.allOf(
        prefixList.map(_fileNameStartsWith),
        description: 'have name starting with all of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Selects files whose basenames start with none of [prefixes].
  FilePredicateBuilder haveNameStartingWithNoneOf(Iterable<String> prefixes) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        prefixList.map(_fileNameStartsWith),
        description: 'have name starting with none of ${prefixList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for file name prefix rules.
extension FileHaveNameStartingWithShouldRules on FileShouldBuilder {
  /// Requires matching file names to start with [prefix].
  HeimdallRule<HeimdallSourceFile> haveNameStartingWith(String prefix) {
    return satisfy(_fileShouldHaveNameStartingWith(prefix));
  }

  /// Requires matching file names to not start with [prefix].
  HeimdallRule<HeimdallSourceFile> notHaveNameStartingWith(String prefix) {
    return satisfy(_fileShouldNotHaveNameStartingWith(prefix));
  }

  /// Requires matching file names to start with at least one prefix in [prefixes].
  HeimdallRule<HeimdallSourceFile> haveNameStartingWithAnyOf(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.anyOf(
        prefixList.map(_fileShouldHaveNameStartingWith),
        description: 'have name starting with any of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Requires matching file names to start with every prefix in [prefixes].
  HeimdallRule<HeimdallSourceFile> haveNameStartingWithAllOf(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.allOf(
        prefixList.map(_fileShouldHaveNameStartingWith),
        description: 'have name starting with all of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Requires matching file names to start with none of [prefixes].
  HeimdallRule<HeimdallSourceFile> haveNameStartingWithNoneOf(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.noneOf(
        prefixList.map(_fileShouldHaveNameStartingWith),
        description: 'have name starting with none of ${prefixList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<HeimdallSourceFile> _fileNameStartsWith(String prefix) {
  return HeimdallPredicate(
    'have name starting with $prefix',
    (item, _) => p.basename(item.relativePath).startsWith(prefix),
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldHaveNameStartingWith(
  String prefix,
) {
  return HeimdallCondition('have name starting with $prefix', (item, _) {
    final findings = p.basename(item.relativePath).startsWith(prefix)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              message: 'should start with $prefix',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<HeimdallSourceFile> _fileNameDoesNotStartWith(
  String prefix,
) {
  return HeimdallPredicate(
    'not have name starting with $prefix',
    (item, _) => !p.basename(item.relativePath).startsWith(prefix),
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldNotHaveNameStartingWith(
  String prefix,
) {
  return HeimdallCondition('not have name starting with $prefix', (item, _) {
    final findings = !p.basename(item.relativePath).startsWith(prefix)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              line: 1,
              column: 1,
              message: 'starts with forbidden prefix $prefix',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
