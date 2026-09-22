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
extension MemberAnnotatedWithTypeNameStartingWithPredicateRules on MemberPredicateBuilder {
  /// Selects members that annotated with type name starting with [prefix].
  MemberPredicateBuilder areAnnotatedWithTypeNameStartingWith(String prefix) {
    return satisfy(_annotatedWithTypeNameStartingWithPredicate(prefix));
  }

  /// Selects members that do not satisfy `areAnnotatedWithTypeNameStartingWith`.
  MemberPredicateBuilder areNotAnnotatedWithTypeNameStartingWith(String prefix) {
    return satisfy(_memberDoesNotBeAnnotatedWithTypeNameStartingWith(prefix));
  }

  /// Selects members that annotated with type name starting with every value in [prefixes].
  MemberPredicateBuilder areAnnotatedWithTypeNameStartingWithAllOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.allOf(
        valueList.map(_annotatedWithTypeNameStartingWithPredicate),
        description: 'are annotated with type name starting with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members that annotated with type name starting with at least one value in [prefixes].
  MemberPredicateBuilder areAnnotatedWithTypeNameStartingWithAnyOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        valueList.map(_annotatedWithTypeNameStartingWithPredicate),
        description: 'are annotated with type name starting with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members that annotated with type name starting with none of [prefixes].
  MemberPredicateBuilder areAnnotatedWithTypeNameStartingWithNoneOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        valueList.map(_annotatedWithTypeNameStartingWithPredicate),
        description: 'are annotated with type name starting with none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member pattern rules.
extension MemberAnnotatedWithTypeNameStartingWithShouldRules on MemberShouldBuilder {
  /// Requires members to annotated with type name starting with [prefix].
  HeimdallRule<ClassMember> beAnnotatedWithTypeNameStartingWith(String prefix) {
    return satisfy(_annotatedWithTypeNameStartingWithCondition(prefix));
  }

  /// Requires members not to satisfy `beAnnotatedWithTypeNameStartingWith`.
  HeimdallRule<ClassMember> notBeAnnotatedWithTypeNameStartingWith(String prefix) {
    return satisfy(_memberShouldNotBeAnnotatedWithTypeNameStartingWith(prefix));
  }

  /// Requires members to annotated with type name starting with every value in [prefixes].
  HeimdallRule<ClassMember> beAnnotatedWithTypeNameStartingWithAllOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_annotatedWithTypeNameStartingWithCondition),
        description: 'are annotated with type name starting with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to annotated with type name starting with at least one value in [prefixes].
  HeimdallRule<ClassMember> beAnnotatedWithTypeNameStartingWithAnyOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_annotatedWithTypeNameStartingWithCondition),
        description: 'are annotated with type name starting with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to annotated with type name starting with none of [prefixes].
  HeimdallRule<ClassMember> beAnnotatedWithTypeNameStartingWithNoneOf(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(_annotatedWithTypeNameStartingWithCondition),
        description: 'are annotated with type name starting with none of ${valueList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _annotatedWithTypeNameStartingWithCondition(String prefix) {
  return memberCondition(
    'annotated with type name starting with $prefix',
    (item, _) => item.annotations.any((annotation) => annotation.startsWith(prefix)),
  );
}

HeimdallCondition<ClassMember> _memberShouldNotBeAnnotatedWithTypeNameStartingWith(String prefix) {
  return prohibitedMemberCondition(
    'be annotated with type name starting with $prefix',
    (item, _) => item.annotations.any((annotation) => annotation.startsWith(prefix)),
  );
}

HeimdallPredicate<ClassMember> _annotatedWithTypeNameStartingWithPredicate(String prefix) {
  return HeimdallPredicate(
    'be annotated with type name starting with $prefix',
    (item, _) => item.annotations.any((annotation) => annotation.startsWith(prefix)),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotBeAnnotatedWithTypeNameStartingWith(String prefix) {
  return HeimdallPredicate(
    'not be annotated with type name starting with $prefix',
    (item, _) => item.annotations.every((annotation) => !annotation.startsWith(prefix)),
  );
}
