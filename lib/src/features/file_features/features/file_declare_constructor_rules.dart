import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/file_features/helpers/source_file_location.dart';

/// Predicate-side DSL for declared constructor rules.
extension FileDeclareConstructorPredicateRules on FilePredicateBuilder {
  /// Selects files that declare a constructor named [name].
  FilePredicateBuilder declareConstructor({
    String name = 'new',
    String? className,
  }) {
    return satisfy(_fileDeclaresConstructor(name: name, className: className));
  }

  /// Selects files that do not declare a constructor named [name].
  FilePredicateBuilder noDeclareConstructor({
    String name = 'new',
    String? className,
  }) {
    return satisfy(
      _fileDoesNotDeclareConstructor(name: name, className: className),
    );
  }

  /// Selects files that declare every constructor in [names].
  FilePredicateBuilder declareAllConstructors(
    Iterable<String> names, {
    String? className,
  }) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.allOf(
        nameList.map(
          (name) => _fileDeclaresConstructor(
            name: name,
            className: className,
          ),
        ),
        description: 'declare all constructors ${nameList.join(', ')}',
      ),
    );
  }

  /// Selects files that declare at least one constructor in [names].
  FilePredicateBuilder declareAnyConstructor(
    Iterable<String> names, {
    String? className,
  }) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.anyOf(
        nameList.map(
          (name) => _fileDeclaresConstructor(
            name: name,
            className: className,
          ),
        ),
        description: 'declare any constructor ${nameList.join(', ')}',
      ),
    );
  }

  /// Selects files that declare none of the constructors in [names].
  FilePredicateBuilder declareNoConstructors(
    Iterable<String> names, {
    String? className,
  }) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.noneOf(
        nameList.map(
          (name) => _fileDeclaresConstructor(
            name: name,
            className: className,
          ),
        ),
        description: 'declare no constructors ${nameList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for declared constructor rules.
extension FileDeclareConstructorShouldRules on FileShouldBuilder {
  /// Requires matching files to declare a constructor named [name].
  HeimdallRule<HeimdallSourceFile> declareConstructor({
    String name = 'new',
    String? className,
  }) {
    return satisfy(
      _fileShouldDeclareConstructor(name: name, className: className),
    );
  }

  /// Requires matching files to not declare a constructor named [name].
  HeimdallRule<HeimdallSourceFile> noDeclareConstructor({
    String name = 'new',
    String? className,
  }) {
    return satisfy(
      _fileShouldNotDeclareConstructor(name: name, className: className),
    );
  }

  /// Requires matching files to declare every constructor in [names].
  HeimdallRule<HeimdallSourceFile> declareAllConstructors(
    Iterable<String> names, {
    String? className,
  }) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.allOf(
        nameList.map(
          (name) => _fileShouldDeclareConstructor(
            name: name,
            className: className,
          ),
        ),
        description: 'declare all constructors ${nameList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to declare at least one constructor in [names].
  HeimdallRule<HeimdallSourceFile> declareAnyConstructor(
    Iterable<String> names, {
    String? className,
  }) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.anyOf(
        nameList.map(
          (name) => _fileShouldDeclareConstructor(
            name: name,
            className: className,
          ),
        ),
        description: 'declare any constructor ${nameList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to declare none of the constructors in [names].
  HeimdallRule<HeimdallSourceFile> declareNoConstructors(
    Iterable<String> names, {
    String? className,
  }) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.noneOf(
        nameList.map(
          (name) => _fileShouldDeclareConstructor(
            name: name,
            className: className,
          ),
        ),
        description: 'declare no constructors ${nameList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<HeimdallSourceFile> _fileShouldDeclareConstructor({
  String name = 'new',
  String? className,
}) {
  return HeimdallCondition('declare constructor $name', (item, _) {
    final hasConstructor = _constructors(item, className: className).any(
      (constructor) => _constructorName(constructor) == name,
    );
    final findings = hasConstructor
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              message: 'does not declare constructor $name',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<HeimdallSourceFile> _fileDeclaresConstructor({
  String name = 'new',
  String? className,
}) {
  return HeimdallPredicate(
    'declare constructor $name',
    (item, _) => _constructors(item, className: className).any(
      (constructor) => _constructorName(constructor) == name,
    ),
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldNotDeclareConstructor({
  String name = 'new',
  String? className,
}) {
  return HeimdallCondition('not declare constructor $name', (item, _) {
    final findings = _constructors(item, className: className)
        .where((constructor) => _constructorName(constructor) == name)
        .map(
          (constructor) => fileNodeFinding(
            item,
            constructor,
            'declares forbidden constructor $name',
            offset: constructor.name?.offset ?? constructor.offset,
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

HeimdallPredicate<HeimdallSourceFile> _fileDoesNotDeclareConstructor({
  String name = 'new',
  String? className,
}) {
  return HeimdallPredicate(
    'not declare constructor $name',
    (item, _) => !_constructors(item, className: className).any(
      (constructor) => _constructorName(constructor) == name,
    ),
  );
}

Iterable<ConstructorDeclaration> _constructors(
  HeimdallSourceFile item, {
  String? className,
}) {
  if (className == null) return item.constructors;
  return item.constructors.where((constructor) => constructor.ownerName == className);
}

String _constructorName(ConstructorDeclaration constructor) {
  return constructor.name?.lexeme ?? 'new';
}
