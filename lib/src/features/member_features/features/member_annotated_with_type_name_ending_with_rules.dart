import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/core/behavior_rule/heimdall_rule.dart';
import 'package:heimdall_test/src/core/heimdall_condition.dart';
import 'package:heimdall_test/src/core/heimdall_predicate.dart';
import 'package:heimdall_test/src/core/member_rules/member_predicate_builder.dart';
import 'package:heimdall_test/src/core/member_rules/member_should_builder.dart';
import 'package:heimdall_test/src/core/non_empty_iterable.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_member.dart';

/// Predicate-side DSL for member pattern rules.
extension MemberAnnotatedWithTypeNameEndingWithPredicateRules on MemberPredicateBuilder {
  /// Selects members that annotated with type name ending with [suffix].
  MemberPredicateBuilder areAnnotatedWithTypeNameEndingWith(String suffix) {
    return satisfy(_annotatedWithTypeNameEndingWithPredicate(suffix));
  }

  /// Selects members that do not satisfy `areAnnotatedWithTypeNameEndingWith`.
  MemberPredicateBuilder noAreAnnotatedWithTypeNameEndingWith(String suffix) {
    return satisfy(_memberDoesNotBeAnnotatedWithTypeNameEndingWith(suffix));
  }

  /// Selects members that annotated with type name ending with every value in [suffixes].
  MemberPredicateBuilder areAnnotatedWithTypeNameEndingWithAll(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.allOf(
        valueList.map(_annotatedWithTypeNameEndingWithPredicate),
        description: 'are annotated with type name ending with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members that annotated with type name ending with at least one value in [suffixes].
  MemberPredicateBuilder areAnnotatedWithTypeNameEndingWithAny(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        valueList.map(_annotatedWithTypeNameEndingWithPredicate),
        description: 'are annotated with type name ending with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members that annotated with type name ending with none of [suffixes].
  MemberPredicateBuilder areAnnotatedWithTypeNameEndingWithNone(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        valueList.map(_annotatedWithTypeNameEndingWithPredicate),
        description: 'are annotated with type name ending with none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member pattern rules.
extension MemberAnnotatedWithTypeNameEndingWithShouldRules on MemberShouldBuilder {
  /// Requires members to annotated with type name ending with [suffix].
  HeimdallRule<ClassMember> beAnnotatedWithTypeNameEndingWith(String suffix) {
    return satisfy(_annotatedWithTypeNameEndingWithCondition(suffix));
  }

  /// Requires members not to satisfy `beAnnotatedWithTypeNameEndingWith`.
  HeimdallRule<ClassMember> noBeAnnotatedWithTypeNameEndingWith(String suffix) {
    return satisfy(_memberShouldNotBeAnnotatedWithTypeNameEndingWith(suffix));
  }

  /// Requires members to annotated with type name ending with every value in [suffixes].
  HeimdallRule<ClassMember> beAnnotatedWithTypeNameEndingWithAll(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_annotatedWithTypeNameEndingWithCondition),
        description: 'are annotated with type name ending with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to annotated with type name ending with at least one value in [suffixes].
  HeimdallRule<ClassMember> beAnnotatedWithTypeNameEndingWithAny(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_annotatedWithTypeNameEndingWithCondition),
        description: 'are annotated with type name ending with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to annotated with type name ending with none of [suffixes].
  HeimdallRule<ClassMember> beAnnotatedWithTypeNameEndingWithNone(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(_annotatedWithTypeNameEndingWithCondition),
        description: 'are annotated with type name ending with none of ${valueList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _annotatedWithTypeNameEndingWithCondition(String suffix) {
  return memberCondition(
    'annotated with type name ending with $suffix',
    (item, _) => item.annotations.any((annotation) => annotation.endsWith(suffix)),
  );
}

HeimdallCondition<ClassMember> _memberShouldNotBeAnnotatedWithTypeNameEndingWith(String suffix) {
  return prohibitedMemberCondition(
    'be annotated with type name ending with $suffix',
    (item, _) => item.annotations.any((annotation) => annotation.endsWith(suffix)),
  );
}

HeimdallPredicate<ClassMember> _annotatedWithTypeNameEndingWithPredicate(String suffix) {
  return HeimdallPredicate(
    'be annotated with type name ending with $suffix',
    (item, _) => item.annotations.any((annotation) => annotation.endsWith(suffix)),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotBeAnnotatedWithTypeNameEndingWith(String suffix) {
  return HeimdallPredicate(
    'not be annotated with type name ending with $suffix',
    (item, _) => item.annotations.every((annotation) => !annotation.endsWith(suffix)),
  );
}
