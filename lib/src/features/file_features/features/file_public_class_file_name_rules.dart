import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/file_features/helpers/public_class_name_mismatch.dart';

/// Predicate-side DSL for public class/file-name convention rules.
extension FilePublicClassFileNamePredicateRules on FilePredicateBuilder {
  /// Selects files whose public class name matches the file name.
  FilePredicateBuilder havePublicClassNameMatchingFileName() {
    return satisfy(_fileHasPublicClassNameMatchingFileName());
  }

  /// Selects files whose public class name does not match the file name.
  FilePredicateBuilder noHavePublicClassNameMatchingFileName() {
    return satisfy(_fileDoesNotHavePublicClassNameMatchingFileName());
  }

  /// Selects files with a matching public class and at most one public class.
  FilePredicateBuilder haveMatchingSinglePublicClassFileName() {
    return satisfy(
      HeimdallPredicate.allOf([
        _fileHasPublicClassNameMatchingFileName(),
        fileHasAtMostOnePublicClass(),
      ], description: 'have matching single public class file name'),
    );
  }
}

/// Condition-side DSL for public class/file-name convention rules.
extension FilePublicClassFileNameShouldRules on FileShouldBuilder {
  /// Requires a file's public class name to match its file name.
  HeimdallRule<HeimdallSourceFile> havePublicClassNameMatchingFileName() {
    return satisfy(_fileShouldHavePublicClassNameMatchingFileName());
  }

  /// Requires a file's public class name to not match its file name.
  HeimdallRule<HeimdallSourceFile> noHavePublicClassNameMatchingFileName() {
    return satisfy(_fileShouldNotHavePublicClassNameMatchingFileName());
  }

  /// Requires a matching public class and at most one public class.
  HeimdallRule<HeimdallSourceFile> haveMatchingSinglePublicClassFileName() {
    return satisfy(
      HeimdallCondition.allOf([
        _fileShouldHavePublicClassNameMatchingFileName(),
        fileShouldHaveAtMostOnePublicClass(),
      ], description: 'have matching single public class file name'),
    );
  }
}

HeimdallCondition<HeimdallSourceFile> _fileShouldHavePublicClassNameMatchingFileName() {
  return HeimdallCondition('have public class name matching file name', (
    item,
    _,
  ) {
    final mismatch = publicClassNameMismatch(item);
    final findings = mismatch == null
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              line: mismatch.declaration.line,
              message: 'should be named ${mismatch.expectedFileName}.dart for ${mismatch.declaration.namePart.typeName.lexeme}',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<HeimdallSourceFile> _fileHasPublicClassNameMatchingFileName() {
  return HeimdallPredicate(
    'have public class name matching file name',
    (item, _) => publicClassNameMismatch(item) == null,
  );
}

HeimdallPredicate<HeimdallSourceFile> _fileDoesNotHavePublicClassNameMatchingFileName() {
  return HeimdallPredicate(
    'not have public class name matching file name',
    (item, _) => publicClassNameMismatch(item) != null,
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldNotHavePublicClassNameMatchingFileName() {
  return HeimdallCondition('not have public class name matching file name', (
    item,
    _,
  ) {
    final findings = publicClassNameMismatch(item) != null
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              line: 1,
              column: 1,
              message: 'has public class name matching file name',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
