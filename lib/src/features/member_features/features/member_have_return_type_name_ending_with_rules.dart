import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/member_features/helpers/member_return_type_rule_helpers.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member method return type-name rules.
extension MemberHaveReturnTypeNameEndingWithPredicateRules on MemberPredicateBuilder {
  /// Selects members whose method return type name matches [suffix].
  MemberPredicateBuilder haveReturnTypeNameEndingWith(String suffix) {
    return satisfy(_memberReturnTypeName(suffix));
  }

  /// Selects members that do not satisfy `haveReturnTypeNameEndingWith`.
  MemberPredicateBuilder notHaveReturnTypeNameEndingWith(String suffix) {
    return satisfy(_memberDoesNotHaveReturnTypeNameEndingWith(suffix));
  }

  /// Selects members whose method return type name matches any value in [suffixes].
  MemberPredicateBuilder haveReturnTypeNameEndingWithAnyOf(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        valueList.map(_memberReturnTypeName),
        description: 'have return type name ending with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members whose method return type name matches every value in [suffixes].
  MemberPredicateBuilder haveReturnTypeNameEndingWithAllOf(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.allOf(
        valueList.map(_memberReturnTypeName),
        description: 'have return type name ending with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members whose method return type name matches none of [suffixes].
  MemberPredicateBuilder haveReturnTypeNameEndingWithNoneOf(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        valueList.map(_memberReturnTypeName),
        description: 'have return type name ending with none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member method return type-name rules.
extension MemberHaveReturnTypeNameEndingWithShouldRules on MemberShouldBuilder {
  /// Requires members to have a method return type name matching [suffix].
  HeimdallRule<ClassMember> haveReturnTypeNameEndingWith(String suffix) {
    return satisfy(_memberShouldHaveReturnTypeName(suffix));
  }

  /// Requires members not to satisfy `haveReturnTypeNameEndingWith`.
  HeimdallRule<ClassMember> notHaveReturnTypeNameEndingWith(String suffix) {
    return satisfy(_memberShouldNotHaveReturnTypeNameEndingWith(suffix));
  }

  /// Requires members to have a method return type name matching any value in [suffixes].
  HeimdallRule<ClassMember> haveReturnTypeNameEndingWithAnyOf(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_memberShouldHaveReturnTypeName),
        description: 'have return type name ending with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to have a method return type name matching every value in [suffixes].
  HeimdallRule<ClassMember> haveReturnTypeNameEndingWithAllOf(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_memberShouldHaveReturnTypeName),
        description: 'have return type name ending with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to have a method return type name matching none of [suffixes].
  HeimdallRule<ClassMember> haveReturnTypeNameEndingWithNoneOf(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(_memberShouldHaveReturnTypeName),
        description: 'have return type name ending with none of ${valueList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<ClassMember> _memberReturnTypeName(String suffix) {
  return HeimdallPredicate(
    'have return type name ending with $suffix',
    (item, _) => memberReturnTypeName(item) != null && memberReturnTypeName(item)!.endsWith(suffix),
  );
}

HeimdallCondition<ClassMember> _memberShouldHaveReturnTypeName(String suffix) {
  return HeimdallCondition('have return type name ending with $suffix', (item, _) {
    final type = memberReturnTypeName(item);
    final findings = type != null && type.endsWith(suffix)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.ownerName}.${item.name} should have return type name ending with $suffix',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<ClassMember> _memberShouldNotHaveReturnTypeNameEndingWith(String suffix) {
  return prohibitedMemberCondition(
    'have return type name ending with $suffix',
    (item, _) => memberReturnTypeName(item) != null && memberReturnTypeName(item)!.endsWith(suffix),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotHaveReturnTypeNameEndingWith(String suffix) {
  return HeimdallPredicate(
    'not have return type name ending with $suffix',
    (item, project) => memberReturnTypeName(item) == null || !memberReturnTypeName(item)!.endsWith(suffix),
  );
}
