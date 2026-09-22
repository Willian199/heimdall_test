import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';

/// Predicate-side DSL for mixin type regex rules.
extension ClassMixinTypeNameMatchingPredicateRules on ClassPredicateBuilder {
  /// Selects classes that mix in a type whose name matches [pattern].
  ClassPredicateBuilder applyMixinTypeNameMatching(RegExp pattern) {
    return satisfy(_classMixesInTypeNameMatching(pattern));
  }

  /// Selects classes that do not mix in a type whose name matches [pattern].
  ClassPredicateBuilder notApplyMixinTypeNameMatching(RegExp pattern) {
    return satisfy(_classDoesNotMixinTypeNameMatching(pattern));
  }

  /// Selects classes that mix in a type name matching at least one regex in [patterns].
  ClassPredicateBuilder applyMixinTypeNameMatchingAnyOf(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.anyOf(
        patternList.map(_classMixesInTypeNameMatching),
        description: 'mixin type name matching any of ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects classes that mix in types matching every regex in [patterns].
  ClassPredicateBuilder applyMixinTypeNameMatchingAllOf(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.allOf(
        patternList.map(_classMixesInTypeNameMatching),
        description: 'mixin types matching all of ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects classes that mix in no type name matching [patterns].
  ClassPredicateBuilder applyMixinTypeNameMatchingNoneOf(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.noneOf(
        patternList.map(_classMixesInTypeNameMatching),
        description: 'mixin type name matching none of ${patternList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for mixin type regex rules.
extension ClassMixinTypeNameMatchingShouldRules on ClassShouldBuilder {
  /// Requires matching classes to mix in a type whose name matches [pattern].
  HeimdallRule<CompilationUnitMember> applyMixinTypeNameMatching(RegExp pattern) {
    return satisfy(_classShouldMixinTypeNameMatching(pattern));
  }

  /// Requires matching classes to not mix in a type whose name matches [pattern].
  HeimdallRule<CompilationUnitMember> notApplyMixinTypeNameMatching(RegExp pattern) {
    return satisfy(_classShouldNotMixinTypeNameMatching(pattern));
  }

  /// Requires matching classes to mix in a type name matching at least one regex in [patterns].
  HeimdallRule<CompilationUnitMember> applyMixinTypeNameMatchingAnyOf(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        patternList.map(_classShouldMixinTypeNameMatching),
        description: 'mixin type name matching any of ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to mix in types matching every regex in [patterns].
  HeimdallRule<CompilationUnitMember> applyMixinTypeNameMatchingAllOf(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        patternList.map(_classShouldMixinTypeNameMatching),
        description: 'mixin types matching all of ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to mix in no type name matching [patterns].
  HeimdallRule<CompilationUnitMember> applyMixinTypeNameMatchingNoneOf(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.noneOf(
        patternList.map(_classShouldMixinTypeNameMatching),
        description: 'mixin type name matching none of ${patternList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _classMixesInTypeNameMatching(
  RegExp pattern,
) {
  return HeimdallPredicate(
    'mixin type name matching ${pattern.pattern}',
    (item, project) => mixesInTypeNamedWhere(
      item,
      project,
      (typeName) => pattern.hasMatch(typeName),
    ),
  );
}

HeimdallPredicate<CompilationUnitMember> _classDoesNotMixinTypeNameMatching(
  RegExp pattern,
) {
  return HeimdallPredicate(
    'not mixin type name matching ${pattern.pattern}',
    (item, project) => !mixesInTypeNamedWhere(
      item,
      project,
      (typeName) => pattern.hasMatch(typeName),
    ),
  );
}

HeimdallCondition<CompilationUnitMember> _classShouldMixinTypeNameMatching(
  RegExp pattern,
) {
  return HeimdallCondition('mixin type name matching ${pattern.pattern}', (
    item,
    project,
  ) {
    final matches = mixesInTypeNamedWhere(
      item,
      project,
      (typeName) => pattern.hasMatch(typeName),
    );
    final findings = [
      if (matches)
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: item.line,
          message: '${item.name} mixes in a type name matching ${pattern.pattern}',
        )
      else
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: item.line,
          message: '${item.name} should mixin a type name matching ${pattern.pattern}',
        ),
    ];

    return HeimdallFindings(
      subject: item,
      passed: matches,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotMixinTypeNameMatching(
  RegExp pattern,
) {
  return HeimdallCondition('not mixin type name matching ${pattern.pattern}', (
    item,
    project,
  ) {
    final matches = mixesInTypeNamedWhere(
      item,
      project,
      (typeName) => pattern.hasMatch(typeName),
    );
    final findings = [
      if (matches)
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: item.line,
          message: '${item.name} should not mixin a type name matching ${pattern.pattern}',
        ),
    ];

    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
