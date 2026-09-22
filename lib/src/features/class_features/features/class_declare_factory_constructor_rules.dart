import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_location_queries.dart';

/// Predicate-side DSL for factory constructor rules.
extension ClassDeclareFactoryConstructorPredicateRules on ClassPredicateBuilder {
  /// Selects classes that declare a `factory` constructor named [name].
  ///
  /// Defaults to `new`, the unnamed default constructor.
  ClassPredicateBuilder declareFactoryConstructor({String name = 'new'}) {
    return satisfy(_classDeclaresFactoryConstructor(name: name));
  }

  /// Selects classes that do not declare a `factory` constructor named [name].
  ClassPredicateBuilder notDeclareFactoryConstructor({String name = 'new'}) {
    return satisfy(
      HeimdallPredicate(
        'not declare factory constructor $name',
        (item, _) => !_declaresFactoryConstructor(item, name),
      ),
    );
  }

  /// Selects classes that declare every `factory` constructor in [names].
  ClassPredicateBuilder declareAllFactoryConstructors(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.allOf(
        nameList.map((name) => _classDeclaresFactoryConstructor(name: name)),
        description: 'declare all factory constructors ${nameList.join(', ')}',
      ),
    );
  }

  /// Selects classes that declare at least one `factory` constructor in [names].
  ClassPredicateBuilder declareAnyFactoryConstructor(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.anyOf(
        nameList.map((name) => _classDeclaresFactoryConstructor(name: name)),
        description: 'declare any factory constructor ${nameList.join(', ')}',
      ),
    );
  }

  /// Selects classes that declare none of the `factory` constructors in [names].
  ClassPredicateBuilder declareNoFactoryConstructors(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.noneOf(
        nameList.map((name) => _classDeclaresFactoryConstructor(name: name)),
        description: 'declare no factory constructors ${nameList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for factory constructor rules.
extension ClassDeclareFactoryConstructorShouldRules on ClassShouldBuilder {
  /// Requires matching classes to declare a `factory` constructor named [name].
  ///
  /// Defaults to `new`, the unnamed default constructor.
  HeimdallRule<CompilationUnitMember> declareFactoryConstructor({
    String name = 'new',
  }) {
    return satisfy(_classShouldDeclareFactoryConstructor(name: name));
  }

  /// Requires matching classes to not declare a `factory` constructor named [name].
  HeimdallRule<CompilationUnitMember> notDeclareFactoryConstructor({
    String name = 'new',
  }) {
    return satisfy(_classShouldNotDeclareFactoryConstructor(name: name));
  }

  /// Requires matching classes to declare every `factory` constructor in [names].
  HeimdallRule<CompilationUnitMember> declareAllFactoryConstructors(
    Iterable<String> names,
  ) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.allOf(
        nameList.map((name) => _classShouldDeclareFactoryConstructor(name: name)),
        description: 'declare all factory constructors ${nameList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to declare at least one `factory` constructor in [names].
  HeimdallRule<CompilationUnitMember> declareAnyFactoryConstructor(
    Iterable<String> names,
  ) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.anyOf(
        nameList.map((name) => _classShouldDeclareFactoryConstructor(name: name)),
        description: 'declare any factory constructor ${nameList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to declare none of the `factory` constructors in [names].
  HeimdallRule<CompilationUnitMember> declareNoFactoryConstructors(
    Iterable<String> names,
  ) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.noneOf(
        nameList.map((name) => _classShouldDeclareFactoryConstructor(name: name)),
        description: 'declare no factory constructors ${nameList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<CompilationUnitMember> _classShouldDeclareFactoryConstructor({
  String name = 'new',
}) {
  return HeimdallCondition('declare factory constructor $name', (item, _) {
    final findings = _declaresFactoryConstructor(item, name)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} does not declare factory constructor $name',
            ),
          ];

    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotDeclareFactoryConstructor({
  String name = 'new',
}) {
  return HeimdallCondition('not declare factory constructor $name', (item, _) {
    final findings = _matchingFactoryConstructors(item, name).map(
      (constructor) {
        final location = constructorLocation(constructor);
        return HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: location.line,
          column: location.column,
          message: '${item.name} declares prohibited factory constructor $name',
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

HeimdallPredicate<CompilationUnitMember> _classDeclaresFactoryConstructor({
  String name = 'new',
}) {
  return HeimdallPredicate(
    'declare factory constructor $name',
    (item, _) => _declaresFactoryConstructor(item, name),
  );
}

bool _declaresFactoryConstructor(CompilationUnitMember item, String name) {
  return item.constructors.any(
    (constructor) => constructor.isFactory && (constructor as ClassMember).name == name,
  );
}

Iterable<ConstructorDeclaration> _matchingFactoryConstructors(
  CompilationUnitMember item,
  String name,
) {
  return item.constructors.where(
    (constructor) => constructor.isFactory && (constructor as ClassMember).name == name,
  );
}
