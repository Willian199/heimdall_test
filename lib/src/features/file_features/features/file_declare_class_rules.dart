import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/file_features/helpers/source_file_location.dart';

/// Predicate-side DSL for declared class rules.
extension FileDeclareClassPredicateRules on FilePredicateBuilder {
  /// Selects files that declare a class named [className].
  FilePredicateBuilder declareClass(String className) {
    return satisfy(_fileDeclaresClass(className));
  }

  /// Selects files that do not declare a class named [className].
  FilePredicateBuilder notDeclareClass(String className) {
    return satisfy(
      HeimdallPredicate(
        'not declare class $className',
        (item, _) => !item.classDeclarations.any(
          (declaration) => declaration.name == className,
        ),
      ),
    );
  }

  /// Selects files that declare every class in [classNames].
  FilePredicateBuilder declareAllClasses(Iterable<String> classNames) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallPredicate.allOf(
        classList.map(_fileDeclaresClass),
        description: 'declare all classes ${classList.join(', ')}',
      ),
    );
  }

  /// Selects files that declare at least one class in [classNames].
  FilePredicateBuilder declareAnyClass(Iterable<String> classNames) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        classList.map(_fileDeclaresClass),
        description: 'declare any class ${classList.join(', ')}',
      ),
    );
  }

  /// Selects files that declare none of [classNames].
  FilePredicateBuilder declareNoClasses(Iterable<String> classNames) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        classList.map(_fileDeclaresClass),
        description: 'declare no classes ${classList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for declared class rules.
extension FileDeclareClassShouldRules on FileShouldBuilder {
  /// Requires matching files to declare a class named [className].
  HeimdallRule<HeimdallSourceFile> declareClass(String className) {
    return satisfy(_fileShouldDeclareClass(className));
  }

  /// Requires matching files to not declare a class named [className].
  HeimdallRule<HeimdallSourceFile> notDeclareClass(String className) {
    return satisfy(_fileShouldNotDeclareClass(className));
  }

  /// Requires matching files to declare every class in [classNames].
  HeimdallRule<HeimdallSourceFile> declareAllClasses(
    Iterable<String> classNames,
  ) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallCondition.allOf(
        classList.map(_fileShouldDeclareClass),
        description: 'declare all classes ${classList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to declare at least one class in [classNames].
  HeimdallRule<HeimdallSourceFile> declareAnyClass(
    Iterable<String> classNames,
  ) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallCondition.anyOf(
        classList.map(_fileShouldDeclareClass),
        description: 'declare any class ${classList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to declare none of [classNames].
  HeimdallRule<HeimdallSourceFile> declareNoClasses(
    Iterable<String> classNames,
  ) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallCondition.noneOf(
        classList.map(_fileShouldDeclareClass),
        description: 'declare no classes ${classList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<HeimdallSourceFile> _fileShouldDeclareClass(
  String className,
) {
  return HeimdallCondition('declare class $className', (item, _) {
    final hasClass = item.classDeclarations.any(
      (declaration) => declaration.name == className,
    );
    final findings = hasClass
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              message: 'does not declare class $className',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<HeimdallSourceFile> _fileDeclaresClass(String className) {
  return HeimdallPredicate(
    'declare class $className',
    (item, _) => item.classDeclarations.any(
      (declaration) => declaration.name == className,
    ),
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldNotDeclareClass(
  String className,
) {
  return HeimdallCondition('not declare class $className', (item, _) {
    final findings = item.classDeclarations
        .where(
          (declaration) => declaration.name == className,
        )
        .map(
          (declaration) => fileNodeFinding(
            item,
            declaration,
            'declares forbidden class $className',
            offset: switch (declaration) {
              ClassDeclaration() => declaration.namePart.typeName.offset,
              ClassTypeAlias() => declaration.name.offset,
              _ => declaration.offset,
            },
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
