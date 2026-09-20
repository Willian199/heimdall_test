import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/core/behavior_rule/heimdall_rule.dart';
import 'package:heimdall_test/src/core/heimdall_condition.dart';
import 'package:heimdall_test/src/core/heimdall_predicate.dart';
import 'package:heimdall_test/src/core/member_rules/member_predicate_builder.dart';
import 'package:heimdall_test/src/core/member_rules/member_should_builder.dart';
import 'package:heimdall_test/src/core/non_empty_iterable.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_member.dart';

/// Predicate-side DSL for raw return or field type rules.
extension MemberHaveReturnTypePredicateRules on MemberPredicateBuilder {
  /// Selects members with textual return or field type [type].
  MemberPredicateBuilder haveReturnType(String type) {
    return satisfy(_memberHasReturnType(type));
  }

  /// Selects members that do not satisfy `haveReturnType`.
  MemberPredicateBuilder noHaveReturnType(String type) {
    return satisfy(
      HeimdallPredicate(
        'not have return type $type',
        (item, project) => item.type != type,
      ),
    );
  }

  /// Selects members with any raw return or field type in [types].
  MemberPredicateBuilder haveReturnTypeAny(Iterable<String> types) {
    final typeList = types.toNonEmptyList('types');
    return satisfy(
      HeimdallPredicate.anyOf(
        typeList.map(_memberHasReturnType),
        description: 'have any raw return type ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects members with every raw return or field type in [types].
  MemberPredicateBuilder haveReturnTypeAll(Iterable<String> types) {
    final typeList = types.toNonEmptyList('types');
    return satisfy(
      HeimdallPredicate.allOf(
        typeList.map(_memberHasReturnType),
        description: 'have all raw return types ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects members with none of the raw return or field types in [types].
  MemberPredicateBuilder haveReturnTypeNone(Iterable<String> types) {
    final typeList = types.toNonEmptyList('types');
    return satisfy(
      HeimdallPredicate.noneOf(
        typeList.map(_memberHasReturnType),
        description: 'have no raw return type ${typeList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for raw return or field type rules.
extension MemberHaveReturnTypeShouldRules on MemberShouldBuilder {
  /// Requires members to have textual return or field type [type].
  HeimdallRule<ClassMember> haveReturnType(String type) {
    return satisfy(_memberShouldHaveReturnType(type));
  }

  /// Requires members not to satisfy `haveReturnType`.
  HeimdallRule<ClassMember> noHaveReturnType(String type) {
    return satisfy(
      prohibitedMemberCondition(
        'have return type $type',
        (item, project) => item.type == type,
      ),
    );
  }

  /// Requires members to have any raw return or field type in [types].
  HeimdallRule<ClassMember> haveReturnTypeAny(Iterable<String> types) {
    final typeList = types.toNonEmptyList('types');
    return satisfy(
      HeimdallCondition.anyOf(
        typeList.map(_memberShouldHaveReturnType),
        description: 'have any raw return type ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires members to have every raw return or field type in [types].
  HeimdallRule<ClassMember> haveReturnTypeAll(Iterable<String> types) {
    final typeList = types.toNonEmptyList('types');
    return satisfy(
      HeimdallCondition.allOf(
        typeList.map(_memberShouldHaveReturnType),
        description: 'have all raw return types ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires members to have none of the raw return or field types in [types].
  HeimdallRule<ClassMember> haveReturnTypeNone(Iterable<String> types) {
    final typeList = types.toNonEmptyList('types');
    return satisfy(
      HeimdallCondition.noneOf(
        typeList.map(_memberShouldHaveReturnType),
        description: 'have no raw return type ${typeList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<ClassMember> _memberHasReturnType(String type) {
  return HeimdallPredicate(
    'have raw return type $type',
    (item, _) => item.type == type,
  );
}

HeimdallCondition<ClassMember> _memberShouldHaveReturnType(String type) {
  return memberCondition(
    'have raw return type $type',
    (item, _) => item.type == type,
  );
}
