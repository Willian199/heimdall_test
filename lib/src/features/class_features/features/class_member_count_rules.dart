import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for class member-count rules.
extension ClassMemberCountPredicateRules on ClassPredicateBuilder {
  /// Selects classes that declare exactly [count] members.
  ClassPredicateBuilder haveMemberCount(int count) {
    return satisfy(
      HeimdallPredicate(
        'have member count $count',
        (item, _) => item.members.length == count,
      ),
    );
  }

  /// Selects classes that do not declare exactly [count] members.
  ClassPredicateBuilder noHaveMemberCount(int count) {
    return satisfy(
      HeimdallPredicate(
        'not have member count $count',
        (item, _) => item.members.length != count,
      ),
    );
  }

  /// Selects classes that declare more than [count] members.
  ClassPredicateBuilder haveMoreThanMembers(int count) {
    return satisfy(
      HeimdallPredicate(
        'have more than $count members',
        (item, _) => item.members.length > count,
      ),
    );
  }

  /// Selects classes that declare [count] or fewer members.
  ClassPredicateBuilder noHaveMoreThanMembers(int count) {
    return satisfy(
      HeimdallPredicate(
        'not have more than $count members',
        (item, _) => item.members.length <= count,
      ),
    );
  }
}

/// Condition-side DSL for class member-count rules.
extension ClassMemberCountShouldRules on ClassShouldBuilder {
  /// Requires classes to declare exactly [count] members.
  HeimdallRule<CompilationUnitMember> haveMemberCount(int count) {
    return satisfy(
      _memberCountCondition(
        'have member count $count',
        (item) => item.members.length == count,
      ),
    );
  }

  /// Requires classes not to declare exactly [count] members.
  HeimdallRule<CompilationUnitMember> noHaveMemberCount(int count) {
    return satisfy(
      _memberCountCondition(
        'not have member count $count',
        (item) => item.members.length != count,
      ),
    );
  }

  /// Requires classes to declare more than [count] members.
  HeimdallRule<CompilationUnitMember> haveMoreThanMembers(int count) {
    return satisfy(
      _memberCountCondition(
        'have more than $count members',
        (item) => item.members.length > count,
      ),
    );
  }

  /// Requires classes to declare [count] or fewer members.
  HeimdallRule<CompilationUnitMember> noHaveMoreThanMembers(int count) {
    return satisfy(
      _memberCountCondition(
        'not have more than $count members',
        (item) => item.members.length <= count,
      ),
    );
  }
}

HeimdallCondition<CompilationUnitMember> _memberCountCondition(
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
