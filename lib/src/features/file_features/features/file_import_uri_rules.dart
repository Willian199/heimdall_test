import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/file_features/helpers/source_file_location.dart';

/// Predicate-side DSL for import URI rules.
extension FileImportUriPredicateRules on FilePredicateBuilder {
  /// Selects files that import [uri].
  FilePredicateBuilder importUri(String uri) {
    return satisfy(_fileImportsUri(uri));
  }

  /// Selects files that do not import [uri].
  FilePredicateBuilder noImportUri(String uri) {
    return satisfy(
      HeimdallPredicate(
        'not import $uri',
        (item, _) => !item.importDirectives.any((directive) => directive.targetUris.contains(uri)),
      ),
    );
  }

  /// Selects files that import every URI in [uris].
  FilePredicateBuilder importAllUris(Iterable<String> uris) {
    final uriList = uris.toNonEmptyList('uris');
    return satisfy(
      HeimdallPredicate.allOf(
        uriList.map(_fileImportsUri),
        description: 'import all of ${uriList.join(', ')}',
      ),
    );
  }

  /// Selects files that import at least one URI in [uris].
  FilePredicateBuilder importAnyUri(Iterable<String> uris) {
    final uriList = uris.toNonEmptyList('uris');
    return satisfy(
      HeimdallPredicate.anyOf(
        uriList.map(_fileImportsUri),
        description: 'import any of ${uriList.join(', ')}',
      ),
    );
  }

  /// Selects files that import none of the URIs in [uris].
  FilePredicateBuilder importNoneUris(Iterable<String> uris) {
    final uriList = uris.toNonEmptyList('uris');
    return satisfy(
      HeimdallPredicate.noneOf(
        uriList.map(_fileImportsUri),
        description: 'import none of ${uriList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for import URI rules.
extension FileImportUriShouldRules on FileShouldBuilder {
  /// Requires matching files to import [uri].
  HeimdallRule<HeimdallSourceFile> importUri(String uri) {
    return satisfy(_fileShouldImportUri(uri));
  }

  /// Requires matching files to not import [uri].
  HeimdallRule<HeimdallSourceFile> noImportUri(String uri) {
    return satisfy(
      HeimdallCondition('not import $uri', (item, _) {
        final findings = item.importDirectives
            .where((directive) => directive.targetUris.contains(uri))
            .map(
              (directive) => fileNodeFinding(
                item,
                directive,
                'imports forbidden URI $uri',
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

  /// Requires matching files to import every URI in [uris].
  HeimdallRule<HeimdallSourceFile> importAllUris(Iterable<String> uris) {
    final uriList = uris.toNonEmptyList('uris');
    return satisfy(
      HeimdallCondition.allOf(
        uriList.map(_fileShouldImportUri),
        description: 'import all of ${uriList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to import at least one URI in [uris].
  HeimdallRule<HeimdallSourceFile> importAnyUri(Iterable<String> uris) {
    final uriList = uris.toNonEmptyList('uris');
    return satisfy(
      HeimdallCondition.anyOf(
        uriList.map(_fileShouldImportUri),
        description: 'import any of ${uriList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to import none of the URIs in [uris].
  HeimdallRule<HeimdallSourceFile> importNoneUris(Iterable<String> uris) {
    final uriList = uris.toNonEmptyList('uris');
    return satisfy(
      HeimdallCondition.noneOf(
        uriList.map(_fileShouldImportUri),
        description: 'import none of ${uriList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<HeimdallSourceFile> _fileShouldImportUri(String uri) {
  return HeimdallCondition('import $uri', (item, _) {
    final importsUri = item.importDirectives.any((directive) => directive.targetUris.contains(uri));
    final findings = importsUri
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              message: 'does not import $uri',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<HeimdallSourceFile> _fileImportsUri(String uri) {
  return HeimdallPredicate(
    'import $uri',
    (item, _) => item.importDirectives.any((directive) => directive.targetUris.contains(uri)),
  );
}
