import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for annotation type name regex rules.
extension ClassAnnotatedWithTypeNameMatchingPredicateRules on ClassPredicateBuilder {
  /// Selects declarations annotated with a type name matching [pattern].
  ClassPredicateBuilder areAnnotatedWithTypeNameMatching(RegExp pattern) {
    return satisfy(_classAnnotatedWithTypeNameMatching(pattern));
  }

  /// Selects declarations not annotated with a type name matching [pattern].
  ClassPredicateBuilder areNotAnnotatedWithTypeNameMatching(RegExp pattern) {
    return satisfy(
      HeimdallPredicate(
        'are not annotated with type name matching ${pattern.pattern}',
        (item, _) => !item.annotations.any(pattern.hasMatch),
      ),
    );
  }

  /// Selects declarations annotated with a type name matching at least one regex in [patterns].
  ClassPredicateBuilder areAnnotatedWithTypeNameMatchingAnyOf(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.anyOf(
        patternList.map(_classAnnotatedWithTypeNameMatching),
        description: 'are annotated with type name matching any of ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects declarations annotated with type names matching every regex in [patterns].
  ClassPredicateBuilder areAnnotatedWithTypeNameMatchingAllOf(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.allOf(
        patternList.map(_classAnnotatedWithTypeNameMatching),
        description: 'are annotated with type names matching all of ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects declarations annotated with no name matching [patterns].
  ClassPredicateBuilder areAnnotatedWithTypeNameMatchingNoneOf(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.noneOf(
        patternList.map(_classAnnotatedWithTypeNameMatching),
        description: 'are annotated with type name matching none of ${patternList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for annotation type name regex rules.
extension ClassAnnotatedWithTypeNameMatchingShouldRules on ClassShouldBuilder {
  /// Requires matching classes to be annotated with a type name matching [pattern].
  HeimdallRule<CompilationUnitMember> beAnnotatedWithTypeNameMatching(
    RegExp pattern,
  ) {
    return satisfy(_classShouldBeAnnotatedWithTypeNameMatching(pattern));
  }

  /// Requires matching classes to not be annotated with a type name matching [pattern].
  HeimdallRule<CompilationUnitMember> notBeAnnotatedWithTypeNameMatching(
    RegExp pattern,
  ) {
    return satisfy(_classShouldNotBeAnnotatedWithTypeNameMatching(pattern));
  }

  /// Requires matching classes to be annotated with a type name matching at least one regex in [patterns].
  HeimdallRule<CompilationUnitMember> beAnnotatedWithTypeNameMatchingAnyOf(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        patternList.map(_classShouldBeAnnotatedWithTypeNameMatching),
        description: 'be annotated with type name matching any of ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to be annotated with type names matching every regex in [patterns].
  HeimdallRule<CompilationUnitMember> beAnnotatedWithTypeNameMatchingAllOf(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        patternList.map(_classShouldBeAnnotatedWithTypeNameMatching),
        description: 'be annotated with type names matching all of ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to be annotated with no name matching [patterns].
  HeimdallRule<CompilationUnitMember> beAnnotatedWithTypeNameMatchingNoneOf(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.noneOf(
        patternList.map(_classShouldBeAnnotatedWithTypeNameMatching),
        description: 'be annotated with type name matching none of ${patternList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _classAnnotatedWithTypeNameMatching(
  RegExp pattern,
) {
  return HeimdallPredicate(
    'are annotated with type name matching ${pattern.pattern}',
    (item, _) => item.annotations.any(pattern.hasMatch),
  );
}

HeimdallCondition<CompilationUnitMember> _classShouldBeAnnotatedWithTypeNameMatching(
  RegExp pattern,
) {
  return HeimdallCondition('be annotated with type name matching ${pattern.pattern}', (
    item,
    _,
  ) {
    final matchingAnnotation = _matchingAnnotations(item, pattern).firstOrNull;
    final findings = <HeimdallValidationInfo>[];
    if (matchingAnnotation != null) {
      final location = item.sourceLocationAt(matchingAnnotation.offset);
      findings.add(
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: location.line,
          column: location.column,
          message: '${item.name} is annotated with type name matching ${pattern.pattern}',
        ),
      );
    } else {
      findings.add(
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: item.line,
          message: '${item.name} is not annotated with a type name matching ${pattern.pattern}',
        ),
      );
    }
    return HeimdallFindings(
      subject: item,
      passed: matchingAnnotation != null,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotBeAnnotatedWithTypeNameMatching(
  RegExp pattern,
) {
  return HeimdallCondition('not be annotated with type name matching ${pattern.pattern}', (
    item,
    _,
  ) {
    final findings = _matchingAnnotations(item, pattern).map(
      (match) {
        final location = item.sourceLocationAt(match.offset);
        return HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: location.line,
          column: location.column,
          message: '${item.name} is annotated with prohibited annotation matching ${pattern.pattern}',
        );
      },
    ).toList();
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

Iterable<Annotation> _matchingAnnotations(
  CompilationUnitMember item,
  RegExp pattern,
) {
  return item.annotationNodes.where((annotation) => pattern.hasMatch(annotation.name.name));
}
