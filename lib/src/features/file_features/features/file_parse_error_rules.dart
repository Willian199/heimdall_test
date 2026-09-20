import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for general parse error rules.
extension FileParseErrorPredicateRules on FilePredicateBuilder {
  /// Selects files that have no parse errors.
  FilePredicateBuilder haveNoParseErrors() {
    return satisfy(_fileHasNoParseErrors());
  }

  /// Selects files that have parse errors.
  FilePredicateBuilder haveParseErrors() {
    return satisfy(_fileHasParseErrors());
  }
}

/// Condition-side DSL for general parse error rules.
extension FileParseErrorShouldRules on FileShouldBuilder {
  /// Requires matching files to have no parse errors.
  HeimdallRule<HeimdallSourceFile> haveNoParseErrors() {
    return satisfy(_fileShouldHaveNoParseErrors());
  }

  /// Requires matching files to have at least one parse error.
  HeimdallRule<HeimdallSourceFile> haveParseErrors() {
    return satisfy(_fileShouldHaveParseErrors());
  }
}

HeimdallPredicate<HeimdallSourceFile> _fileHasNoParseErrors() {
  return HeimdallPredicate(
    'have no parse errors',
    (item, _) => item.parseErrors.isEmpty,
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldHaveNoParseErrors() {
  return HeimdallCondition('have no parse errors', (item, _) {
    final findings = item.parseErrors
        .map(
          (error) => HeimdallValidationInfo(
            filePath: item.absolutePath,
            line: error.line,
            column: error.column,
            message: error.message,
          ),
        )
        .toList();
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<HeimdallSourceFile> _fileHasParseErrors() {
  return HeimdallPredicate(
    'have parse errors',
    (item, _) => item.parseErrors.isNotEmpty,
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldHaveParseErrors() {
  return HeimdallCondition('have parse errors', (item, _) {
    final findings = item.parseErrors.isNotEmpty
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              line: 1,
              column: 1,
              message: 'has no parse errors',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
