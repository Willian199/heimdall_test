import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatHaveMixinStartingWithPredicateRules on MemberPredicateBuilder {
  /// Selects members declared in classes that mixin type name starting with [prefix].
  MemberPredicateBuilder areDeclaredInClassesThatHaveMixinTypeNameStartingWith(String prefix) {
    return areDeclaredInClassesThat(_classMixesInTypeNameStartingWith(prefix));
  }

  /// Selects members that do not satisfy `areDeclaredInClassesThatHaveMixinTypeNameStartingWith`.
  MemberPredicateBuilder noAreDeclaredInClassesThatHaveMixinTypeNameStartingWith(String prefix) {
    return satisfy(_memberDoesNotBeDeclaredInClassesThatHaveMixinTypeNameStartingWith(prefix));
  }

  /// Selects members declared in classes that mixin type name starting with any value in [prefixes].
  MemberPredicateBuilder areDeclaredInClassesThatHaveMixinTypeNameStartingWithAny(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.anyOf(
        valueList.map(_classMixesInTypeNameStartingWith),
        description: 'mixin type name starting with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that mixin type name starting with every value in [prefixes].
  MemberPredicateBuilder areDeclaredInClassesThatHaveMixinTypeNameStartingWithAll(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.allOf(
        valueList.map(_classMixesInTypeNameStartingWith),
        description: 'mixin type name starting with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that mixin type name starting with none of [prefixes].
  MemberPredicateBuilder areDeclaredInClassesThatHaveMixinTypeNameStartingWithNone(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return areDeclaredInClassesThat(
      HeimdallPredicate.noneOf(
        valueList.map(_classMixesInTypeNameStartingWith),
        description: 'mixin type name starting with none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatHaveMixinStartingWithShouldRules on MemberShouldBuilder {
  /// Requires members to be declared in classes that mixin type name starting with [prefix].
  HeimdallRule<ClassMember> beDeclaredInClassesThatHaveMixinTypeNameStartingWith(String prefix) {
    return beDeclaredInClassesThat(_classMixesInTypeNameStartingWith(prefix));
  }

  /// Requires members not to satisfy `beDeclaredInClassesThatHaveMixinTypeNameStartingWith`.
  HeimdallRule<ClassMember> noBeDeclaredInClassesThatHaveMixinTypeNameStartingWith(String prefix) {
    return satisfy(_memberShouldNotBeDeclaredInClassesThatHaveMixinTypeNameStartingWith(prefix));
  }

  /// Requires members to be declared in classes that mixin type name starting with any value in [prefixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatHaveMixinTypeNameStartingWithAny(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_classMixesInTypeNameStartingWith).map(_memberShouldBeDeclaredInClassesThat),
        description: 'mixin type name starting with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that mixin type name starting with every value in [prefixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatHaveMixinTypeNameStartingWithAll(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_classMixesInTypeNameStartingWith).map(_memberShouldBeDeclaredInClassesThat),
        description: 'mixin type name starting with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that mixin type name starting with none of [prefixes].
  HeimdallRule<ClassMember> beDeclaredInClassesThatHaveMixinTypeNameStartingWithNone(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(_classMixesInTypeNameStartingWith).map(_memberShouldBeDeclaredInClassesThat),
        description: 'mixin type name starting with none of ${valueList.join(', ')}',
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

HeimdallPredicate<CompilationUnitMember> _classMixesInTypeNameStartingWith(String prefix) {
  return HeimdallPredicate(
    'mixin type name starting with $prefix',
    (item, project) => mixesInTypeNamedWhere(
      item,
      project,
      (typeName) => typeName.startsWith(prefix),
    ),
  );
}

HeimdallCondition<ClassMember> _memberShouldNotBeDeclaredInClassesThatHaveMixinTypeNameStartingWith(String prefix) {
  final classPredicate = _classMixesInTypeNameStartingWith(prefix);
  return prohibitedMemberCondition(
    'be declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotBeDeclaredInClassesThatHaveMixinTypeNameStartingWith(String prefix) {
  final classPredicate = _classMixesInTypeNameStartingWith(prefix);
  return HeimdallPredicate(
    'not be declared in classes that have mixin type name starting with $prefix',
    (item, project) => !classPredicate.test(item.owner, project),
  );
}
