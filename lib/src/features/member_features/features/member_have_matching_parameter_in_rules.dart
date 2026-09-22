import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/field_relationship_queries.dart';

/// Predicate-side have a matching parameter in rules.
extension MemberHaveMatchingParameterInPredicateRules on MemberPredicateBuilder {
  /// Matches the relation in the same owner.
  MemberPredicateBuilder haveMatchingParameterIn(String methodName) => satisfy(_matches(methodName));

  /// Rejects the relation in the same owner.
  MemberPredicateBuilder notHaveMatchingParameterIn(String methodName) => satisfy(_matches(methodName, prohibited: true));

  /// Matches all of [methodNames].
  MemberPredicateBuilder haveMatchingParameterInAllMethods(Iterable<String> methodNames) {
    final values = methodNames.toNonEmptyList('methodNames');
    return satisfy(HeimdallPredicate.allOf(values.map(_matches)));
  }

  /// Matches any of [methodNames].
  MemberPredicateBuilder haveMatchingParameterInAnyMethod(Iterable<String> methodNames) {
    final values = methodNames.toNonEmptyList('methodNames');
    return satisfy(HeimdallPredicate.anyOf(values.map(_matches)));
  }

  /// Matches none of [methodNames].
  MemberPredicateBuilder haveMatchingParameterInNoMethods(Iterable<String> methodNames) {
    final values = methodNames.toNonEmptyList('methodNames');
    return satisfy(HeimdallPredicate.noneOf(values.map(_matches)));
  }
}

/// Should-side have a matching parameter in rules.
extension MemberHaveMatchingParameterInShouldRules on MemberShouldBuilder {
  /// Matches the relation in the same owner.
  HeimdallRule<ClassMember> haveMatchingParameterIn(String methodName) => satisfy(_requires(methodName));

  /// Rejects the relation in the same owner.
  HeimdallRule<ClassMember> notHaveMatchingParameterIn(String methodName) => satisfy(_requires(methodName, prohibited: true));

  /// Matches all of [methodNames].
  HeimdallRule<ClassMember> haveMatchingParameterInAllMethods(Iterable<String> methodNames) {
    final values = methodNames.toNonEmptyList('methodNames');
    return satisfy(HeimdallCondition.allOf(values.map(_requires)));
  }

  /// Matches any of [methodNames].
  HeimdallRule<ClassMember> haveMatchingParameterInAnyMethod(Iterable<String> methodNames) {
    final values = methodNames.toNonEmptyList('methodNames');
    return satisfy(HeimdallCondition.anyOf(values.map(_requires)));
  }

  /// Matches none of [methodNames].
  HeimdallRule<ClassMember> haveMatchingParameterInNoMethods(Iterable<String> methodNames) {
    final values = methodNames.toNonEmptyList('methodNames');
    return satisfy(HeimdallCondition.noneOf(values.map(_requires)));
  }
}

HeimdallPredicate<ClassMember> _matches(
  String methodName, {
  bool prohibited = false,
}) {
  return HeimdallPredicate(
    '${prohibited ? 'not ' : ''}have a matching parameter in $methodName',
    (item, _) => prohibited ? !fieldMatchesMethod(item, methodName, returnedList: false) : fieldMatchesMethod(item, methodName, returnedList: false),
  );
}

HeimdallCondition<ClassMember> _requires(
  String methodName, {
  bool prohibited = false,
}) {
  return fieldRelationshipCondition(methodName, returnedList: false, prohibited: prohibited);
}
