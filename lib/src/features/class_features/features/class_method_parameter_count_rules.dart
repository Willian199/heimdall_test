import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for class method-parameter count rules.
extension ClassMethodParameterCountPredicateRules on ClassPredicateBuilder {
  /// Selects classes whose methods declare exactly [count] total parameters.
  ClassPredicateBuilder haveMethodParameterCount(int count) {
    return satisfy(
      HeimdallPredicate(
        'have method parameter count $count',
        (item, _) => _methodParameterCount(item) == count,
      ),
    );
  }

  /// Selects classes whose methods do not declare exactly [count] total parameters.
  ClassPredicateBuilder noHaveMethodParameterCount(int count) {
    return satisfy(
      HeimdallPredicate(
        'not have method parameter count $count',
        (item, _) => _methodParameterCount(item) != count,
      ),
    );
  }

  /// Selects classes whose methods declare more than [count] total parameters.
  ClassPredicateBuilder haveMoreThanMethodParameters(int count) {
    return satisfy(
      HeimdallPredicate(
        'have more than $count method parameters',
        (item, _) => _methodParameterCount(item) > count,
      ),
    );
  }

  /// Selects classes whose methods declare [count] or fewer total parameters.
  ClassPredicateBuilder noHaveMoreThanMethodParameters(int count) {
    return satisfy(
      HeimdallPredicate(
        'not have more than $count method parameters',
        (item, _) => _methodParameterCount(item) <= count,
      ),
    );
  }
}

/// Condition-side DSL for class method-parameter count rules.
extension ClassMethodParameterCountShouldRules on ClassShouldBuilder {
  /// Requires classes whose methods declare exactly [count] total parameters.
  HeimdallRule<CompilationUnitMember> haveMethodParameterCount(int count) {
    return satisfy(
      _methodParameterCountCondition(
        'have method parameter count $count',
        (item) => _methodParameterCount(item) == count,
      ),
    );
  }

  /// Requires classes whose methods do not declare exactly [count] total parameters.
  HeimdallRule<CompilationUnitMember> noHaveMethodParameterCount(int count) {
    return satisfy(
      _methodParameterCountCondition(
        'not have method parameter count $count',
        (item) => _methodParameterCount(item) != count,
      ),
    );
  }

  /// Requires classes whose methods declare more than [count] total parameters.
  HeimdallRule<CompilationUnitMember> haveMoreThanMethodParameters(int count) {
    return satisfy(
      _methodParameterCountCondition(
        'have more than $count method parameters',
        (item) => _methodParameterCount(item) > count,
      ),
    );
  }

  /// Requires classes whose methods declare [count] or fewer total parameters.
  HeimdallRule<CompilationUnitMember> noHaveMoreThanMethodParameters(
    int count,
  ) {
    return satisfy(
      _methodParameterCountCondition(
        'not have more than $count method parameters',
        (item) => _methodParameterCount(item) <= count,
      ),
    );
  }
}

HeimdallCondition<CompilationUnitMember> _methodParameterCountCondition(
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

int _methodParameterCount(CompilationUnitMember item) {
  return item.methods.fold<int>(
    0,
    (count, method) => count + (method.parameters?.parameters.length ?? 0),
  );
}
