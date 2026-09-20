import 'package:heimdall_test/heimdall_test.dart';

/// Fluent predicate builder for class-member rules.
///
/// Each predicate narrows the members that the later condition chain will
/// validate. The default selection is every member in the configured member
/// scope.
final class MemberPredicateBuilder implements HeimdallPredicateBuilder<ClassMember, MemberPredicateBuilder, MemberShouldBuilder> {
  /// Creates a member predicate builder.
  MemberPredicateBuilder({required this.inverted, required this.selection});

  /// Whether generated rules should invert their final condition.
  final bool inverted;

  /// Member group selected by this builder.
  final MemberSelection selection;
  HeimdallPredicate<ClassMember> _predicate = alwaysMember;
  bool _useOr = false;
  bool _negateNext = false;

  @override
  MemberPredicateBuilder and() {
    _useOr = false;
    return this;
  }

  @override
  MemberPredicateBuilder or() {
    _useOr = true;
    return this;
  }

  @override
  MemberPredicateBuilder not() {
    assert(!_negateNext, 'not() called twice in sequence');
    _negateNext = true;
    return this;
  }

  @override
  MemberPredicateBuilder satisfy(HeimdallPredicate<ClassMember> predicate) {
    final nextPredicate = _negateNext ? predicate.not() : predicate;
    _predicate = _predicate == alwaysMember && !_useOr ? nextPredicate : (_useOr ? _predicate.or(nextPredicate) : _predicate.and(nextPredicate));
    _useOr = false;
    _negateNext = false;
    return this;
  }

  /// Selects public members.
  MemberPredicateBuilder arePublic() => satisfy(
    HeimdallPredicate('are public', (item, _) => item.isPublic),
  );

  /// Selects private members.
  MemberPredicateBuilder arePrivate() => satisfy(
    HeimdallPredicate('are private', (item, _) => item.isPrivate),
  );

  /// Selects final fields.
  MemberPredicateBuilder areFinal() => satisfy(
    HeimdallPredicate('are final', (item, _) => item.isFinal),
  );

  /// Selects static fields and methods.
  MemberPredicateBuilder areStatic() => satisfy(
    HeimdallPredicate('are static', (item, _) => item.isStatic),
  );

  @override
  MemberShouldBuilder should() {
    return MemberShouldBuilder(
      predicate: _predicate,
      inverted: inverted,
      selection: selection,
    );
  }

  /// Predicate that accepts every member.
  static const alwaysMember = HeimdallPredicate<ClassMember>(
    'all members',
    _alwaysMemberPredicate,
  );

  static bool _alwaysMemberPredicate(ClassMember _, HeimdallProject project) => true;
}
