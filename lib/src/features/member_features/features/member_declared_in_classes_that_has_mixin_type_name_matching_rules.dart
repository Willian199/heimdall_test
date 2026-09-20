import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatHaveMixinMatchingPredicateRules on MemberPredicateBuilder {
  /// Selects members declared in classes that mixin type name matching [pattern].
  MemberPredicateBuilder areDeclaredInClassesThatHaveMixinTypeNameMatching(RegExp pattern) {
    return areDeclaredInClassesThat(_classMixesInTypeNameMatching(pattern));
  }

  /// Selects members that do not satisfy `areDeclaredInClassesThatHaveMixinTypeNameMatching`.
  MemberPredicateBuilder noAreDeclaredInClassesThatHaveMixinTypeNameMatching(RegExp pattern) {
    return satisfy(_memberDoesNotBeDeclaredInClassesThatHaveMixinTypeNameMatching(pattern));
  }

  /// Selects members declared in classes that mixin type name matching any value in [patterns].
  MemberPredicateBuilder areDeclaredInClassesThatHaveMixinTypeNameMatchingAny(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return areDeclaredInClassesThat(
      HeimdallPredicate.anyOf(
        valueList.map(_classMixesInTypeNameMatching),
        description: 'mixin type name matching any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that mixin type name matching every value in [patterns].
  MemberPredicateBuilder areDeclaredInClassesThatHaveMixinTypeNameMatchingAll(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return areDeclaredInClassesThat(
      HeimdallPredicate.allOf(
        valueList.map(_classMixesInTypeNameMatching),
        description: 'mixin type name matching all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that mixin type name matching none of [patterns].
  MemberPredicateBuilder areDeclaredInClassesThatHaveMixinTypeNameMatchingNone(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return areDeclaredInClassesThat(
      HeimdallPredicate.noneOf(
        valueList.map(_classMixesInTypeNameMatching),
        description: 'mixin type name matching none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatHaveMixinMatchingShouldRules on MemberShouldBuilder {
  /// Requires members to be declared in classes that mixin type name matching [pattern].
  HeimdallRule<ClassMember> beDeclaredInClassesThatHaveMixinTypeNameMatching(RegExp pattern) {
    return beDeclaredInClassesThat(_classMixesInTypeNameMatching(pattern));
  }

  /// Requires members not to satisfy `beDeclaredInClassesThatHaveMixinTypeNameMatching`.
  HeimdallRule<ClassMember> noBeDeclaredInClassesThatHaveMixinTypeNameMatching(RegExp pattern) {
    return satisfy(_memberShouldNotBeDeclaredInClassesThatHaveMixinTypeNameMatching(pattern));
  }

  /// Requires members to be declared in classes that mixin type name matching any value in [patterns].
  HeimdallRule<ClassMember> beDeclaredInClassesThatHaveMixinTypeNameMatchingAny(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_classMixesInTypeNameMatching).map(_memberShouldBeDeclaredInClassesThat),
        description: 'mixin type name matching any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that mixin type name matching every value in [patterns].
  HeimdallRule<ClassMember> beDeclaredInClassesThatHaveMixinTypeNameMatchingAll(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_classMixesInTypeNameMatching).map(_memberShouldBeDeclaredInClassesThat),
        description: 'mixin type name matching all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that mixin type name matching none of [patterns].
  HeimdallRule<ClassMember> beDeclaredInClassesThatHaveMixinTypeNameMatchingNone(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(_classMixesInTypeNameMatching).map(_memberShouldBeDeclaredInClassesThat),
        description: 'mixin type name matching none of ${valueList.join(', ')}',
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

HeimdallPredicate<CompilationUnitMember> _classMixesInTypeNameMatching(RegExp pattern) {
  return HeimdallPredicate(
    'mixin type name matching ${pattern.pattern}',
    (item, project) => mixesInTypeNamedWhere(
      item,
      project,
      pattern.hasMatch,
    ),
  );
}

HeimdallCondition<ClassMember> _memberShouldNotBeDeclaredInClassesThatHaveMixinTypeNameMatching(RegExp pattern) {
  final classPredicate = _classMixesInTypeNameMatching(pattern);
  return prohibitedMemberCondition(
    'be declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotBeDeclaredInClassesThatHaveMixinTypeNameMatching(RegExp pattern) {
  final classPredicate = _classMixesInTypeNameMatching(pattern);
  return HeimdallPredicate(
    'not be declared in classes that have mixin type name matching ${pattern.pattern}',
    (item, project) => !classPredicate.test(item.owner, project),
  );
}
