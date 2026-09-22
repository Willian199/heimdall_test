import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for allowed import prefix policy rules.
extension FileImportPolicyPredicateRules on FilePredicateBuilder {
  /// Selects files whose imports all start with one of [allowedPrefixes].
  FilePredicateBuilder onlyImportFrom(Iterable<String> allowedPrefixes) {
    final prefixList = allowedPrefixes.toNonEmptyList('allowedPrefixes');
    return satisfy(_fileOnlyImportsFrom(prefixList));
  }

  /// Selects files with at least one import outside [allowedPrefixes].
  FilePredicateBuilder importFromOutside(Iterable<String> allowedPrefixes) {
    final prefixList = allowedPrefixes.toNonEmptyList('allowedPrefixes');
    return satisfy(_fileDoesNotOnlyImportFrom(prefixList));
  }

  /// Selects files where every import matches every prefix in [allowedPrefixes].
  FilePredicateBuilder haveEveryImportMatchAllPrefixes(Iterable<String> allowedPrefixes) {
    final prefixList = allowedPrefixes.toNonEmptyList('allowedPrefixes');
    return satisfy(
      HeimdallPredicate.allOf(
        prefixList.map(_fileOnlyImportsFromPrefix),
        description: 'have every import match all prefixes ${prefixList.join(', ')}',
      ),
    );
  }

  /// Selects files where at least one prefix in [allowedPrefixes] matches all imports.
  FilePredicateBuilder haveAllImportsShareAnyPrefix(Iterable<String> allowedPrefixes) {
    final prefixList = allowedPrefixes.toNonEmptyList('allowedPrefixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        prefixList.map(_fileOnlyImportsFromPrefix),
        description: 'have all imports share at least one prefix in ${prefixList.join(', ')}',
      ),
    );
  }

  /// Selects files where no prefix in [allowedPrefixes] matches all imports.
  FilePredicateBuilder haveNoPrefixSharedByAllImports(Iterable<String> allowedPrefixes) {
    final prefixList = allowedPrefixes.toNonEmptyList('allowedPrefixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        prefixList.map(_fileOnlyImportsFromPrefix),
        description: 'have no prefix shared by all imports in ${prefixList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for allowed import prefix policy rules.
extension FileImportPolicyShouldRules on FileShouldBuilder {
  /// Requires matching files to import only from [allowedPrefixes].
  HeimdallRule<HeimdallSourceFile> onlyImportFrom(
    Iterable<String> allowedPrefixes,
  ) {
    final prefixList = allowedPrefixes.toNonEmptyList('allowedPrefixes');
    return satisfy(_fileShouldOnlyImportFrom(prefixList));
  }

  /// Requires matching files to import at least one URI outside [allowedPrefixes].
  HeimdallRule<HeimdallSourceFile> importFromOutside(
    Iterable<String> allowedPrefixes,
  ) {
    final prefixList = allowedPrefixes.toNonEmptyList('allowedPrefixes');
    return satisfy(_fileShouldNotOnlyImportFrom(prefixList));
  }

  /// Requires matching files to have every import match every prefix in [allowedPrefixes].
  HeimdallRule<HeimdallSourceFile> haveEveryImportMatchAllPrefixes(
    Iterable<String> allowedPrefixes,
  ) {
    final prefixList = allowedPrefixes.toNonEmptyList('allowedPrefixes');
    return satisfy(
      HeimdallCondition.allOf(
        prefixList.map(_fileShouldOnlyImportFromPrefix),
        description: 'have every import match all prefixes ${prefixList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to have a prefix in [allowedPrefixes] shared by all imports.
  HeimdallRule<HeimdallSourceFile> haveAllImportsShareAnyPrefix(
    Iterable<String> allowedPrefixes,
  ) {
    final prefixList = allowedPrefixes.toNonEmptyList('allowedPrefixes');
    return satisfy(
      HeimdallCondition.anyOf(
        prefixList.map(_fileShouldOnlyImportFromPrefix),
        description: 'have all imports share at least one prefix in ${prefixList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to have no prefix in [allowedPrefixes] shared by all imports.
  HeimdallRule<HeimdallSourceFile> haveNoPrefixSharedByAllImports(
    Iterable<String> allowedPrefixes,
  ) {
    final prefixList = allowedPrefixes.toNonEmptyList('allowedPrefixes');
    return satisfy(
      HeimdallCondition.noneOf(
        prefixList.map(_fileShouldOnlyImportFromPrefix),
        description: 'have no prefix shared by all imports in ${prefixList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<HeimdallSourceFile> _fileOnlyImportsFrom(
  Iterable<String> allowedPrefixes,
) {
  return HeimdallPredicate(
    'only import from ${allowedPrefixes.join(', ')}',
    (item, _) => item.importDirectives
        .expand((directive) => directive.targetUris)
        .every(
          (uri) => allowedPrefixes.any(uri.startsWith),
        ),
  );
}

HeimdallPredicate<HeimdallSourceFile> _fileOnlyImportsFromPrefix(
  String allowedPrefix,
) {
  return HeimdallPredicate(
    'only import from $allowedPrefix',
    (item, _) => item.importDirectives.expand((directive) => directive.targetUris).every((uri) => uri.startsWith(allowedPrefix)),
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldOnlyImportFrom(
  Iterable<String> allowedPrefixes,
) {
  final description = 'only import from ${allowedPrefixes.join(', ')}';
  return HeimdallCondition(description, (item, _) {
    final findings = [
      for (final directive in item.importDirectives)
        for (final uri in directive.targetUris)
          if (!allowedPrefixes.any(uri.startsWith))
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              line: directive.line,
              message: 'imports $uri outside ${allowedPrefixes.join(', ')}',
            ),
    ];

    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<HeimdallSourceFile> _fileShouldOnlyImportFromPrefix(
  String allowedPrefix,
) {
  return _fileShouldOnlyImportFrom([allowedPrefix]);
}

HeimdallPredicate<HeimdallSourceFile> _fileDoesNotOnlyImportFrom(
  Iterable<String> allowedPrefixes,
) {
  return HeimdallPredicate(
    'not only import from ${allowedPrefixes.join(', ')}',
    (item, _) => item.importDirectives
        .expand((directive) => directive.targetUris)
        .any(
          (uri) => !allowedPrefixes.any(uri.startsWith),
        ),
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldNotOnlyImportFrom(
  Iterable<String> allowedPrefixes,
) {
  final description = 'not only import from ${allowedPrefixes.join(', ')}';
  return HeimdallCondition(description, (item, _) {
    final hasOutsideImport = item.importDirectives
        .expand((directive) => directive.targetUris)
        .any(
          (uri) => !allowedPrefixes.any(uri.startsWith),
        );
    final findings = hasOutsideImport
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              line: 1,
              column: 1,
              message: 'only imports from ${allowedPrefixes.join(', ')}',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
