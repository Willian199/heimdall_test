import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_location_queries.dart';

/// Predicate-side DSL for class type name regex rules.
extension ClassHaveTypeNameMatchingPredicateRules on ClassPredicateBuilder {
  /// Selects declarations whose names match [regex].
  ClassPredicateBuilder haveTypeNameMatching(RegExp regex) {
    return satisfy(HeimdallPredicate('have type name matching ${regex.pattern}', (item, _) => regex.hasMatch(item.name)));
  }

  /// Selects declarations whose names do not match [regex].
  ClassPredicateBuilder notHaveTypeNameMatching(RegExp regex) {
    return satisfy(HeimdallPredicate('not have type name matching ${regex.pattern}', (item, _) => !regex.hasMatch(item.name)));
  }

  /// Selects declarations whose names match at least one regex in [patterns].
  ClassPredicateBuilder haveTypeNameMatchingAnyOf(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.anyOf(
        patternList.map(
          (pattern) =>
              HeimdallPredicate<CompilationUnitMember>('have type name matching ${pattern.pattern}', (item, _) => pattern.hasMatch(item.name)),
        ),
        description: 'have type name matching any of ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects declarations whose names match every regex in [patterns].
  ClassPredicateBuilder haveTypeNameMatchingAllOf(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.allOf(
        patternList.map(
          (pattern) =>
              HeimdallPredicate<CompilationUnitMember>('have type name matching ${pattern.pattern}', (item, _) => pattern.hasMatch(item.name)),
        ),
        description: 'have type name matching all of ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects declarations whose names match none of [patterns].
  ClassPredicateBuilder haveTypeNameMatchingNoneOf(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.noneOf(
        patternList.map(
          (pattern) =>
              HeimdallPredicate<CompilationUnitMember>('have type name matching ${pattern.pattern}', (item, _) => pattern.hasMatch(item.name)),
        ),
        description: 'have type name matching none of ${patternList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for class type name regex rules.
extension ClassHaveTypeNameMatchingShouldRules on ClassShouldBuilder {
  /// Requires matching class type names to match [regex].
  HeimdallRule<CompilationUnitMember> haveTypeNameMatching(RegExp regex) {
    return satisfy(_classShouldHaveTypeNameMatching(regex));
  }

  /// Requires matching class type names to not match [regex].
  HeimdallRule<CompilationUnitMember> notHaveTypeNameMatching(RegExp regex) {
    return satisfy(_classShouldNotHaveTypeNameMatching(regex));
  }

  /// Requires matching class type names to match at least one regex in [patterns].
  HeimdallRule<CompilationUnitMember> haveTypeNameMatchingAnyOf(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        patternList.map(_classShouldHaveTypeNameMatching),
        description: 'have type name matching any of ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching class type names to match every regex in [patterns].
  HeimdallRule<CompilationUnitMember> haveTypeNameMatchingAllOf(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        patternList.map(_classShouldHaveTypeNameMatching),
        description: 'have type name matching all of ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching class type names to match none of [patterns].
  HeimdallRule<CompilationUnitMember> haveTypeNameMatchingNoneOf(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.noneOf(
        patternList.map(_classShouldHaveTypeNameMatching),
        description: 'have type name matching none of ${patternList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<CompilationUnitMember> _classShouldHaveTypeNameMatching(
  RegExp pattern,
) {
  return HeimdallCondition('have type name matching ${pattern.pattern}', (item, _) {
    final matches = pattern.hasMatch(item.name);
    final location = matches ? item.sourceLocationAt(declarationNameOffset(item)) : null;
    final findings = [
      if (location != null)
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: location.line,
          column: location.column,
          message: '${item.name} matches ${pattern.pattern}',
        )
      else
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: item.line,
          message: '${item.name} should match ${pattern.pattern}',
        ),
    ];
    return HeimdallFindings(
      subject: item,
      passed: matches,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotHaveTypeNameMatching(
  RegExp pattern,
) {
  return HeimdallCondition('not have type name matching ${pattern.pattern}', (item, _) {
    final matches = pattern.hasMatch(item.name);
    final location = matches ? item.sourceLocationAt(declarationNameOffset(item)) : null;
    final findings = [
      if (location != null)
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: location.line,
          column: location.column,
          message: '${item.name} has prohibited type name matching ${pattern.pattern}',
        ),
    ];

    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
