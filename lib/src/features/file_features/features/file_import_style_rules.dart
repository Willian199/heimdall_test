import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for source-file import style rules.
extension FileImportStylePredicateRules on FilePredicateBuilder {
  /// Selects files whose imports use only `package:` or `dart:` URIs.
  FilePredicateBuilder useOnlyPackageImports() {
    return satisfy(
      HeimdallPredicate(
        'use only package imports',
        (item, _) => item.importDirectives.expand((directive) => directive.targetUris).every(_isPackageOrSdkUri),
      ),
    );
  }

  /// Selects files that use at least one non-package import URI.
  FilePredicateBuilder noUseOnlyPackageImports() {
    return satisfy(
      HeimdallPredicate(
        'not use only package imports',
        (item, _) => item.importDirectives.expand((directive) => directive.targetUris).any((uri) => !_isPackageOrSdkUri(uri)),
      ),
    );
  }

  /// Selects files that do not use relative import URIs.
  FilePredicateBuilder notUseRelativeImports() {
    return satisfy(
      HeimdallPredicate(
        'not use relative imports',
        (item, _) => item.relativeImports.isEmpty,
      ),
    );
  }
}

/// Condition-side DSL for source-file import style rules.
extension FileImportStyleShouldRules on FileShouldBuilder {
  /// Requires matching files to use only `package:` or `dart:` imports.
  HeimdallRule<HeimdallSourceFile> useOnlyPackageImports() {
    return satisfy(
      HeimdallCondition('use only package imports', (item, _) {
        final findings = [
          for (final directive in item.importDirectives)
            for (final uri in directive.targetUris)
              if (!_isPackageOrSdkUri(uri))
                HeimdallValidationInfo(
                  filePath: item.absolutePath,
                  line: directive.line,
                  message: 'imports $uri without a package URI',
                ),
        ];

        return HeimdallFindings(
          subject: item,
          passed: findings.isEmpty,
          findings: findings,
        );
      }),
    );
  }

  /// Requires matching files to use at least one non-package import URI.
  HeimdallRule<HeimdallSourceFile> noUseOnlyPackageImports() {
    return satisfy(
      HeimdallCondition('not use only package imports', (item, _) {
        final hasNonPackageImport = item.importDirectives
            .expand((directive) => directive.targetUris)
            .any(
              (uri) => !_isPackageOrSdkUri(uri),
            );
        final findings = hasNonPackageImport
            ? const <HeimdallValidationInfo>[]
            : [
                HeimdallValidationInfo(
                  filePath: item.absolutePath,
                  line: 1,
                  column: 1,
                  message: 'uses only package imports',
                ),
              ];

        return HeimdallFindings(
          subject: item,
          passed: findings.isEmpty,
          findings: findings,
        );
      }),
    );
  }

  /// Requires matching files not to use relative import URIs.
  HeimdallRule<HeimdallSourceFile> notUseRelativeImports() {
    return satisfy(
      HeimdallCondition('not use relative imports', (item, _) {
        final findings = item.relativeImports
            .map(
              (directive) => HeimdallValidationInfo(
                filePath: item.absolutePath,
                line: directive.line,
                message: 'uses relative import ${directive.targetUri}',
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
}

bool _isPackageOrSdkUri(String uri) {
  return uri.startsWith('package:') || uri.startsWith('dart:');
}
