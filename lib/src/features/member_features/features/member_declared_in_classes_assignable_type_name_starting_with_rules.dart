import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesAssignableStartingWithPredicateRules on MemberPredicateBuilder {
  /// Selects members declared in classes that assignable to type name starting with [prefix].
  MemberPredicateBuilder areDeclaredInClassesAssignableToTypeNameStartingWith(String prefix) {
    return areDeclaredInClassesThat(_classAssignableToTypeNameStartingWith(prefix));
  }

  /// Selects members that do not satisfy `areDeclaredInClassesAssignableToTypeNameStartingWith`.
  MemberPredicateBuilder noAreDeclaredInClassesAssignableToTypeNameStartingWith(String prefix) {
    return satisfy(_memberDoesNotBeDeclaredInClassesAssignableToTypeNameStartingWith(prefix));
  }

  /// Selects members declared in classes that assignable to type name starting with any value in [prefixes].
  MemberPredicateBuilder areDeclaredInClassesAssignableToTypeNameStartingWithAny(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.anyOf(
        valueList.map(_classAssignableToTypeNameStartingWith),
        description: 'assignable to type name starting with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that assignable to type name starting with every value in [prefixes].
  MemberPredicateBuilder areDeclaredInClassesAssignableToTypeNameStartingWithAll(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.allOf(
        valueList.map(_classAssignableToTypeNameStartingWith),
        description: 'assignable to type name starting with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that assignable to type name starting with none of [prefixes].
  MemberPredicateBuilder areDeclaredInClassesAssignableToTypeNameStartingWithNone(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.noneOf(
        valueList.map(_classAssignableToTypeNameStartingWith),
        description: 'assignable to type name starting with none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesAssignableStartingWithShouldRules on MemberShouldBuilder {
  /// Requires members to be declared in classes that assignable to type name starting with [prefix].
  HeimdallRule<ClassMember> beDeclaredInClassesAssignableToTypeNameStartingWith(String prefix) {
    return beDeclaredInClassesThat(_classAssignableToTypeNameStartingWith(prefix));
  }

  /// Requires members not to satisfy `beDeclaredInClassesAssignableToTypeNameStartingWith`.
  HeimdallRule<ClassMember> noBeDeclaredInClassesAssignableToTypeNameStartingWith(String prefix) {
    return satisfy(_memberShouldNotBeDeclaredInClassesAssignableToTypeNameStartingWith(prefix));
  }

  /// Requires members to be declared in classes that assignable to type name starting with any value in [prefixes].
  HeimdallRule<ClassMember> beDeclaredInClassesAssignableToTypeNameStartingWithAny(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_classAssignableToTypeNameStartingWith).map(_memberShouldBeDeclaredInClassesThat),
        description: 'assignable to type name starting with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that assignable to type name starting with every value in [prefixes].
  HeimdallRule<ClassMember> beDeclaredInClassesAssignableToTypeNameStartingWithAll(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_classAssignableToTypeNameStartingWith).map(_memberShouldBeDeclaredInClassesThat),
        description: 'assignable to type name starting with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that assignable to type name starting with none of [prefixes].
  HeimdallRule<ClassMember> beDeclaredInClassesAssignableToTypeNameStartingWithNone(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(_classAssignableToTypeNameStartingWith).map(_memberShouldBeDeclaredInClassesThat),
        description: 'assignable to type name starting with none of ${valueList.join(', ')}',
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

HeimdallPredicate<CompilationUnitMember> _classAssignableToTypeNameStartingWith(String prefix) {
  return HeimdallPredicate(
    'assignable to type name starting with $prefix',
    (item, project) => isAssignableToTypeNamedWhere(
      item,
      project,
      (typeName) => typeName.startsWith(prefix),
    ),
  );
}

HeimdallCondition<ClassMember> _memberShouldNotBeDeclaredInClassesAssignableToTypeNameStartingWith(String prefix) {
  final classPredicate = _classAssignableToTypeNameStartingWith(prefix);
  return prohibitedMemberCondition(
    'be declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotBeDeclaredInClassesAssignableToTypeNameStartingWith(String prefix) {
  final classPredicate = _classAssignableToTypeNameStartingWith(prefix);
  return HeimdallPredicate(
    'not be declared in classes assignable to type name starting with $prefix',
    (item, project) => !classPredicate.test(item.owner, project),
  );
}
