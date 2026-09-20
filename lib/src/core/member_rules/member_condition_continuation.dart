import 'package:heimdall_test/heimdall_test.dart';

/// Continues a member condition chain after a rule condition was added.
extension MemberConditionChain on HeimdallRule<ClassMember> {
  /// Combines the next member condition with logical `and`.
  MemberShouldBuilder and() {
    return MemberShouldBuilder.fromRule(this, useOr: false);
  }

  /// Combines the next member condition with logical `or`.
  MemberShouldBuilder or() {
    return MemberShouldBuilder.fromRule(this, useOr: true);
  }
}
