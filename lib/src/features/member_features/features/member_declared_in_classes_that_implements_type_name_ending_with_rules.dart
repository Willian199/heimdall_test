import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatImplementsEndingWithPredicateRules on MemberPredicateBuilder {
  /// Selects members declared in classes that implement a type whose name ends with [suffix].
  MemberPredicateBuilder areDeclaredInClassesThatImplementTypeNameEndingWith(
    String suffix,
  ) {
    return areDeclaredInClassesThat(_classImplementsTypeNameEndingWith(suffix));
  }

  /// Selects members that do not satisfy `areDeclaredInClassesThatImplementTypeNameEndingWith`.
  MemberPredicateBuilder noAreDeclaredInClassesThatImplementTypeNameEndingWith(
    String suffix,
  ) {
    return satisfy(_memberDoesNotBeDeclaredInClassesThatImplementTypeNameEndingWith(suffix));
  }

  /// Selects members declared in classes that implement a type name ending with any suffix in [suffixes].
  MemberPredicateBuilder areDeclaredInClassesThatImplementTypeNameEndingWithAny(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.anyOf(
        suffixList.map(_classImplementsTypeNameEndingWith),
        description: 'implement type name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that implement type names ending with every suffix in [suffixes].
  MemberPredicateBuilder areDeclaredInClassesThatImplementTypeNameEndingWithAll(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.allOf(
        suffixList.map(_classImplementsTypeNameEndingWith),
        description: 'implement type names ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that implement no type name ending with [suffixes].
  MemberPredicateBuilder areDeclaredInClassesThatImplementTypeNameEndingWithNone(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.noneOf(
        suffixList.map(_classImplementsTypeNameEndingWith),
        description: 'implement type name ending with none of ${suffixList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatImplementsEndingWithShouldRules on MemberShouldBuilder {
  /// Requires members to be declared in classes that implement a type whose name ends with [suffix].
  HeimdallRule<ClassMember> beDeclaredInClassesThatImplementTypeNameEndingWith(
    String suffix,
  ) {
    return beDeclaredInClassesThat(_classImplementsTypeNameEndingWith(suffix));
  }

  /// Requires members not to satisfy `beDeclaredInClassesThatImplementTypeNameEndingWith`.
  HeimdallRule<ClassMember> noBeDeclaredInClassesThatImplementTypeNameEndingWith(
    String suffix,
  ) {
    return satisfy(_memberShouldNotBeDeclaredInClassesThatImplementTypeNameEndingWith(suffix));
  }

  /// Requires members to be declared in classes that implement a type name ending with any suffix in [suffixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatImplementTypeNameEndingWithAny(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.anyOf(
        suffixList.map(_classImplementsTypeNameEndingWith).map(_memberShouldBeDeclaredInClassesThat),
        description: 'implement type name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that implement type names ending with every suffix in [suffixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatImplementTypeNameEndingWithAll(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.allOf(
        suffixList.map(_classImplementsTypeNameEndingWith).map(_memberShouldBeDeclaredInClassesThat),
        description: 'implement type names ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that implement no type name ending with [suffixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatImplementTypeNameEndingWithNone(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.noneOf(
        suffixList.map(_classImplementsTypeNameEndingWith).map(_memberShouldBeDeclaredInClassesThat),
        description: 'implement type name ending with none of ${suffixList.join(', ')}',
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

HeimdallPredicate<CompilationUnitMember> _classImplementsTypeNameEndingWith(
  String suffix,
) {
  return HeimdallPredicate(
    'implement type name ending with $suffix',
    (item, project) => implementsTypeNamedWhere(
      item,
      project,
      (typeName) => typeName.endsWith(suffix),
    ),
  );
}

HeimdallCondition<ClassMember> _memberShouldNotBeDeclaredInClassesThatImplementTypeNameEndingWith(
  String suffix,
) {
  final classPredicate = _classImplementsTypeNameEndingWith(suffix);
  return prohibitedMemberCondition(
    'be declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotBeDeclaredInClassesThatImplementTypeNameEndingWith(
  String suffix,
) {
  final classPredicate = _classImplementsTypeNameEndingWith(suffix);
  return HeimdallPredicate(
    'not be declared in classes that implement type name ending with $suffix',
    (item, project) => !classPredicate.test(item.owner, project),
  );
}
