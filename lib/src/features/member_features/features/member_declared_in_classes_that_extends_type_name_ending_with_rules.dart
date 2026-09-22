import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/member_features/helpers/member_owner_rule_helpers.dart';
import 'package:heimdall_test/src/features/queries/declaration_rule_predicates.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatExtendsEndingWithPredicateRules on MemberPredicateBuilder {
  /// Selects members declared in classes that extend a type whose name ends with [suffix].
  MemberPredicateBuilder areDeclaredInClassesThatExtendTypeNameEndingWith(
    String suffix,
  ) {
    return areDeclaredInClassesThat(classExtendsTypeNameEndingWith(suffix));
  }

  /// Selects members that do not satisfy `areDeclaredInClassesThatExtendTypeNameEndingWith`.
  MemberPredicateBuilder areNotDeclaredInClassesThatExtendTypeNameEndingWith(
    String suffix,
  ) {
    return satisfy(_memberDoesNotBeDeclaredInClassesThatExtendTypeNameEndingWith(suffix));
  }

  /// Selects members declared in classes that extend a type name ending with any suffix in [suffixes].
  MemberPredicateBuilder areDeclaredInClassesThatExtendTypeNameEndingWithAnyOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.anyOf(
        suffixList.map(classExtendsTypeNameEndingWith),
        description: 'extend type name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that extend type names ending with every suffix in [suffixes].
  MemberPredicateBuilder areDeclaredInClassesThatExtendTypeNameEndingWithAllOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.allOf(
        suffixList.map(classExtendsTypeNameEndingWith),
        description: 'extend type names ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that extend no type name ending with [suffixes].
  MemberPredicateBuilder areDeclaredInClassesThatExtendTypeNameEndingWithNoneOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.noneOf(
        suffixList.map(classExtendsTypeNameEndingWith),
        description: 'extend type name ending with none of ${suffixList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatExtendsEndingWithShouldRules on MemberShouldBuilder {
  /// Requires members to be declared in classes that extend a type whose name ends with [suffix].
  HeimdallRule<ClassMember> beDeclaredInClassesThatExtendTypeNameEndingWith(
    String suffix,
  ) {
    return beDeclaredInClassesThat(classExtendsTypeNameEndingWith(suffix));
  }

  /// Requires members not to satisfy `beDeclaredInClassesThatExtendTypeNameEndingWith`.
  HeimdallRule<ClassMember> notBeDeclaredInClassesThatExtendTypeNameEndingWith(
    String suffix,
  ) {
    return satisfy(_memberShouldNotBeDeclaredInClassesThatExtendTypeNameEndingWith(suffix));
  }

  /// Requires members to be declared in classes that extend a type name ending with any suffix in [suffixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatExtendTypeNameEndingWithAnyOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.anyOf(
        suffixList.map(classExtendsTypeNameEndingWith).map(memberShouldBeDeclaredInClassesThat),
        description: 'extend type name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that extend type names ending with every suffix in [suffixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatExtendTypeNameEndingWithAllOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.allOf(
        suffixList.map(classExtendsTypeNameEndingWith).map(memberShouldBeDeclaredInClassesThat),
        description: 'extend type names ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that extend no type name ending with [suffixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatExtendTypeNameEndingWithNoneOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.noneOf(
        suffixList.map(classExtendsTypeNameEndingWith).map(memberShouldBeDeclaredInClassesThat),
        description: 'extend type name ending with none of ${suffixList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _memberShouldNotBeDeclaredInClassesThatExtendTypeNameEndingWith(
  String suffix,
) {
  final classPredicate = classExtendsTypeNameEndingWith(suffix);
  return prohibitedMemberCondition(
    'be declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotBeDeclaredInClassesThatExtendTypeNameEndingWith(
  String suffix,
) {
  final classPredicate = classExtendsTypeNameEndingWith(suffix);
  return HeimdallPredicate(
    'not be declared in classes that extend type name ending with $suffix',
    (item, project) => !classPredicate.test(item.owner, project),
  );
}
