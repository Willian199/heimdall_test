import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for classes whose constructors must be private.
extension ClassHaveOnlyPrivateConstructorsPredicateRules on ClassPredicateBuilder {
  /// Selects classes that declare only private constructors.
  ClassPredicateBuilder haveOnlyPrivateConstructors() {
    return satisfy(_classHasOnlyPrivateConstructors());
  }

  /// Selects classes with at least one non-private constructor.
  ClassPredicateBuilder noHaveOnlyPrivateConstructors() {
    return satisfy(_classDoesNotHaveOnlyPrivateConstructors());
  }

  /// Selects classes where every constructor in [names] is private.
  ClassPredicateBuilder haveAllPrivateConstructors(
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
  ClassPredicateBuilder haveAnyPrivateConstructors(
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
  ClassPredicateBuilder haveNoPrivateConstructors(
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
  HeimdallRule<CompilationUnitMember> noHaveOnlyPrivateConstructors() {
    return satisfy(_classShouldNotHaveOnlyPrivateConstructors());
  }

  /// Requires every constructor in [names] to be private.
  HeimdallRule<CompilationUnitMember> haveAllPrivateConstructors(
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
  HeimdallRule<CompilationUnitMember> haveAnyPrivateConstructors(
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
  HeimdallRule<CompilationUnitMember> haveNoPrivateConstructors(
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
    final findings = constructors.isEmpty
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
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotHaveOnlyPrivateConstructors() {
  return HeimdallCondition('not have only private constructors', (item, _) {
    final constructors = item.constructors;
    final findings = constructors.isEmpty || constructors.any((member) => !member.isPrivate)
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
    (item, _) {
      final constructors = item.constructors;
      return constructors.isNotEmpty && constructors.every((member) => member.isPrivate);
    },
  );
}

HeimdallPredicate<CompilationUnitMember> _classDoesNotHaveOnlyPrivateConstructors() {
  return HeimdallPredicate(
    'not have only private constructors',
    (item, _) {
      final constructors = item.constructors;
      return constructors.isEmpty || constructors.any((member) => !member.isPrivate);
    },
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
  return item.constructors.cast<ClassMember>().any(
    (constructor) => constructor.name == name && constructor.isPrivate,
  );
}
