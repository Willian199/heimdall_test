import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatExtendsEndingWithPredicateRules on MemberPredicateBuilder {
  /// Selects members declared in classes that extend a type whose name ends with [suffix].
  MemberPredicateBuilder areDeclaredInClassesThatExtendTypeNameEndingWith(
    String suffix,
  ) {
    return areDeclaredInClassesThat(_classExtendsTypeNameEndingWith(suffix));
  }

  /// Selects members that do not satisfy `areDeclaredInClassesThatExtendTypeNameEndingWith`.
  MemberPredicateBuilder noAreDeclaredInClassesThatExtendTypeNameEndingWith(
    String suffix,
  ) {
    return satisfy(_memberDoesNotBeDeclaredInClassesThatExtendTypeNameEndingWith(suffix));
  }

  /// Selects members declared in classes that extend a type name ending with any suffix in [suffixes].
  MemberPredicateBuilder areDeclaredInClassesThatExtendTypeNameEndingWithAny(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.anyOf(
        suffixList.map(_classExtendsTypeNameEndingWith),
        description: 'extend type name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that extend type names ending with every suffix in [suffixes].
  MemberPredicateBuilder areDeclaredInClassesThatExtendTypeNameEndingWithAll(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.allOf(
        suffixList.map(_classExtendsTypeNameEndingWith),
        description: 'extend type names ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that extend no type name ending with [suffixes].
  MemberPredicateBuilder areDeclaredInClassesThatExtendTypeNameEndingWithNone(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.noneOf(
        suffixList.map(_classExtendsTypeNameEndingWith),
        description: 'extend type name ending with none of ${suffixList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatExtendsEndingWithShouldRules on MemberShouldBuilder {
  /// Requires members to be declared in classes that extend a type whose name ends with [suffix].
  HeimdallRule<ClassMember> beDeclaredInClassesThatExtendTypeNameEndingWith(
    String suffix,
  ) {
    return beDeclaredInClassesThat(_classExtendsTypeNameEndingWith(suffix));
  }

  /// Requires members not to satisfy `beDeclaredInClassesThatExtendTypeNameEndingWith`.
  HeimdallRule<ClassMember> noBeDeclaredInClassesThatExtendTypeNameEndingWith(
    String suffix,
  ) {
    return satisfy(_memberShouldNotBeDeclaredInClassesThatExtendTypeNameEndingWith(suffix));
  }

  /// Requires members to be declared in classes that extend a type name ending with any suffix in [suffixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatExtendTypeNameEndingWithAny(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.anyOf(
        suffixList.map(_classExtendsTypeNameEndingWith).map(_memberShouldBeDeclaredInClassesThat),
        description: 'extend type name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that extend type names ending with every suffix in [suffixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatExtendTypeNameEndingWithAll(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.allOf(
        suffixList.map(_classExtendsTypeNameEndingWith).map(_memberShouldBeDeclaredInClassesThat),
        description: 'extend type names ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that extend no type name ending with [suffixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatExtendTypeNameEndingWithNone(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.noneOf(
        suffixList.map(_classExtendsTypeNameEndingWith).map(_memberShouldBeDeclaredInClassesThat),
        description: 'extend type name ending with none of ${suffixList.join(', ')}',
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

HeimdallPredicate<CompilationUnitMember> _classExtendsTypeNameEndingWith(
  String suffix,
) {
  return HeimdallPredicate(
    'extend type name ending with $suffix',
    (item, project) => extendsTypeNamedWhere(
      item,
      project,
      (typeName) => typeName.endsWith(suffix),
    ),
  );
}

HeimdallCondition<ClassMember> _memberShouldNotBeDeclaredInClassesThatExtendTypeNameEndingWith(
  String suffix,
) {
  final classPredicate = _classExtendsTypeNameEndingWith(suffix);
  return prohibitedMemberCondition(
    'be declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotBeDeclaredInClassesThatExtendTypeNameEndingWith(
  String suffix,
) {
  final classPredicate = _classExtendsTypeNameEndingWith(suffix);
  return HeimdallPredicate(
    'not be declared in classes that extend type name ending with $suffix',
    (item, project) => !classPredicate.test(item.owner, project),
  );
}
