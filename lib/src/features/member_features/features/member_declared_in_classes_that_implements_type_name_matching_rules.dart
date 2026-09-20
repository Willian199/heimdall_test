import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatImplementsMatchingPredicateRules on MemberPredicateBuilder {
  /// Selects members declared in classes that implement type name matching [pattern].
  MemberPredicateBuilder areDeclaredInClassesThatImplementTypeNameMatching(RegExp pattern) {
    return areDeclaredInClassesThat(_classImplementsTypeNameMatching(pattern));
  }

  /// Selects members that do not satisfy `areDeclaredInClassesThatImplementTypeNameMatching`.
  MemberPredicateBuilder noAreDeclaredInClassesThatImplementTypeNameMatching(RegExp pattern) {
    return satisfy(_memberDoesNotBeDeclaredInClassesThatImplementTypeNameMatching(pattern));
  }

  /// Selects members declared in classes that implement type name matching any value in [patterns].
  MemberPredicateBuilder areDeclaredInClassesThatImplementTypeNameMatchingAny(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return areDeclaredInClassesThat(
      HeimdallPredicate.anyOf(
        valueList.map(_classImplementsTypeNameMatching),
        description: 'implement type name matching any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that implement type name matching every value in [patterns].
  MemberPredicateBuilder areDeclaredInClassesThatImplementTypeNameMatchingAll(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return areDeclaredInClassesThat(
      HeimdallPredicate.allOf(
        valueList.map(_classImplementsTypeNameMatching),
        description: 'implement type name matching all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that implement type name matching none of [patterns].
  MemberPredicateBuilder areDeclaredInClassesThatImplementTypeNameMatchingNone(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return areDeclaredInClassesThat(
      HeimdallPredicate.noneOf(
        valueList.map(_classImplementsTypeNameMatching),
        description: 'implement type name matching none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatImplementsMatchingShouldRules on MemberShouldBuilder {
  /// Requires members to be declared in classes that implement type name matching [pattern].
  HeimdallRule<ClassMember> beDeclaredInClassesThatImplementTypeNameMatching(RegExp pattern) {
    return beDeclaredInClassesThat(_classImplementsTypeNameMatching(pattern));
  }

  /// Requires members not to satisfy `beDeclaredInClassesThatImplementTypeNameMatching`.
  HeimdallRule<ClassMember> noBeDeclaredInClassesThatImplementTypeNameMatching(RegExp pattern) {
    return satisfy(_memberShouldNotBeDeclaredInClassesThatImplementTypeNameMatching(pattern));
  }

  /// Requires members to be declared in classes that implement type name matching any value in [patterns].
  HeimdallRule<ClassMember> beDeclaredInClassesThatImplementTypeNameMatchingAny(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_classImplementsTypeNameMatching).map(_memberShouldBeDeclaredInClassesThat),
        description: 'implement type name matching any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that implement type name matching every value in [patterns].
  HeimdallRule<ClassMember> beDeclaredInClassesThatImplementTypeNameMatchingAll(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_classImplementsTypeNameMatching).map(_memberShouldBeDeclaredInClassesThat),
        description: 'implement type name matching all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that implement type name matching none of [patterns].
  HeimdallRule<ClassMember> beDeclaredInClassesThatImplementTypeNameMatchingNone(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(_classImplementsTypeNameMatching).map(_memberShouldBeDeclaredInClassesThat),
        description: 'implement type name matching none of ${valueList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _memberShouldBeDeclaredInClassesThat(
  HeimdallPredicate<CompilationUnitMember> classPredicate,
) {
  return memberCondition(
    'be declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}

HeimdallPredicate<CompilationUnitMember> _classImplementsTypeNameMatching(RegExp pattern) {
  return HeimdallPredicate(
    'implement type name matching ${pattern.pattern}',
    (item, project) => implementsTypeNamedWhere(
      item,
      project,
      pattern.hasMatch,
    ),
  );
}

HeimdallCondition<ClassMember> _memberShouldNotBeDeclaredInClassesThatImplementTypeNameMatching(RegExp pattern) {
  final classPredicate = _classImplementsTypeNameMatching(pattern);
  return prohibitedMemberCondition(
    'be declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotBeDeclaredInClassesThatImplementTypeNameMatching(RegExp pattern) {
  final classPredicate = _classImplementsTypeNameMatching(pattern);
  return HeimdallPredicate(
    'not be declared in classes that implement type name matching ${pattern.pattern}',
    (item, project) => !classPredicate.test(item.owner, project),
  );
}
