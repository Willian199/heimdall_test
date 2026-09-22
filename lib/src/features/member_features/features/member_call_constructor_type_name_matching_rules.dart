import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member pattern rules.
extension MemberCallConstructorTypeNameMatchingPredicateRules on MemberPredicateBuilder {
  /// Selects members that call constructor type name matching [pattern].
  MemberPredicateBuilder callConstructorTypeNameMatching(RegExp pattern) {
    return satisfy(_callConstructorTypeNameMatchingPredicate(pattern));
  }

  /// Selects members that do not satisfy `callConstructorTypeNameMatching`.
  MemberPredicateBuilder notCallConstructorTypeNameMatching(RegExp pattern) {
    return satisfy(
      HeimdallPredicate(
        'not call constructor type name matching ${pattern.pattern}',
        (item, project) => !_memberCallsConstructorTypeName(item, pattern, project),
      ),
    );
  }

  /// Selects members that call constructor type name matching every value in [patterns].
  MemberPredicateBuilder callConstructorTypeNameMatchingAllOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.allOf(
        valueList.map(_callConstructorTypeNameMatchingPredicate),
        description: 'call constructor type name matching all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members that call constructor type name matching at least one value in [patterns].
  MemberPredicateBuilder callConstructorTypeNameMatchingAnyOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.anyOf(
        valueList.map(_callConstructorTypeNameMatchingPredicate),
        description: 'call constructor type name matching any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members that call constructor type name matching none of [patterns].
  MemberPredicateBuilder callConstructorTypeNameMatchingNoneOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.noneOf(
        valueList.map(_callConstructorTypeNameMatchingPredicate),
        description: 'call constructor type name matching none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member pattern rules.
extension MemberCallConstructorTypeNameMatchingShouldRules on MemberShouldBuilder {
  /// Requires members to call constructor type name matching [pattern].
  HeimdallRule<ClassMember> callConstructorTypeNameMatching(RegExp pattern) {
    return satisfy(_callConstructorTypeNameMatchingCondition(pattern));
  }

  /// Requires members not to satisfy `callConstructorTypeNameMatching`.
  HeimdallRule<ClassMember> notCallConstructorTypeNameMatching(RegExp pattern) {
    return satisfy(
      prohibitedMemberCondition(
        'call constructor type name matching ${pattern.pattern}',
        (item, project) => _memberCallsConstructorTypeName(item, pattern, project),
      ),
    );
  }

  /// Requires members to call constructor type name matching every value in [patterns].
  HeimdallRule<ClassMember> callConstructorTypeNameMatchingAllOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_callConstructorTypeNameMatchingCondition),
        description: 'call constructor type name matching all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to call constructor type name matching at least one value in [patterns].
  HeimdallRule<ClassMember> callConstructorTypeNameMatchingAnyOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_callConstructorTypeNameMatchingCondition),
        description: 'call constructor type name matching any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to call constructor type name matching none of [patterns].
  HeimdallRule<ClassMember> callConstructorTypeNameMatchingNoneOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(_callConstructorTypeNameMatchingCondition),
        description: 'call constructor type name matching none of ${valueList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _callConstructorTypeNameMatchingCondition(RegExp pattern) {
  return HeimdallCondition('call constructor type name matching $pattern', (item, project) {
    final call = memberConstructorCallWhere(item, project, (typeName) => pattern.hasMatch(typeName));
    final passed = call != null;
    final offset = switch (call) {
      InstanceCreationExpression(:final constructorName) => constructorName.type.offset,
      MethodInvocation(:final methodName) => methodName.offset,
      _ => item.offset,
    };
    final location = item.sourceLocationAt(offset);
    return HeimdallFindings(
      subject: item,
      passed: passed,
      findings: [
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: location.line,
          column: location.column,
          message: passed
              ? '${item.ownerName}.${item.name} calls constructor type name matching ${pattern.pattern}'
              : '${item.ownerName}.${item.name} should call constructor type name matching ${pattern.pattern}',
        ),
      ],
    );
  });
}

bool _memberCallsConstructorTypeName(ClassMember item, RegExp pattern, HeimdallProject project) {
  return memberHasConstructorCallWhere(item, project, (typeName) => pattern.hasMatch(typeName));
}

HeimdallPredicate<ClassMember> _callConstructorTypeNameMatchingPredicate(RegExp pattern) {
  return HeimdallPredicate(
    'call constructor type name matching ${pattern.pattern}',
    (item, project) => _memberCallsConstructorTypeName(item, pattern, project),
  );
}
