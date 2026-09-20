import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/file_features/helpers/source_file_location.dart';

/// Predicate-side DSL for const constructor rules.
extension FileDeclareConstConstructorPredicateRules on FilePredicateBuilder {
  /// Selects files that declare a `const` constructor.
  FilePredicateBuilder declareConstConstructor({String? className}) {
    return satisfy(_fileDeclaresConstConstructor(className: className));
  }

  /// Selects files that do not declare a `const` constructor.
  FilePredicateBuilder noDeclareConstConstructor({String? className}) {
    return satisfy(_fileDoesNotDeclareConstConstructor(className: className));
  }

  /// Selects files that declare a `const` constructor for every class in [classNames].
  FilePredicateBuilder declareAllConstConstructors(
    Iterable<String> classNames,
  ) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallPredicate.allOf(
        classList.map(
          (className) => _fileDeclaresConstConstructor(className: className),
        ),
        description: 'declare all const constructors ${classList.join(', ')}',
      ),
    );
  }

  /// Selects files that declare a `const` constructor for at least one class in [classNames].
  FilePredicateBuilder declareAnyConstConstructor(
    Iterable<String> classNames,
  ) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        classList.map(
          (className) => _fileDeclaresConstConstructor(className: className),
        ),
        description: 'declare any const constructor ${classList.join(', ')}',
      ),
    );
  }

  /// Selects files that declare a `const` constructor for none of [classNames].
  FilePredicateBuilder declareNoConstConstructors(
    Iterable<String> classNames,
  ) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        classList.map(
          (className) => _fileDeclaresConstConstructor(className: className),
        ),
        description: 'declare no const constructors ${classList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for const constructor rules.
extension FileDeclareConstConstructorShouldRules on FileShouldBuilder {
  /// Requires matching files to declare a `const` constructor.
  HeimdallRule<HeimdallSourceFile> declareConstConstructor({
    String? className,
  }) {
    return satisfy(_fileShouldDeclareConstConstructor(className: className));
  }

  /// Requires matching files to not declare a `const` constructor.
  HeimdallRule<HeimdallSourceFile> noDeclareConstConstructor({
    String? className,
  }) {
    return satisfy(
      _fileShouldNotDeclareConstConstructor(className: className),
    );
  }

  /// Requires matching files to declare a `const` constructor for every class in [classNames].
  HeimdallRule<HeimdallSourceFile> declareAllConstConstructors(
    Iterable<String> classNames,
  ) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallCondition.allOf(
        classList.map(
          (className) => _fileShouldDeclareConstConstructor(
            className: className,
          ),
        ),
        description: 'declare all const constructors ${classList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to declare a `const` constructor for at least one class in [classNames].
  HeimdallRule<HeimdallSourceFile> declareAnyConstConstructor(
    Iterable<String> classNames,
  ) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallCondition.anyOf(
        classList.map(
          (className) => _fileShouldDeclareConstConstructor(
            className: className,
          ),
        ),
        description: 'declare any const constructor ${classList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to declare a `const` constructor for none of [classNames].
  HeimdallRule<HeimdallSourceFile> declareNoConstConstructors(
    Iterable<String> classNames,
  ) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallCondition.noneOf(
        classList.map(
          (className) => _fileShouldDeclareConstConstructor(
            className: className,
          ),
        ),
        description: 'declare no const constructors ${classList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<HeimdallSourceFile> _fileDeclaresConstConstructor({
  String? className,
}) {
  return HeimdallPredicate(
    'declare const constructor',
    (item, _) => _constructors(
      item,
      className: className,
    ).any((constructor) => constructor.isConst),
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldDeclareConstConstructor({
  String? className,
}) {
  return HeimdallCondition('declare const constructor', (item, _) {
    final hasConstructor = _constructors(
      item,
      className: className,
    ).any((constructor) => constructor.isConst);
    final findings = hasConstructor
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              message: 'does not declare a const constructor',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<HeimdallSourceFile> _fileDoesNotDeclareConstConstructor({
  String? className,
}) {
  return HeimdallPredicate(
    'not declare const constructor',
    (item, _) => !_constructors(
      item,
      className: className,
    ).any((constructor) => constructor.isConst),
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldNotDeclareConstConstructor({
  String? className,
}) {
  return HeimdallCondition('not declare const constructor', (item, _) {
    final findings = _constructors(item, className: className)
        .where((constructor) => constructor.isConst)
        .map(
          (constructor) => fileNodeFinding(
            item,
            constructor,
            'declares forbidden const constructor',
            offset: constructor.constKeyword?.offset,
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

Iterable<ConstructorDeclaration> _constructors(
  HeimdallSourceFile item, {
  String? className,
}) {
  if (className == null) return item.constructors;
  return item.constructors.where((constructor) => constructor.ownerName == className);
}
