import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_location_queries.dart';

/// Predicate-side DSL for const constructor rules.
extension ClassDeclareConstConstructorPredicateRules on ClassPredicateBuilder {
  /// Selects classes that declare a `const` constructor named [name].
  ///
  /// Defaults to `new`, the unnamed default constructor.
  ClassPredicateBuilder declareConstConstructor({String name = 'new'}) {
    return satisfy(_classDeclaresConstConstructor(name: name));
  }

  /// Selects classes that do not declare a `const` constructor named [name].
  ClassPredicateBuilder notDeclareConstConstructor({String name = 'new'}) {
    return satisfy(
      HeimdallPredicate(
        'not declare const constructor $name',
        (item, _) => !_declaresConstConstructor(item, name),
      ),
    );
  }

  /// Selects classes that declare every `const` constructor in [names].
  ClassPredicateBuilder declareAllConstConstructors(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.allOf(
        nameList.map((name) => _classDeclaresConstConstructor(name: name)),
        description: 'declare all const constructors ${nameList.join(', ')}',
      ),
    );
  }

  /// Selects classes that declare at least one `const` constructor in [names].
  ClassPredicateBuilder declareAnyConstConstructor(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.anyOf(
        nameList.map((name) => _classDeclaresConstConstructor(name: name)),
        description: 'declare any const constructor ${nameList.join(', ')}',
      ),
    );
  }

  /// Selects classes that declare none of the `const` constructors in [names].
  ClassPredicateBuilder declareNoConstConstructors(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.noneOf(
        nameList.map((name) => _classDeclaresConstConstructor(name: name)),
        description: 'declare no const constructors ${nameList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for const constructor rules.
extension ClassDeclareConstConstructorShouldRules on ClassShouldBuilder {
  /// Requires matching classes to declare a `const` constructor named [name].
  ///
  /// Defaults to `new`, the unnamed default constructor.
  HeimdallRule<CompilationUnitMember> declareConstConstructor({
    String name = 'new',
  }) {
    return satisfy(_classShouldDeclareConstConstructor(name: name));
  }

  /// Requires matching classes to not declare a `const` constructor named [name].
  HeimdallRule<CompilationUnitMember> notDeclareConstConstructor({
    String name = 'new',
  }) {
    return satisfy(_classShouldNotDeclareConstConstructor(name: name));
  }

  /// Requires matching classes to declare every `const` constructor in [names].
  HeimdallRule<CompilationUnitMember> declareAllConstConstructors(
    Iterable<String> names,
  ) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.allOf(
        nameList.map((name) => _classShouldDeclareConstConstructor(name: name)),
        description: 'declare all const constructors ${nameList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to declare at least one `const` constructor in [names].
  HeimdallRule<CompilationUnitMember> declareAnyConstConstructor(
    Iterable<String> names,
  ) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.anyOf(
        nameList.map((name) => _classShouldDeclareConstConstructor(name: name)),
        description: 'declare any const constructor ${nameList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to declare none of the `const` constructors in [names].
  HeimdallRule<CompilationUnitMember> declareNoConstConstructors(
    Iterable<String> names,
  ) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.noneOf(
        nameList.map((name) => _classShouldDeclareConstConstructor(name: name)),
        description: 'declare no const constructors ${nameList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<CompilationUnitMember> _classShouldDeclareConstConstructor({
  String name = 'new',
}) {
  return HeimdallCondition('declare const constructor $name', (item, _) {
    final findings = _declaresConstConstructor(item, name)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} does not declare const constructor $name',
            ),
          ];

    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotDeclareConstConstructor({
  String name = 'new',
}) {
  return HeimdallCondition('not declare const constructor $name', (item, _) {
    final findings = _matchingConstConstructors(item, name).map(
      (constructor) {
        final location = constructorLocation(constructor);
        return HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: location.line,
          column: location.column,
          message: '${item.name} declares prohibited const constructor $name',
        );
      },
    ).toList();

    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<CompilationUnitMember> _classDeclaresConstConstructor({
  String name = 'new',
}) {
  return HeimdallPredicate(
    'declare const constructor $name',
    (item, _) => _declaresConstConstructor(item, name),
  );
}

bool _declaresConstConstructor(CompilationUnitMember item, String name) {
  return item.constructors.any(
    (constructor) => constructor.isConst && (constructor as ClassMember).name == name,
  );
}

Iterable<ConstructorDeclaration> _matchingConstConstructors(
  CompilationUnitMember item,
  String name,
) {
  return item.constructors.where(
    (constructor) => constructor.isConst && (constructor as ClassMember).name == name,
  );
}
