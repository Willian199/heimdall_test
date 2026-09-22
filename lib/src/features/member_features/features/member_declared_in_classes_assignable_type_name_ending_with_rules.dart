import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/member_features/helpers/member_owner_rule_helpers.dart';
import 'package:heimdall_test/src/features/queries/declaration_rule_predicates.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesAssignableEndingWithPredicateRules on MemberPredicateBuilder {
  /// Selects members declared in classes assignable to a type whose name ends with [suffix].
  MemberPredicateBuilder areDeclaredInClassesAssignableToTypeNameEndingWith(
    String suffix,
  ) {
    return areDeclaredInClassesThat(classAssignableToTypeNameEndingWith(suffix));
  }

  /// Selects members that do not satisfy `areDeclaredInClassesAssignableToTypeNameEndingWith`.
  MemberPredicateBuilder areNotDeclaredInClassesAssignableToTypeNameEndingWith(
    String suffix,
  ) {
    return satisfy(_memberDoesNotBeDeclaredInClassesAssignableToTypeNameEndingWith(suffix));
  }

  /// Selects members declared in classes assignable to a type name ending with any suffix in [suffixes].
  MemberPredicateBuilder areDeclaredInClassesAssignableToTypeNameEndingWithAnyOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.anyOf(
        suffixList.map(classAssignableToTypeNameEndingWith),
        description: 'are assignable to type name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes assignable to type names ending with every suffix in [suffixes].
  MemberPredicateBuilder areDeclaredInClassesAssignableToTypeNameEndingWithAllOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.allOf(
        suffixList.map(classAssignableToTypeNameEndingWith),
        description: 'are assignable to type names ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes assignable to no type name ending with [suffixes].
  MemberPredicateBuilder areDeclaredInClassesAssignableToTypeNameEndingWithNoneOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.noneOf(
        suffixList.map(classAssignableToTypeNameEndingWith),
        description: 'are assignable to type name ending with none of ${suffixList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesAssignableEndingWithShouldRules on MemberShouldBuilder {
  /// Requires members to be declared in classes assignable to a type whose name ends with [suffix].
  HeimdallRule<ClassMember> beDeclaredInClassesAssignableToTypeNameEndingWith(
    String suffix,
  ) {
    return beDeclaredInClassesThat(classAssignableToTypeNameEndingWith(suffix));
  }

  /// Requires members not to satisfy `beDeclaredInClassesAssignableToTypeNameEndingWith`.
  HeimdallRule<ClassMember> notBeDeclaredInClassesAssignableToTypeNameEndingWith(
    String suffix,
  ) {
    return satisfy(_memberShouldNotBeDeclaredInClassesAssignableToTypeNameEndingWith(suffix));
  }

  /// Requires members to be declared in classes assignable to a type name ending with any suffix in [suffixes].
  HeimdallRule<ClassMember> beDeclaredInClassesAssignableToTypeNameEndingWithAnyOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.anyOf(
        suffixList.map(classAssignableToTypeNameEndingWith).map(memberShouldBeDeclaredInClassesThat),
        description: 'be assignable to type name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes assignable to type names ending with every suffix in [suffixes].
  HeimdallRule<ClassMember> beDeclaredInClassesAssignableToTypeNameEndingWithAllOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.allOf(
        suffixList.map(classAssignableToTypeNameEndingWith).map(memberShouldBeDeclaredInClassesThat),
        description: 'be assignable to type names ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes assignable to no type name ending with [suffixes].
  HeimdallRule<ClassMember> beDeclaredInClassesAssignableToTypeNameEndingWithNoneOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.noneOf(
        suffixList.map(classAssignableToTypeNameEndingWith).map(memberShouldBeDeclaredInClassesThat),
        description: 'be assignable to type name ending with none of ${suffixList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _memberShouldNotBeDeclaredInClassesAssignableToTypeNameEndingWith(
  String suffix,
) {
  final classPredicate = classAssignableToTypeNameEndingWith(suffix);
  return prohibitedMemberCondition(
    'be declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotBeDeclaredInClassesAssignableToTypeNameEndingWith(
  String suffix,
) {
  final classPredicate = classAssignableToTypeNameEndingWith(suffix);
  return HeimdallPredicate(
    'not be declared in classes assignable to type name ending with $suffix',
    (item, project) => !classPredicate.test(item.owner, project),
  );
}
