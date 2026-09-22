import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/core/behavior_rule/heimdall_rule.dart';
import 'package:heimdall_test/src/core/heimdall_condition.dart';
import 'package:heimdall_test/src/core/heimdall_predicate.dart';
import 'package:heimdall_test/src/core/member_rules/member_predicate_builder.dart';
import 'package:heimdall_test/src/core/member_rules/member_should_builder.dart';
import 'package:heimdall_test/src/core/non_empty_iterable.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_member.dart';

/// Predicate-side DSL for member annotation rules.
extension MemberAnnotatedWithPredicateRules on MemberPredicateBuilder {
  /// Selects members annotated with [annotation].
  MemberPredicateBuilder areAnnotatedWith(String annotation) {
    return satisfy(_memberAnnotatedWith(annotation));
  }

  /// Selects members that do not satisfy `areAnnotatedWith`.
  MemberPredicateBuilder areNotAnnotatedWith(String annotation) {
    return satisfy(
      HeimdallPredicate(
        'not be annotated with $annotation',
        (item, project) => !item.annotations.contains(annotation),
      ),
    );
  }

  /// Selects members annotated with every annotation in [annotations].
  MemberPredicateBuilder areAnnotatedWithAllOf(Iterable<String> annotations) {
    final annotationList = annotations.toNonEmptyList('annotations');
    return satisfy(
      HeimdallPredicate.allOf(
        annotationList.map(_memberAnnotatedWith),
        description: 'are annotated with all of ${annotationList.join(', ')}',
      ),
    );
  }

  /// Selects members annotated with at least one annotation in [annotations].
  MemberPredicateBuilder areAnnotatedWithAnyOf(Iterable<String> annotations) {
    final annotationList = annotations.toNonEmptyList('annotations');
    return satisfy(
      HeimdallPredicate.anyOf(
        annotationList.map(_memberAnnotatedWith),
        description: 'are annotated with any of ${annotationList.join(', ')}',
      ),
    );
  }

  /// Selects members annotated with none of [annotations].
  MemberPredicateBuilder areAnnotatedWithNoneOf(Iterable<String> annotations) {
    final annotationList = annotations.toNonEmptyList('annotations');
    return satisfy(
      HeimdallPredicate.noneOf(
        annotationList.map(_memberAnnotatedWith),
        description: 'are annotated with none of ${annotationList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member annotation rules.
extension MemberAnnotatedWithShouldRules on MemberShouldBuilder {
  /// Requires members to be annotated with [annotation].
  HeimdallRule<ClassMember> beAnnotatedWith(String annotation) {
    return satisfy(_memberShouldBeAnnotatedWith(annotation));
  }

  /// Requires members not to satisfy `beAnnotatedWith`.
  HeimdallRule<ClassMember> notBeAnnotatedWith(String annotation) {
    return satisfy(
      prohibitedMemberCondition(
        'be annotated with $annotation',
        (item, project) => item.annotations.contains(annotation),
      ),
    );
  }

  /// Requires members to be annotated with every annotation in [annotations].
  HeimdallRule<ClassMember> beAnnotatedWithAllOf(Iterable<String> annotations) {
    final annotationList = annotations.toNonEmptyList('annotations');
    return satisfy(
      HeimdallCondition.allOf(
        annotationList.map(_memberShouldBeAnnotatedWith),
        description: 'be annotated with all of ${annotationList.join(', ')}',
      ),
    );
  }

  /// Requires members to be annotated with at least one annotation in [annotations].
  HeimdallRule<ClassMember> beAnnotatedWithAnyOf(Iterable<String> annotations) {
    final annotationList = annotations.toNonEmptyList('annotations');
    return satisfy(
      HeimdallCondition.anyOf(
        annotationList.map(_memberShouldBeAnnotatedWith),
        description: 'be annotated with any of ${annotationList.join(', ')}',
      ),
    );
  }

  /// Requires members to be annotated with none of [annotations].
  HeimdallRule<ClassMember> beAnnotatedWithNoneOf(Iterable<String> annotations) {
    final annotationList = annotations.toNonEmptyList('annotations');
    return satisfy(
      HeimdallCondition.noneOf(
        annotationList.map(_memberShouldBeAnnotatedWith),
        description: 'be annotated with none of ${annotationList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<ClassMember> _memberAnnotatedWith(String annotation) {
  return HeimdallPredicate(
    'are annotated with $annotation',
    (item, _) => item.annotations.contains(annotation),
  );
}

HeimdallCondition<ClassMember> _memberShouldBeAnnotatedWith(
  String annotation,
) {
  return memberCondition(
    'be annotated with $annotation',
    (item, _) => item.annotations.contains(annotation),
  );
}
