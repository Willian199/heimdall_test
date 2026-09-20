import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for class method-count rules.
extension ClassMethodCountPredicateRules on ClassPredicateBuilder {
  /// Selects classes that declare exactly [count] methods.
  ClassPredicateBuilder haveMethodCount(int count) {
    return satisfy(
      HeimdallPredicate(
        'have method count $count',
        (item, _) => item.methods.length == count,
      ),
    );
  }

  /// Selects classes that do not declare exactly [count] methods.
  ClassPredicateBuilder noHaveMethodCount(int count) {
    return satisfy(
      HeimdallPredicate(
        'not have method count $count',
        (item, _) => item.methods.length != count,
      ),
    );
  }

  /// Selects classes that declare more than [count] methods.
  ClassPredicateBuilder haveMoreThanMethods(int count) {
    return satisfy(
      HeimdallPredicate(
        'have more than $count methods',
        (item, _) => item.methods.length > count,
      ),
    );
  }

  /// Selects classes that declare [count] or fewer methods.
  ClassPredicateBuilder noHaveMoreThanMethods(int count) {
    return satisfy(
      HeimdallPredicate(
        'not have more than $count methods',
        (item, _) => item.methods.length <= count,
      ),
    );
  }
}

/// Condition-side DSL for class method-count rules.
extension ClassMethodCountShouldRules on ClassShouldBuilder {
  /// Requires classes to declare exactly [count] methods.
  HeimdallRule<CompilationUnitMember> haveMethodCount(int count) {
    return satisfy(
      _methodCountCondition(
        'have method count $count',
        (item) => item.methods.length == count,
      ),
    );
  }

  /// Requires classes not to declare exactly [count] methods.
  HeimdallRule<CompilationUnitMember> noHaveMethodCount(int count) {
    return satisfy(
      _methodCountCondition(
        'not have method count $count',
        (item) => item.methods.length != count,
      ),
    );
  }

  /// Requires classes to declare more than [count] methods.
  HeimdallRule<CompilationUnitMember> haveMoreThanMethods(int count) {
    return satisfy(
      _methodCountCondition(
        'have more than $count methods',
        (item) => item.methods.length > count,
      ),
    );
  }

  /// Requires classes to declare [count] or fewer methods.
  HeimdallRule<CompilationUnitMember> noHaveMoreThanMethods(int count) {
    return satisfy(
      _methodCountCondition(
        'not have more than $count methods',
        (item) => item.methods.length <= count,
      ),
    );
  }
}

HeimdallCondition<CompilationUnitMember> _methodCountCondition(
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
