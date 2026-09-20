import 'package:heimdall_test/heimdall_test.dart';

/// Member groups supported by member rules.
enum MemberSelection {
  /// Selects every class member.
  members,

  /// Selects field declarations.
  fields,

  /// Selects method declarations.
  methods,

  /// Selects constructor declarations.
  constructors,

  /// Selects executable class members, meaning methods and constructors.
  codeUnits,
}

/// DSL entry point for class-member rules.
///
/// This rule family evaluates members declared by imported type declarations.
/// The selected [MemberSelection] determines whether the scope contains all
/// members, fields, methods, constructors, or executable members.
final class MemberRules implements HeimdallRules<MemberPredicateBuilder, MemberShouldBuilder> {
  /// Creates a member rule entry point.
  const MemberRules({required this.inverted, required this.selection});

  /// Whether generated rules should invert their final condition.
  final bool inverted;

  /// Member group selected by this rule entry point.
  final MemberSelection selection;

  /// Starts selecting members with predicates.
  @override
  MemberPredicateBuilder that() {
    return MemberPredicateBuilder(inverted: inverted, selection: selection);
  }

  /// Starts asserting conditions over all members in this scope.
  @override
  MemberShouldBuilder should() {
    return MemberPredicateBuilder(
      inverted: inverted,
      selection: selection,
    ).should();
  }
}
