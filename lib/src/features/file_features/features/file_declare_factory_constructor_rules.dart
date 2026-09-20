import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/file_features/helpers/source_file_location.dart';

/// Predicate-side DSL for factory constructor rules.
extension FileDeclareFactoryConstructorPredicateRules on FilePredicateBuilder {
  /// Selects files that declare a `factory` constructor.
  FilePredicateBuilder declareFactoryConstructor({String? className}) {
    return satisfy(_fileDeclaresFactoryConstructor(className: className));
  }

  /// Selects files that do not declare a `factory` constructor.
  FilePredicateBuilder noDeclareFactoryConstructor({String? className}) {
    return satisfy(
      _fileDoesNotDeclareFactoryConstructor(className: className),
    );
  }

  /// Selects files that declare a `factory` constructor for every class in [classNames].
  FilePredicateBuilder declareAllFactoryConstructors(
    Iterable<String> classNames,
  ) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallPredicate.allOf(
        classList.map(
          (className) => _fileDeclaresFactoryConstructor(
            className: className,
          ),
        ),
        description: 'declare all factory constructors ${classList.join(', ')}',
      ),
    );
  }

  /// Selects files that declare a `factory` constructor for at least one class in [classNames].
  FilePredicateBuilder declareAnyFactoryConstructor(
    Iterable<String> classNames,
  ) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        classList.map(
          (className) => _fileDeclaresFactoryConstructor(
            className: className,
          ),
        ),
        description: 'declare any factory constructor ${classList.join(', ')}',
      ),
    );
  }

  /// Selects files that declare a `factory` constructor for none of [classNames].
  FilePredicateBuilder declareNoFactoryConstructors(
    Iterable<String> classNames,
  ) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        classList.map(
          (className) => _fileDeclaresFactoryConstructor(
            className: className,
          ),
        ),
        description: 'declare no factory constructors ${classList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for factory constructor rules.
extension FileDeclareFactoryConstructorShouldRules on FileShouldBuilder {
  /// Requires matching files to declare a `factory` constructor.
  HeimdallRule<HeimdallSourceFile> declareFactoryConstructor({
    String? className,
  }) {
    return satisfy(_fileShouldDeclareFactoryConstructor(className: className));
  }

  /// Requires matching files to not declare a `factory` constructor.
  HeimdallRule<HeimdallSourceFile> noDeclareFactoryConstructor({
    String? className,
  }) {
    return satisfy(
      _fileShouldNotDeclareFactoryConstructor(className: className),
    );
  }

  /// Requires matching files to declare a `factory` constructor for every class in [classNames].
  HeimdallRule<HeimdallSourceFile> declareAllFactoryConstructors(
    Iterable<String> classNames,
  ) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallCondition.allOf(
        classList.map(
          (className) => _fileShouldDeclareFactoryConstructor(
            className: className,
          ),
        ),
        description: 'declare all factory constructors ${classList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to declare a `factory` constructor for at least one class in [classNames].
  HeimdallRule<HeimdallSourceFile> declareAnyFactoryConstructor(
    Iterable<String> classNames,
  ) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallCondition.anyOf(
        classList.map(
          (className) => _fileShouldDeclareFactoryConstructor(
            className: className,
          ),
        ),
        description: 'declare any factory constructor ${classList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to declare a `factory` constructor for none of [classNames].
  HeimdallRule<HeimdallSourceFile> declareNoFactoryConstructors(
    Iterable<String> classNames,
  ) {
    final classList = classNames.toNonEmptyList('classNames');
    return satisfy(
      HeimdallCondition.noneOf(
        classList.map(
          (className) => _fileShouldDeclareFactoryConstructor(
            className: className,
          ),
        ),
        description: 'declare no factory constructors ${classList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<HeimdallSourceFile> _fileDeclaresFactoryConstructor({
  String? className,
}) {
  return HeimdallPredicate(
    'declare factory constructor',
    (item, _) => _constructors(
      item,
      className: className,
    ).any((constructor) => constructor.isFactory),
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldDeclareFactoryConstructor({
  String? className,
}) {
  return HeimdallCondition('declare factory constructor', (item, _) {
    final hasConstructor = _constructors(
      item,
      className: className,
    ).any((constructor) => constructor.isFactory);
    final findings = hasConstructor
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              message: 'does not declare a factory constructor',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<HeimdallSourceFile> _fileDoesNotDeclareFactoryConstructor({
  String? className,
}) {
  return HeimdallPredicate(
    'not declare factory constructor',
    (item, _) => !_constructors(
      item,
      className: className,
    ).any((constructor) => constructor.isFactory),
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldNotDeclareFactoryConstructor({
  String? className,
}) {
  return HeimdallCondition('not declare factory constructor', (item, _) {
    final findings = _constructors(item, className: className)
        .where((constructor) => constructor.isFactory)
        .map(
          (constructor) => fileNodeFinding(
            item,
            constructor,
            'declares forbidden factory constructor',
            offset: constructor.factoryKeyword?.offset,
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
