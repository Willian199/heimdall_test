import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for class executable code-unit count rules.
extension ClassCodeUnitCountPredicateRules on ClassPredicateBuilder {
  /// Selects classes that declare exactly [count] executable code units.
  ClassPredicateBuilder haveCodeUnitCount(int count) {
    return satisfy(
      HeimdallPredicate(
        'have code unit count $count',
        (item, _) => _codeUnitCount(item) == count,
      ),
    );
  }

  /// Selects classes that do not declare exactly [count] executable code units.
  ClassPredicateBuilder noHaveCodeUnitCount(int count) {
    return satisfy(
      HeimdallPredicate(
        'not have code unit count $count',
        (item, _) => _codeUnitCount(item) != count,
      ),
    );
  }

  /// Selects classes that declare more than [count] executable code units.
  ClassPredicateBuilder haveMoreThanCodeUnits(int count) {
    return satisfy(
      HeimdallPredicate(
        'have more than $count code units',
        (item, _) => _codeUnitCount(item) > count,
      ),
    );
  }

  /// Selects classes that declare [count] or fewer executable code units.
  ClassPredicateBuilder noHaveMoreThanCodeUnits(int count) {
    return satisfy(
      HeimdallPredicate(
        'not have more than $count code units',
        (item, _) => _codeUnitCount(item) <= count,
      ),
    );
  }
}

/// Condition-side DSL for class executable code-unit count rules.
extension ClassCodeUnitCountShouldRules on ClassShouldBuilder {
  /// Requires classes to declare exactly [count] executable code units.
  HeimdallRule<CompilationUnitMember> haveCodeUnitCount(int count) {
    return satisfy(
      _codeUnitCountCondition(
        'have code unit count $count',
        (item) => _codeUnitCount(item) == count,
      ),
    );
  }

  /// Requires classes not to declare exactly [count] executable code units.
  HeimdallRule<CompilationUnitMember> noHaveCodeUnitCount(int count) {
    return satisfy(
      _codeUnitCountCondition(
        'not have code unit count $count',
        (item) => _codeUnitCount(item) != count,
      ),
    );
  }

  /// Requires classes to declare more than [count] executable code units.
  HeimdallRule<CompilationUnitMember> haveMoreThanCodeUnits(int count) {
    return satisfy(
      _codeUnitCountCondition(
        'have more than $count code units',
        (item) => _codeUnitCount(item) > count,
      ),
    );
  }

  /// Requires classes to declare [count] or fewer executable code units.
  HeimdallRule<CompilationUnitMember> noHaveMoreThanCodeUnits(int count) {
    return satisfy(
      _codeUnitCountCondition(
        'not have more than $count code units',
        (item) => _codeUnitCount(item) <= count,
      ),
    );
  }
}

HeimdallCondition<CompilationUnitMember> _codeUnitCountCondition(
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

int _codeUnitCount(CompilationUnitMember item) {
  return item.methods.length + item.constructors.length;
}
