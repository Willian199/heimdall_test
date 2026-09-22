import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/member_features/helpers/member_owner_rule_helpers.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatExtendsMatchingPredicateRules on MemberPredicateBuilder {
  /// Selects members declared in classes that extend type name matching [pattern].
  MemberPredicateBuilder areDeclaredInClassesThatExtendTypeNameMatching(RegExp pattern) {
    return areDeclaredInClassesThat(_classExtendsTypeNameMatching(pattern));
  }

  /// Selects members that do not satisfy `areDeclaredInClassesThatExtendTypeNameMatching`.
  MemberPredicateBuilder areNotDeclaredInClassesThatExtendTypeNameMatching(RegExp pattern) {
    return satisfy(_memberDoesNotBeDeclaredInClassesThatExtendTypeNameMatching(pattern));
  }

  /// Selects members declared in classes that extend type name matching any value in [patterns].
  MemberPredicateBuilder areDeclaredInClassesThatExtendTypeNameMatchingAnyOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return areDeclaredInClassesThat(
      HeimdallPredicate.anyOf(
        valueList.map(_classExtendsTypeNameMatching),
        description: 'extend type name matching any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that extend type name matching every value in [patterns].
  MemberPredicateBuilder areDeclaredInClassesThatExtendTypeNameMatchingAllOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return areDeclaredInClassesThat(
      HeimdallPredicate.allOf(
        valueList.map(_classExtendsTypeNameMatching),
        description: 'extend type name matching all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that extend type name matching none of [patterns].
  MemberPredicateBuilder areDeclaredInClassesThatExtendTypeNameMatchingNoneOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return areDeclaredInClassesThat(
      HeimdallPredicate.noneOf(
        valueList.map(_classExtendsTypeNameMatching),
        description: 'extend type name matching none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatExtendsMatchingShouldRules on MemberShouldBuilder {
  /// Requires members to be declared in classes that extend type name matching [pattern].
  HeimdallRule<ClassMember> beDeclaredInClassesThatExtendTypeNameMatching(RegExp pattern) {
    return beDeclaredInClassesThat(_classExtendsTypeNameMatching(pattern));
  }

  /// Requires members not to satisfy `beDeclaredInClassesThatExtendTypeNameMatching`.
  HeimdallRule<ClassMember> notBeDeclaredInClassesThatExtendTypeNameMatching(RegExp pattern) {
    return satisfy(_memberShouldNotBeDeclaredInClassesThatExtendTypeNameMatching(pattern));
  }

  /// Requires members to be declared in classes that extend type name matching any value in [patterns].
  HeimdallRule<ClassMember> beDeclaredInClassesThatExtendTypeNameMatchingAnyOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_classExtendsTypeNameMatching).map(memberShouldBeDeclaredInClassesThat),
        description: 'extend type name matching any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that extend type name matching every value in [patterns].
  HeimdallRule<ClassMember> beDeclaredInClassesThatExtendTypeNameMatchingAllOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_classExtendsTypeNameMatching).map(memberShouldBeDeclaredInClassesThat),
        description: 'extend type name matching all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that extend type name matching none of [patterns].
  HeimdallRule<ClassMember> beDeclaredInClassesThatExtendTypeNameMatchingNoneOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(_classExtendsTypeNameMatching).map(memberShouldBeDeclaredInClassesThat),
        description: 'extend type name matching none of ${valueList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _classExtendsTypeNameMatching(RegExp pattern) {
  return HeimdallPredicate(
    'extend type name matching ${pattern.pattern}',
    (item, project) => extendsTypeNamedWhere(
      item,
      project,
      pattern.hasMatch,
    ),
  );
}

HeimdallCondition<ClassMember> _memberShouldNotBeDeclaredInClassesThatExtendTypeNameMatching(RegExp pattern) {
  final classPredicate = _classExtendsTypeNameMatching(pattern);
  return prohibitedMemberCondition(
    'be declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotBeDeclaredInClassesThatExtendTypeNameMatching(RegExp pattern) {
  final classPredicate = _classExtendsTypeNameMatching(pattern);
  return HeimdallPredicate(
    'not be declared in classes that extend type name matching ${pattern.pattern}',
    (item, project) => !classPredicate.test(item.owner, project),
  );
}
