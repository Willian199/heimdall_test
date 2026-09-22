import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/core/behavior_rule/heimdall_rule.dart';
import 'package:heimdall_test/src/core/heimdall_condition.dart';
import 'package:heimdall_test/src/core/heimdall_predicate.dart';
import 'package:heimdall_test/src/core/member_rules/member_predicate_builder.dart';
import 'package:heimdall_test/src/core/member_rules/member_should_builder.dart';
import 'package:heimdall_test/src/core/non_empty_iterable.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_member.dart';

/// Predicate-side DSL for extension owner rules.
extension MemberDeclaredInExtensionsPredicateRules on MemberPredicateBuilder {
  /// Selects members declared in extensions on [extendedType].
  MemberPredicateBuilder areDeclaredInExtensions(String extendedType) {
    return satisfy(_memberMatchesBeDeclaredInExtensions(extendedType));
  }

  /// Selects members that do not satisfy `areDeclaredInExtensions`.
  MemberPredicateBuilder areNotDeclaredInExtensions(String extendedType) {
    return satisfy(
      HeimdallPredicate(
        'not be declared in extension on $extendedType',
        (item, project) => !_isDeclaredInExtension(item, extendedType),
      ),
    );
  }

  /// Selects members declared in extensions on every type in [extendedTypes].
  MemberPredicateBuilder areDeclaredInAllExtensions(
    Iterable<String> extendedTypes,
  ) {
    final typeList = extendedTypes.toNonEmptyList('extendedTypes');
    return satisfy(
      HeimdallPredicate.allOf(
        typeList.map(_memberMatchesBeDeclaredInExtensions),
        description: 'be declared in extensions on all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in extensions on at least one type in [extendedTypes].
  MemberPredicateBuilder areDeclaredInAnyExtensions(
    Iterable<String> extendedTypes,
  ) {
    final typeList = extendedTypes.toNonEmptyList('extendedTypes');
    return satisfy(
      HeimdallPredicate.anyOf(
        typeList.map(_memberMatchesBeDeclaredInExtensions),
        description: 'be declared in extension on any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects members declared in extensions on none of [extendedTypes].
  MemberPredicateBuilder areDeclaredInNoExtensions(
    Iterable<String> extendedTypes,
  ) {
    final typeList = extendedTypes.toNonEmptyList('extendedTypes');
    return satisfy(
      HeimdallPredicate.noneOf(
        typeList.map(_memberMatchesBeDeclaredInExtensions),
        description: 'be declared in extensions on none of ${typeList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for extension owner rules.
extension MemberDeclaredInExtensionsShouldRules on MemberShouldBuilder {
  /// Requires members to be declared in extensions on [extendedType].
  HeimdallRule<ClassMember> beDeclaredInExtensions(String extendedType) {
    return satisfy(_memberShouldBeDeclaredInExtensions(extendedType));
  }

  /// Requires members not to satisfy `beDeclaredInExtensions`.
  HeimdallRule<ClassMember> notBeDeclaredInExtensions(String extendedType) {
    return satisfy(
      prohibitedMemberCondition(
        'be declared in extensions on $extendedType',
        (item, project) => _isDeclaredInExtension(item, extendedType),
      ),
    );
  }

  /// Requires members to be declared in extensions on every type in [extendedTypes].
  HeimdallRule<ClassMember> beDeclaredInAllExtensions(
    Iterable<String> extendedTypes,
  ) {
    final typeList = extendedTypes.toNonEmptyList('extendedTypes');
    return satisfy(
      HeimdallCondition.allOf(
        typeList.map(_memberShouldBeDeclaredInExtensions),
        description: 'be declared in extensions on all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in extensions on at least one type in [extendedTypes].
  HeimdallRule<ClassMember> beDeclaredInAnyExtensions(
    Iterable<String> extendedTypes,
  ) {
    final typeList = extendedTypes.toNonEmptyList('extendedTypes');
    return satisfy(
      HeimdallCondition.anyOf(
        typeList.map(_memberShouldBeDeclaredInExtensions),
        description: 'be declared in extension on any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires members to be declared in extensions on none of [extendedTypes].
  HeimdallRule<ClassMember> beDeclaredInNoExtensions(
    Iterable<String> extendedTypes,
  ) {
    final typeList = extendedTypes.toNonEmptyList('extendedTypes');
    return satisfy(
      HeimdallCondition.noneOf(
        typeList.map(_memberShouldBeDeclaredInExtensions),
        description: 'be declared in extensions on none of ${typeList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<ClassMember> _memberShouldBeDeclaredInExtensions(
  String extendedType,
) {
  return memberCondition(
    'be declared in extension on $extendedType',
    (item, _) => _isDeclaredInExtension(item, extendedType),
  );
}

bool _isDeclaredInExtension(ClassMember item, String extendedType) {
  final owner = item.owner;
  return owner is ExtensionDeclaration && owner.onClause?.extendedType.toSource() == extendedType;
}

HeimdallPredicate<ClassMember> _memberMatchesBeDeclaredInExtensions(
  String extendedType,
) {
  return HeimdallPredicate(
    'be declared in extension on $extendedType',
    (item, project) => _isDeclaredInExtension(item, extendedType),
  );
}
