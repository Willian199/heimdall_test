import 'package:heimdall_test/heimdall_test.dart';

/// Fluent condition builder for class-member rules.
///
/// Conditions are evaluated for each member selected by the member rule scope
/// and predicate chain.
final class MemberShouldBuilder implements HeimdallShouldBuilder<ClassMember, MemberShouldBuilder> {
  /// Creates a member condition builder.
  MemberShouldBuilder({
    required this.predicate,
    required this.inverted,
    required this.selection,
  }) : _descriptionPrefix = null,
       _selectorOverride = null,
       _failOnEmptySelection = true;

  /// Creates a member condition builder that continues an existing [rule].
  MemberShouldBuilder.fromRule(
    HeimdallRule<ClassMember> rule, {
    required bool useOr,
  }) : predicate = rule.predicate,
       inverted = rule.inverted,
       selection = rule.continuationContext is MemberSelection ? rule.continuationContext! : MemberSelection.members,
       _condition = rule.condition,
       _useOr = useOr,
       _descriptionPrefix = rule.descriptionPrefix ?? rule.description,
       _selectorOverride = rule.selector,
       _failOnEmptySelection = rule.failOnEmptySelection;

  /// Predicate that selects checked members.
  final HeimdallPredicate<ClassMember> predicate;

  /// Whether generated rules should invert their final condition.
  final bool inverted;

  /// Member group selected by this builder.
  final MemberSelection selection;
  HeimdallCondition<ClassMember>? _condition;
  bool _useOr = false;
  bool _negateNext = false;
  final String? _descriptionPrefix;
  final Selector<ClassMember>? _selectorOverride;
  bool _failOnEmptySelection;

  @override
  MemberShouldBuilder andShould() {
    _useOr = false;
    return this;
  }

  @override
  MemberShouldBuilder orShould() {
    _useOr = true;
    return this;
  }

  @override
  MemberShouldBuilder not() {
    assert(!_negateNext, 'not() called twice in sequence');
    _negateNext = true;
    return this;
  }

  /// Allows the generated rule to select no members.
  MemberShouldBuilder allowEmpty() => failOnEmpty(false);

  /// Configures whether the generated rule should fail on an empty selection.
  MemberShouldBuilder failOnEmpty(bool value) {
    _failOnEmptySelection = value;
    return this;
  }

  @override
  HeimdallRule<ClassMember> satisfy(HeimdallCondition<ClassMember> condition) {
    final nextCondition = _negateNext ? condition.not() : condition;
    _condition = _condition == null
        ? nextCondition
        : _useOr
        ? _condition!.or(nextCondition)
        : _condition!.and(nextCondition);
    _useOr = false;
    _negateNext = false;
    return _build();
  }

  /// Requires members to be public.
  HeimdallRule<ClassMember> bePublic() => satisfy(
    _memberFlagCondition('be public', (item) => item.isPublic),
  );

  /// Requires members to be private.
  HeimdallRule<ClassMember> bePrivate() => satisfy(
    _memberFlagCondition('be private', (item) => item.isPrivate),
  );

  /// Requires fields to be final.
  HeimdallRule<ClassMember> beFinal() => satisfy(
    _memberFlagCondition('be final', (item) => item.isFinal),
  );

  /// Requires members to be static.
  HeimdallRule<ClassMember> beStatic() => satisfy(
    _memberFlagCondition('be static', (item) => item.isStatic),
  );

  HeimdallRule<ClassMember> _build() {
    final condition = _condition;
    if (condition == null) {
      throw StateError('A rule needs at least one condition.');
    }
    final prefix = _descriptionPrefix ?? _memberRulePrefix(inverted: inverted, selection: selection, predicateDescription: predicate.description);

    return HeimdallRule(
      descriptionPrefix: prefix,
      continuationContext: selection,
      selector: _selector,
      predicate: predicate,
      condition: condition,
      inverted: inverted,
      failOnEmptySelection: _failOnEmptySelection,
    );
  }

  Iterable<ClassMember> _selector(HeimdallProject project) {
    final selectorOverride = _selectorOverride;
    if (selectorOverride != null) return selectorOverride(project);

    return switch (selection) {
      MemberSelection.members => project.classMembers,
      MemberSelection.fields => project.fields,
      MemberSelection.methods => project.methods,
      MemberSelection.constructors => project.constructors,
      MemberSelection.codeUnits => project.codeUnits,
    };
  }

  /// Creates a member condition from a boolean [test].
  ///
  /// The produced [HeimdallFindings] always carries the checked member with full
  /// location (file, line, column) so that [HeimdallCondition.not] can
  /// invert the result and still report a located finding.
  static HeimdallCondition<ClassMember> _memberFlagCondition(
    String description,
    bool Function(ClassMember item) test,
  ) {
    return HeimdallCondition(description, (item, _) {
      final List<HeimdallValidationInfo> findings;

      if (test(item)) {
        findings = const <HeimdallValidationInfo>[];
      } else {
        final location = item.location;

        findings = [
          HeimdallValidationInfo(
            filePath: item.sourcePath,
            line: location.lineNumber,
            column: location.columnNumber,
            message: '${item.ownerName}.${item.name} should $description',
          ),
        ];
      }

      return HeimdallFindings(
        subject: item,
        passed: findings.isEmpty,
        findings: findings,
      );
    });
  }
}

String _memberRulePrefix({
  required bool inverted,
  required MemberSelection selection,
  required String predicateDescription,
}) {
  final subject = inverted ? 'no ${selection.name}' : selection.name;
  if (predicateDescription == MemberPredicateBuilder.alwaysMember.description) {
    return subject;
  }
  return '$subject that $predicateDescription';
}
