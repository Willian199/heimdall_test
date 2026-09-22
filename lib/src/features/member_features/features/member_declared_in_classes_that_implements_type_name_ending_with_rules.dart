import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/member_features/helpers/member_owner_rule_helpers.dart';
import 'package:heimdall_test/src/features/queries/declaration_rule_predicates.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatImplementsEndingWithPredicateRules on MemberPredicateBuilder {
  /// Selects members declared in classes that implement a type whose name ends with [suffix].
  MemberPredicateBuilder areDeclaredInClassesThatImplementTypeNameEndingWith(
    String suffix,
  ) {
    return areDeclaredInClassesThat(classImplementsTypeNameEndingWith(suffix));
  }

  /// Selects members that do not satisfy `areDeclaredInClassesThatImplementTypeNameEndingWith`.
  MemberPredicateBuilder areNotDeclaredInClassesThatImplementTypeNameEndingWith(
    String suffix,
  ) {
    return satisfy(_memberDoesNotBeDeclaredInClassesThatImplementTypeNameEndingWith(suffix));
  }

  /// Selects members declared in classes that implement a type name ending with any suffix in [suffixes].
  MemberPredicateBuilder areDeclaredInClassesThatImplementTypeNameEndingWithAnyOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.anyOf(
        suffixList.map(classImplementsTypeNameEndingWith),
        description: 'implement type name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that implement type names ending with every suffix in [suffixes].
  MemberPredicateBuilder areDeclaredInClassesThatImplementTypeNameEndingWithAllOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.allOf(
        suffixList.map(classImplementsTypeNameEndingWith),
        description: 'implement type names ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that implement no type name ending with [suffixes].
  MemberPredicateBuilder areDeclaredInClassesThatImplementTypeNameEndingWithNoneOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.noneOf(
        suffixList.map(classImplementsTypeNameEndingWith),
        description: 'implement type name ending with none of ${suffixList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatImplementsEndingWithShouldRules on MemberShouldBuilder {
  /// Requires members to be declared in classes that implement a type whose name ends with [suffix].
  HeimdallRule<ClassMember> beDeclaredInClassesThatImplementTypeNameEndingWith(
    String suffix,
  ) {
    return beDeclaredInClassesThat(classImplementsTypeNameEndingWith(suffix));
  }

  /// Requires members not to satisfy `beDeclaredInClassesThatImplementTypeNameEndingWith`.
  HeimdallRule<ClassMember> notBeDeclaredInClassesThatImplementTypeNameEndingWith(
    String suffix,
  ) {
    return satisfy(_memberShouldNotBeDeclaredInClassesThatImplementTypeNameEndingWith(suffix));
  }

  /// Requires members to be declared in classes that implement a type name ending with any suffix in [suffixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatImplementTypeNameEndingWithAnyOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.anyOf(
        suffixList.map(classImplementsTypeNameEndingWith).map(memberShouldBeDeclaredInClassesThat),
        description: 'implement type name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that implement type names ending with every suffix in [suffixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatImplementTypeNameEndingWithAllOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.allOf(
        suffixList.map(classImplementsTypeNameEndingWith).map(memberShouldBeDeclaredInClassesThat),
        description: 'implement type names ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that implement no type name ending with [suffixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatImplementTypeNameEndingWithNoneOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.noneOf(
        suffixList.map(classImplementsTypeNameEndingWith).map(memberShouldBeDeclaredInClassesThat),
        description: 'implement type name ending with none of ${suffixList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _memberShouldNotBeDeclaredInClassesThatImplementTypeNameEndingWith(
  String suffix,
) {
  final classPredicate = classImplementsTypeNameEndingWith(suffix);
  return prohibitedMemberCondition(
    'be declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotBeDeclaredInClassesThatImplementTypeNameEndingWith(
  String suffix,
) {
  final classPredicate = classImplementsTypeNameEndingWith(suffix);
  return HeimdallPredicate(
    'not be declared in classes that implement type name ending with $suffix',
    (item, project) => !classPredicate.test(item.owner, project),
  );
}
