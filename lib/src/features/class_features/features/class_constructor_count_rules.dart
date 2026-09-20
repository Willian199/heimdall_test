import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for class constructor-count rules.
extension ClassConstructorCountPredicateRules on ClassPredicateBuilder {
  /// Selects classes that declare exactly [count] constructors.
  ClassPredicateBuilder haveConstructorCount(int count) {
    return satisfy(
      HeimdallPredicate(
        'have constructor count $count',
        (item, _) => item.constructors.length == count,
      ),
    );
  }

  /// Selects classes that do not declare exactly [count] constructors.
  ClassPredicateBuilder noHaveConstructorCount(int count) {
    return satisfy(
      HeimdallPredicate(
        'not have constructor count $count',
        (item, _) => item.constructors.length != count,
      ),
    );
  }

  /// Selects classes that declare more than [count] constructors.
  ClassPredicateBuilder haveMoreThanConstructors(int count) {
    return satisfy(
      HeimdallPredicate(
        'have more than $count constructors',
        (item, _) => item.constructors.length > count,
      ),
    );
  }

  /// Selects classes that declare [count] or fewer constructors.
  ClassPredicateBuilder noHaveMoreThanConstructors(int count) {
    return satisfy(
      HeimdallPredicate(
        'not have more than $count constructors',
        (item, _) => item.constructors.length <= count,
      ),
    );
  }
}

/// Condition-side DSL for class constructor-count rules.
extension ClassConstructorCountShouldRules on ClassShouldBuilder {
  /// Requires classes to declare exactly [count] constructors.
  HeimdallRule<CompilationUnitMember> haveConstructorCount(int count) {
    return satisfy(
      _constructorCountCondition(
        'have constructor count $count',
        (item) => item.constructors.length == count,
      ),
    );
  }

  /// Requires classes not to declare exactly [count] constructors.
  HeimdallRule<CompilationUnitMember> noHaveConstructorCount(int count) {
    return satisfy(
      _constructorCountCondition(
        'not have constructor count $count',
        (item) => item.constructors.length != count,
      ),
    );
  }

  /// Requires classes to declare more than [count] constructors.
  HeimdallRule<CompilationUnitMember> haveMoreThanConstructors(int count) {
    return satisfy(
      _constructorCountCondition(
        'have more than $count constructors',
        (item) => item.constructors.length > count,
      ),
    );
  }

  /// Requires classes to declare [count] or fewer constructors.
  HeimdallRule<CompilationUnitMember> noHaveMoreThanConstructors(int count) {
    return satisfy(
      _constructorCountCondition(
        'not have more than $count constructors',
        (item) => item.constructors.length <= count,
      ),
    );
  }
}

HeimdallCondition<CompilationUnitMember> _constructorCountCondition(
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
