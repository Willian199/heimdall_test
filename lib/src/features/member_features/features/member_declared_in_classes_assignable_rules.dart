import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/member_features/helpers/member_owner_rule_helpers.dart';
import 'package:heimdall_test/src/features/queries/declaration_rule_predicates.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesAssignablePredicateRules on MemberPredicateBuilder {
  /// Selects members declared in classes assignable to [typeName].
  MemberPredicateBuilder areDeclaredInClassesAssignableTo(String typeName) {
    return areDeclaredInClassesThat(classAssignableTo(typeName));
  }

  /// Selects members that do not satisfy `areDeclaredInClassesAssignableTo`.
  MemberPredicateBuilder areNotDeclaredInClassesAssignableTo(String typeName) {
    return satisfy(_memberDoesNotBeDeclaredInClassesAssignableTo(typeName));
  }

  /// Selects members declared in classes assignable to any type in [typeNames].
  MemberPredicateBuilder areDeclaredInClassesAssignableToAnyOf(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return areDeclaredInClassesThat(
      HeimdallPredicate.anyOf(
        typeList.map(classAssignableTo),
        description: 'are assignable to any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes assignable to every type in [typeNames].
  MemberPredicateBuilder areDeclaredInClassesAssignableToAllOf(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return areDeclaredInClassesThat(
      HeimdallPredicate.allOf(
        typeList.map(classAssignableTo),
        description: 'are assignable to all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes assignable to none of [typeNames].
  MemberPredicateBuilder areDeclaredInClassesAssignableToNoneOf(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return areDeclaredInClassesThat(
      HeimdallPredicate.noneOf(
        typeList.map(classAssignableTo),
        description: 'are assignable to none of ${typeList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesAssignableShouldRules on MemberShouldBuilder {
  /// Requires members to be declared in classes assignable to [typeName].
  HeimdallRule<ClassMember> beDeclaredInClassesAssignableTo(String typeName) {
    return beDeclaredInClassesThat(classAssignableTo(typeName));
  }

  /// Requires members not to satisfy `beDeclaredInClassesAssignableTo`.
  HeimdallRule<ClassMember> notBeDeclaredInClassesAssignableTo(String typeName) {
    return satisfy(_memberShouldNotBeDeclaredInClassesAssignableTo(typeName));
  }

  /// Requires members to be declared in classes assignable to any type in [typeNames].
  HeimdallRule<ClassMember> beDeclaredInClassesAssignableToAnyOf(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.anyOf(
        typeList.map(classAssignableTo).map(memberShouldBeDeclaredInClassesThat),
        description: 'are assignable to any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes assignable to every type in [typeNames].
  HeimdallRule<ClassMember> beDeclaredInClassesAssignableToAllOf(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.allOf(
        typeList.map(classAssignableTo).map(memberShouldBeDeclaredInClassesThat),
        description: 'are assignable to all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes assignable to none of [typeNames].
  HeimdallRule<ClassMember> beDeclaredInClassesAssignableToNoneOf(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.noneOf(
        typeList.map(classAssignableTo).map(memberShouldBeDeclaredInClassesThat),
        description: 'are assignable to none of ${typeList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _memberShouldNotBeDeclaredInClassesAssignableTo(String typeName) {
  final classPredicate = classAssignableTo(typeName);
  return prohibitedMemberCondition(
    'be declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotBeDeclaredInClassesAssignableTo(String typeName) {
  final classPredicate = classAssignableTo(typeName);
  return HeimdallPredicate(
    'not be declared in classes assignable to $typeName',
    (item, project) => !classPredicate.test(item.owner, project),
  );
}
