import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member return or field type-name rules.
extension MemberHaveReturnTypeNameMatchingPredicateRules on MemberPredicateBuilder {
  /// Selects members whose return or field type name matches [pattern].
  MemberPredicateBuilder haveReturnTypeNameMatching(RegExp pattern) {
    return satisfy(_memberReturnTypeName(pattern));
  }

  /// Selects members that do not satisfy `haveReturnTypeNameMatching`.
  MemberPredicateBuilder noHaveReturnTypeNameMatching(RegExp pattern) {
    return satisfy(_memberDoesNotHaveReturnTypeNameMatching(pattern));
  }

  /// Selects members whose return or field type name matches any value in [patterns].
  MemberPredicateBuilder haveReturnTypeNameMatchingAny(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.anyOf(
        valueList.map(_memberReturnTypeName),
        description: 'have return type name matching any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members whose return or field type name matches every value in [patterns].
  MemberPredicateBuilder haveReturnTypeNameMatchingAll(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.allOf(
        valueList.map(_memberReturnTypeName),
        description: 'have return type name matching all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members whose return or field type name matches none of [patterns].
  MemberPredicateBuilder haveReturnTypeNameMatchingNone(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.noneOf(
        valueList.map(_memberReturnTypeName),
        description: 'have return type name matching none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member return or field type-name rules.
extension MemberHaveReturnTypeNameMatchingShouldRules on MemberShouldBuilder {
  /// Requires members to have a return or field type name matching [pattern].
  HeimdallRule<ClassMember> haveReturnTypeNameMatching(RegExp pattern) {
    return satisfy(_memberShouldHaveReturnTypeName(pattern));
  }

  /// Requires members not to satisfy `haveReturnTypeNameMatching`.
  HeimdallRule<ClassMember> noHaveReturnTypeNameMatching(RegExp pattern) {
    return satisfy(_memberShouldNotHaveReturnTypeNameMatching(pattern));
  }

  /// Requires members to have a return or field type name matching any value in [patterns].
  HeimdallRule<ClassMember> haveReturnTypeNameMatchingAny(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_memberShouldHaveReturnTypeName),
        description: 'have return type name matching any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to have a return or field type name matching every value in [patterns].
  HeimdallRule<ClassMember> haveReturnTypeNameMatchingAll(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_memberShouldHaveReturnTypeName),
        description: 'have return type name matching all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to have a return or field type name matching none of [patterns].
  HeimdallRule<ClassMember> haveReturnTypeNameMatchingNone(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(_memberShouldHaveReturnTypeName),
        description: 'have return type name matching none of ${valueList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<ClassMember> _memberReturnTypeName(RegExp pattern) {
  return HeimdallPredicate(
    'have return type name matching ${pattern.pattern}',
    (item, _) => item.type != null && pattern.hasMatch(item.type!),
  );
}

HeimdallCondition<ClassMember> _memberShouldHaveReturnTypeName(RegExp pattern) {
  return HeimdallCondition('have return type name matching ${pattern.pattern}', (item, _) {
    final type = item.type;
    final matches = type != null && pattern.hasMatch(type);
    final location = item.location;
    final findings = [
      if (matches)
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: item.line,
          column: location.columnNumber,
          message: '${item.ownerName}.${item.name} has return type name matching ${pattern.pattern}',
        )
      else
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: item.line,
          message: '${item.ownerName}.${item.name} should have return type name matching ${pattern.pattern}',
        ),
    ];

    return HeimdallFindings(
      subject: item,
      passed: matches,
      findings: findings,
    );
  });
}

HeimdallCondition<ClassMember> _memberShouldNotHaveReturnTypeNameMatching(RegExp pattern) {
  return prohibitedMemberCondition(
    'have return type name matching ${pattern.pattern}',
    (item, _) => item.type != null && pattern.hasMatch(item.type!),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotHaveReturnTypeNameMatching(RegExp pattern) {
  return HeimdallPredicate(
    'not have return type name matching ${pattern.pattern}',
    (item, project) => item.type == null || !pattern.hasMatch(item.type!),
  );
}
