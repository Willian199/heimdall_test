import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/file_features/helpers/source_file_location.dart';

/// Predicate-side DSL for export URI rules.
extension FileExportUriPredicateRules on FilePredicateBuilder {
  /// Selects files that export [uri].
  FilePredicateBuilder exportUri(String uri) {
    return satisfy(_fileExportsUri(uri));
  }

  /// Selects files that do not export [uri].
  FilePredicateBuilder notExportUri(String uri) {
    return satisfy(
      HeimdallPredicate(
        'not export $uri',
        (item, _) => !item.exportDirectives.any((directive) => directive.targetUris.contains(uri)),
      ),
    );
  }

  /// Selects files that export every URI in [uris].
  FilePredicateBuilder exportAllUris(Iterable<String> uris) {
    final uriList = uris.toNonEmptyList('uris');
    return satisfy(
      HeimdallPredicate.allOf(
        uriList.map(_fileExportsUri),
        description: 'export all of ${uriList.join(', ')}',
      ),
    );
  }

  /// Selects files that export at least one URI in [uris].
  FilePredicateBuilder exportAnyUri(Iterable<String> uris) {
    final uriList = uris.toNonEmptyList('uris');
    return satisfy(
      HeimdallPredicate.anyOf(
        uriList.map(_fileExportsUri),
        description: 'export any of ${uriList.join(', ')}',
      ),
    );
  }

  /// Selects files that export none of the URIs in [uris].
  FilePredicateBuilder exportNoUris(Iterable<String> uris) {
    final uriList = uris.toNonEmptyList('uris');
    return satisfy(
      HeimdallPredicate.noneOf(
        uriList.map(_fileExportsUri),
        description: 'export none of ${uriList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for export URI rules.
extension FileExportUriShouldRules on FileShouldBuilder {
  /// Requires matching files to export [uri].
  HeimdallRule<HeimdallSourceFile> exportUri(String uri) {
    return satisfy(_fileShouldExportUri(uri));
  }

  /// Requires matching files to not export [uri].
  HeimdallRule<HeimdallSourceFile> notExportUri(String uri) {
    return satisfy(
      HeimdallCondition('not export $uri', (item, _) {
        final findings = item.exportDirectives
            .where((directive) => directive.targetUris.contains(uri))
            .map(
              (directive) => fileNodeFinding(
                item,
                directive,
                'exports forbidden URI $uri',
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

  /// Requires matching files to export every URI in [uris].
  HeimdallRule<HeimdallSourceFile> exportAllUris(Iterable<String> uris) {
    final uriList = uris.toNonEmptyList('uris');
    return satisfy(
      HeimdallCondition.allOf(
        uriList.map(_fileShouldExportUri),
        description: 'export all of ${uriList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to export at least one URI in [uris].
  HeimdallRule<HeimdallSourceFile> exportAnyUri(Iterable<String> uris) {
    final uriList = uris.toNonEmptyList('uris');
    return satisfy(
      HeimdallCondition.anyOf(
        uriList.map(_fileShouldExportUri),
        description: 'export any of ${uriList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to export none of the URIs in [uris].
  HeimdallRule<HeimdallSourceFile> exportNoUris(Iterable<String> uris) {
    final uriList = uris.toNonEmptyList('uris');
    return satisfy(
      HeimdallCondition.noneOf(
        uriList.map(_fileShouldExportUri),
        description: 'export none of ${uriList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<HeimdallSourceFile> _fileShouldExportUri(String uri) {
  return HeimdallCondition('export $uri', (item, _) {
    final exportsUri = item.exportDirectives.any((directive) => directive.targetUris.contains(uri));
    final findings = exportsUri
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              message: 'does not export $uri',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<HeimdallSourceFile> _fileExportsUri(String uri) {
  return HeimdallPredicate(
    'export $uri',
    (item, _) => item.exportDirectives.any((directive) => directive.targetUris.contains(uri)),
  );
}
