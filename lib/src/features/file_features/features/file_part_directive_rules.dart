import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for part directive rules.
extension FilePartDirectivePredicateRules on FilePredicateBuilder {
  /// Selects files that declare a `library` directive.
  FilePredicateBuilder haveLibraryDirective() {
    return satisfy(
      HeimdallPredicate(
        'have library directive',
        (item, _) => item.libraryDirective != null,
      ),
    );
  }

  /// Selects files that do not declare a `library` directive.
  FilePredicateBuilder noHaveLibraryDirective() {
    return satisfy(
      HeimdallPredicate(
        'not have library directive',
        (item, _) => item.libraryDirective == null,
      ),
    );
  }

  /// Selects files that declare a `part of` directive.
  FilePredicateBuilder havePartOfDirective() {
    return satisfy(
      HeimdallPredicate(
        'have part of directive',
        (item, _) => item.partOfDirectives.isNotEmpty,
      ),
    );
  }

  /// Selects files that do not declare a `part of` directive.
  FilePredicateBuilder notUsePartOfDirective() {
    return satisfy(
      HeimdallPredicate(
        'not use part of directive',
        (item, _) => item.partOfDirectives.isEmpty,
      ),
    );
  }
}

/// Condition-side DSL for part directive rules.
extension FilePartDirectiveShouldRules on FileShouldBuilder {
  /// Requires matching files to declare a `library` directive.
  HeimdallRule<HeimdallSourceFile> haveLibraryDirective() {
    return satisfy(
      HeimdallCondition('have library directive', (item, _) {
        final findings = item.libraryDirective != null
            ? const <HeimdallValidationInfo>[]
            : [
                HeimdallValidationInfo(
                  filePath: item.absolutePath,
                  message: 'does not declare a library directive',
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

  /// Requires matching files to not declare a `library` directive.
  HeimdallRule<HeimdallSourceFile> noHaveLibraryDirective() {
    return satisfy(
      HeimdallCondition('not have library directive', (item, _) {
        final directive = item.libraryDirective;
        final findings = directive == null
            ? const <HeimdallValidationInfo>[]
            : [
                HeimdallValidationInfo(
                  filePath: item.absolutePath,
                  line: directive.line,
                  column: 1,
                  message: 'declares forbidden library directive',
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

  /// Requires matching files to declare a `part of` directive.
  HeimdallRule<HeimdallSourceFile> havePartOfDirective() {
    return satisfy(
      HeimdallCondition('have part of directive', (item, _) {
        final findings = item.partOfDirectives.isNotEmpty
            ? const <HeimdallValidationInfo>[]
            : [
                HeimdallValidationInfo(
                  filePath: item.absolutePath,
                  message: 'does not declare a part of directive',
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

  /// Requires matching files not to declare a `part of` directive.
  HeimdallRule<HeimdallSourceFile> notUsePartOfDirective() {
    return satisfy(
      HeimdallCondition('not use part of directive', (item, _) {
        final findings = item.partOfDirectives
            .map(
              (directive) => HeimdallValidationInfo(
                filePath: item.absolutePath,
                line: directive.line,
                message: 'declares part of ${directive.targetUri}',
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
