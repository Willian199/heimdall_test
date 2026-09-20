import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member name suffix rules.
extension MemberHaveNameEndingWithPredicateRules on MemberPredicateBuilder {
  /// Selects members whose names end with [suffix].
  MemberPredicateBuilder haveNameEndingWith(String suffix) {
    return satisfy(_memberNameEndsWith(suffix));
  }

  /// Selects members that do not satisfy `haveNameEndingWith`.
  MemberPredicateBuilder noHaveNameEndingWith(String suffix) {
    return satisfy(_memberDoesNotHaveNameEndingWith(suffix));
  }

  /// Selects members whose names end with at least one suffix in [suffixes].
  MemberPredicateBuilder haveNameEndingWithAny(Iterable<String> suffixes) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        suffixList.map(_memberNameEndsWith),
        description: 'have name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects members whose names end with every suffix in [suffixes].
  MemberPredicateBuilder haveNameEndingWithAll(Iterable<String> suffixes) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.allOf(
        suffixList.map(_memberNameEndsWith),
        description: 'have name ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects members whose names end with none of [suffixes].
  MemberPredicateBuilder haveNameEndingWithNone(Iterable<String> suffixes) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        suffixList.map(_memberNameEndsWith),
        description: 'have name ending with none of ${suffixList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member name suffix rules.
extension MemberHaveNameEndingWithShouldRules on MemberShouldBuilder {
  /// Requires member names to end with [suffix].
  HeimdallRule<ClassMember> haveNameEndingWith(String suffix) {
    return satisfy(_memberShouldHaveNameEndingWith(suffix));
  }

  /// Requires members not to satisfy `haveNameEndingWith`.
  HeimdallRule<ClassMember> noHaveNameEndingWith(String suffix) {
    return satisfy(_memberShouldNotHaveNameEndingWith(suffix));
  }

  /// Requires member names to end with at least one suffix in [suffixes].
  HeimdallRule<ClassMember> haveNameEndingWithAny(Iterable<String> suffixes) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.anyOf(
        suffixList.map(_memberShouldHaveNameEndingWith),
        description: 'have name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires member names to end with every suffix in [suffixes].
  HeimdallRule<ClassMember> haveNameEndingWithAll(Iterable<String> suffixes) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.allOf(
        suffixList.map(_memberShouldHaveNameEndingWith),
        description: 'have name ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires member names to end with none of [suffixes].
  HeimdallRule<ClassMember> haveNameEndingWithNone(Iterable<String> suffixes) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.noneOf(
        suffixList.map(_memberShouldHaveNameEndingWith),
        description: 'have name ending with none of ${suffixList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<ClassMember> _memberNameEndsWith(String suffix) {
  return HeimdallPredicate(
    'have name ending with $suffix',
    (item, _) => item.name.endsWith(suffix),
  );
}

HeimdallCondition<ClassMember> _memberShouldHaveNameEndingWith(String suffix) {
  return HeimdallCondition('have name ending with $suffix', (item, _) {
    final findings = item.name.endsWith(suffix)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.ownerName}.${item.name} should end with $suffix',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<ClassMember> _memberShouldNotHaveNameEndingWith(String suffix) {
  return prohibitedMemberCondition(
    'have name ending with $suffix',
    (item, project) => item.name.endsWith(suffix),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotHaveNameEndingWith(String suffix) {
  return HeimdallPredicate(
    'not have name ending with $suffix',
    (item, project) => !item.name.endsWith(suffix),
  );
}
