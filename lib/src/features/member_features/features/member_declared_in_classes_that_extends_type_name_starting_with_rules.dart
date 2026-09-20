import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatExtendsStartingWithPredicateRules on MemberPredicateBuilder {
  /// Selects members declared in classes that extend type name starting with [prefix].
  MemberPredicateBuilder areDeclaredInClassesThatExtendTypeNameStartingWith(String prefix) {
    return areDeclaredInClassesThat(_classExtendsTypeNameStartingWith(prefix));
  }

  /// Selects members that do not satisfy `areDeclaredInClassesThatExtendTypeNameStartingWith`.
  MemberPredicateBuilder noAreDeclaredInClassesThatExtendTypeNameStartingWith(String prefix) {
    return satisfy(_memberDoesNotBeDeclaredInClassesThatExtendTypeNameStartingWith(prefix));
  }

  /// Selects members declared in classes that extend type name starting with any value in [prefixes].
  MemberPredicateBuilder areDeclaredInClassesThatExtendTypeNameStartingWithAny(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.anyOf(
        valueList.map(_classExtendsTypeNameStartingWith),
        description: 'extend type name starting with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that extend type name starting with every value in [prefixes].
  MemberPredicateBuilder areDeclaredInClassesThatExtendTypeNameStartingWithAll(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.allOf(
        valueList.map(_classExtendsTypeNameStartingWith),
        description: 'extend type name starting with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that extend type name starting with none of [prefixes].
  MemberPredicateBuilder areDeclaredInClassesThatExtendTypeNameStartingWithNone(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.noneOf(
        valueList.map(_classExtendsTypeNameStartingWith),
        description: 'extend type name starting with none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatExtendsStartingWithShouldRules on MemberShouldBuilder {
  /// Requires members to be declared in classes that extend type name starting with [prefix].
  HeimdallRule<ClassMember> beDeclaredInClassesThatExtendTypeNameStartingWith(String prefix) {
    return beDeclaredInClassesThat(_classExtendsTypeNameStartingWith(prefix));
  }

  /// Requires members not to satisfy `beDeclaredInClassesThatExtendTypeNameStartingWith`.
  HeimdallRule<ClassMember> noBeDeclaredInClassesThatExtendTypeNameStartingWith(String prefix) {
    return satisfy(_memberShouldNotBeDeclaredInClassesThatExtendTypeNameStartingWith(prefix));
  }

  /// Requires members to be declared in classes that extend type name starting with any value in [prefixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatExtendTypeNameStartingWithAny(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_classExtendsTypeNameStartingWith).map(_memberShouldBeDeclaredInClassesThat),
        description: 'extend type name starting with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that extend type name starting with every value in [prefixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatExtendTypeNameStartingWithAll(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_classExtendsTypeNameStartingWith).map(_memberShouldBeDeclaredInClassesThat),
        description: 'extend type name starting with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that extend type name starting with none of [prefixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatExtendTypeNameStartingWithNone(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(_classExtendsTypeNameStartingWith).map(_memberShouldBeDeclaredInClassesThat),
        description: 'extend type name starting with none of ${valueList.join(', ')}',
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

HeimdallPredicate<CompilationUnitMember> _classExtendsTypeNameStartingWith(String prefix) {
  return HeimdallPredicate(
    'extend type name starting with $prefix',
    (item, project) => extendsTypeNamedWhere(
      item,
      project,
      (typeName) => typeName.startsWith(prefix),
    ),
  );
}

HeimdallCondition<ClassMember> _memberShouldNotBeDeclaredInClassesThatExtendTypeNameStartingWith(String prefix) {
  final classPredicate = _classExtendsTypeNameStartingWith(prefix);
  return prohibitedMemberCondition(
    'be declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotBeDeclaredInClassesThatExtendTypeNameStartingWith(String prefix) {
  final classPredicate = _classExtendsTypeNameStartingWith(prefix);
  return HeimdallPredicate(
    'not be declared in classes that extend type name starting with $prefix',
    (item, project) => !classPredicate.test(item.owner, project),
  );
}
