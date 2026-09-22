import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/member_features/helpers/member_owner_rule_helpers.dart';
import 'package:heimdall_test/src/features/queries/declaration_rule_predicates.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatExtendsPredicateRules on MemberPredicateBuilder {
  /// Selects members declared in classes that extend [typeName].
  MemberPredicateBuilder areDeclaredInClassesThatExtend(String typeName) {
    return areDeclaredInClassesThat(classExtends(typeName));
  }

  /// Selects members that do not satisfy `areDeclaredInClassesThatExtend`.
  MemberPredicateBuilder areNotDeclaredInClassesThatExtend(String typeName) {
    return satisfy(_memberDoesNotBeDeclaredInClassesThatExtend(typeName));
  }

  /// Selects members declared in classes that extend any type in [typeNames].
  MemberPredicateBuilder areDeclaredInClassesThatExtendAnyOf(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return areDeclaredInClassesThat(
      HeimdallPredicate.anyOf(
        typeList.map(classExtends),
        description: 'extend any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that extend every type in [typeNames].
  MemberPredicateBuilder areDeclaredInClassesThatExtendAllOf(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return areDeclaredInClassesThat(
      HeimdallPredicate.allOf(
        typeList.map(classExtends),
        description: 'extend all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that extend none of [typeNames].
  MemberPredicateBuilder areDeclaredInClassesThatExtendNoneOf(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return areDeclaredInClassesThat(
      HeimdallPredicate.noneOf(
        typeList.map(classExtends),
        description: 'extend none of ${typeList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatExtendsShouldRules on MemberShouldBuilder {
  /// Requires members to be declared in classes that extend [typeName].
  HeimdallRule<ClassMember> beDeclaredInClassesThatExtend(String typeName) {
    return beDeclaredInClassesThat(classExtends(typeName));
  }

  /// Requires members not to satisfy `beDeclaredInClassesThatExtend`.
  HeimdallRule<ClassMember> notBeDeclaredInClassesThatExtend(String typeName) {
    return satisfy(_memberShouldNotBeDeclaredInClassesThatExtend(typeName));
  }

  /// Requires members to be declared in classes that extend any type in [typeNames].
  HeimdallRule<ClassMember> beDeclaredInClassesThatExtendAnyOf(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.anyOf(
        typeList.map(classExtends).map(memberShouldBeDeclaredInClassesThat),
        description: 'extend any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that extend every type in [typeNames].
  HeimdallRule<ClassMember> beDeclaredInClassesThatExtendAllOf(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.allOf(
        typeList.map(classExtends).map(memberShouldBeDeclaredInClassesThat),
        description: 'extend all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that extend none of [typeNames].
  HeimdallRule<ClassMember> beDeclaredInClassesThatExtendNoneOf(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.noneOf(
        typeList.map(classExtends).map(memberShouldBeDeclaredInClassesThat),
        description: 'extend none of ${typeList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _memberShouldNotBeDeclaredInClassesThatExtend(String typeName) {
  final classPredicate = classExtends(typeName);
  return prohibitedMemberCondition(
    'be declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotBeDeclaredInClassesThatExtend(String typeName) {
  final classPredicate = classExtends(typeName);
  return HeimdallPredicate(
    'not be declared in classes that extend $typeName',
    (item, project) => !classPredicate.test(item.owner, project),
  );
}
