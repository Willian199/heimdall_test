import 'package:heimdall_test/heimdall_test.dart';

/// Fluent condition builder for class and type declaration rules.
///
/// Conditions are evaluated for each declaration selected by the class rule
/// scope and predicate chain.
final class ClassShouldBuilder implements HeimdallShouldBuilder<CompilationUnitMember, ClassShouldBuilder> {
  /// Creates a class condition builder.
  ClassShouldBuilder({required this.predicate, required this.inverted}) : _descriptionPrefix = null, _failOnEmptySelection = true;

  /// Creates a class condition builder that continues an existing [rule].
  ClassShouldBuilder.fromRule(
    HeimdallRule<CompilationUnitMember> rule, {
    required bool useOr,
  }) : predicate = rule.predicate,
       inverted = rule.inverted,
       _condition = rule.condition,
       _useOr = useOr,
       _descriptionPrefix = rule.descriptionPrefix ?? rule.description,
       _failOnEmptySelection = rule.failOnEmptySelection;

  /// Predicate that selects checked declarations.
  final HeimdallPredicate<CompilationUnitMember> predicate;

  /// Whether generated rules should invert their final condition.
  final bool inverted;
  HeimdallCondition<CompilationUnitMember>? _condition;
  bool _useOr = false;
  bool _negateNext = false;
  final String? _descriptionPrefix;
  bool _failOnEmptySelection;

  @override
  ClassShouldBuilder andShould() {
    _useOr = false;
    return this;
  }

  @override
  ClassShouldBuilder orShould() {
    _useOr = true;
    return this;
  }

  @override
  ClassShouldBuilder not() {
    assert(!_negateNext, 'not() called twice in sequence');
    _negateNext = true;
    return this;
  }

  /// Allows the generated rule to select no classes.
  ClassShouldBuilder allowEmpty() => failOnEmpty(false);

  /// Configures whether the generated rule should fail on an empty selection.
  ClassShouldBuilder failOnEmpty(bool value) {
    _failOnEmptySelection = value;
    return this;
  }

  @override
  HeimdallRule<CompilationUnitMember> satisfy(
    HeimdallCondition<CompilationUnitMember> condition,
  ) {
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

  /// Requires matching classes to be public.
  HeimdallRule<CompilationUnitMember> bePublic() => satisfy(
    _classFlagCondition('be public', (item) => item.isPublic),
  );

  /// Requires matching classes to be private.
  HeimdallRule<CompilationUnitMember> bePrivate() => satisfy(
    _classFlagCondition('be private', (item) => item.isPrivate),
  );

  /// Requires matching classes to be final.
  HeimdallRule<CompilationUnitMember> beFinal() => satisfy(
    _classFlagCondition('be final', (item) => item.isFinal),
  );

  /// Requires matching classes to be abstract.
  HeimdallRule<CompilationUnitMember> beAbstract() => satisfy(
    _classFlagCondition('be abstract', (item) => item.isAbstract),
  );

  /// Requires matching declarations to be enums.
  HeimdallRule<CompilationUnitMember> beEnums() => satisfy(
    _classFlagCondition('be enum', (item) => item.isEnum),
  );

  /// Requires matching declarations to be mixins.
  HeimdallRule<CompilationUnitMember> beMixins() => satisfy(
    _classFlagCondition('be mixin', (item) => item.isMixin),
  );

  /// Requires matching classes to be sealed.
  HeimdallRule<CompilationUnitMember> beSealed() => satisfy(
    _classFlagCondition('be sealed', (item) => item.isSealed),
  );

  /// Requires matching classes to be base.
  HeimdallRule<CompilationUnitMember> beBase() => satisfy(
    _classFlagCondition('be base', (item) => item.isBase),
  );

  /// Requires matching declarations to be interfaces.
  HeimdallRule<CompilationUnitMember> beInterfaces() => satisfy(
    _classFlagCondition('be interface', (item) => item.isInterface),
  );

  /// Requires matching declarations to be extension types.
  HeimdallRule<CompilationUnitMember> beExtensionTypes() => satisfy(
    _classFlagCondition('be extension type', (item) => item.isExtensionType),
  );

  HeimdallRule<CompilationUnitMember> _build() {
    final condition = _condition;

    if (condition == null) {
      throw StateError('A rule needs at least one condition.');
    }

    final prefix = _descriptionPrefix ?? _classRulePrefix(inverted: inverted, predicateDescription: predicate.description);

    return HeimdallRule(
      descriptionPrefix: prefix,
      selector: (project) => project.typeDeclarations,
      predicate: predicate,
      condition: condition,
      inverted: inverted,
      failOnEmptySelection: _failOnEmptySelection,
    );
  }

  /// Creates a class condition from a boolean [test].
  ///
  /// The produced [HeimdallFindings] always carries its subject with full
  /// location (file, line, column) so that [HeimdallCondition.not] can
  /// invert the result and still report a located finding.
  static HeimdallCondition<CompilationUnitMember> _classFlagCondition(
    String description,
    bool Function(CompilationUnitMember item) test,
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
            message: '${item.name} should $description',
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

String _classRulePrefix({
  required bool inverted,
  required String predicateDescription,
}) {
  final subject = inverted ? 'no classes' : 'classes';
  if (predicateDescription == ClassPredicateBuilder.alwaysClass.description) {
    return subject;
  }
  return '$subject that $predicateDescription';
}
