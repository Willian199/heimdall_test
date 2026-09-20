import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesAssignablePredicateRules on MemberPredicateBuilder {
  /// Selects members declared in classes assignable to [typeName].
  MemberPredicateBuilder areDeclaredInClassesAssignableTo(String typeName) {
    return areDeclaredInClassesThat(_assignableClassPredicate(typeName));
  }

  /// Selects members that do not satisfy `areDeclaredInClassesAssignableTo`.
  MemberPredicateBuilder noAreDeclaredInClassesAssignableTo(String typeName) {
    return satisfy(_memberDoesNotBeDeclaredInClassesAssignableTo(typeName));
  }

  /// Selects members declared in classes assignable to any type in [typeNames].
  MemberPredicateBuilder areDeclaredInClassesAssignableToAny(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return areDeclaredInClassesThat(
      HeimdallPredicate.anyOf(
        typeList.map(_assignableClassPredicate),
        description: 'are assignable to any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes assignable to every type in [typeNames].
  MemberPredicateBuilder areDeclaredInClassesAssignableToAll(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return areDeclaredInClassesThat(
      HeimdallPredicate.allOf(
        typeList.map(_assignableClassPredicate),
        description: 'are assignable to all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes assignable to none of [typeNames].
  MemberPredicateBuilder areDeclaredInClassesAssignableToNone(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return areDeclaredInClassesThat(
      HeimdallPredicate.noneOf(
        typeList.map(_assignableClassPredicate),
        description: 'are assignable to none of ${typeList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesAssignableShouldRules on MemberShouldBuilder {
  /// Requires members to be declared in classes assignable to [typeName].
  HeimdallRule<ClassMember> beDeclaredInClassesAssignableTo(String typeName) {
    return beDeclaredInClassesThat(_assignableClassPredicate(typeName));
  }

  /// Requires members not to satisfy `beDeclaredInClassesAssignableTo`.
  HeimdallRule<ClassMember> noBeDeclaredInClassesAssignableTo(String typeName) {
    return satisfy(_memberShouldNotBeDeclaredInClassesAssignableTo(typeName));
  }

  /// Requires members to be declared in classes assignable to any type in [typeNames].
  HeimdallRule<ClassMember> beDeclaredInClassesAssignableToAny(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.anyOf(
        typeList.map(_assignableClassPredicate).map(_memberShouldBeDeclaredInClassesThat),
        description: 'are assignable to any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes assignable to every type in [typeNames].
  HeimdallRule<ClassMember> beDeclaredInClassesAssignableToAll(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.allOf(
        typeList.map(_assignableClassPredicate).map(_memberShouldBeDeclaredInClassesThat),
        description: 'are assignable to all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes assignable to none of [typeNames].
  HeimdallRule<ClassMember> beDeclaredInClassesAssignableToNone(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.noneOf(
        typeList.map(_assignableClassPredicate).map(_memberShouldBeDeclaredInClassesThat),
        description: 'are assignable to none of ${typeList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _memberShouldBeDeclaredInClassesThat(
  HeimdallPredicate<CompilationUnitMember> classPredicate,
) {
  return memberCondition(
    'be declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}

HeimdallPredicate<CompilationUnitMember> _assignableClassPredicate(
  String typeName,
) {
  return HeimdallPredicate(
    'are assignable to $typeName',
    (item, project) => isAssignableTo(item, typeName, project),
  );
}

HeimdallCondition<ClassMember> _memberShouldNotBeDeclaredInClassesAssignableTo(String typeName) {
  final classPredicate = _assignableClassPredicate(typeName);
  return prohibitedMemberCondition(
    'be declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotBeDeclaredInClassesAssignableTo(String typeName) {
  final classPredicate = _assignableClassPredicate(typeName);
  return HeimdallPredicate(
    'not be declared in classes assignable to $typeName',
    (item, project) => !classPredicate.test(item.owner, project),
  );
}
