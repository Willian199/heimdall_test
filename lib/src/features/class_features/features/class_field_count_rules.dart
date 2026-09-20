import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for class field-count rules.
extension ClassFieldCountPredicateRules on ClassPredicateBuilder {
  /// Selects classes that declare exactly [count] instance fields.
  ClassPredicateBuilder haveFieldCount(int count) {
    return satisfy(
      HeimdallPredicate(
        'have field count $count',
        (item, _) => _fieldCount(item) == count,
      ),
    );
  }

  /// Selects classes that do not declare exactly [count] instance fields.
  ClassPredicateBuilder noHaveFieldCount(int count) {
    return satisfy(
      HeimdallPredicate(
        'not have field count $count',
        (item, _) => _fieldCount(item) != count,
      ),
    );
  }

  /// Selects classes that declare more than [count] instance fields.
  ClassPredicateBuilder haveMoreThanFields(int count) {
    return satisfy(
      HeimdallPredicate(
        'have more than $count fields',
        (item, _) => _fieldCount(item) > count,
      ),
    );
  }

  /// Selects classes that declare [count] or fewer instance fields.
  ClassPredicateBuilder noHaveMoreThanFields(int count) {
    return satisfy(
      HeimdallPredicate(
        'not have more than $count fields',
        (item, _) => _fieldCount(item) <= count,
      ),
    );
  }
}

/// Condition-side DSL for class field-count rules.
extension ClassFieldCountShouldRules on ClassShouldBuilder {
  /// Requires classes to declare exactly [count] instance fields.
  HeimdallRule<CompilationUnitMember> haveFieldCount(int count) {
    return satisfy(
      _fieldCountCondition(
        'have field count $count',
        (item) => _fieldCount(item) == count,
      ),
    );
  }

  /// Requires classes not to declare exactly [count] instance fields.
  HeimdallRule<CompilationUnitMember> noHaveFieldCount(int count) {
    return satisfy(
      _fieldCountCondition(
        'not have field count $count',
        (item) => _fieldCount(item) != count,
      ),
    );
  }

  /// Requires classes to declare more than [count] instance fields.
  HeimdallRule<CompilationUnitMember> haveMoreThanFields(int count) {
    return satisfy(
      _fieldCountCondition(
        'have more than $count fields',
        (item) => _fieldCount(item) > count,
      ),
    );
  }

  /// Requires classes to declare [count] or fewer instance fields.
  HeimdallRule<CompilationUnitMember> noHaveMoreThanFields(int count) {
    return satisfy(
      _fieldCountCondition(
        'not have more than $count fields',
        (item) => _fieldCount(item) <= count,
      ),
    );
  }
}

HeimdallCondition<CompilationUnitMember> _fieldCountCondition(
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

int _fieldCount(CompilationUnitMember item) {
  return item.fields
      .where((field) => !field.isStatic)
      .fold<int>(
        0,
        (count, field) => count + field.fields.variables.length,
      );
}
