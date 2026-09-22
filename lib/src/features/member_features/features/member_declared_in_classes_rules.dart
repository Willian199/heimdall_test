import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/core/behavior_rule/heimdall_rule.dart';
import 'package:heimdall_test/src/core/heimdall_condition.dart';
import 'package:heimdall_test/src/core/heimdall_predicate.dart';
import 'package:heimdall_test/src/core/member_rules/member_predicate_builder.dart';
import 'package:heimdall_test/src/core/member_rules/member_should_builder.dart';
import 'package:heimdall_test/src/core/non_empty_iterable.dart';
import 'package:heimdall_test/src/features/member_features/helpers/member_owner_rule_helpers.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_member.dart';

/// Predicate-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesPredicateRules on MemberPredicateBuilder {
  /// Selects members whose owner declaration matches [classPredicate].
  MemberPredicateBuilder areDeclaredInClassesThat(
    HeimdallPredicate<CompilationUnitMember> classPredicate,
  ) {
    return satisfy(_memberDeclaredInClassesThat(classPredicate));
  }

  /// Selects members that do not satisfy `areDeclaredInClassesThat`.
  MemberPredicateBuilder areNotDeclaredInClassesThat(
    HeimdallPredicate<CompilationUnitMember> classPredicate,
  ) {
    return satisfy(_memberDoesNotBeDeclaredInClassesThat(classPredicate));
  }

  /// Selects members whose owner declaration matches at least one predicate in [classPredicates].
  MemberPredicateBuilder areDeclaredInClassesMatchingAnyOf(
    Iterable<HeimdallPredicate<CompilationUnitMember>> classPredicates,
  ) {
    final predicateList = classPredicates.toNonEmptyList('classPredicates');
    return areDeclaredInClassesThat(
      HeimdallPredicate.anyOf(
        predicateList,
        description: 'match any of ${predicateList.map((predicate) => predicate.description).join(', ')}',
      ),
    );
  }

  /// Selects members whose owner declaration matches every predicate in [classPredicates].
  MemberPredicateBuilder areDeclaredInClassesMatchingAllOf(
    Iterable<HeimdallPredicate<CompilationUnitMember>> classPredicates,
  ) {
    final predicateList = classPredicates.toNonEmptyList('classPredicates');
    return areDeclaredInClassesThat(
      HeimdallPredicate.allOf(
        predicateList,
        description: 'match all of ${predicateList.map((predicate) => predicate.description).join(', ')}',
      ),
    );
  }

  /// Selects members whose owner declaration matches none of [classPredicates].
  MemberPredicateBuilder areDeclaredInClassesMatchingNoneOf(
    Iterable<HeimdallPredicate<CompilationUnitMember>> classPredicates,
  ) {
    final predicateList = classPredicates.toNonEmptyList('classPredicates');
    return areDeclaredInClassesThat(
      HeimdallPredicate.noneOf(
        predicateList,
        description: 'match none of ${predicateList.map((predicate) => predicate.description).join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesShouldRules on MemberShouldBuilder {
  /// Requires members to be declared in classes that match [classPredicate].
  HeimdallRule<ClassMember> beDeclaredInClassesThat(
    HeimdallPredicate<CompilationUnitMember> classPredicate,
  ) {
    return satisfy(memberShouldBeDeclaredInClassesThat(classPredicate));
  }

  /// Requires members not to satisfy `beDeclaredInClassesThat`.
  HeimdallRule<ClassMember> notBeDeclaredInClassesThat(
    HeimdallPredicate<CompilationUnitMember> classPredicate,
  ) {
    return satisfy(_memberShouldNotBeDeclaredInClassesThat(classPredicate));
  }

  /// Requires members to be declared in classes that match at least one predicate in [classPredicates].
  HeimdallRule<ClassMember> beDeclaredInClassesMatchingAnyOf(
    Iterable<HeimdallPredicate<CompilationUnitMember>> classPredicates,
  ) {
    final predicateList = classPredicates.toNonEmptyList('classPredicates');
    return satisfy(
      HeimdallCondition.anyOf(
        predicateList.map(memberShouldBeDeclaredInClassesThat),
        description: 'match any of ${predicateList.map((predicate) => predicate.description).join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that match every predicate in [classPredicates].
  HeimdallRule<ClassMember> beDeclaredInClassesMatchingAllOf(
    Iterable<HeimdallPredicate<CompilationUnitMember>> classPredicates,
  ) {
    final predicateList = classPredicates.toNonEmptyList('classPredicates');
    return satisfy(
      HeimdallCondition.allOf(
        predicateList.map(memberShouldBeDeclaredInClassesThat),
        description: 'match all of ${predicateList.map((predicate) => predicate.description).join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that match none of [classPredicates].
  HeimdallRule<ClassMember> beDeclaredInClassesMatchingNoneOf(
    Iterable<HeimdallPredicate<CompilationUnitMember>> classPredicates,
  ) {
    final predicateList = classPredicates.toNonEmptyList('classPredicates');
    return satisfy(
      HeimdallCondition.noneOf(
        predicateList.map(memberShouldBeDeclaredInClassesThat),
        description: 'match none of ${predicateList.map((predicate) => predicate.description).join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<ClassMember> _memberDeclaredInClassesThat(
  HeimdallPredicate<CompilationUnitMember> classPredicate,
) {
  return HeimdallPredicate(
    'are declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}

HeimdallCondition<ClassMember> _memberShouldNotBeDeclaredInClassesThat(
  HeimdallPredicate<CompilationUnitMember> classPredicate,
) {
  return prohibitedMemberCondition(
    'be declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotBeDeclaredInClassesThat(
  HeimdallPredicate<CompilationUnitMember> classPredicate,
) {
  return HeimdallPredicate(
    'not be declared in classes that ${classPredicate.description}',
    (item, project) => !classPredicate.test(item.owner, project),
  );
}
