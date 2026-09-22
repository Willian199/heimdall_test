import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/member_features/helpers/member_owner_rule_helpers.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesAssignableMatchingPredicateRules on MemberPredicateBuilder {
  /// Selects members declared in classes that assignable to type name matching [pattern].
  MemberPredicateBuilder areDeclaredInClassesAssignableToTypeNameMatching(RegExp pattern) {
    return areDeclaredInClassesThat(_classAssignableToTypeNameMatching(pattern));
  }

  /// Selects members that do not satisfy `areDeclaredInClassesAssignableToTypeNameMatching`.
  MemberPredicateBuilder areNotDeclaredInClassesAssignableToTypeNameMatching(RegExp pattern) {
    return satisfy(_memberDoesNotBeDeclaredInClassesAssignableToTypeNameMatching(pattern));
  }

  /// Selects members declared in classes that assignable to type name matching any value in [patterns].
  MemberPredicateBuilder areDeclaredInClassesAssignableToTypeNameMatchingAnyOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return areDeclaredInClassesThat(
      HeimdallPredicate.anyOf(
        valueList.map(_classAssignableToTypeNameMatching),
        description: 'assignable to type name matching any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that assignable to type name matching every value in [patterns].
  MemberPredicateBuilder areDeclaredInClassesAssignableToTypeNameMatchingAllOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return areDeclaredInClassesThat(
      HeimdallPredicate.allOf(
        valueList.map(_classAssignableToTypeNameMatching),
        description: 'assignable to type name matching all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that assignable to type name matching none of [patterns].
  MemberPredicateBuilder areDeclaredInClassesAssignableToTypeNameMatchingNoneOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return areDeclaredInClassesThat(
      HeimdallPredicate.noneOf(
        valueList.map(_classAssignableToTypeNameMatching),
        description: 'assignable to type name matching none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesAssignableMatchingShouldRules on MemberShouldBuilder {
  /// Requires members to be declared in classes that assignable to type name matching [pattern].
  HeimdallRule<ClassMember> beDeclaredInClassesAssignableToTypeNameMatching(RegExp pattern) {
    return beDeclaredInClassesThat(_classAssignableToTypeNameMatching(pattern));
  }

  /// Requires members not to satisfy `beDeclaredInClassesAssignableToTypeNameMatching`.
  HeimdallRule<ClassMember> notBeDeclaredInClassesAssignableToTypeNameMatching(RegExp pattern) {
    return satisfy(_memberShouldNotBeDeclaredInClassesAssignableToTypeNameMatching(pattern));
  }

  /// Requires members to be declared in classes that assignable to type name matching any value in [patterns].
  HeimdallRule<ClassMember> beDeclaredInClassesAssignableToTypeNameMatchingAnyOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_classAssignableToTypeNameMatching).map(memberShouldBeDeclaredInClassesThat),
        description: 'assignable to type name matching any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that assignable to type name matching every value in [patterns].
  HeimdallRule<ClassMember> beDeclaredInClassesAssignableToTypeNameMatchingAllOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_classAssignableToTypeNameMatching).map(memberShouldBeDeclaredInClassesThat),
        description: 'assignable to type name matching all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that assignable to type name matching none of [patterns].
  HeimdallRule<ClassMember> beDeclaredInClassesAssignableToTypeNameMatchingNoneOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(_classAssignableToTypeNameMatching).map(memberShouldBeDeclaredInClassesThat),
        description: 'assignable to type name matching none of ${valueList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _classAssignableToTypeNameMatching(RegExp pattern) {
  return HeimdallPredicate(
    'assignable to type name matching ${pattern.pattern}',
    (item, project) => isAssignableToTypeNamedWhere(
      item,
      project,
      pattern.hasMatch,
    ),
  );
}

HeimdallCondition<ClassMember> _memberShouldNotBeDeclaredInClassesAssignableToTypeNameMatching(RegExp pattern) {
  final classPredicate = _classAssignableToTypeNameMatching(pattern);
  return prohibitedMemberCondition(
    'be declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotBeDeclaredInClassesAssignableToTypeNameMatching(RegExp pattern) {
  final classPredicate = _classAssignableToTypeNameMatching(pattern);
  return HeimdallPredicate(
    'not be declared in classes assignable to type name matching ${pattern.pattern}',
    (item, project) => !classPredicate.test(item.owner, project),
  );
}
