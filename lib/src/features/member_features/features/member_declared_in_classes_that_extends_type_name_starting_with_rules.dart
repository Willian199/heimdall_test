import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/member_features/helpers/member_owner_rule_helpers.dart';
import 'package:heimdall_test/src/features/queries/declaration_rule_predicates.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatExtendsStartingWithPredicateRules on MemberPredicateBuilder {
  /// Selects members declared in classes that extend type name starting with [prefix].
  MemberPredicateBuilder areDeclaredInClassesThatExtendTypeNameStartingWith(String prefix) {
    return areDeclaredInClassesThat(classExtendsTypeNameStartingWith(prefix));
  }

  /// Selects members that do not satisfy `areDeclaredInClassesThatExtendTypeNameStartingWith`.
  MemberPredicateBuilder areNotDeclaredInClassesThatExtendTypeNameStartingWith(String prefix) {
    return satisfy(_memberDoesNotBeDeclaredInClassesThatExtendTypeNameStartingWith(prefix));
  }

  /// Selects members declared in classes that extend type name starting with any value in [prefixes].
  MemberPredicateBuilder areDeclaredInClassesThatExtendTypeNameStartingWithAnyOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.anyOf(
        valueList.map(classExtendsTypeNameStartingWith),
        description: 'extend type name starting with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that extend type name starting with every value in [prefixes].
  MemberPredicateBuilder areDeclaredInClassesThatExtendTypeNameStartingWithAllOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.allOf(
        valueList.map(classExtendsTypeNameStartingWith),
        description: 'extend type name starting with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that extend type name starting with none of [prefixes].
  MemberPredicateBuilder areDeclaredInClassesThatExtendTypeNameStartingWithNoneOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.noneOf(
        valueList.map(classExtendsTypeNameStartingWith),
        description: 'extend type name starting with none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatExtendsStartingWithShouldRules on MemberShouldBuilder {
  /// Requires members to be declared in classes that extend type name starting with [prefix].
  HeimdallRule<ClassMember> beDeclaredInClassesThatExtendTypeNameStartingWith(String prefix) {
    return beDeclaredInClassesThat(classExtendsTypeNameStartingWith(prefix));
  }

  /// Requires members not to satisfy `beDeclaredInClassesThatExtendTypeNameStartingWith`.
  HeimdallRule<ClassMember> notBeDeclaredInClassesThatExtendTypeNameStartingWith(String prefix) {
    return satisfy(_memberShouldNotBeDeclaredInClassesThatExtendTypeNameStartingWith(prefix));
  }

  /// Requires members to be declared in classes that extend type name starting with any value in [prefixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatExtendTypeNameStartingWithAnyOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(classExtendsTypeNameStartingWith).map(memberShouldBeDeclaredInClassesThat),
        description: 'extend type name starting with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that extend type name starting with every value in [prefixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatExtendTypeNameStartingWithAllOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(classExtendsTypeNameStartingWith).map(memberShouldBeDeclaredInClassesThat),
        description: 'extend type name starting with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that extend type name starting with none of [prefixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatExtendTypeNameStartingWithNoneOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(classExtendsTypeNameStartingWith).map(memberShouldBeDeclaredInClassesThat),
        description: 'extend type name starting with none of ${valueList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _memberShouldNotBeDeclaredInClassesThatExtendTypeNameStartingWith(String prefix) {
  final classPredicate = classExtendsTypeNameStartingWith(prefix);
  return prohibitedMemberCondition(
    'be declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotBeDeclaredInClassesThatExtendTypeNameStartingWith(String prefix) {
  final classPredicate = classExtendsTypeNameStartingWith(prefix);
  return HeimdallPredicate(
    'not be declared in classes that extend type name starting with $prefix',
    (item, project) => !classPredicate.test(item.owner, project),
  );
}
