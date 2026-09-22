import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/file_features/helpers/source_file_location.dart';

/// Predicate-side DSL for import URI regex rules.
extension FileImportUriMatchingPredicateRules on FilePredicateBuilder {
  /// Selects files that import a URI matching [pattern].
  FilePredicateBuilder importUriMatching(RegExp pattern) {
    return satisfy(_fileImportsUriMatching(pattern));
  }

  /// Selects files that do not import a URI matching [pattern].
  FilePredicateBuilder notImportUriMatching(RegExp pattern) {
    return satisfy(
      HeimdallPredicate(
        'not import URI matching ${pattern.pattern}',
        (item, _) => !item.importDirectives.any(
          (directive) => directive.targetUris.any(pattern.hasMatch),
        ),
      ),
    );
  }

  /// Selects files that import every URI pattern in [patterns].
  FilePredicateBuilder importAllUrisMatching(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.allOf(
        patternList.map(_fileImportsUriMatching),
        description: 'import all URIs matching ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects files that import at least one URI pattern in [patterns].
  FilePredicateBuilder importAnyUriMatching(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.anyOf(
        patternList.map(_fileImportsUriMatching),
        description: 'import any URI matching ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects files that import none of the URI patterns in [patterns].
  FilePredicateBuilder importNoUrisMatching(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.noneOf(
        patternList.map(_fileImportsUriMatching),
        description: 'import no URI matching ${patternList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for import URI regex rules.
extension FileImportUriMatchingShouldRules on FileShouldBuilder {
  /// Requires matching files to import a URI matching [pattern].
  HeimdallRule<HeimdallSourceFile> importUriMatching(RegExp pattern) {
    return satisfy(_fileShouldImportUriMatching(pattern));
  }

  /// Requires matching files to not import a URI matching [pattern].
  HeimdallRule<HeimdallSourceFile> notImportUriMatching(RegExp pattern) {
    return satisfy(
      HeimdallCondition('not import URI matching ${pattern.pattern}', (item, _) {
        final findings = item.importDirectives
            .where((directive) => directive.targetUris.any(pattern.hasMatch))
            .map(
              (directive) => fileNodeFinding(
                item,
                directive,
                'imports forbidden URI matching ${pattern.pattern}',
                offset: directive.uri.offset,
              ),
            )
            .toList();

        return HeimdallFindings(
          subject: item,
          passed: findings.isEmpty,
          findings: findings,
        );
      }),
    );
  }

  /// Requires matching files to import every URI pattern in [patterns].
  HeimdallRule<HeimdallSourceFile> importAllUrisMatching(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        patternList.map(_fileShouldImportUriMatching),
        description: 'import all URIs matching ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to import at least one URI pattern in [patterns].
  HeimdallRule<HeimdallSourceFile> importAnyUriMatching(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        patternList.map(_fileShouldImportUriMatching),
        description: 'import any URI matching ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to import none of the URI patterns in [patterns].
  HeimdallRule<HeimdallSourceFile> importNoUrisMatching(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.noneOf(
        patternList.map(_fileShouldImportUriMatching),
        description: 'import no URI matching ${patternList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<HeimdallSourceFile> _fileImportsUriMatching(
  RegExp pattern,
) {
  return HeimdallPredicate(
    'import URI matching ${pattern.pattern}',
    (item, _) => item.importDirectives.any(
      (directive) => directive.targetUris.any(pattern.hasMatch),
    ),
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldImportUriMatching(
  RegExp pattern,
) {
  return HeimdallCondition('import URI matching ${pattern.pattern}', (item, _) {
    final matchingDirectives = item.importDirectives.where((directive) => directive.targetUris.any(pattern.hasMatch)).toList();
    final findings = <HeimdallValidationInfo>[];
    if (matchingDirectives.isNotEmpty) {
      final matchingDirective = matchingDirectives.first;
      findings.add(
        fileNodeFinding(
          item,
          matchingDirective,
          'imports URI matching ${pattern.pattern}',
          offset: matchingDirective.uri.offset,
        ),
      );
    } else {
      findings.add(
        HeimdallValidationInfo(
          filePath: item.absolutePath,
          message: 'does not import a URI matching ${pattern.pattern}',
        ),
      );
    }
    return HeimdallFindings(
      subject: item,
      passed: matchingDirectives.isNotEmpty,
      findings: findings,
    );
  });
}
