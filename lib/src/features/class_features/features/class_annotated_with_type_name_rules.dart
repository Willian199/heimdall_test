import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for exact class annotation rules.
extension ClassAnnotatedWithPredicateRules on ClassPredicateBuilder {
  /// Selects declarations annotated with [annotation].
  ClassPredicateBuilder areAnnotatedWith(String annotation) {
    return satisfy(_classAnnotatedWith(annotation));
  }

  /// Selects declarations not annotated with [annotation].
  ClassPredicateBuilder noAreAnnotatedWith(String annotation) {
    return satisfy(
      HeimdallPredicate(
        'are not annotated with $annotation',
        (item, _) => !item.annotations.contains(annotation),
      ),
    );
  }

  /// Selects declarations annotated with at least one annotation in [annotations].
  ClassPredicateBuilder areAnnotatedWithAny(Iterable<String> annotations) {
    final annotationList = annotations.toNonEmptyList('annotations');
    return satisfy(
      HeimdallPredicate.anyOf(
        annotationList.map(_classAnnotatedWith),
        description: 'are annotated with any of ${annotationList.join(', ')}',
      ),
    );
  }

  /// Selects declarations annotated with every annotation in [annotations].
  ClassPredicateBuilder areAnnotatedWithAll(Iterable<String> annotations) {
    final annotationList = annotations.toNonEmptyList('annotations');
    return satisfy(
      HeimdallPredicate.allOf(
        annotationList.map(_classAnnotatedWith),
        description: 'are annotated with all of ${annotationList.join(', ')}',
      ),
    );
  }

  /// Selects declarations annotated with none of [annotations].
  ClassPredicateBuilder areAnnotatedWithNone(Iterable<String> annotations) {
    final annotationList = annotations.toNonEmptyList('annotations');
    return satisfy(
      HeimdallPredicate.noneOf(
        annotationList.map(_classAnnotatedWith),
        description: 'are annotated with none of ${annotationList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for exact class annotation rules.
extension ClassAnnotatedWithShouldRules on ClassShouldBuilder {
  /// Requires matching classes to be annotated with [annotation].
  HeimdallRule<CompilationUnitMember> beAnnotatedWith(String annotation) {
    return satisfy(_classShouldBeAnnotatedWith(annotation));
  }

  /// Requires matching classes to not be annotated with [annotation].
  HeimdallRule<CompilationUnitMember> noBeAnnotatedWith(String annotation) {
    return satisfy(_classShouldNotBeAnnotatedWith(annotation));
  }

  /// Requires matching classes to be annotated with at least one annotation in [annotations].
  HeimdallRule<CompilationUnitMember> beAnnotatedWithAny(
    Iterable<String> annotations,
  ) {
    final annotationList = annotations.toNonEmptyList('annotations');
    return satisfy(
      HeimdallCondition.anyOf(
        annotationList.map(_classShouldBeAnnotatedWith),
        description: 'be annotated with any of ${annotationList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to be annotated with every annotation in [annotations].
  HeimdallRule<CompilationUnitMember> beAnnotatedWithAll(
    Iterable<String> annotations,
  ) {
    final annotationList = annotations.toNonEmptyList('annotations');
    return satisfy(
      HeimdallCondition.allOf(
        annotationList.map(_classShouldBeAnnotatedWith),
        description: 'be annotated with all of ${annotationList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to be annotated with none of [annotations].
  HeimdallRule<CompilationUnitMember> beAnnotatedWithNone(
    Iterable<String> annotations,
  ) {
    final annotationList = annotations.toNonEmptyList('annotations');
    return satisfy(
      HeimdallCondition.noneOf(
        annotationList.map(_classShouldBeAnnotatedWith),
        description: 'be annotated with none of ${annotationList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _classAnnotatedWith(
  String annotation,
) {
  return HeimdallPredicate(
    'are annotated with $annotation',
    (item, _) => item.annotations.contains(annotation),
  );
}

HeimdallCondition<CompilationUnitMember> _classShouldBeAnnotatedWith(
  String annotation,
) {
  return HeimdallCondition('be annotated with $annotation', (item, _) {
    final findings = item.annotations.contains(annotation)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} is not annotated with $annotation',
            ),
          ];

    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotBeAnnotatedWith(
  String annotation,
) {
  return HeimdallCondition('not be annotated with $annotation', (item, _) {
    final findings = _matchingAnnotations(item, (name) => name == annotation).map(
      (match) {
        final location = item.sourceLocationAt(match.offset);
        return HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: location.line,
          column: location.column,
          message: '${item.name} is annotated with prohibited annotation $annotation',
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
  bool Function(String name) test,
) {
  return item.annotationNodes.where((annotation) => test(annotation.name.name));
}
