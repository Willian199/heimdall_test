import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';

/// Predicate-side DSL for implemented type regex rules.
extension ClassImplementTypeNameMatchingPredicateRules on ClassPredicateBuilder {
  /// Selects classes that implement a type whose name matches [pattern].
  ClassPredicateBuilder implementTypeNameMatching(RegExp pattern) {
    return satisfy(_classImplementsTypeNameMatching(pattern));
  }

  /// Selects classes that do not implement a type whose name matches [pattern].
  ClassPredicateBuilder noImplementTypeNameMatching(RegExp pattern) {
    return satisfy(_classDoesNotImplementTypeNameMatching(pattern));
  }

  /// Selects classes that implement a type name matching at least one regex in [patterns].
  ClassPredicateBuilder implementTypeNameMatchingAny(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.anyOf(
        patternList.map(_classImplementsTypeNameMatching),
        description: 'implement type name matching any of ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects classes that implement types matching every regex in [patterns].
  ClassPredicateBuilder implementTypeNameMatchingAll(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.allOf(
        patternList.map(_classImplementsTypeNameMatching),
        description: 'implement types matching all of ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects classes that implement no type name matching [patterns].
  ClassPredicateBuilder implementTypeNameMatchingNone(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.noneOf(
        patternList.map(_classImplementsTypeNameMatching),
        description: 'implement type name matching none of ${patternList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for implemented type regex rules.
extension ClassImplementTypeNameMatchingShouldRules on ClassShouldBuilder {
  /// Requires matching classes to implement a type whose type matches [pattern].
  HeimdallRule<CompilationUnitMember> implementTypeNameMatching(RegExp pattern) {
    return satisfy(_classShouldImplementTypeNameMatching(pattern));
  }

  /// Requires matching classes to not implement a type whose name matches [pattern].
  HeimdallRule<CompilationUnitMember> noImplementTypeNameMatching(RegExp pattern) {
    return satisfy(_classShouldNotImplementTypeNameMatching(pattern));
  }

  /// Requires matching classes to implement a type name matching at least one regex in [patterns].
  HeimdallRule<CompilationUnitMember> implementTypeNameMatchingAny(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        patternList.map(_classShouldImplementTypeNameMatching),
        description: 'implement type name matching any of ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to implement types matching every regex in [patterns].
  HeimdallRule<CompilationUnitMember> implementTypeNameMatchingAll(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        patternList.map(_classShouldImplementTypeNameMatching),
        description: 'implement type name matching all of ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to implement no type name matching [patterns].
  HeimdallRule<CompilationUnitMember> implementTypeNameMatchingNone(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.noneOf(
        patternList.map(_classShouldImplementTypeNameMatching),
        description: 'implement type name matching none of ${patternList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _classImplementsTypeNameMatching(
  RegExp pattern,
) {
  return HeimdallPredicate(
    'implement type name matching ${pattern.pattern}',
    (item, project) => implementsTypeNamedWhere(
      item,
      project,
      (typeName) => pattern.hasMatch(typeName),
    ),
  );
}

HeimdallPredicate<CompilationUnitMember> _classDoesNotImplementTypeNameMatching(
  RegExp pattern,
) {
  return HeimdallPredicate(
    'not implement type name matching ${pattern.pattern}',
    (item, project) => !implementsTypeNamedWhere(
      item,
      project,
      (typeName) => pattern.hasMatch(typeName),
    ),
  );
}

HeimdallCondition<CompilationUnitMember> _classShouldImplementTypeNameMatching(
  RegExp pattern,
) {
  return HeimdallCondition('implement type name matching ${pattern.pattern}', (
    item,
    project,
  ) {
    final matches = implementsTypeNamedWhere(
      item,
      project,
      (typeName) => pattern.hasMatch(typeName),
    );
    final findings = [
      if (matches)
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: item.line,
          message: '${item.name} implements a type name matching ${pattern.pattern}',
        )
      else
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: item.line,
          message: '${item.name} should implement a type name matching ${pattern.pattern}',
        ),
    ];

    return HeimdallFindings(
      subject: item,
      passed: matches,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotImplementTypeNameMatching(
  RegExp pattern,
) {
  return HeimdallCondition('not implement type name matching ${pattern.pattern}', (
    item,
    project,
  ) {
    final matches = implementsTypeNamedWhere(
      item,
      project,
      (typeName) => pattern.hasMatch(typeName),
    );
    final findings = [
      if (matches)
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: item.line,
          message: '${item.name} should not implement a type name matching ${pattern.pattern}',
        ),
    ];

    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
