import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/member_features/helpers/member_owner_rule_helpers.dart';
import 'package:heimdall_test/src/features/queries/declaration_rule_predicates.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatImplementsPredicateRules on MemberPredicateBuilder {
  /// Selects members declared in classes that implement [typeName].
  MemberPredicateBuilder areDeclaredInClassesThatImplement(String typeName) {
    return areDeclaredInClassesThat(classImplements(typeName));
  }

  /// Selects members that do not satisfy `areDeclaredInClassesThatImplement`.
  MemberPredicateBuilder areNotDeclaredInClassesThatImplement(String typeName) {
    return satisfy(_memberDoesNotBeDeclaredInClassesThatImplement(typeName));
  }

  /// Selects members declared in classes that implement any type in [typeNames].
  MemberPredicateBuilder areDeclaredInClassesThatImplementAnyOf(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return areDeclaredInClassesThat(
      HeimdallPredicate.anyOf(
        typeList.map(classImplements),
        description: 'implement any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that implement every type in [typeNames].
  MemberPredicateBuilder areDeclaredInClassesThatImplementAllOf(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return areDeclaredInClassesThat(
      HeimdallPredicate.allOf(
        typeList.map(classImplements),
        description: 'implement all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that implement none of [typeNames].
  MemberPredicateBuilder areDeclaredInClassesThatImplementNoneOf(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return areDeclaredInClassesThat(
      HeimdallPredicate.noneOf(
        typeList.map(classImplements),
        description: 'implement none of ${typeList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatImplementsShouldRules on MemberShouldBuilder {
  /// Requires members to be declared in classes that implement [typeName].
  HeimdallRule<ClassMember> beDeclaredInClassesThatImplement(String typeName) {
    return beDeclaredInClassesThat(classImplements(typeName));
  }

  /// Requires members not to satisfy `beDeclaredInClassesThatImplement`.
  HeimdallRule<ClassMember> notBeDeclaredInClassesThatImplement(String typeName) {
    return satisfy(_memberShouldNotBeDeclaredInClassesThatImplement(typeName));
  }

  /// Requires members to be declared in classes that implement any type in [typeNames].
  HeimdallRule<ClassMember> beDeclaredInClassesThatImplementAnyOf(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.anyOf(
        typeList.map(classImplements).map(memberShouldBeDeclaredInClassesThat),
        description: 'implement any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that implement every type in [typeNames].
  HeimdallRule<ClassMember> beDeclaredInClassesThatImplementAllOf(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.allOf(
        typeList.map(classImplements).map(memberShouldBeDeclaredInClassesThat),
        description: 'implement all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that implement none of [typeNames].
  HeimdallRule<ClassMember> beDeclaredInClassesThatImplementNoneOf(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.noneOf(
        typeList.map(classImplements).map(memberShouldBeDeclaredInClassesThat),
        description: 'implement none of ${typeList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _memberShouldNotBeDeclaredInClassesThatImplement(String typeName) {
  final classPredicate = classImplements(typeName);
  return prohibitedMemberCondition(
    'be declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotBeDeclaredInClassesThatImplement(String typeName) {
  final classPredicate = classImplements(typeName);
  return HeimdallPredicate(
    'not be declared in classes that implement $typeName',
    (item, project) => !classPredicate.test(item.owner, project),
  );
}
