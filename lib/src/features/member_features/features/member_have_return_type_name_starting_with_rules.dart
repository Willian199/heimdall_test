import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/member_features/helpers/member_return_type_rule_helpers.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member method return type-name rules.
extension MemberHaveReturnTypeNameStartingWithPredicateRules on MemberPredicateBuilder {
  /// Selects members whose method return type name matches [prefix].
  MemberPredicateBuilder haveReturnTypeNameStartingWith(String prefix) {
    return satisfy(_memberReturnTypeName(prefix));
  }

  /// Selects members that do not satisfy `haveReturnTypeNameStartingWith`.
  MemberPredicateBuilder notHaveReturnTypeNameStartingWith(String prefix) {
    return satisfy(_memberDoesNotHaveReturnTypeNameStartingWith(prefix));
  }

  /// Selects members whose method return type name matches any value in [prefixes].
  MemberPredicateBuilder haveReturnTypeNameStartingWithAnyOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        valueList.map(_memberReturnTypeName),
        description: 'have return type name starting with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members whose method return type name matches every value in [prefixes].
  MemberPredicateBuilder haveReturnTypeNameStartingWithAllOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.allOf(
        valueList.map(_memberReturnTypeName),
        description: 'have return type name starting with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members whose method return type name matches none of [prefixes].
  MemberPredicateBuilder haveReturnTypeNameStartingWithNoneOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        valueList.map(_memberReturnTypeName),
        description: 'have return type name starting with none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member method return type-name rules.
extension MemberHaveReturnTypeNameStartingWithShouldRules on MemberShouldBuilder {
  /// Requires members to have a method return type name matching [prefix].
  HeimdallRule<ClassMember> haveReturnTypeNameStartingWith(String prefix) {
    return satisfy(_memberShouldHaveReturnTypeName(prefix));
  }

  /// Requires members not to satisfy `haveReturnTypeNameStartingWith`.
  HeimdallRule<ClassMember> notHaveReturnTypeNameStartingWith(String prefix) {
    return satisfy(_memberShouldNotHaveReturnTypeNameStartingWith(prefix));
  }

  /// Requires members to have a method return type name matching any value in [prefixes].
  HeimdallRule<ClassMember> haveReturnTypeNameStartingWithAnyOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_memberShouldHaveReturnTypeName),
        description: 'have return type name starting with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to have a method return type name matching every value in [prefixes].
  HeimdallRule<ClassMember> haveReturnTypeNameStartingWithAllOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_memberShouldHaveReturnTypeName),
        description: 'have return type name starting with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to have a method return type name matching none of [prefixes].
  HeimdallRule<ClassMember> haveReturnTypeNameStartingWithNoneOf(Iterable<String> prefixes) {
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
    (item, _) => memberReturnTypeName(item) != null && memberReturnTypeName(item)!.startsWith(prefix),
  );
}

HeimdallCondition<ClassMember> _memberShouldHaveReturnTypeName(String prefix) {
  return HeimdallCondition('have return type name starting with $prefix', (item, _) {
    final type = memberReturnTypeName(item);
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
    (item, _) => memberReturnTypeName(item) != null && memberReturnTypeName(item)!.startsWith(prefix),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotHaveReturnTypeNameStartingWith(String prefix) {
  return HeimdallPredicate(
    'not have return type name starting with $prefix',
    (item, project) => memberReturnTypeName(item) == null || !memberReturnTypeName(item)!.startsWith(prefix),
  );
}
