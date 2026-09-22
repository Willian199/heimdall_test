import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/member_features/helpers/member_owner_rule_helpers.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatImplementsStartingWithPredicateRules on MemberPredicateBuilder {
  /// Selects members declared in classes that implement type name starting with [prefix].
  MemberPredicateBuilder areDeclaredInClassesThatImplementTypeNameStartingWith(String prefix) {
    return areDeclaredInClassesThat(_classImplementsTypeNameStartingWith(prefix));
  }

  /// Selects members that do not satisfy `areDeclaredInClassesThatImplementTypeNameStartingWith`.
  MemberPredicateBuilder areNotDeclaredInClassesThatImplementTypeNameStartingWith(String prefix) {
    return satisfy(_memberDoesNotBeDeclaredInClassesThatImplementTypeNameStartingWith(prefix));
  }

  /// Selects members declared in classes that implement type name starting with any value in [prefixes].
  MemberPredicateBuilder areDeclaredInClassesThatImplementTypeNameStartingWithAnyOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.anyOf(
        valueList.map(_classImplementsTypeNameStartingWith),
        description: 'implement type name starting with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that implement type name starting with every value in [prefixes].
  MemberPredicateBuilder areDeclaredInClassesThatImplementTypeNameStartingWithAllOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.allOf(
        valueList.map(_classImplementsTypeNameStartingWith),
        description: 'implement type name starting with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that implement type name starting with none of [prefixes].
  MemberPredicateBuilder areDeclaredInClassesThatImplementTypeNameStartingWithNoneOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.noneOf(
        valueList.map(_classImplementsTypeNameStartingWith),
        description: 'implement type name starting with none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatImplementsStartingWithShouldRules on MemberShouldBuilder {
  /// Requires members to be declared in classes that implement type name starting with [prefix].
  HeimdallRule<ClassMember> beDeclaredInClassesThatImplementTypeNameStartingWith(String prefix) {
    return beDeclaredInClassesThat(_classImplementsTypeNameStartingWith(prefix));
  }

  /// Requires members not to satisfy `beDeclaredInClassesThatImplementTypeNameStartingWith`.
  HeimdallRule<ClassMember> notBeDeclaredInClassesThatImplementTypeNameStartingWith(String prefix) {
    return satisfy(_memberShouldNotBeDeclaredInClassesThatImplementTypeNameStartingWith(prefix));
  }

  /// Requires members to be declared in classes that implement type name starting with any value in [prefixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatImplementTypeNameStartingWithAnyOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_classImplementsTypeNameStartingWith).map(memberShouldBeDeclaredInClassesThat),
        description: 'implement type name starting with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that implement type name starting with every value in [prefixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatImplementTypeNameStartingWithAllOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_classImplementsTypeNameStartingWith).map(memberShouldBeDeclaredInClassesThat),
        description: 'implement type name starting with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that implement type name starting with none of [prefixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatImplementTypeNameStartingWithNoneOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(_classImplementsTypeNameStartingWith).map(memberShouldBeDeclaredInClassesThat),
        description: 'implement type name starting with none of ${valueList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _classImplementsTypeNameStartingWith(String prefix) {
  return HeimdallPredicate(
    'implement type name starting with $prefix',
    (item, project) => implementsTypeNamedWhere(
      item,
      project,
      (typeName) => typeName.startsWith(prefix),
    ),
  );
}

HeimdallCondition<ClassMember> _memberShouldNotBeDeclaredInClassesThatImplementTypeNameStartingWith(String prefix) {
  final classPredicate = _classImplementsTypeNameStartingWith(prefix);
  return prohibitedMemberCondition(
    'be declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotBeDeclaredInClassesThatImplementTypeNameStartingWith(String prefix) {
  final classPredicate = _classImplementsTypeNameStartingWith(prefix);
  return HeimdallPredicate(
    'not be declared in classes that implement type name starting with $prefix',
    (item, project) => !classPredicate.test(item.owner, project),
  );
}
