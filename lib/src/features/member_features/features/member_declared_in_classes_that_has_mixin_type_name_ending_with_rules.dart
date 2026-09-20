import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatHaveMixinEndingWithPredicateRules on MemberPredicateBuilder {
  /// Selects members declared in classes that mix in a type whose name ends with [suffix].
  MemberPredicateBuilder areDeclaredInClassesThatHaveMixinTypeNameEndingWith(
    String suffix,
  ) {
    return areDeclaredInClassesThat(_classMixesInTypeNameEndingWith(suffix));
  }

  /// Selects members that do not satisfy `areDeclaredInClassesThatHaveMixinTypeNameEndingWith`.
  MemberPredicateBuilder noAreDeclaredInClassesThatHaveMixinTypeNameEndingWith(
    String suffix,
  ) {
    return satisfy(_memberDoesNotBeDeclaredInClassesThatHaveMixinTypeNameEndingWith(suffix));
  }

  /// Selects members declared in classes that mix in a type name ending with any suffix in [suffixes].
  MemberPredicateBuilder areDeclaredInClassesThatHaveMixinTypeNameEndingWithAny(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.anyOf(
        suffixList.map(_classMixesInTypeNameEndingWith),
        description: 'mixin type name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that mix in type names ending with every suffix in [suffixes].
  MemberPredicateBuilder areDeclaredInClassesThatHaveMixinTypeNameEndingWithAll(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.allOf(
        suffixList.map(_classMixesInTypeNameEndingWith),
        description: 'mixin type names ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that mix in no type name ending with [suffixes].
  MemberPredicateBuilder areDeclaredInClassesThatHaveMixinTypeNameEndingWithNone(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.noneOf(
        suffixList.map(_classMixesInTypeNameEndingWith),
        description: 'mixin type name ending with none of ${suffixList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatHaveMixinEndingWithShouldRules on MemberShouldBuilder {
  /// Requires members to be declared in classes that mix in a type whose name ends with [suffix].
  HeimdallRule<ClassMember> beDeclaredInClassesThatHaveMixinTypeNameEndingWith(
    String suffix,
  ) {
    return beDeclaredInClassesThat(_classMixesInTypeNameEndingWith(suffix));
  }

  /// Requires members not to satisfy `beDeclaredInClassesThatHaveMixinTypeNameEndingWith`.
  HeimdallRule<ClassMember> noBeDeclaredInClassesThatHaveMixinTypeNameEndingWith(
    String suffix,
  ) {
    return satisfy(_memberShouldNotBeDeclaredInClassesThatHaveMixinTypeNameEndingWith(suffix));
  }

  /// Requires members to be declared in classes that mix in a type name ending with any suffix in [suffixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatHaveMixinTypeNameEndingWithAny(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.anyOf(
        suffixList.map(_classMixesInTypeNameEndingWith).map(_memberShouldBeDeclaredInClassesThat),
        description: 'mixin type name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that mix in type names ending with every suffix in [suffixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatHaveMixinTypeNameEndingWithAll(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.allOf(
        suffixList.map(_classMixesInTypeNameEndingWith).map(_memberShouldBeDeclaredInClassesThat),
        description: 'mixin type names ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that mix in no type name ending with [suffixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatHaveMixinTypeNameEndingWithNone(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.noneOf(
        suffixList.map(_classMixesInTypeNameEndingWith).map(_memberShouldBeDeclaredInClassesThat),
        description: 'mixin type name ending with none of ${suffixList.join(', ')}',
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

HeimdallPredicate<CompilationUnitMember> _classMixesInTypeNameEndingWith(
  String suffix,
) {
  return HeimdallPredicate(
    'mixin type name ending with $suffix',
    (item, project) => mixesInTypeNamedWhere(
      item,
      project,
      (typeName) => typeName.endsWith(suffix),
    ),
  );
}

HeimdallCondition<ClassMember> _memberShouldNotBeDeclaredInClassesThatHaveMixinTypeNameEndingWith(
  String suffix,
) {
  final classPredicate = _classMixesInTypeNameEndingWith(suffix);
  return prohibitedMemberCondition(
    'be declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotBeDeclaredInClassesThatHaveMixinTypeNameEndingWith(
  String suffix,
) {
  final classPredicate = _classMixesInTypeNameEndingWith(suffix);
  return HeimdallPredicate(
    'not be declared in classes that have mixin type name ending with $suffix',
    (item, project) => !classPredicate.test(item.owner, project),
  );
}
