import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatHaveMixinPredicateRules on MemberPredicateBuilder {
  /// Selects members declared in classes that mix in [typeName].
  MemberPredicateBuilder areDeclaredInClassesThatHaveMixin(String typeName) {
    return areDeclaredInClassesThat(_classMixesIn(typeName));
  }

  /// Selects members that do not satisfy `areDeclaredInClassesThatHaveMixin`.
  MemberPredicateBuilder noAreDeclaredInClassesThatHaveMixin(String typeName) {
    return satisfy(_memberDoesNotBeDeclaredInClassesThatHaveMixin(typeName));
  }

  /// Selects members declared in classes that mix in any type in [typeNames].
  MemberPredicateBuilder areDeclaredInClassesThatHaveMixinAny(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return areDeclaredInClassesThat(
      HeimdallPredicate.anyOf(
        typeList.map(_classMixesIn),
        description: 'mixin any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that mix in every type in [typeNames].
  MemberPredicateBuilder areDeclaredInClassesThatHaveMixinAll(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return areDeclaredInClassesThat(
      HeimdallPredicate.allOf(
        typeList.map(_classMixesIn),
        description: 'mixin all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in classes that mix in none of [typeNames].
  MemberPredicateBuilder areDeclaredInClassesThatHaveMixinNone(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return areDeclaredInClassesThat(
      HeimdallPredicate.noneOf(
        typeList.map(_classMixesIn),
        description: 'mixin none of ${typeList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member owner declaration rules.
extension MemberDeclaredInClassesThatHaveMixinShouldRules on MemberShouldBuilder {
  /// Requires members to be declared in classes that mix in [typeName].
  HeimdallRule<ClassMember> beDeclaredInClassesThatHaveMixin(String typeName) {
    return beDeclaredInClassesThat(_classMixesIn(typeName));
  }

  /// Requires members not to satisfy `beDeclaredInClassesThatHaveMixin`.
  HeimdallRule<ClassMember> noBeDeclaredInClassesThatHaveMixin(String typeName) {
    return satisfy(_memberShouldNotBeDeclaredInClassesThatHaveMixin(typeName));
  }

  /// Requires members to be declared in classes that mix in any type in [typeNames].
  HeimdallRule<ClassMember> beDeclaredInClassesThatHaveMixinAny(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.anyOf(
        typeList.map(_classMixesIn).map(_memberShouldBeDeclaredInClassesThat),
        description: 'mixin any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that mix in every type in [typeNames].
  HeimdallRule<ClassMember> beDeclaredInClassesThatHaveMixinAll(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.allOf(
        typeList.map(_classMixesIn).map(_memberShouldBeDeclaredInClassesThat),
        description: 'mixin all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in classes that mix in none of [typeNames].
  HeimdallRule<ClassMember> beDeclaredInClassesThatHaveMixinNone(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.noneOf(
        typeList.map(_classMixesIn).map(_memberShouldBeDeclaredInClassesThat),
        description: 'mixin none of ${typeList.join(', ')}',
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

HeimdallPredicate<CompilationUnitMember> _classMixesIn(String typeName) {
  return HeimdallPredicate(
    'mixin $typeName',
    (item, project) => mixesInType(item, typeName, project),
  );
}

HeimdallCondition<ClassMember> _memberShouldNotBeDeclaredInClassesThatHaveMixin(String typeName) {
  final classPredicate = _classMixesIn(typeName);
  return prohibitedMemberCondition(
    'be declared in classes that ${classPredicate.description}',
    (item, project) => classPredicate.test(item.owner, project),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotBeDeclaredInClassesThatHaveMixin(String typeName) {
  final classPredicate = _classMixesIn(typeName);
  return HeimdallPredicate(
    'not be declared in classes that have mixin $typeName',
    (item, project) => !classPredicate.test(item.owner, project),
  );
}
