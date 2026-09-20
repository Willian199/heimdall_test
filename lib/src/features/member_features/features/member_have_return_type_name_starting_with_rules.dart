import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member return or field type-name rules.
extension MemberHaveReturnTypeNameStartingWithPredicateRules on MemberPredicateBuilder {
  /// Selects members whose return or field type name matches [prefix].
  MemberPredicateBuilder haveReturnTypeNameStartingWith(String prefix) {
    return satisfy(_memberReturnTypeName(prefix));
  }

  /// Selects members that do not satisfy `haveReturnTypeNameStartingWith`.
  MemberPredicateBuilder noHaveReturnTypeNameStartingWith(String prefix) {
    return satisfy(_memberDoesNotHaveReturnTypeNameStartingWith(prefix));
  }

  /// Selects members whose return or field type name matches any value in [prefixes].
  MemberPredicateBuilder haveReturnTypeNameStartingWithAny(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        valueList.map(_memberReturnTypeName),
        description: 'have return type name starting with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members whose return or field type name matches every value in [prefixes].
  MemberPredicateBuilder haveReturnTypeNameStartingWithAll(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.allOf(
        valueList.map(_memberReturnTypeName),
        description: 'have return type name starting with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members whose return or field type name matches none of [prefixes].
  MemberPredicateBuilder haveReturnTypeNameStartingWithNone(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        valueList.map(_memberReturnTypeName),
        description: 'have return type name starting with none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member return or field type-name rules.
extension MemberHaveReturnTypeNameStartingWithShouldRules on MemberShouldBuilder {
  /// Requires members to have a return or field type name matching [prefix].
  HeimdallRule<ClassMember> haveReturnTypeNameStartingWith(String prefix) {
    return satisfy(_memberShouldHaveReturnTypeName(prefix));
  }

  /// Requires members not to satisfy `haveReturnTypeNameStartingWith`.
  HeimdallRule<ClassMember> noHaveReturnTypeNameStartingWith(String prefix) {
    return satisfy(_memberShouldNotHaveReturnTypeNameStartingWith(prefix));
  }

  /// Requires members to have a return or field type name matching any value in [prefixes].
  HeimdallRule<ClassMember> haveReturnTypeNameStartingWithAny(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_memberShouldHaveReturnTypeName),
        description: 'have return type name starting with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to have a return or field type name matching every value in [prefixes].
  HeimdallRule<ClassMember> haveReturnTypeNameStartingWithAll(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_memberShouldHaveReturnTypeName),
        description: 'have return type name starting with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to have a return or field type name matching none of [prefixes].
  HeimdallRule<ClassMember> haveReturnTypeNameStartingWithNone(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(_memberShouldHaveReturnTypeName),
        description: 'have return type name starting with none of ${valueList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<ClassMember> _memberReturnTypeName(String prefix) {
  return HeimdallPredicate(
    'have return type name starting with $prefix',
    (item, _) => item.type != null && item.type!.startsWith(prefix),
  );
}

HeimdallCondition<ClassMember> _memberShouldHaveReturnTypeName(String prefix) {
  return HeimdallCondition('have return type name starting with $prefix', (item, _) {
    final type = item.type;
    final findings = type != null && type.startsWith(prefix)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.ownerName}.${item.name} should have return type name starting with $prefix',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<ClassMember> _memberShouldNotHaveReturnTypeNameStartingWith(String prefix) {
  return prohibitedMemberCondition(
    'have return type name starting with $prefix',
    (item, _) => item.type != null && item.type!.startsWith(prefix),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotHaveReturnTypeNameStartingWith(String prefix) {
  return HeimdallPredicate(
    'not have return type name starting with $prefix',
    (item, project) => item.type == null || !item.type!.startsWith(prefix),
  );
}
