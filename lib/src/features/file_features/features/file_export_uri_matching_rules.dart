import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/file_features/helpers/source_file_location.dart';

/// Predicate-side DSL for export URI regex rules.
extension FileExportUriMatchingPredicateRules on FilePredicateBuilder {
  /// Selects files that export a URI matching [pattern].
  FilePredicateBuilder exportUriMatching(RegExp pattern) {
    return satisfy(_fileExportsUriMatching(pattern));
  }

  /// Selects files that do not export a URI matching [pattern].
  FilePredicateBuilder noExportUriMatching(RegExp pattern) {
    return satisfy(
      HeimdallPredicate(
        'not export URI matching ${pattern.pattern}',
        (item, _) => !item.exportDirectives.any(
          (directive) => directive.targetUris.any(pattern.hasMatch),
        ),
      ),
    );
  }

  /// Selects files that export every URI pattern in [patterns].
  FilePredicateBuilder exportAllUrisMatching(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.allOf(
        patternList.map(_fileExportsUriMatching),
        description: 'export all URIs matching ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects files that export at least one URI pattern in [patterns].
  FilePredicateBuilder exportAnyUriMatching(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.anyOf(
        patternList.map(_fileExportsUriMatching),
        description: 'export any URI matching ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects files that export none of the URI patterns in [patterns].
  FilePredicateBuilder exportNoneUrisMatching(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.noneOf(
        patternList.map(_fileExportsUriMatching),
        description: 'export no URI matching ${patternList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for export URI regex rules.
extension FileExportUriMatchingShouldRules on FileShouldBuilder {
  /// Requires matching files to export a URI matching [pattern].
  HeimdallRule<HeimdallSourceFile> exportUriMatching(RegExp pattern) {
    return satisfy(_fileShouldExportUriMatching(pattern));
  }

  /// Requires matching files to not export a URI matching [pattern].
  HeimdallRule<HeimdallSourceFile> noExportUriMatching(RegExp pattern) {
    return satisfy(
      HeimdallCondition('not export URI matching ${pattern.pattern}', (
        item,
        _,
      ) {
        final findings = item.exportDirectives
            .where((directive) => directive.targetUris.any(pattern.hasMatch))
            .map(
              (directive) => fileNodeFinding(
                item,
                directive,
                'exports forbidden URI matching ${pattern.pattern}',
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

  /// Requires matching files to export every URI pattern in [patterns].
  HeimdallRule<HeimdallSourceFile> exportAllUrisMatching(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        patternList.map(_fileShouldExportUriMatching),
        description: 'export all URIs matching ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to export at least one URI pattern in [patterns].
  HeimdallRule<HeimdallSourceFile> exportAnyUriMatching(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        patternList.map(_fileShouldExportUriMatching),
        description: 'export any URI matching ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to export none of the URI patterns in [patterns].
  HeimdallRule<HeimdallSourceFile> exportNoneUrisMatching(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.noneOf(
        patternList.map(_fileShouldExportUriMatching),
        description: 'export no URI matching ${patternList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<HeimdallSourceFile> _fileExportsUriMatching(
  RegExp pattern,
) {
  return HeimdallPredicate(
    'export URI matching ${pattern.pattern}',
    (item, _) => item.exportDirectives.any(
      (directive) => directive.targetUris.any(pattern.hasMatch),
    ),
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldExportUriMatching(
  RegExp pattern,
) {
  return HeimdallCondition('export URI matching ${pattern.pattern}', (
    item,
    _,
  ) {
    final matchingDirectives = item.exportDirectives.where((directive) => directive.targetUris.any(pattern.hasMatch)).toList();
    final findings = <HeimdallValidationInfo>[];
    if (matchingDirectives.isNotEmpty) {
      final matchingDirective = matchingDirectives.first;
      findings.add(
        fileNodeFinding(
          item,
          matchingDirective,
          'exports URI matching ${pattern.pattern}',
          offset: matchingDirective.uri.offset,
        ),
      );
    } else {
      findings.add(
        HeimdallValidationInfo(
          filePath: item.absolutePath,
          message: 'does not export a URI matching ${pattern.pattern}',
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
