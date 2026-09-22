import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/class_features/helpers/declaration_condition.dart';

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
  ClassPredicateBuilder haveMemberCountOtherThan(int count) {
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
  ClassPredicateBuilder haveAtMostMembers(int count) {
    return satisfy(
      HeimdallPredicate(
        'have at most $count members',
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
      declarationCondition(
        'have member count $count',
        (item) => item.members.length == count,
      ),
    );
  }

  /// Requires classes not to declare exactly [count] members.
  HeimdallRule<CompilationUnitMember> haveMemberCountOtherThan(int count) {
    return satisfy(
      declarationCondition(
        'not have member count $count',
        (item) => item.members.length != count,
      ),
    );
  }

  /// Requires classes to declare more than [count] members.
  HeimdallRule<CompilationUnitMember> haveMoreThanMembers(int count) {
    return satisfy(
      declarationCondition(
        'have more than $count members',
        (item) => item.members.length > count,
      ),
    );
  }

  /// Requires classes to declare [count] or fewer members.
  HeimdallRule<CompilationUnitMember> haveAtMostMembers(int count) {
    return satisfy(
      declarationCondition(
        'have at most $count members',
        (item) => item.members.length <= count,
      ),
    );
  }
}
