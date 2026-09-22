import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/member_features/helpers/member_owner_rule_helpers.dart';
import 'package:heimdall_test/src/features/queries/declaration_rule_predicates.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatHaveMixinStartingWithPredicateRules on MemberPredicateBuilder {
  /// Selects members declared in classes that mixin type name starting with [prefix].
  MemberPredicateBuilder areDeclaredInClassesThatApplyMixinTypeNameStartingWith(String prefix) {
    return areDeclaredInClassesThat(classMixesInTypeNameStartingWith(prefix));
  }

  /// Selects members that do not satisfy `areDeclaredInClassesThatApplyMixinTypeNameStartingWith`.
  MemberPredicateBuilder areNotDeclaredInClassesThatApplyMixinTypeNameStartingWith(String prefix) {
    return satisfy(_memberDoesNotBeDeclaredInClassesThatHaveMixinTypeNameStartingWith(prefix));
  }

  /// Selects members declared in classes that mixin type name starting with any value in [prefixes].
  MemberPredicateBuilder areDeclaredInClassesThatApplyMixinTypeNameStartingWithAnyOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.anyOf(
        valueList.map(classMixesInTypeNameStartingWith),
        description: 'mixin type name starting with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that mixin type name starting with every value in [prefixes].
  MemberPredicateBuilder areDeclaredInClassesThatApplyMixinTypeNameStartingWithAllOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.allOf(
        valueList.map(classMixesInTypeNameStartingWith),
        description: 'mixin type name starting with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that mixin type name starting with none of [prefixes].
  MemberPredicateBuilder areDeclaredInClassesThatApplyMixinTypeNameStartingWithNoneOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.noneOf(
        valueList.map(classMixesInTypeNameStartingWith),
        description: 'mixin type name starting with none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatHaveMixinStartingWithShouldRules on MemberShouldBuilder {
  /// Requires members to be declared in classes that mixin type name starting with [prefix].
  HeimdallRule<ClassMember> beDeclaredInClassesThatApplyMixinTypeNameStartingWith(String prefix) {
    return beDeclaredInClassesThat(classMixesInTypeNameStartingWith(prefix));
  }

  /// Requires members not to satisfy `beDeclaredInClassesThatApplyMixinTypeNameStartingWith`.
  HeimdallRule<ClassMember> notBeDeclaredInClassesThatApplyMixinTypeNameStartingWith(String prefix) {
    return satisfy(_memberShouldNotBeDeclaredInClassesThatHaveMixinTypeNameStartingWith(prefix));
  }

  /// Requires members to be declared in classes that mixin type name starting with any value in [prefixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatApplyMixinTypeNameStartingWithAnyOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(classMixesInTypeNameStartingWith).map(memberShouldBeDeclaredInClassesThat),
        description: 'mixin type name starting with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that mixin type name starting with every value in [prefixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatApplyMixinTypeNameStartingWithAllOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(classMixesInTypeNameStartingWith).map(memberShouldBeDeclaredInClassesThat),
        description: 'mixin type name starting with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that mixin type name starting with none of [prefixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatApplyMixinTypeNameStartingWithNoneOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(classMixesInTypeNameStartingWith).map(memberShouldBeDeclaredInClassesThat),
        description: 'mixin type name starting with none of ${valueList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _memberShouldNotBeDeclaredInClassesThatHaveMixinTypeNameStartingWith(String prefix) {
  final classPredicate = classMixesInTypeNameStartingWith(prefix);
  return prohibitedMemberCondition(
    'be declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotBeDeclaredInClassesThatHaveMixinTypeNameStartingWith(String prefix) {
  final classPredicate = classMixesInTypeNameStartingWith(prefix);
  return HeimdallPredicate(
    'not be declared in classes that have mixin type name starting with $prefix',
    (item, project) => !classPredicate.test(item.owner, project),
  );
}
