import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_location_queries.dart';

/// Predicate-side DSL for declared constructor rules.
extension ClassDeclareConstructorPredicateRules on ClassPredicateBuilder {
  /// Selects classes that declare a constructor named [name].
  ClassPredicateBuilder declareConstructor({String name = 'new'}) {
    return satisfy(_classDeclaresConstructor(name: name));
  }

  /// Selects classes that do not declare a constructor named [name].
  ClassPredicateBuilder notDeclareConstructor({String name = 'new'}) {
    return satisfy(
      HeimdallPredicate(
        'not declare constructor $name',
        (item, _) => !_declaresConstructor(item, name),
      ),
    );
  }

  /// Selects classes that declare every constructor in [names].
  ClassPredicateBuilder declareAllConstructors(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.allOf(
        nameList.map((name) => _classDeclaresConstructor(name: name)),
        description: 'declare all constructors ${nameList.join(', ')}',
      ),
    );
  }

  /// Selects classes that declare at least one constructor in [names].
  ClassPredicateBuilder declareAnyConstructor(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.anyOf(
        nameList.map((name) => _classDeclaresConstructor(name: name)),
        description: 'declare any constructor ${nameList.join(', ')}',
      ),
    );
  }

  /// Selects classes that declare none of the constructors in [names].
  ClassPredicateBuilder declareNoConstructors(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.noneOf(
        nameList.map((name) => _classDeclaresConstructor(name: name)),
        description: 'declare no constructors ${nameList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for declared constructor rules.
extension ClassDeclareConstructorShouldRules on ClassShouldBuilder {
  /// Requires matching classes to declare a constructor named [name].
  HeimdallRule<CompilationUnitMember> declareConstructor({
    String name = 'new',
  }) {
    return satisfy(_classShouldDeclareConstructor(name: name));
  }

  /// Requires matching classes to not declare a constructor named [name].
  HeimdallRule<CompilationUnitMember> notDeclareConstructor({
    String name = 'new',
  }) {
    return satisfy(_classShouldNotDeclareConstructor(name: name));
  }

  /// Requires matching classes to declare every constructor in [names].
  HeimdallRule<CompilationUnitMember> declareAllConstructors(
    Iterable<String> names,
  ) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.allOf(
        nameList.map((name) => _classShouldDeclareConstructor(name: name)),
        description: 'declare all constructors ${nameList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to declare at least one constructor in [names].
  HeimdallRule<CompilationUnitMember> declareAnyConstructor(
    Iterable<String> names,
  ) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.anyOf(
        nameList.map((name) => _classShouldDeclareConstructor(name: name)),
        description: 'declare any constructor ${nameList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to declare none of the constructors in [names].
  HeimdallRule<CompilationUnitMember> declareNoConstructors(
    Iterable<String> names,
  ) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.noneOf(
        nameList.map((name) => _classShouldDeclareConstructor(name: name)),
        description: 'declare no constructors ${nameList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<CompilationUnitMember> _classShouldDeclareConstructor({
  String name = 'new',
}) {
  return HeimdallCondition('declare constructor $name', (item, _) {
    final findings = _declaresConstructor(item, name)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} does not declare constructor $name',
            ),
          ];

    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotDeclareConstructor({
  String name = 'new',
}) {
  return HeimdallCondition('not declare constructor $name', (item, _) {
    final findings = _matchingConstructors(item, name).map(
      (constructor) {
        final location = constructorLocation(constructor);
        return HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: location.line,
          column: location.column,
          message: '${item.name} declares prohibited constructor $name',
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

HeimdallPredicate<CompilationUnitMember> _classDeclaresConstructor({
  String name = 'new',
}) {
  return HeimdallPredicate(
    'declare constructor $name',
    (item, _) => _declaresConstructor(item, name),
  );
}

bool _declaresConstructor(CompilationUnitMember item, String name) {
  return item.constructors.any(
    (constructor) => (constructor as ClassMember).name == name,
  );
}

Iterable<ConstructorDeclaration> _matchingConstructors(
  CompilationUnitMember item,
  String name,
) {
  return item.constructors.where(
    (constructor) => (constructor as ClassMember).name == name,
  );
}
