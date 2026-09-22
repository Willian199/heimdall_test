import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for source snippet rules.
extension FileContainSourcePredicateRules on FilePredicateBuilder {
  /// Selects files that contain [source].
  FilePredicateBuilder containSource(String source) {
    return satisfy(_fileContainsSource(source));
  }

  /// Selects files that do not contain [source].
  FilePredicateBuilder notContainSource(String source) {
    return satisfy(_fileDoesNotContainSource(source));
  }

  /// Selects files that contain every source snippet in [sources].
  FilePredicateBuilder containAllSource(Iterable<String> sources) {
    final sourceList = sources.toNonEmptyList('sources');
    return satisfy(
      HeimdallPredicate.allOf(
        sourceList.map(_fileContainsSource),
        description: 'contain all source snippets',
      ),
    );
  }

  /// Selects files that contain at least one snippet in [sources].
  FilePredicateBuilder containAnySource(Iterable<String> sources) {
    final sourceList = sources.toNonEmptyList('sources');
    return satisfy(
      HeimdallPredicate.anyOf(
        sourceList.map(_fileContainsSource),
        description: 'contain any source snippet',
      ),
    );
  }

  /// Selects files that contain none of the snippets in [sources].
  FilePredicateBuilder containNoSource(Iterable<String> sources) {
    final sourceList = sources.toNonEmptyList('sources');
    return satisfy(
      HeimdallPredicate.noneOf(
        sourceList.map(_fileContainsSource),
        description: 'contain no source snippets',
      ),
    );
  }
}

/// Condition-side DSL for source snippet rules.
extension FileContainSourceShouldRules on FileShouldBuilder {
  /// Requires matching files to contain [source].
  HeimdallRule<HeimdallSourceFile> containSource(String source) {
    return satisfy(_fileShouldContainSource(source));
  }

  /// Requires matching files to not contain [source].
  HeimdallRule<HeimdallSourceFile> notContainSource(String source) {
    return satisfy(_fileShouldNotContainSource(source));
  }

  /// Requires matching files to contain every source snippet in [sources].
  HeimdallRule<HeimdallSourceFile> containAllSource(
    Iterable<String> sources,
  ) {
    final sourceList = sources.toNonEmptyList('sources');
    return satisfy(
      HeimdallCondition.allOf(
        sourceList.map(_fileShouldContainSource),
        description: 'contain all source snippets',
      ),
    );
  }

  /// Requires matching files to contain at least one snippet in [sources].
  HeimdallRule<HeimdallSourceFile> containAnySource(
    Iterable<String> sources,
  ) {
    final sourceList = sources.toNonEmptyList('sources');
    return satisfy(
      HeimdallCondition.anyOf(
        sourceList.map(_fileShouldContainSource),
        description: 'contain any source snippet',
      ),
    );
  }

  /// Requires matching files to contain none of the snippets in [sources].
  HeimdallRule<HeimdallSourceFile> containNoSource(Iterable<String> sources) {
    final sourceList = sources.toNonEmptyList('sources');
    return satisfy(
      HeimdallCondition.noneOf(
        sourceList.map(_fileShouldContainSource),
        description: 'contain no source snippets',
      ),
    );
  }
}

HeimdallCondition<HeimdallSourceFile> _fileShouldContainSource(String source) {
  return HeimdallCondition('contain source "$source"', (item, _) {
    final offset = item.content.indexOf(source);
    final location = offset == -1 ? null : item.sourceLocationAt(offset);
    final findings = location == null
        ? [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              message: 'does not contain $source',
            ),
          ]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              line: location.lineNumber,
              column: location.columnNumber,
              message: 'contains source $source',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: item.content.contains(source),
      findings: findings,
    );
  });
}

HeimdallPredicate<HeimdallSourceFile> _fileContainsSource(String source) {
  return HeimdallPredicate(
    'contain source "$source"',
    (item, _) => item.content.contains(source),
  );
}

HeimdallPredicate<HeimdallSourceFile> _fileDoesNotContainSource(
  String source,
) {
  return HeimdallPredicate(
    'not contain source "$source"',
    (item, _) => !item.content.contains(source),
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldNotContainSource(
  String source,
) {
  return HeimdallCondition('not contain source "$source"', (item, _) {
    final offset = item.content.indexOf(source);
    final location = offset == -1 ? null : item.sourceLocationAt(offset);
    final findings = location == null
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              line: location.lineNumber,
              column: location.columnNumber,
              message: 'contains forbidden source $source',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
