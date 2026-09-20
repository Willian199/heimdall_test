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
extension MemberCallConstructorTypeNameStartingWithPredicateRules on MemberPredicateBuilder {
  /// Selects members that call constructor type name starting with [prefix].
  MemberPredicateBuilder callConstructorTypeNameStartingWith(String prefix) {
    return satisfy(_callConstructorTypeNameStartingWithPredicate(prefix));
  }

  /// Selects members that do not satisfy `callConstructorTypeNameStartingWith`.
  MemberPredicateBuilder noCallConstructorTypeNameStartingWith(String prefix) {
    return satisfy(_memberDoesNotCallConstructorTypeNameStartingWith(prefix));
  }

  /// Selects members that call constructor type name starting with every value in [prefixes].
  MemberPredicateBuilder callConstructorTypeNameStartingWithAll(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.allOf(
        valueList.map(_callConstructorTypeNameStartingWithPredicate),
        description: 'call constructor type name starting with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members that call constructor type name starting with at least one value in [prefixes].
  MemberPredicateBuilder callConstructorTypeNameStartingWithAny(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        valueList.map(_callConstructorTypeNameStartingWithPredicate),
        description: 'call constructor type name starting with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects members that call constructor type name starting with none of [prefixes].
  MemberPredicateBuilder callConstructorTypeNameStartingWithNone(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        valueList.map(_callConstructorTypeNameStartingWithPredicate),
        description: 'call constructor type name starting with none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for member pattern rules.
extension MemberCallConstructorTypeNameStartingWithShouldRules on MemberShouldBuilder {
  /// Requires members to call constructor type name starting with [prefix].
  HeimdallRule<ClassMember> callConstructorTypeNameStartingWith(String prefix) {
    return satisfy(_callConstructorTypeNameStartingWithCondition(prefix));
  }

  /// Requires members not to satisfy `callConstructorTypeNameStartingWith`.
  HeimdallRule<ClassMember> noCallConstructorTypeNameStartingWith(String prefix) {
    return satisfy(_memberShouldNotCallConstructorTypeNameStartingWith(prefix));
  }

  /// Requires members to call constructor type name starting with every value in [prefixes].
  HeimdallRule<ClassMember> callConstructorTypeNameStartingWithAll(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(_callConstructorTypeNameStartingWithCondition),
        description: 'call constructor type name starting with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to call constructor type name starting with at least one value in [prefixes].
  HeimdallRule<ClassMember> callConstructorTypeNameStartingWithAny(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(_callConstructorTypeNameStartingWithCondition),
        description: 'call constructor type name starting with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires members to call constructor type name starting with none of [prefixes].
  HeimdallRule<ClassMember> callConstructorTypeNameStartingWithNone(Iterable<String> prefixes) {
    final valueList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(_callConstructorTypeNameStartingWithCondition),
        description: 'call constructor type name starting with none of ${valueList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _callConstructorTypeNameStartingWithCondition(String prefix) {
  return memberCondition(
    'call constructor type name starting with $prefix',
    (item, project) => _memberCallsConstructorTypeName(item, prefix, project),
  );
}

bool _memberCallsConstructorTypeName(ClassMember item, String prefix, HeimdallProject project) {
  return memberHasConstructorCallWhere(item, project, (typeName) => typeName.startsWith(prefix));
}

HeimdallCondition<ClassMember> _memberShouldNotCallConstructorTypeNameStartingWith(String prefix) {
  return prohibitedMemberCondition(
    'call constructor type name starting with $prefix',
    (item, project) => _memberCallsConstructorTypeName(item, prefix, project),
  );
}

HeimdallPredicate<ClassMember> _callConstructorTypeNameStartingWithPredicate(String prefix) {
  return HeimdallPredicate(
    'call constructor type name starting with $prefix',
    (item, project) => _memberCallsConstructorTypeName(item, prefix, project),
  );
}

HeimdallPredicate<ClassMember> _memberDoesNotCallConstructorTypeNameStartingWith(String prefix) {
  return HeimdallPredicate(
    'not call constructor type name starting with $prefix',
    (item, project) => !_memberCallsConstructorTypeName(item, prefix, project),
  );
}
