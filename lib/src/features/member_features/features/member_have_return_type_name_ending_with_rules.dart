import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member return or field type-name rules.
extension MemberHaveReturnTypeNameEndingWithPredicateRules on MemberPredicateBuilder {
  /// Selects members whose return or field type name matches [suffix].
  MemberPredicateBuilder haveReturnTypeNameEndingWith(String suffix) {
    return satisfy(_memberReturnTypeName(suffix));
  }

  /// Selects members that do not satisfy `haveReturnTypeNameEndingWith`.
  MemberPredicateBuilder noHaveReturnTypeNameEndingWith(String suffix) {
    return satisfy(_memberDoesNotHaveReturnTypeNameEndingWith(suffix));
  }

  /// Selects members whose return or field type name matches any value in [suffixes].
  MemberPredicateBuilder haveReturnTypeNameEndingWithAny(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        valueList.map(_memberReturnTypeName),
        description: 'have return type name ending with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members whose return or field type name matches every value in [suffixes].
  MemberPredicateBuilder haveReturnTypeNameEndingWithAll(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.allOf(
        valueList.map(_memberReturnTypeName),
        description: 'have return type name ending with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members whose return or field type name matches none of [suffixes].
  MemberPredicateBuilder haveReturnTypeNameEndingWithNone(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        valueList.map(_memberReturnTypeName),
        description: 'have return type name ending with none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member return or field type-name rules.
extension MemberHaveReturnTypeNameEndingWithShouldRules on MemberShouldBuilder {
  /// Requires members to have a return or field type name matching [suffix].
  HeimdallRule<ClassMember> haveReturnTypeNameEndingWith(String suffix) {
    return satisfy(_memberShouldHaveReturnTypeName(suffix));
  }

  /// Requires members not to satisfy `haveReturnTypeNameEndingWith`.
  HeimdallRule<ClassMember> noHaveReturnTypeNameEndingWith(String suffix) {
    return satisfy(_memberShouldNotHaveReturnTypeNameEndingWith(suffix));
  }

  /// Requires members to have a return or field type name matching any value in [suffixes].
  HeimdallRule<ClassMember> haveReturnTypeNameEndingWithAny(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_memberShouldHaveReturnTypeName),
        description: 'have return type name ending with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to have a return or field type name matching every value in [suffixes].
  HeimdallRule<ClassMember> haveReturnTypeNameEndingWithAll(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_memberShouldHaveReturnTypeName),
        description: 'have return type name ending with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to have a return or field type name matching none of [suffixes].
  HeimdallRule<ClassMember> haveReturnTypeNameEndingWithNone(Iterable<String> suffixes) {
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
    (item, _) => item.type != null && item.type!.endsWith(suffix),
  );
}

HeimdallCondition<ClassMember> _memberShouldHaveReturnTypeName(String suffix) {
  return HeimdallCondition('have return type name ending with $suffix', (item, _) {
    final type = item.type;
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
    (item, _) => item.type != null && item.type!.endsWith(suffix),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotHaveReturnTypeNameEndingWith(String suffix) {
  return HeimdallPredicate(
    'not have return type name ending with $suffix',
    (item, project) => item.type == null || !item.type!.endsWith(suffix),
  );
}
