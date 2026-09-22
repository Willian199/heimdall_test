import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/field_relationship_queries.dart';

/// Predicate-side be included in a returned list of rules.
extension MemberBeIncludedInReturnedListOfPredicateRules on MemberPredicateBuilder {
  /// Matches the relation in the same owner.
  MemberPredicateBuilder areIncludedInReturnedListOf(String methodName) => satisfy(_matches(methodName));

  /// Rejects the relation in the same owner.
  MemberPredicateBuilder areNotIncludedInReturnedListOf(String methodName) => satisfy(_matches(methodName, prohibited: true));

  /// Matches all of [methodNames].
  MemberPredicateBuilder areIncludedInReturnedListOfAllMethods(Iterable<String> methodNames) {
    final values = methodNames.toNonEmptyList('methodNames');
    return satisfy(HeimdallPredicate.allOf(values.map(_matches)));
  }

  /// Matches any of [methodNames].
  MemberPredicateBuilder areIncludedInReturnedListOfAnyMethod(Iterable<String> methodNames) {
    final values = methodNames.toNonEmptyList('methodNames');
    return satisfy(HeimdallPredicate.anyOf(values.map(_matches)));
  }

  /// Matches none of [methodNames].
  MemberPredicateBuilder areIncludedInReturnedListOfNoMethods(Iterable<String> methodNames) {
    final values = methodNames.toNonEmptyList('methodNames');
    return satisfy(HeimdallPredicate.noneOf(values.map(_matches)));
  }
}

/// Should-side be included in a returned list of rules.
extension MemberBeIncludedInReturnedListOfShouldRules on MemberShouldBuilder {
  /// Matches the relation in the same owner.
  HeimdallRule<ClassMember> beIncludedInReturnedListOf(String methodName) => satisfy(_requires(methodName));

  /// Rejects the relation in the same owner.
  HeimdallRule<ClassMember> notBeIncludedInReturnedListOf(String methodName) => satisfy(_requires(methodName, prohibited: true));

  /// Matches all of [methodNames].
  HeimdallRule<ClassMember> beIncludedInReturnedListOfAllMethods(Iterable<String> methodNames) {
    final values = methodNames.toNonEmptyList('methodNames');
    return satisfy(HeimdallCondition.allOf(values.map(_requires)));
  }

  /// Matches any of [methodNames].
  HeimdallRule<ClassMember> beIncludedInReturnedListOfAnyMethod(Iterable<String> methodNames) {
    final values = methodNames.toNonEmptyList('methodNames');
    return satisfy(HeimdallCondition.anyOf(values.map(_requires)));
  }

  /// Matches none of [methodNames].
  HeimdallRule<ClassMember> beIncludedInReturnedListOfNoMethods(Iterable<String> methodNames) {
    final values = methodNames.toNonEmptyList('methodNames');
    return satisfy(HeimdallCondition.noneOf(values.map(_requires)));
  }
}

HeimdallPredicate<ClassMember> _matches(
  String methodName, {
  bool prohibited = false,
}) {
  return HeimdallPredicate(
    '${prohibited ? 'not ' : ''}be included in a returned list of $methodName',
    (item, _) => prohibited ? !fieldMatchesMethod(item, methodName, returnedList: true) : fieldMatchesMethod(item, methodName, returnedList: true),
  );
}

HeimdallCondition<ClassMember> _requires(
  String methodName, {
  bool prohibited = false,
}) {
  return fieldRelationshipCondition(methodName, returnedList: true, prohibited: prohibited);
}
