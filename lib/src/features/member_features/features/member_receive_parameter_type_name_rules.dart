import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/core/behavior_rule/heimdall_rule.dart';
import 'package:heimdall_test/src/core/heimdall_condition.dart';
import 'package:heimdall_test/src/core/heimdall_predicate.dart';
import 'package:heimdall_test/src/core/member_rules/member_predicate_builder.dart';
import 'package:heimdall_test/src/core/member_rules/member_should_builder.dart';
import 'package:heimdall_test/src/core/non_empty_iterable.dart';
import 'package:heimdall_test/src/features/member_features/helpers/member_parameter_type_name_rule_helpers.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Predicate-side DSL for exact executable parameter type-name rules.
extension MemberReceiveParameterTypeNamePredicateRules on MemberPredicateBuilder {
  /// Selects executable members that receive parameter type name [typeName].
  MemberPredicateBuilder receiveParameterTypeName(String typeName) {
    return satisfy(
      HeimdallPredicate(
        'receive parameter type name $typeName',
        (item, project) => memberReceivesResolvedParameterTypeNameWhere(
          item,
          project,
          (parameterTypeName) => parameterTypeName == typeName,
        ),
      ),
    );
  }

  /// Selects members that do not satisfy `receiveParameterTypeName`.
  MemberPredicateBuilder noReceiveParameterTypeName(String typeName) {
    return satisfy(
      HeimdallPredicate(
        'not receive parameter type name $typeName',
        (item, project) => !memberReceivesResolvedParameterTypeNameWhere(
          item,
          project,
          (parameterTypeName) => parameterTypeName == typeName,
        ),
      ),
    );
  }

  /// Selects executable members that receive parameter type name every value in [typeNames].
  MemberPredicateBuilder receiveParameterTypeNameAll(Iterable<String> typeNames) {
    final valueList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.allOf(
        valueList.map(
          (typeName) => HeimdallPredicate(
            'receive parameter type name $typeName',
            (item, project) => memberReceivesResolvedParameterTypeNameWhere(
              item,
              project,
              (parameterTypeName) => parameterTypeName == typeName,
            ),
          ),
        ),
        description: 'receive all parameter type names ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects executable members that receive parameter type name at least one value in [typeNames].
  MemberPredicateBuilder receiveParameterTypeNameAny(Iterable<String> typeNames) {
    final valueList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        valueList.map(
          (typeName) => HeimdallPredicate(
            'receive parameter type name $typeName',
            (item, project) => memberReceivesResolvedParameterTypeNameWhere(
              item,
              project,
              (parameterTypeName) => parameterTypeName == typeName,
            ),
          ),
        ),
        description: 'receive any parameter type name ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects executable members that receive none of the parameter type names in [typeNames].
  MemberPredicateBuilder receiveParameterTypeNameNone(Iterable<String> typeNames) {
    final valueList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        valueList.map(
          (typeName) => HeimdallPredicate(
            'receive parameter type name $typeName',
            (item, project) => memberReceivesResolvedParameterTypeNameWhere(
              item,
              project,
              (parameterTypeName) => parameterTypeName == typeName,
            ),
          ),
        ),
        description: 'receive no parameter type names ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for exact executable parameter type-name rules.
extension MemberReceiveParameterTypeNameShouldRules on MemberShouldBuilder {
  /// Requires executable members to receive parameter type name [typeName].
  HeimdallRule<ClassMember> receiveParameterTypeName(String typeName) {
    return satisfy(
      memberCondition(
        'receive parameter type name $typeName',
        (item, project) => memberReceivesResolvedParameterTypeNameWhere(
          item,
          project,
          (parameterTypeName) => parameterTypeName == typeName,
        ),
      ),
    );
  }

  /// Requires members not to satisfy `receiveParameterTypeName`.
  HeimdallRule<ClassMember> noReceiveParameterTypeName(String typeName) {
    return satisfy(
      prohibitedMemberCondition(
        'receive parameter type name $typeName',
        (item, project) => memberReceivesResolvedParameterTypeNameWhere(
          item,
          project,
          (parameterTypeName) => parameterTypeName == typeName,
        ),
      ),
    );
  }

  /// Requires executable members to receive parameter type name every value in [typeNames].
  HeimdallRule<ClassMember> receiveParameterTypeNameAll(Iterable<String> typeNames) {
    final valueList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(
          (typeName) => memberCondition(
            'receive parameter type name $typeName',
            (item, project) => memberReceivesResolvedParameterTypeNameWhere(
              item,
              project,
              (parameterTypeName) => parameterTypeName == typeName,
            ),
          ),
        ),
        description: 'receive all parameter type names ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires executable members to receive parameter type name at least one value in [typeNames].
  HeimdallRule<ClassMember> receiveParameterTypeNameAny(Iterable<String> typeNames) {
    final valueList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(
          (typeName) => memberCondition(
            'receive parameter type name $typeName',
            (item, project) => memberReceivesResolvedParameterTypeNameWhere(
              item,
              project,
              (parameterTypeName) => parameterTypeName == typeName,
            ),
          ),
        ),
        description: 'receive any parameter type name ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires executable members to receive none of the parameter type names in [typeNames].
  HeimdallRule<ClassMember> receiveParameterTypeNameNone(Iterable<String> typeNames) {
    final valueList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(
          (typeName) => memberCondition(
            'receive parameter type name $typeName',
            (item, project) => memberReceivesResolvedParameterTypeNameWhere(
              item,
              project,
              (parameterTypeName) => parameterTypeName == typeName,
            ),
          ),
        ),
        description: 'receive no parameter type names ${valueList.join(', ')}',
      ),
    );
  }
}
