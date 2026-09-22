import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for member pattern rules.
extension MemberAnnotatedWithTypeNameMatchingPredicateRules on MemberPredicateBuilder {
  /// Selects members that annotated with type name matching [pattern].
  MemberPredicateBuilder areAnnotatedWithTypeNameMatching(RegExp pattern) {
    return satisfy(_annotatedWithTypeNameMatchingPredicate(pattern));
  }

  /// Selects members that do not satisfy `areAnnotatedWithTypeNameMatching`.
  MemberPredicateBuilder areNotAnnotatedWithTypeNameMatching(RegExp pattern) {
    return satisfy(_memberDoesNotBeAnnotatedWithTypeNameMatching(pattern));
  }

  /// Selects members that annotated with type name matching every value in [patterns].
  MemberPredicateBuilder areAnnotatedWithTypeNameMatchingAllOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.allOf(
        valueList.map(_annotatedWithTypeNameMatchingPredicate),
        description: 'are annotated with type name matching all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members that annotated with type name matching at least one value in [patterns].
  MemberPredicateBuilder areAnnotatedWithTypeNameMatchingAnyOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.anyOf(
        valueList.map(_annotatedWithTypeNameMatchingPredicate),
        description: 'are annotated with type name matching any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members that annotated with type name matching none of [patterns].
  MemberPredicateBuilder areAnnotatedWithTypeNameMatchingNoneOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.noneOf(
        valueList.map(_annotatedWithTypeNameMatchingPredicate),
        description: 'are annotated with type name matching none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member pattern rules.
extension MemberAnnotatedWithTypeNameMatchingShouldRules on MemberShouldBuilder {
  /// Requires members to annotated with type name matching [pattern].
  HeimdallRule<ClassMember> beAnnotatedWithTypeNameMatching(RegExp pattern) {
    return satisfy(_annotatedWithTypeNameMatchingCondition(pattern));
  }

  /// Requires members not to satisfy `beAnnotatedWithTypeNameMatching`.
  HeimdallRule<ClassMember> notBeAnnotatedWithTypeNameMatching(RegExp pattern) {
    return satisfy(_memberShouldNotBeAnnotatedWithTypeNameMatching(pattern));
  }

  /// Requires members to annotated with type name matching every value in [patterns].
  HeimdallRule<ClassMember> beAnnotatedWithTypeNameMatchingAllOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_annotatedWithTypeNameMatchingCondition),
        description: 'are annotated with type name matching all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to annotated with type name matching at least one value in [patterns].
  HeimdallRule<ClassMember> beAnnotatedWithTypeNameMatchingAnyOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_annotatedWithTypeNameMatchingCondition),
        description: 'are annotated with type name matching any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to annotated with type name matching none of [patterns].
  HeimdallRule<ClassMember> beAnnotatedWithTypeNameMatchingNoneOf(Iterable<RegExp> patterns) {
    final valueList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(_annotatedWithTypeNameMatchingCondition),
        description: 'are annotated with type name matching none of ${valueList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _annotatedWithTypeNameMatchingCondition(RegExp pattern) {
  return HeimdallCondition('annotated with type name matching $pattern', (item, _) {
    final matchingAnnotation = item.annotationNodes.where((annotation) => pattern.hasMatch(annotation.name.name)).firstOrNull;
    final passed = matchingAnnotation != null;
    final offset = matchingAnnotation?.offset ?? item.offset;
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
              ? '${item.ownerName}.${item.name} is annotated with type name matching ${pattern.pattern}'
              : '${item.ownerName}.${item.name} should be annotated with type name matching ${pattern.pattern}',
        ),
      ],
    );
  });
}

HeimdallCondition<ClassMember> _memberShouldNotBeAnnotatedWithTypeNameMatching(RegExp pattern) {
  return prohibitedMemberCondition(
    'be annotated with type name matching ${pattern.pattern}',
    (item, _) => item.annotations.any(pattern.hasMatch),
  );
}

HeimdallPredicate<ClassMember> _annotatedWithTypeNameMatchingPredicate(RegExp pattern) {
  return HeimdallPredicate(
    'be annotated with type name matching ${pattern.pattern}',
    (item, _) => item.annotations.any(pattern.hasMatch),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotBeAnnotatedWithTypeNameMatching(RegExp pattern) {
  return HeimdallPredicate(
    'not be annotated with type name matching ${pattern.pattern}',
    (item, _) => item.annotations.every((annotation) => !pattern.hasMatch(annotation)),
  );
}
