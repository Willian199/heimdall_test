import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for class constructor-parameter count rules.
extension ClassConstructorParameterCountPredicateRules on ClassPredicateBuilder {
  /// Selects classes whose constructors declare exactly [count] total parameters.
  ClassPredicateBuilder haveConstructorParameterCount(int count) {
    return satisfy(
      HeimdallPredicate(
        'have constructor parameter count $count',
        (item, _) => _constructorParameterCount(item) == count,
      ),
    );
  }

  /// Selects classes whose constructors do not declare exactly [count] total parameters.
  ClassPredicateBuilder noHaveConstructorParameterCount(int count) {
    return satisfy(
      HeimdallPredicate(
        'not have constructor parameter count $count',
        (item, _) => _constructorParameterCount(item) != count,
      ),
    );
  }

  /// Selects classes whose constructors declare more than [count] total parameters.
  ClassPredicateBuilder haveMoreThanConstructorParameters(int count) {
    return satisfy(
      HeimdallPredicate(
        'have more than $count constructor parameters',
        (item, _) => _constructorParameterCount(item) > count,
      ),
    );
  }

  /// Selects classes whose constructors declare [count] or fewer total parameters.
  ClassPredicateBuilder noHaveMoreThanConstructorParameters(int count) {
    return satisfy(
      HeimdallPredicate(
        'not have more than $count constructor parameters',
        (item, _) => _constructorParameterCount(item) <= count,
      ),
    );
  }
}

/// Condition-side DSL for class constructor-parameter count rules.
extension ClassConstructorParameterCountShouldRules on ClassShouldBuilder {
  /// Requires classes whose constructors declare exactly [count] total parameters.
  HeimdallRule<CompilationUnitMember> haveConstructorParameterCount(int count) {
    return satisfy(
      _constructorParameterCountCondition(
        'have constructor parameter count $count',
        (item) => _constructorParameterCount(item) == count,
      ),
    );
  }

  /// Requires classes whose constructors do not declare exactly [count] total parameters.
  HeimdallRule<CompilationUnitMember> noHaveConstructorParameterCount(
    int count,
  ) {
    return satisfy(
      _constructorParameterCountCondition(
        'not have constructor parameter count $count',
        (item) => _constructorParameterCount(item) != count,
      ),
    );
  }

  /// Requires classes whose constructors declare more than [count] total parameters.
  HeimdallRule<CompilationUnitMember> haveMoreThanConstructorParameters(
    int count,
  ) {
    return satisfy(
      _constructorParameterCountCondition(
        'have more than $count constructor parameters',
        (item) => _constructorParameterCount(item) > count,
      ),
    );
  }

  /// Requires classes whose constructors declare [count] or fewer total parameters.
  HeimdallRule<CompilationUnitMember> noHaveMoreThanConstructorParameters(
    int count,
  ) {
    return satisfy(
      _constructorParameterCountCondition(
        'not have more than $count constructor parameters',
        (item) => _constructorParameterCount(item) <= count,
      ),
    );
  }
}

HeimdallCondition<CompilationUnitMember> _constructorParameterCountCondition(
  String description,
  bool Function(CompilationUnitMember item) test,
) {
  return HeimdallCondition(description, (item, _) {
    final passed = test(item);
    return HeimdallFindings(
      subject: item,
      passed: passed,
      findings: [
        if (!passed)
          HeimdallValidationInfo(
            filePath: item.sourcePath,
            line: item.line,
            message: '${item.name} should $description',
          ),
      ],
    );
  });
}

int _constructorParameterCount(CompilationUnitMember item) {
  return item.constructors.fold<int>(0, (count, constructor) => count + constructor.parameters.parameters.length);
}
