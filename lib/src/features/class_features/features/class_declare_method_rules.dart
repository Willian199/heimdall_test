import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for declared method rules.
extension ClassDeclareMethodPredicateRules on ClassPredicateBuilder {
  /// Selects classes that declare a method named [methodName].
  ClassPredicateBuilder declareMethod(String methodName) {
    return satisfy(_classDeclaresMethod(methodName));
  }

  /// Selects classes that do not declare a method named [methodName].
  ClassPredicateBuilder notDeclareMethod(String methodName) {
    return satisfy(
      HeimdallPredicate(
        'not declare method $methodName',
        (item, _) => !_declaresMethod(item, methodName),
      ),
    );
  }

  /// Selects classes that declare every method in [methodNames].
  ClassPredicateBuilder declareAllMethods(Iterable<String> methodNames) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallPredicate.allOf(
        methodList.map(_classDeclaresMethod),
        description: 'declare all methods ${methodList.join(', ')}',
      ),
    );
  }

  /// Selects classes that declare at least one method in [methodNames].
  ClassPredicateBuilder declareAnyMethod(Iterable<String> methodNames) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        methodList.map(_classDeclaresMethod),
        description: 'declare any method ${methodList.join(', ')}',
      ),
    );
  }

  /// Selects classes that declare none of [methodNames].
  ClassPredicateBuilder declareNoMethods(Iterable<String> methodNames) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        methodList.map(_classDeclaresMethod),
        description: 'declare no methods ${methodList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for declared method rules.
extension ClassDeclareMethodShouldRules on ClassShouldBuilder {
  /// Requires matching classes to declare a method named [methodName].
  HeimdallRule<CompilationUnitMember> declareMethod(String methodName) {
    return satisfy(_classShouldDeclareMethod(methodName));
  }

  /// Requires matching classes to not declare a method named [methodName].
  HeimdallRule<CompilationUnitMember> notDeclareMethod(String methodName) {
    return satisfy(_classShouldNotDeclareMethod(methodName));
  }

  /// Requires matching classes to declare every method in [methodNames].
  HeimdallRule<CompilationUnitMember> declareAllMethods(
    Iterable<String> methodNames,
  ) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallCondition.allOf(
        methodList.map(_classShouldDeclareMethod),
        description: 'declare all methods ${methodList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to declare at least one method in [methodNames].
  HeimdallRule<CompilationUnitMember> declareAnyMethod(
    Iterable<String> methodNames,
  ) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallCondition.anyOf(
        methodList.map(_classShouldDeclareMethod),
        description: 'declare any method ${methodList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to declare none of [methodNames].
  HeimdallRule<CompilationUnitMember> declareNoMethods(
    Iterable<String> methodNames,
  ) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallCondition.noneOf(
        methodList.map(_classShouldDeclareMethod),
        description: 'declare no methods ${methodList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<CompilationUnitMember> _classShouldDeclareMethod(
  String methodName,
) {
  return HeimdallCondition('declare method $methodName', (item, _) {
    final findings = _declaresMethod(item, methodName)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} does not declare method $methodName',
            ),
          ];

    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotDeclareMethod(
  String methodName,
) {
  return HeimdallCondition('not declare method $methodName', (item, _) {
    final findings = _matchingMethods(item, methodName).map(
      (method) {
        final location = method.sourceLocationAt(method.name.offset);
        return HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: location.line,
          column: location.column,
          message: '${item.name} declares prohibited method $methodName',
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

HeimdallPredicate<CompilationUnitMember> _classDeclaresMethod(
  String methodName,
) {
  return HeimdallPredicate(
    'declare method $methodName',
    (item, _) => _declaresMethod(item, methodName),
  );
}

bool _declaresMethod(CompilationUnitMember item, String methodName) {
  return item.methods.cast<ClassMember>().any((member) => member.name == methodName);
}

Iterable<MethodDeclaration> _matchingMethods(
  CompilationUnitMember item,
  String methodName,
) {
  return item.methods.where((member) => (member as ClassMember).name == methodName);
}
