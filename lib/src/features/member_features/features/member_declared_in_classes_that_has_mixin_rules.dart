import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/member_features/helpers/member_owner_rule_helpers.dart';
import 'package:heimdall_test/src/features/queries/declaration_rule_predicates.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatHaveMixinPredicateRules on MemberPredicateBuilder {
  /// Selects members declared in classes that mix in [typeName].
  MemberPredicateBuilder areDeclaredInClassesThatApplyMixin(String typeName) {
    return areDeclaredInClassesThat(classMixesIn(typeName));
  }

  /// Selects members that do not satisfy `areDeclaredInClassesThatApplyMixin`.
  MemberPredicateBuilder areNotDeclaredInClassesThatApplyMixin(String typeName) {
    return satisfy(_memberDoesNotBeDeclaredInClassesThatHaveMixin(typeName));
  }

  /// Selects members declared in classes that mix in any type in [typeNames].
  MemberPredicateBuilder areDeclaredInClassesThatApplyMixinAnyOf(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return areDeclaredInClassesThat(
      HeimdallPredicate.anyOf(
        typeList.map(classMixesIn),
        description: 'mixin any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that mix in every type in [typeNames].
  MemberPredicateBuilder areDeclaredInClassesThatApplyMixinAllOf(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return areDeclaredInClassesThat(
      HeimdallPredicate.allOf(
        typeList.map(classMixesIn),
        description: 'mixin all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that mix in none of [typeNames].
  MemberPredicateBuilder areDeclaredInClassesThatApplyMixinNoneOf(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return areDeclaredInClassesThat(
      HeimdallPredicate.noneOf(
        typeList.map(classMixesIn),
        description: 'mixin none of ${typeList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatHaveMixinShouldRules on MemberShouldBuilder {
  /// Requires members to be declared in classes that mix in [typeName].
  HeimdallRule<ClassMember> beDeclaredInClassesThatApplyMixin(String typeName) {
    return beDeclaredInClassesThat(classMixesIn(typeName));
  }

  /// Requires members not to satisfy `beDeclaredInClassesThatApplyMixin`.
  HeimdallRule<ClassMember> notBeDeclaredInClassesThatApplyMixin(String typeName) {
    return satisfy(_memberShouldNotBeDeclaredInClassesThatHaveMixin(typeName));
  }

  /// Requires members to be declared in classes that mix in any type in [typeNames].
  HeimdallRule<ClassMember> beDeclaredInClassesThatApplyMixinAnyOf(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.anyOf(
        typeList.map(classMixesIn).map(memberShouldBeDeclaredInClassesThat),
        description: 'mixin any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that mix in every type in [typeNames].
  HeimdallRule<ClassMember> beDeclaredInClassesThatApplyMixinAllOf(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.allOf(
        typeList.map(classMixesIn).map(memberShouldBeDeclaredInClassesThat),
        description: 'mixin all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that mix in none of [typeNames].
  HeimdallRule<ClassMember> beDeclaredInClassesThatApplyMixinNoneOf(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.noneOf(
        typeList.map(classMixesIn).map(memberShouldBeDeclaredInClassesThat),
        description: 'mixin none of ${typeList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _memberShouldNotBeDeclaredInClassesThatHaveMixin(String typeName) {
  final classPredicate = classMixesIn(typeName);
  return prohibitedMemberCondition(
    'be declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotBeDeclaredInClassesThatHaveMixin(String typeName) {
  final classPredicate = classMixesIn(typeName);
  return HeimdallPredicate(
    'not be declared in classes that have mixin $typeName',
    (item, project) => !classPredicate.test(item.owner, project),
  );
}
