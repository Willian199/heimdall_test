import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/core/behavior_rule/heimdall_rule.dart';
import 'package:heimdall_test/src/core/heimdall_condition.dart';
import 'package:heimdall_test/src/core/heimdall_predicate.dart';
import 'package:heimdall_test/src/core/member_rules/member_predicate_builder.dart';
import 'package:heimdall_test/src/core/member_rules/member_should_builder.dart';
import 'package:heimdall_test/src/core/non_empty_iterable.dart';
import 'package:heimdall_test/src/features/member_features/helpers/member_declared_type_name_rule_helpers.dart';

/// Predicate-side DSL for field declared type-name suffix rules.
extension MemberHaveDeclaredTypeNameEndingWithPredicateRules on MemberPredicateBuilder {
  /// Selects fields whose declared type name ends with [suffix].
  MemberPredicateBuilder haveDeclaredTypeNameEndingWith(String suffix) {
    return satisfy(
      memberDeclaredTypeNamePredicate(
        'have declared type name ending with $suffix',
        (typeName) => typeName.endsWith(suffix),
      ),
    );
  }

  /// Selects members that do not satisfy `haveDeclaredTypeNameEndingWith`.
  MemberPredicateBuilder noHaveDeclaredTypeNameEndingWith(String suffix) {
    return satisfy(
      memberDoesNotHaveDeclaredTypeNamePredicate(
        'have declared type name ending with $suffix',
        (typeName) => typeName.endsWith(suffix),
      ),
    );
  }

  /// Selects fields whose declared type name ends with any value in [suffixes].
  MemberPredicateBuilder haveDeclaredTypeNameEndingWithAny(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        valueList.map(
          (suffix) => memberDeclaredTypeNamePredicate(
            'have declared type name ending with $suffix',
            (typeName) => typeName.endsWith(suffix),
          ),
        ),
        description: 'have declared type name ending with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects fields whose declared type name ends with every value in [suffixes].
  MemberPredicateBuilder haveDeclaredTypeNameEndingWithAll(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.allOf(
        valueList.map(
          (suffix) => memberDeclaredTypeNamePredicate(
            'have declared type name ending with $suffix',
            (typeName) => typeName.endsWith(suffix),
          ),
        ),
        description: 'have declared type name ending with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Selects fields whose declared type name ends with none of [suffixes].
  MemberPredicateBuilder haveDeclaredTypeNameEndingWithNone(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        valueList.map(
          (suffix) => memberDeclaredTypeNamePredicate(
            'have declared type name ending with $suffix',
            (typeName) => typeName.endsWith(suffix),
          ),
        ),
        description: 'have declared type name ending with none of ${valueList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for field declared type-name suffix rules.
extension MemberHaveDeclaredTypeNameEndingWithShouldRules on MemberShouldBuilder {
  /// Requires fields to have a declared type name ending with [suffix].
  HeimdallRule<ClassMember> haveDeclaredTypeNameEndingWith(String suffix) {
    return satisfy(
      memberDeclaredTypeNameCondition(
        'have declared type name ending with $suffix',
        (typeName) => typeName.endsWith(suffix),
      ),
    );
  }

  /// Requires members not to satisfy `haveDeclaredTypeNameEndingWith`.
  HeimdallRule<ClassMember> noHaveDeclaredTypeNameEndingWith(String suffix) {
    return satisfy(
      memberMustNotHaveDeclaredTypeNameCondition(
        'have declared type name ending with $suffix',
        (typeName) => typeName.endsWith(suffix),
      ),
    );
  }

  /// Requires fields to have a declared type name ending with any value in [suffixes].
  HeimdallRule<ClassMember> haveDeclaredTypeNameEndingWithAny(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.anyOf(
        valueList.map(
          (suffix) => memberDeclaredTypeNameCondition(
            'have declared type name ending with $suffix',
            (typeName) => typeName.endsWith(suffix),
          ),
        ),
        description: 'have declared type name ending with any of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires fields to have a declared type name ending with every value in [suffixes].
  HeimdallRule<ClassMember> haveDeclaredTypeNameEndingWithAll(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.allOf(
        valueList.map(
          (suffix) => memberDeclaredTypeNameCondition(
            'have declared type name ending with $suffix',
            (typeName) => typeName.endsWith(suffix),
          ),
        ),
        description: 'have declared type name ending with all of ${valueList.join(', ')}',
      ),
    );
  }

  /// Requires fields to have a declared type name ending with none of [suffixes].
  HeimdallRule<ClassMember> haveDeclaredTypeNameEndingWithNone(Iterable<String> suffixes) {
    final valueList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.noneOf(
        valueList.map(
          (suffix) => memberDeclaredTypeNameCondition(
            'have declared type name ending with $suffix',
            (typeName) => typeName.endsWith(suffix),
          ),
        ),
        description: 'have declared type name ending with none of ${valueList.join(', ')}',
      ),
    );
  }
}
