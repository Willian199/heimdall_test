import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for class annotation suffix rules.
extension ClassAnnotatedWithTypeNameEndingPredicateRules on ClassPredicateBuilder {
  /// Selects declarations annotated with a type name ending with [suffix].
  ClassPredicateBuilder areAnnotatedWithTypeNameEnding(String suffix) {
    return satisfy(_classAnnotatedWithTypeNameEnding(suffix));
  }

  /// Selects declarations not annotated with a type name ending with [suffix].
  ClassPredicateBuilder noAreAnnotatedWithTypeNameEnding(String suffix) {
    return satisfy(
      HeimdallPredicate(
        'are not annotated with type name ending with $suffix',
        (item, _) => !item.annotations.any((name) => name.endsWith(suffix)),
      ),
    );
  }

  /// Selects declarations annotated with a type name ending with any suffix in [suffixes].
  ClassPredicateBuilder areAnnotatedWithTypeNameEndingAny(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        suffixList.map(_classAnnotatedWithTypeNameEnding),
        description: 'are annotated with type name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects declarations annotated with type names ending with every suffix in [suffixes].
  ClassPredicateBuilder areAnnotatedWithTypeNameEndingAll(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.allOf(
        suffixList.map(_classAnnotatedWithTypeNameEnding),
        description: 'are annotated with type names ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects declarations annotated with no name ending with [suffixes].
  ClassPredicateBuilder areAnnotatedWithTypeNameEndingNone(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        suffixList.map(_classAnnotatedWithTypeNameEnding),
        description: 'are annotated with type name ending with none of ${suffixList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for class annotation suffix rules.
extension ClassAnnotatedWithTypeNameEndingShouldRules on ClassShouldBuilder {
  /// Requires matching classes to be annotated with a type name ending with [suffix].
  HeimdallRule<CompilationUnitMember> beAnnotatedWithTypeNameEnding(String suffix) {
    return satisfy(_classShouldBeAnnotatedWithTypeNameEnding(suffix));
  }

  /// Requires matching classes to not be annotated with a type name ending with [suffix].
  HeimdallRule<CompilationUnitMember> noBeAnnotatedWithTypeNameEnding(String suffix) {
    return satisfy(_classShouldNotBeAnnotatedWithTypeNameEnding(suffix));
  }

  /// Requires matching classes to be annotated with a type name ending with any suffix in [suffixes].
  HeimdallRule<CompilationUnitMember> beAnnotatedWithTypeNameEndingAny(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.anyOf(
        suffixList.map(_classShouldBeAnnotatedWithTypeNameEnding),
        description: 'be annotated with type name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to be annotated with type names ending with every suffix in [suffixes].
  HeimdallRule<CompilationUnitMember> beAnnotatedWithTypeNameEndingAll(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.allOf(
        suffixList.map(_classShouldBeAnnotatedWithTypeNameEnding),
        description: 'be annotated with type names ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to be annotated with no name ending with [suffixes].
  HeimdallRule<CompilationUnitMember> beAnnotatedWithTypeNameEndingNone(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.noneOf(
        suffixList.map(_classShouldBeAnnotatedWithTypeNameEnding),
        description: 'be annotated with type name ending with none of ${suffixList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _classAnnotatedWithTypeNameEnding(
  String suffix,
) {
  return HeimdallPredicate(
    'are annotated with type name ending with $suffix',
    (item, _) => item.annotations.any((name) => name.endsWith(suffix)),
  );
}

HeimdallCondition<CompilationUnitMember> _classShouldBeAnnotatedWithTypeNameEnding(String suffix) {
  return HeimdallCondition('be annotated with type name ending with $suffix', (
    item,
    _,
  ) {
    final findings = item.annotations.any((name) => name.endsWith(suffix))
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} is not annotated with a type name ending with $suffix',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotBeAnnotatedWithTypeNameEnding(String suffix) {
  return HeimdallCondition('not be annotated with type name ending with $suffix', (
    item,
    _,
  ) {
    final findings = _matchingAnnotations(item, suffix).map(
      (match) {
        final location = item.sourceLocationAt(match.offset);
        return HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: location.line,
          column: location.column,
          message: '${item.name} is annotated with prohibited annotation ending with $suffix',
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
  String suffix,
) {
  return item.annotationNodes.where((annotation) => annotation.name.name.endsWith(suffix));
}
