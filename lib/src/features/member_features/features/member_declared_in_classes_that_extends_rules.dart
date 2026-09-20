import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatExtendsPredicateRules on MemberPredicateBuilder {
  /// Selects members declared in classes that extend [typeName].
  MemberPredicateBuilder areDeclaredInClassesThatExtend(String typeName) {
    return areDeclaredInClassesThat(_classExtends(typeName));
  }

  /// Selects members that do not satisfy `areDeclaredInClassesThatExtend`.
  MemberPredicateBuilder noAreDeclaredInClassesThatExtend(String typeName) {
    return satisfy(_memberDoesNotBeDeclaredInClassesThatExtend(typeName));
  }

  /// Selects members declared in classes that extend any type in [typeNames].
  MemberPredicateBuilder areDeclaredInClassesThatExtendAny(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return areDeclaredInClassesThat(
      HeimdallPredicate.anyOf(
        typeList.map(_classExtends),
        description: 'extend any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that extend every type in [typeNames].
  MemberPredicateBuilder areDeclaredInClassesThatExtendAll(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return areDeclaredInClassesThat(
      HeimdallPredicate.allOf(
        typeList.map(_classExtends),
        description: 'extend all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that extend none of [typeNames].
  MemberPredicateBuilder areDeclaredInClassesThatExtendNone(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return areDeclaredInClassesThat(
      HeimdallPredicate.noneOf(
        typeList.map(_classExtends),
        description: 'extend none of ${typeList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatExtendsShouldRules on MemberShouldBuilder {
  /// Requires members to be declared in classes that extend [typeName].
  HeimdallRule<ClassMember> beDeclaredInClassesThatExtend(String typeName) {
    return beDeclaredInClassesThat(_classExtends(typeName));
  }

  /// Requires members not to satisfy `beDeclaredInClassesThatExtend`.
  HeimdallRule<ClassMember> noBeDeclaredInClassesThatExtend(String typeName) {
    return satisfy(_memberShouldNotBeDeclaredInClassesThatExtend(typeName));
  }

  /// Requires members to be declared in classes that extend any type in [typeNames].
  HeimdallRule<ClassMember> beDeclaredInClassesThatExtendAny(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.anyOf(
        typeList.map(_classExtends).map(_memberShouldBeDeclaredInClassesThat),
        description: 'extend any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that extend every type in [typeNames].
  HeimdallRule<ClassMember> beDeclaredInClassesThatExtendAll(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.allOf(
        typeList.map(_classExtends).map(_memberShouldBeDeclaredInClassesThat),
        description: 'extend all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that extend none of [typeNames].
  HeimdallRule<ClassMember> beDeclaredInClassesThatExtendNone(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.noneOf(
        typeList.map(_classExtends).map(_memberShouldBeDeclaredInClassesThat),
        description: 'extend none of ${typeList.join(', ')}',
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

HeimdallPredicate<CompilationUnitMember> _classExtends(String typeName) {
  return HeimdallPredicate(
    'extend $typeName',
    (item, project) => extendsType(item, typeName, project),
  );
}

HeimdallCondition<ClassMember> _memberShouldNotBeDeclaredInClassesThatExtend(String typeName) {
  final classPredicate = _classExtends(typeName);
  return prohibitedMemberCondition(
    'be declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotBeDeclaredInClassesThatExtend(String typeName) {
  final classPredicate = _classExtends(typeName);
  return HeimdallPredicate(
    'not be declared in classes that extend $typeName',
    (item, project) => !classPredicate.test(item.owner, project),
  );
}
