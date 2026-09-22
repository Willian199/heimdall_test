import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/member_features/helpers/member_owner_rule_helpers.dart';
import 'package:heimdall_test/src/features/queries/declaration_rule_predicates.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatHaveMixinEndingWithPredicateRules on MemberPredicateBuilder {
  /// Selects members declared in classes that mix in a type whose name ends with [suffix].
  MemberPredicateBuilder areDeclaredInClassesThatApplyMixinTypeNameEndingWith(
    String suffix,
  ) {
    return areDeclaredInClassesThat(classMixesInTypeNameEndingWith(suffix));
  }

  /// Selects members that do not satisfy `areDeclaredInClassesThatApplyMixinTypeNameEndingWith`.
  MemberPredicateBuilder areNotDeclaredInClassesThatApplyMixinTypeNameEndingWith(
    String suffix,
  ) {
    return satisfy(_memberDoesNotBeDeclaredInClassesThatHaveMixinTypeNameEndingWith(suffix));
  }

  /// Selects members declared in classes that mix in a type name ending with any suffix in [suffixes].
  MemberPredicateBuilder areDeclaredInClassesThatApplyMixinTypeNameEndingWithAnyOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.anyOf(
        suffixList.map(classMixesInTypeNameEndingWith),
        description: 'mixin type name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that mix in type names ending with every suffix in [suffixes].
  MemberPredicateBuilder areDeclaredInClassesThatApplyMixinTypeNameEndingWithAllOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.allOf(
        suffixList.map(classMixesInTypeNameEndingWith),
        description: 'mixin type names ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that mix in no type name ending with [suffixes].
  MemberPredicateBuilder areDeclaredInClassesThatApplyMixinTypeNameEndingWithNoneOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.noneOf(
        suffixList.map(classMixesInTypeNameEndingWith),
        description: 'mixin type name ending with none of ${suffixList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatHaveMixinEndingWithShouldRules on MemberShouldBuilder {
  /// Requires members to be declared in classes that mix in a type whose name ends with [suffix].
  HeimdallRule<ClassMember> beDeclaredInClassesThatApplyMixinTypeNameEndingWith(
    String suffix,
  ) {
    return beDeclaredInClassesThat(classMixesInTypeNameEndingWith(suffix));
  }

  /// Requires members not to satisfy `beDeclaredInClassesThatApplyMixinTypeNameEndingWith`.
  HeimdallRule<ClassMember> notBeDeclaredInClassesThatApplyMixinTypeNameEndingWith(
    String suffix,
  ) {
    return satisfy(_memberShouldNotBeDeclaredInClassesThatHaveMixinTypeNameEndingWith(suffix));
  }

  /// Requires members to be declared in classes that mix in a type name ending with any suffix in [suffixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatApplyMixinTypeNameEndingWithAnyOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.anyOf(
        suffixList.map(classMixesInTypeNameEndingWith).map(memberShouldBeDeclaredInClassesThat),
        description: 'mixin type name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that mix in type names ending with every suffix in [suffixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatApplyMixinTypeNameEndingWithAllOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.allOf(
        suffixList.map(classMixesInTypeNameEndingWith).map(memberShouldBeDeclaredInClassesThat),
        description: 'mixin type names ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that mix in no type name ending with [suffixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatApplyMixinTypeNameEndingWithNoneOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.noneOf(
        suffixList.map(classMixesInTypeNameEndingWith).map(memberShouldBeDeclaredInClassesThat),
        description: 'mixin type name ending with none of ${suffixList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _memberShouldNotBeDeclaredInClassesThatHaveMixinTypeNameEndingWith(
  String suffix,
) {
  final classPredicate = classMixesInTypeNameEndingWith(suffix);
  return prohibitedMemberCondition(
    'be declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotBeDeclaredInClassesThatHaveMixinTypeNameEndingWith(
  String suffix,
) {
  final classPredicate = classMixesInTypeNameEndingWith(suffix);
  return HeimdallPredicate(
    'not be declared in classes that have mixin type name ending with $suffix',
    (item, project) => !classPredicate.test(item.owner, project),
  );
}
