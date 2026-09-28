import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for classes whose constructors must be private.
extension ClassHaveOnlyPrivateConstructorsPredicateRules on ClassPredicateBuilder {
  /// Selects classes that declare only private constructors.
  ClassPredicateBuilder haveOnlyPrivateConstructors() {
    return satisfy(_classHasOnlyPrivateConstructors());
  }

  /// Selects classes with no constructors or at least one non-private constructor.
  ClassPredicateBuilder notHaveOnlyPrivateConstructors() {
    return satisfy(_classDoesNotHaveOnlyPrivateConstructors());
  }

  /// Selects classes where every constructor in [names] is private.
  ClassPredicateBuilder havePrivateConstructorsNamedAllOf(
    Iterable<String> names,
  ) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.allOf(
        nameList.map(_classHasPrivateConstructor),
        description: 'have all private constructors ${nameList.join(', ')}',
      ),
    );
  }

  /// Selects classes where at least one constructor in [names] is private.
  ClassPredicateBuilder havePrivateConstructorNamedAnyOf(
    Iterable<String> names,
  ) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.anyOf(
        nameList.map(_classHasPrivateConstructor),
        description: 'have any private constructor ${nameList.join(', ')}',
      ),
    );
  }

  /// Selects classes where none of [names] is a private constructor.
  ClassPredicateBuilder haveNoPrivateConstructorsNamed(
    Iterable<String> names,
  ) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.noneOf(
        nameList.map(_classHasPrivateConstructor),
        description: 'have no private constructors ${nameList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for classes that must expose only private constructors.
extension ClassHaveOnlyPrivateConstructorsShouldRules on ClassShouldBuilder {
  /// Requires matching classes to declare only private constructors.
  HeimdallRule<CompilationUnitMember> haveOnlyPrivateConstructors() {
    return satisfy(_classShouldHaveOnlyPrivateConstructors());
  }

  /// Requires matching classes to have at least one non-private constructor.
  HeimdallRule<CompilationUnitMember> notHaveOnlyPrivateConstructors() {
    return satisfy(_classShouldNotHaveOnlyPrivateConstructors());
  }

  /// Requires every constructor in [names] to be private.
  HeimdallRule<CompilationUnitMember> havePrivateConstructorsNamedAllOf(
    Iterable<String> names,
  ) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.allOf(
        nameList.map(_classShouldHavePrivateConstructor),
        description: 'have all private constructors ${nameList.join(', ')}',
      ),
    );
  }

  /// Requires at least one constructor in [names] to be private.
  HeimdallRule<CompilationUnitMember> havePrivateConstructorNamedAnyOf(
    Iterable<String> names,
  ) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.anyOf(
        nameList.map(_classShouldHavePrivateConstructor),
        description: 'have any private constructor ${nameList.join(', ')}',
      ),
    );
  }

  /// Requires none of [names] to be a private constructor.
  HeimdallRule<CompilationUnitMember> haveNoPrivateConstructorsNamed(
    Iterable<String> names,
  ) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.noneOf(
        nameList.map(_classShouldHavePrivateConstructor),
        description: 'have no private constructors ${nameList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<CompilationUnitMember> _classShouldHaveOnlyPrivateConstructors() {
  return HeimdallCondition('have only private constructors', (item, _) {
    final constructors = item.constructors;

    final findings = constructors.isEmpty && item is! ExtensionTypeDeclaration
        ? [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} declares an implicit public constructor',
            ),
          ]
        : constructors
              .where((member) => !member.isPrivate)
              .map(
                (member) => HeimdallValidationInfo(
                  filePath: item.sourcePath,
                  line: member.line,
                  message: '${item.name}.${member.name} is not private',
                ),
              )
              .toList();

    if (item is ExtensionTypeDeclaration && !(item.primaryConstructor.constructorName?.name.lexeme.startsWith('_') ?? false)) {
      findings.add(HeimdallValidationInfo.forSubject(item, '${item.name} declares a public primary constructor'));
    }

    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotHaveOnlyPrivateConstructors() {
  return HeimdallCondition('not have only private constructors', (item, _) {
    final findings = !_hasOnlyPrivateConstructors(item)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} declares only private constructors',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldHavePrivateConstructor(
  String name,
) {
  return HeimdallCondition('have private constructor $name', (item, _) {
    final findings = _hasPrivateConstructor(item, name)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} does not declare private constructor $name',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<CompilationUnitMember> _classHasOnlyPrivateConstructors() {
  return HeimdallPredicate(
    'have only private constructors',
    (item, _) => _hasOnlyPrivateConstructors(item),
  );
}

HeimdallPredicate<CompilationUnitMember> _classDoesNotHaveOnlyPrivateConstructors() {
  return HeimdallPredicate(
    'not have only private constructors',
    (item, _) => !_hasOnlyPrivateConstructors(item),
  );
}

HeimdallPredicate<CompilationUnitMember> _classHasPrivateConstructor(
  String name,
) {
  return HeimdallPredicate(
    'have private constructor $name',
    (item, _) => _hasPrivateConstructor(item, name),
  );
}

bool _hasPrivateConstructor(CompilationUnitMember item, String name) {
  if (item is ExtensionTypeDeclaration && item.primaryConstructor.constructorName?.name.lexeme == name && name.startsWith('_')) {
    return true;
  }
  return item.constructors.cast<ClassMember>().any(
    (constructor) => constructor.name == name && constructor.isPrivate,
  );
}

bool _hasOnlyPrivateConstructors(CompilationUnitMember item) {
  final constructors = item.constructors;
  if (item is ExtensionTypeDeclaration) {
    return (item.primaryConstructor.constructorName?.name.lexeme.startsWith('_') ?? false) && constructors.every((member) => member.isPrivate);
  }
  return constructors.isNotEmpty && constructors.every((member) => member.isPrivate);
}
