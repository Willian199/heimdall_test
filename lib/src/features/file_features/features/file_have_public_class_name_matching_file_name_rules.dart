import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/file_features/helpers/public_class_name_mismatch.dart';

/// Predicate-side DSL for named public class/file-name convention rules.
extension FileHavePublicClassNameMatchingFileNamePredicateRules on FilePredicateBuilder {
  /// Selects files whose public class named [className] matches the file name.
  FilePredicateBuilder havePublicClassNameMatchingFileNameFor(
    String className,
  ) {
    return satisfy(_fileHasPublicClassNameMatchingFileNameFor(className));
  }

  /// Selects files whose public class named [className] does not match the file name.
  FilePredicateBuilder noHavePublicClassNameMatchingFileNameFor(
    String className,
  ) {
    return satisfy(_fileDoesNotHavePublicClassNameMatchingFileNameFor(className));
  }

  /// Selects files whose public class/file-name convention matches at least one name in [classNames].
  FilePredicateBuilder havePublicClassNameMatchingFileNameForAny(
    Iterable<String> classNames,
  ) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        classList.map(_fileHasPublicClassNameMatchingFileNameFor),
        description: 'have public class name matching file name for any of ${classList.join(', ')}',
      ),
    );
  }

  /// Selects files whose public class/file-name convention matches every name in [classNames].
  FilePredicateBuilder havePublicClassNameMatchingFileNameForAll(
    Iterable<String> classNames,
  ) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallPredicate.allOf(
        classList.map(_fileHasPublicClassNameMatchingFileNameFor),
        description: 'have public class name matching file name for all of ${classList.join(', ')}',
      ),
    );
  }

  /// Selects files whose public class/file-name convention matches none of [classNames].
  FilePredicateBuilder havePublicClassNameMatchingFileNameForNone(
    Iterable<String> classNames,
  ) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        classList.map(_fileHasPublicClassNameMatchingFileNameFor),
        description: 'have public class name matching file name for none of ${classList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for named public class/file-name convention rules.
extension FileHavePublicClassNameMatchingFileNameShouldRules on FileShouldBuilder {
  /// Requires a public class named [className] to match its file name.
  HeimdallRule<HeimdallSourceFile> havePublicClassNameMatchingFileNameFor(
    String className,
  ) {
    return satisfy(_fileShouldHavePublicClassNameMatchingFileNameFor(className));
  }

  /// Requires a public class named [className] to not match its file name.
  HeimdallRule<HeimdallSourceFile> noHavePublicClassNameMatchingFileNameFor(
    String className,
  ) {
    return satisfy(_fileShouldNotHavePublicClassNameMatchingFileNameFor(className));
  }

  /// Requires the public class/file-name convention to match at least one name in [classNames].
  HeimdallRule<HeimdallSourceFile> havePublicClassNameMatchingFileNameForAny(
    Iterable<String> classNames,
  ) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallCondition.anyOf(
        classList.map(_fileShouldHavePublicClassNameMatchingFileNameFor),
        description: 'have public class name matching file name for any of ${classList.join(', ')}',
      ),
    );
  }

  /// Requires the public class/file-name convention to match every name in [classNames].
  HeimdallRule<HeimdallSourceFile> havePublicClassNameMatchingFileNameForAll(
    Iterable<String> classNames,
  ) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallCondition.allOf(
        classList.map(_fileShouldHavePublicClassNameMatchingFileNameFor),
        description: 'have public class name matching file name for all of ${classList.join(', ')}',
      ),
    );
  }

  /// Requires the public class/file-name convention to match none of [classNames].
  HeimdallRule<HeimdallSourceFile> havePublicClassNameMatchingFileNameForNone(
    Iterable<String> classNames,
  ) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallCondition.noneOf(
        classList.map(_fileShouldHavePublicClassNameMatchingFileNameFor),
        description: 'have public class name matching file name for none of ${classList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<HeimdallSourceFile> _fileHasPublicClassNameMatchingFileNameFor(String className) {
  return HeimdallPredicate(
    'have public class name matching file name for $className',
    (item, _) => publicClassNameMismatch(item, className: className) == null,
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldHavePublicClassNameMatchingFileNameFor(String className) {
  return HeimdallCondition('have public class name matching file name for $className', (item, _) {
    final mismatch = publicClassNameMismatch(item, className: className);
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

HeimdallPredicate<HeimdallSourceFile> _fileDoesNotHavePublicClassNameMatchingFileNameFor(String className) {
  return HeimdallPredicate(
    'not have public class name matching file name for $className',
    (item, _) => publicClassNameMismatch(item, className: className) != null,
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldNotHavePublicClassNameMatchingFileNameFor(String className) {
  return HeimdallCondition('not have public class name matching file name for $className', (item, _) {
    final findings = publicClassNameMismatch(item, className: className) != null
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              line: 1,
              column: 1,
              message: 'has public class name matching file name for $className',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
