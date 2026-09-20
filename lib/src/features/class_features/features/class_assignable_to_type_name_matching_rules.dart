import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';

/// Predicate-side DSL for assignability type name regex rules.
extension ClassAssignableToTypeNameMatchingPredicateRules on ClassPredicateBuilder {
  /// Selects declarations assignable to a type whose name matches [pattern].
  ClassPredicateBuilder areAssignableToTypeNameMatching(RegExp pattern) {
    return satisfy(_classAssignableToTypeNameMatching(pattern));
  }

  /// Selects declarations not assignable to a type whose name matches [pattern].
  ClassPredicateBuilder noAreAssignableToTypeNameMatching(RegExp pattern) {
    return satisfy(_classNotAssignableToTypeNameMatching(pattern));
  }

  /// Selects declarations assignable to a type name matching at least one regex in [patterns].
  ClassPredicateBuilder areAssignableToTypeNameMatchingAny(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.anyOf(
        patternList.map(_classAssignableToTypeNameMatching),
        description: 'are assignable to type name matching any of ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects declarations assignable to type names matching every regex in [patterns].
  ClassPredicateBuilder areAssignableToTypeNameMatchingAll(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.allOf(
        patternList.map(_classAssignableToTypeNameMatching),
        description: 'are assignable to type names matching all of ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects declarations assignable to no type name matching [patterns].
  ClassPredicateBuilder areAssignableToTypeNameMatchingNone(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.noneOf(
        patternList.map(_classAssignableToTypeNameMatching),
        description: 'are assignable to type name matching none of ${patternList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for assignability type name regex rules.
extension ClassAssignableToTypeNameMatchingShouldRules on ClassShouldBuilder {
  /// Requires matching classes to be assignable to a type whose name matches [pattern].
  HeimdallRule<CompilationUnitMember> beAssignableToTypeNameMatching(
    RegExp pattern,
  ) {
    return satisfy(_classShouldBeAssignableToTypeNameMatching(pattern));
  }

  /// Requires matching classes to not be assignable to a type whose name matches [pattern].
  HeimdallRule<CompilationUnitMember> noBeAssignableToTypeNameMatching(
    RegExp pattern,
  ) {
    return satisfy(_classShouldNotBeAssignableToTypeNameMatching(pattern));
  }

  /// Requires matching classes to be assignable to a type name matching at least one regex in [patterns].
  HeimdallRule<CompilationUnitMember> beAssignableToTypeNameMatchingAny(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        patternList.map(_classShouldBeAssignableToTypeNameMatching),
        description: 'be assignable to type name matching any of ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to be assignable to type names matching every regex in [patterns].
  HeimdallRule<CompilationUnitMember> beAssignableToTypeNameMatchingAll(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        patternList.map(_classShouldBeAssignableToTypeNameMatching),
        description: 'be assignable to type names matching all of ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to be assignable to no type name matching [patterns].
  HeimdallRule<CompilationUnitMember> beAssignableToTypeNameMatchingNone(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.noneOf(
        patternList.map(_classShouldBeAssignableToTypeNameMatching),
        description: 'be assignable to type name matching none of ${patternList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _classAssignableToTypeNameMatching(
  RegExp pattern,
) {
  return HeimdallPredicate(
    'are assignable to type name matching ${pattern.pattern}',
    (item, project) => isAssignableToTypeNamedWhere(
      item,
      project,
      (typeName) => pattern.hasMatch(typeName),
    ),
  );
}

HeimdallPredicate<CompilationUnitMember> _classNotAssignableToTypeNameMatching(
  RegExp pattern,
) {
  return HeimdallPredicate(
    'are not assignable to type name matching ${pattern.pattern}',
    (item, project) => !isAssignableToTypeNamedWhere(
      item,
      project,
      (typeName) => pattern.hasMatch(typeName),
    ),
  );
}

HeimdallCondition<CompilationUnitMember> _classShouldBeAssignableToTypeNameMatching(
  RegExp pattern,
) {
  return HeimdallCondition('be assignable to type name matching ${pattern.pattern}', (item, project) {
    final matches = isAssignableToTypeNamedWhere(
      item,
      project,
      (typeName) => pattern.hasMatch(typeName),
    );
    final findings = [
      if (matches)
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: item.line,
          message: '${item.name} is assignable to a type name matching ${pattern.pattern}',
        )
      else
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: item.line,
          message: '${item.name} should be assignable to a type name matching ${pattern.pattern}',
        ),
    ];

    return HeimdallFindings(
      subject: item,
      passed: matches,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotBeAssignableToTypeNameMatching(
  RegExp pattern,
) {
  return HeimdallCondition('not be assignable to type name matching ${pattern.pattern}', (item, project) {
    final matches = isAssignableToTypeNamedWhere(
      item,
      project,
      (typeName) => pattern.hasMatch(typeName),
    );
    final findings = [
      if (matches)
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: item.line,
          message: '${item.name} should not be assignable to a type name matching ${pattern.pattern}',
        ),
    ];

    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
