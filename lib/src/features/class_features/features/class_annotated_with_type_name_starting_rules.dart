import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for class annotation prefix rules.
extension ClassAnnotatedWithTypeNameStartingPredicateRules on ClassPredicateBuilder {
  /// Selects declarations annotated with a type name starting with [prefix].
  ClassPredicateBuilder areAnnotatedWithTypeNameStarting(String prefix) {
    return satisfy(_classAnnotatedWithTypeNameStarting(prefix));
  }

  /// Selects declarations not annotated with a type name starting with [prefix].
  ClassPredicateBuilder noAreAnnotatedWithTypeNameStarting(String prefix) {
    return satisfy(
      HeimdallPredicate(
        'are not annotated with type name starting with $prefix',
        (item, _) => !item.annotations.any((name) => name.startsWith(prefix)),
      ),
    );
  }

  /// Selects declarations annotated with a type name starting with any prefix in [prefixes].
  ClassPredicateBuilder areAnnotatedWithTypeNameStartingAny(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        prefixList.map(_classAnnotatedWithTypeNameStarting),
        description: 'are annotated with type name starting with any of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Selects declarations annotated with type names starting with every prefix in [prefixes].
  ClassPredicateBuilder areAnnotatedWithTypeNameStartingAll(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.allOf(
        prefixList.map(_classAnnotatedWithTypeNameStarting),
        description: 'are annotated with type names starting with all of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Selects declarations annotated with no name starting with [prefixes].
  ClassPredicateBuilder areAnnotatedWithTypeNameStartingNone(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        prefixList.map(_classAnnotatedWithTypeNameStarting),
        description: 'are annotated with type name starting with none of ${prefixList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for class annotation prefix rules.
extension ClassAnnotatedWithTypeNameStartingShouldRules on ClassShouldBuilder {
  /// Requires matching classes to be annotated with a type name starting with [prefix].
  HeimdallRule<CompilationUnitMember> beAnnotatedWithTypeNameStarting(
    String prefix,
  ) {
    return satisfy(_classShouldBeAnnotatedWithTypeNameStarting(prefix));
  }

  /// Requires matching classes to not be annotated with a type name starting with [prefix].
  HeimdallRule<CompilationUnitMember> noBeAnnotatedWithTypeNameStarting(
    String prefix,
  ) {
    return satisfy(_classShouldNotBeAnnotatedWithTypeNameStarting(prefix));
  }

  /// Requires matching classes to be annotated with a type name starting with any prefix in [prefixes].
  HeimdallRule<CompilationUnitMember> beAnnotatedWithTypeNameStartingAny(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.anyOf(
        prefixList.map(_classShouldBeAnnotatedWithTypeNameStarting),
        description: 'be annotated with type name starting with any of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to be annotated with type names starting with every prefix in [prefixes].
  HeimdallRule<CompilationUnitMember> beAnnotatedWithTypeNameStartingAll(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.allOf(
        prefixList.map(_classShouldBeAnnotatedWithTypeNameStarting),
        description: 'be annotated with type names starting with all of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to be annotated with no name starting with [prefixes].
  HeimdallRule<CompilationUnitMember> beAnnotatedWithTypeNameStartingNone(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.noneOf(
        prefixList.map(_classShouldBeAnnotatedWithTypeNameStarting),
        description: 'be annotated with type name starting with none of ${prefixList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _classAnnotatedWithTypeNameStarting(
  String prefix,
) {
  return HeimdallPredicate(
    'are annotated with type name starting with $prefix',
    (item, _) => item.annotations.any((name) => name.startsWith(prefix)),
  );
}

HeimdallCondition<CompilationUnitMember> _classShouldBeAnnotatedWithTypeNameStarting(String prefix) {
  return HeimdallCondition('be annotated with type name starting with $prefix', (
    item,
    _,
  ) {
    final findings = item.annotations.any((name) => name.startsWith(prefix))
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} is not annotated with a type name starting with $prefix',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotBeAnnotatedWithTypeNameStarting(String prefix) {
  return HeimdallCondition('not be annotated with type name starting with $prefix', (
    item,
    _,
  ) {
    final findings = _matchingAnnotations(item, prefix).map(
      (match) {
        final location = item.sourceLocationAt(match.offset);
        return HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: location.line,
          column: location.column,
          message: '${item.name} is annotated with prohibited annotation starting with $prefix',
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
  String prefix,
) {
  return item.annotationNodes.where((annotation) => annotation.name.name.startsWith(prefix));
}
