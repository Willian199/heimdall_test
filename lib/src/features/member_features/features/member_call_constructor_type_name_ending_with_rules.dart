import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/core/behavior_rule/heimdall_rule.dart';
import 'package:heimdall_test/src/core/heimdall_condition.dart';
import 'package:heimdall_test/src/core/heimdall_predicate.dart';
import 'package:heimdall_test/src/core/member_rules/member_predicate_builder.dart';
import 'package:heimdall_test/src/core/member_rules/member_should_builder.dart';
import 'package:heimdall_test/src/core/non_empty_iterable.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_project.dart';

/// Predicate-side DSL for member pattern rules.
extension MemberCallConstructorTypeNameEndingWithPredicateRules on MemberPredicateBuilder {
  /// Selects members that call constructor type name ending with [suffix].
  MemberPredicateBuilder callConstructorTypeNameEndingWith(String suffix) {
    return satisfy(_callConstructorTypeNameEndingWithPredicate(suffix));
  }

  /// Selects members that do not satisfy `callConstructorTypeNameEndingWith`.
  MemberPredicateBuilder notCallConstructorTypeNameEndingWith(String suffix) {
    return satisfy(
      HeimdallPredicate(
        'not call constructor type name ending with $suffix',
        (item, project) => !_memberCallsConstructorTypeName(item, suffix, project),
      ),
    );
  }

  /// Selects members that call constructor type name ending with every value in [suffixes].
  MemberPredicateBuilder callConstructorTypeNameEndingWithAllOf(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.allOf(
        valueList.map(_callConstructorTypeNameEndingWithPredicate),
        description: 'call constructor type name ending with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members that call constructor type name ending with at least one value in [suffixes].
  MemberPredicateBuilder callConstructorTypeNameEndingWithAnyOf(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        valueList.map(_callConstructorTypeNameEndingWithPredicate),
        description: 'call constructor type name ending with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members that call constructor type name ending with none of [suffixes].
  MemberPredicateBuilder callConstructorTypeNameEndingWithNoneOf(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        valueList.map(_callConstructorTypeNameEndingWithPredicate),
        description: 'call constructor type name ending with none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member pattern rules.
extension MemberCallConstructorTypeNameEndingWithShouldRules on MemberShouldBuilder {
  /// Requires members to call constructor type name ending with [suffix].
  HeimdallRule<ClassMember> callConstructorTypeNameEndingWith(String suffix) {
    return satisfy(_callConstructorTypeNameEndingWithCondition(suffix));
  }

  /// Requires members not to satisfy `callConstructorTypeNameEndingWith`.
  HeimdallRule<ClassMember> notCallConstructorTypeNameEndingWith(String suffix) {
    return satisfy(
      prohibitedMemberCondition(
        'call constructor type name ending with $suffix',
        (item, project) => _memberCallsConstructorTypeName(item, suffix, project),
      ),
    );
  }

  /// Requires members to call constructor type name ending with every value in [suffixes].
  HeimdallRule<ClassMember> callConstructorTypeNameEndingWithAllOf(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_callConstructorTypeNameEndingWithCondition),
        description: 'call constructor type name ending with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to call constructor type name ending with at least one value in [suffixes].
  HeimdallRule<ClassMember> callConstructorTypeNameEndingWithAnyOf(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_callConstructorTypeNameEndingWithCondition),
        description: 'call constructor type name ending with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to call constructor type name ending with none of [suffixes].
  HeimdallRule<ClassMember> callConstructorTypeNameEndingWithNoneOf(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(_callConstructorTypeNameEndingWithCondition),
        description: 'call constructor type name ending with none of ${valueList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _callConstructorTypeNameEndingWithCondition(String suffix) {
  return memberCondition(
    'call constructor type name ending with $suffix',
    (item, project) => _memberCallsConstructorTypeName(item, suffix, project),
  );
}

bool _memberCallsConstructorTypeName(ClassMember item, String suffix, HeimdallProject project) {
  return memberHasConstructorCallWhere(item, project, (typeName) => typeName.endsWith(suffix));
}

HeimdallPredicate<ClassMember> _callConstructorTypeNameEndingWithPredicate(String suffix) {
  return HeimdallPredicate(
    'call constructor type name ending with $suffix',
    (item, project) => _memberCallsConstructorTypeName(item, suffix, project),
  );
}
