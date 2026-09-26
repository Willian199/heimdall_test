import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for named public class count rules.
extension FileHaveAtMostOnePublicClassPredicateRules on FilePredicateBuilder {
  /// Selects files that declare at most one public class named [className].
  FilePredicateBuilder haveAtMostOnePublicClassNamed(String className) {
    return satisfy(_fileHasAtMostOnePublicClassNamed(className));
  }

  /// Selects files that declare more than one public class named [className].
  FilePredicateBuilder haveMoreThanOnePublicClassNamed(String className) {
    return satisfy(_fileHasMoreThanOnePublicClassNamed(className));
  }

  /// Selects files that declare at most one public class for at least one name in [classNames].
  FilePredicateBuilder haveAtMostOnePublicClassForAtLeastOneName(
    Iterable<String> classNames,
  ) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        classList.map(_fileHasAtMostOnePublicClassNamed),
        description: 'have at most one public class named any of ${classList.join(', ')}',
      ),
    );
  }

  /// Selects files that declare at most one public class for every name in [classNames].
  FilePredicateBuilder haveAtMostOnePublicClassForEachName(
    Iterable<String> classNames,
  ) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallPredicate.allOf(
        classList.map(_fileHasAtMostOnePublicClassNamed),
        description: 'have at most one public class named all of ${classList.join(', ')}',
      ),
    );
  }

  /// Selects files that declare at most one public class for none of [classNames].
  FilePredicateBuilder haveMultiplePublicClassesForEachName(
    Iterable<String> classNames,
  ) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        classList.map(_fileHasAtMostOnePublicClassNamed),
        description: 'have at most one public class named none of ${classList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for named public class count rules.
extension FileHaveAtMostOnePublicClassShouldRules on FileShouldBuilder {
  /// Requires matching files to declare at most one public class named [className].
  HeimdallRule<HeimdallSourceFile> haveAtMostOnePublicClassNamed(
    String className,
  ) {
    return satisfy(_fileShouldHaveAtMostOnePublicClassNamed(className));
  }

  /// Requires matching files to not declare at most one public class named [className].
  HeimdallRule<HeimdallSourceFile> haveMoreThanOnePublicClassNamed(
    String className,
  ) {
    return satisfy(_fileShouldHaveMoreThanOnePublicClassNamed(className));
  }

  /// Requires matching files to declare at most one public class for at least one name in [classNames].
  HeimdallRule<HeimdallSourceFile> haveAtMostOnePublicClassForAtLeastOneName(
    Iterable<String> classNames,
  ) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallCondition.anyOf(
        classList.map(_fileShouldHaveAtMostOnePublicClassNamed),
        description: 'have at most one public class named any of ${classList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to declare at most one public class for every name in [classNames].
  HeimdallRule<HeimdallSourceFile> haveAtMostOnePublicClassForEachName(
    Iterable<String> classNames,
  ) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallCondition.allOf(
        classList.map(_fileShouldHaveAtMostOnePublicClassNamed),
        description: 'have at most one public class named all of ${classList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to declare at most one public class for none of [classNames].
  HeimdallRule<HeimdallSourceFile> haveMultiplePublicClassesForEachName(
    Iterable<String> classNames,
  ) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallCondition.noneOf(
        classList.map(_fileShouldHaveAtMostOnePublicClassNamed),
        description: 'have at most one public class named none of ${classList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<HeimdallSourceFile> _fileHasAtMostOnePublicClassNamed(
  String className,
) {
  return HeimdallPredicate(
    'have at most one public class named $className',
    (item, _) => _publicClassesNamed(item, className).length <= 1,
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldHaveAtMostOnePublicClassNamed(String className) {
  return HeimdallCondition('have at most one public class named $className', (
    item,
    _,
  ) {
    final classes = _publicClassesNamed(item, className);
    final findings = classes.length <= 1
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              line: classes[1].line,
              message: 'declares more than one public class named $className',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

List<CompilationUnitMember> _publicClassesNamed(
  HeimdallSourceFile item,
  String className,
) {
  return item.publicClassDeclarations.where((declaration) => declaration.name == className).toList();
}

HeimdallPredicate<HeimdallSourceFile> _fileHasMoreThanOnePublicClassNamed(
  String className,
) {
  return HeimdallPredicate(
    'have more than one public class named $className',
    (item, _) => _publicClassesNamed(item, className).length > 1,
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldHaveMoreThanOnePublicClassNamed(String className) {
  return HeimdallCondition('have more than one public class named $className', (item, _) {
    final classes = _publicClassesNamed(item, className);
    final findings = classes.length > 1
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              line: classes.isEmpty ? 1 : classes.single.line,
              column: 1,
              message: 'should declare more than one public class named $className',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
