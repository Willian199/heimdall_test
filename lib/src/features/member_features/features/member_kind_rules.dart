import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/member_queries.dart';

/// Kinds of class members that can be selected by member rules.
enum MemberKind {
  /// A method declaration.
  method,

  /// Any constructor declaration.
  constructor,

  /// A factory constructor declaration.
  factoryConstructor,

  /// A generative constructor declaration.
  generativeConstructor,
}

/// Predicate-side DSL for member kind rules.
extension MemberKindPredicateRules on MemberPredicateBuilder {
  /// Selects members with [kind].
  MemberPredicateBuilder areKind(MemberKind kind) => satisfy(_memberIsKind(kind));

  /// Selects members that do not satisfy `areKind`.
  MemberPredicateBuilder noAreKind(MemberKind kind) {
    return satisfy(
      HeimdallPredicate(
        'not be ${kind.name}',
        (item, project) => !_matchesKind(item, kind),
      ),
    );
  }

  /// Selects members with every kind in [kinds].
  MemberPredicateBuilder areAllKinds(Iterable<MemberKind> kinds) {
    final kindList = kinds.toNonEmptyList('kinds');
    return satisfy(HeimdallPredicate.allOf(kindList.map(_memberIsKind), description: 'are all kinds ${kindList.join(', ')}'));
  }

  /// Selects members with at least one kind in [kinds].
  MemberPredicateBuilder areAnyKind(Iterable<MemberKind> kinds) {
    final kindList = kinds.toNonEmptyList('kinds');
    return satisfy(HeimdallPredicate.anyOf(kindList.map(_memberIsKind), description: 'are any kind ${kindList.join(', ')}'));
  }

  /// Selects members with none of [kinds].
  MemberPredicateBuilder areNoKinds(Iterable<MemberKind> kinds) {
    final kindList = kinds.toNonEmptyList('kinds');
    return satisfy(HeimdallPredicate.noneOf(kindList.map(_memberIsKind), description: 'are no kinds ${kindList.join(', ')}'));
  }
}

/// Condition-side DSL for member kind rules.
extension MemberKindShouldRules on MemberShouldBuilder {
  /// Requires members to have [kind].
  HeimdallRule<ClassMember> beKind(MemberKind kind) => satisfy(_memberShouldBeKind(kind));

  /// Requires members not to satisfy `beKind`.
  HeimdallRule<ClassMember> noBeKind(MemberKind kind) {
    return satisfy(
      prohibitedMemberCondition(
        'be ${kind.name}',
        (item, _) => _matchesKind(item, kind),
      ),
    );
  }

  /// Requires members to have every kind in [kinds].
  HeimdallRule<ClassMember> beAllKinds(Iterable<MemberKind> kinds) {
    final kindList = kinds.toNonEmptyList('kinds');
    return satisfy(HeimdallCondition.allOf(kindList.map(_memberShouldBeKind), description: 'be all kinds ${kindList.join(', ')}'));
  }

  /// Requires members to have at least one kind in [kinds].
  HeimdallRule<ClassMember> beAnyKind(Iterable<MemberKind> kinds) {
    final kindList = kinds.toNonEmptyList('kinds');
    return satisfy(HeimdallCondition.anyOf(kindList.map(_memberShouldBeKind), description: 'be any kind ${kindList.join(', ')}'));
  }

  /// Requires members to have none of [kinds].
  HeimdallRule<ClassMember> beNoKinds(Iterable<MemberKind> kinds) {
    final kindList = kinds.toNonEmptyList('kinds');
    return satisfy(HeimdallCondition.noneOf(kindList.map(_memberShouldBeKind), description: 'be no kinds ${kindList.join(', ')}'));
  }
}

HeimdallPredicate<ClassMember> _memberIsKind(MemberKind kind) {
  return HeimdallPredicate('are ${kind.name}', (item, _) => _matchesKind(item, kind));
}

HeimdallCondition<ClassMember> _memberShouldBeKind(MemberKind kind) {
  return memberCondition('be ${kind.name}', (item, _) => _matchesKind(item, kind));
}

bool _matchesKind(ClassMember item, MemberKind kind) {
  return switch (kind) {
    MemberKind.method => item.isMethod,
    MemberKind.constructor => item.isConstructor,
    MemberKind.factoryConstructor => item.isConstructor && item.isFactory,
    MemberKind.generativeConstructor => item.isConstructor && !item.isFactory,
  };
}
