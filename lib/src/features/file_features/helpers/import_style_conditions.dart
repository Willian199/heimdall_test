import 'package:heimdall_test/heimdall_test.dart';

/// Rejects every relative import target, including conditional alternatives.
///
/// Uses the import model's lexical definition of relative (no colon). This
/// checks style only; URI validity and package boundaries are separate policies.
HeimdallCondition<HeimdallSourceFile> fileShouldNotUseRelativeImports({
  String description = 'not use relative imports',
  String Function(String uri)? message,
}) {
  return HeimdallCondition(description, (file, _) {
    final findings = [
      for (final directive in file.relativeImports)
        for (final target in directive.targetUris)
          if (!target.contains(':'))
            HeimdallValidationInfo(
              filePath: file.absolutePath,
              line: directive.line,
              message: message?.call(target) ?? 'uses relative import $target',
            ),
    ];
    return HeimdallFindings(subject: file, passed: findings.isEmpty, findings: findings);
  });
}
