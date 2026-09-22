import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/field_relationship_queries.dart';

/// Selects fields included in every returned list of a method or getter.
extension MemberIncludedInEveryReturnedListPredicateRules on MemberPredicateBuilder {
  /// Selects fields present in every return of [methodName].
  MemberPredicateBuilder areIncludedInEveryReturnedListOf(String methodName) => satisfy(
    HeimdallPredicate(
      'are included in every returned list of $methodName',
      (item, _) => fieldMatchesMethod(item, methodName, returnedList: true, everyReturn: true),
    ),
  );

  /// Selects fields missing from at least one return of [methodName].
  MemberPredicateBuilder areNotIncludedInEveryReturnedListOf(String methodName) => satisfy(
    HeimdallPredicate(
      'are not included in every returned list of $methodName',
      (item, _) => !fieldMatchesMethod(item, methodName, returnedList: true, everyReturn: true),
    ),
  );
}

/// Checks whether fields occur in every returned list of a method or getter.
extension MemberIncludedInEveryReturnedListShouldRules on MemberShouldBuilder {
  /// Requires each field to occur in every return of [methodName].
  HeimdallRule<ClassMember> beIncludedInEveryReturnedListOf(String methodName) =>
      satisfy(fieldRelationshipCondition(methodName, returnedList: true, everyReturn: true));

  /// Requires a field to be absent from at least one return of [methodName].
  HeimdallRule<ClassMember> notBeIncludedInEveryReturnedListOf(String methodName) =>
      satisfy(fieldRelationshipCondition(methodName, returnedList: true, everyReturn: true, prohibited: true));
}
