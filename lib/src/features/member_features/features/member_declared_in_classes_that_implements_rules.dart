import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatImplementsPredicateRules on MemberPredicateBuilder {
  /// Selects members declared in classes that implement [typeName].
  MemberPredicateBuilder areDeclaredInClassesThatImplement(String typeName) {
    return areDeclaredInClassesThat(_classImplements(typeName));
  }

  /// Selects members that do not satisfy `areDeclaredInClassesThatImplement`.
  MemberPredicateBuilder noAreDeclaredInClassesThatImplement(String typeName) {
    return satisfy(_memberDoesNotBeDeclaredInClassesThatImplement(typeName));
  }

  /// Selects members declared in classes that implement any type in [typeNames].
  MemberPredicateBuilder areDeclaredInClassesThatImplementAny(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return areDeclaredInClassesThat(
      HeimdallPredicate.anyOf(
        typeList.map(_classImplements),
        description: 'implement any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that implement every type in [typeNames].
  MemberPredicateBuilder areDeclaredInClassesThatImplementAll(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return areDeclaredInClassesThat(
      HeimdallPredicate.allOf(
        typeList.map(_classImplements),
        description: 'implement all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that implement none of [typeNames].
  MemberPredicateBuilder areDeclaredInClassesThatImplementNone(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return areDeclaredInClassesThat(
      HeimdallPredicate.noneOf(
        typeList.map(_classImplements),
        description: 'implement none of ${typeList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatImplementsShouldRules on MemberShouldBuilder {
  /// Requires members to be declared in classes that implement [typeName].
  HeimdallRule<ClassMember> beDeclaredInClassesThatImplement(String typeName) {
    return beDeclaredInClassesThat(_classImplements(typeName));
  }

  /// Requires members not to satisfy `beDeclaredInClassesThatImplement`.
  HeimdallRule<ClassMember> noBeDeclaredInClassesThatImplement(String typeName) {
    return satisfy(_memberShouldNotBeDeclaredInClassesThatImplement(typeName));
  }

  /// Requires members to be declared in classes that implement any type in [typeNames].
  HeimdallRule<ClassMember> beDeclaredInClassesThatImplementAny(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.anyOf(
        typeList.map(_classImplements).map(_memberShouldBeDeclaredInClassesThat),
        description: 'implement any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that implement every type in [typeNames].
  HeimdallRule<ClassMember> beDeclaredInClassesThatImplementAll(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.allOf(
        typeList.map(_classImplements).map(_memberShouldBeDeclaredInClassesThat),
        description: 'implement all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that implement none of [typeNames].
  HeimdallRule<ClassMember> beDeclaredInClassesThatImplementNone(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.noneOf(
        typeList.map(_classImplements).map(_memberShouldBeDeclaredInClassesThat),
        description: 'implement none of ${typeList.join(', ')}',
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

HeimdallPredicate<CompilationUnitMember> _classImplements(String typeName) {
  return HeimdallPredicate(
    'implement $typeName',
    (item, project) => implementsType(item, typeName, project),
  );
}

HeimdallCondition<ClassMember> _memberShouldNotBeDeclaredInClassesThatImplement(String typeName) {
  final classPredicate = _classImplements(typeName);
  return prohibitedMemberCondition(
    'be declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotBeDeclaredInClassesThatImplement(String typeName) {
  final classPredicate = _classImplements(typeName);
  return HeimdallPredicate(
    'not be declared in classes that implement $typeName',
    (item, project) => !classPredicate.test(item.owner, project),
  );
}
