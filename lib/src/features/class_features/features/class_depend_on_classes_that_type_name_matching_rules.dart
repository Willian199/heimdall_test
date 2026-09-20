import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_dependency_queries.dart';

/// Predicate-side DSL for dependency target type name regex rules.
extension ClassDependOnClassesThatTypeNameMatchingPredicateRules on ClassPredicateBuilder {
  /// Selects declarations that depend on a class whose type name matches [pattern].
  ClassPredicateBuilder dependOnClassesWithTypeNameMatching(RegExp pattern) {
    return satisfy(_classDependsOnTarget(_targetTypeNameMatches(pattern)));
  }

  /// Selects declarations that do not depend on a class whose type name matches [pattern].
  ClassPredicateBuilder noDependOnClassesWithTypeNameMatching(RegExp pattern) {
    return satisfy(_classDoesNotDependOnTarget(_targetTypeNameMatches(pattern)));
  }

  /// Selects declarations that depend on every target pattern in [patterns].
  ClassPredicateBuilder dependOnAllClassesWithTypeNameMatching(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    final predicates = patternList.map(_targetTypeNameMatches).toList();
    return satisfy(
      HeimdallPredicate.allOf(
        [
          HeimdallPredicate(
            'depend on all classes with type name matching ${patternList.join(', ')}',
            (item, project) {
              final targets = targetDeclarations(item, project);
              return predicates.every(
                (predicate) => targets.any((target) => predicate.test(target, project)),
              );
            },
          ),
        ],
        description: 'depend on all classes with type name matching ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects declarations that depend on at least one target pattern in [patterns].
  ClassPredicateBuilder dependOnAnyClassesWithTypeNameMatching(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    final predicates = patternList.map(_targetTypeNameMatches).toList();
    return satisfy(
      HeimdallPredicate.anyOf(
        [
          HeimdallPredicate(
            'depend on any class with type name matching ${patternList.join(', ')}',
            (item, project) {
              final targets = targetDeclarations(item, project);
              return predicates.any(
                (predicate) => targets.any((target) => predicate.test(target, project)),
              );
            },
          ),
        ],
        description: 'depend on any class with type name matching ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects declarations that depend on none of [patterns].
  ClassPredicateBuilder dependOnNoClassesWithTypeNameMatching(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    final predicates = patternList.map(_targetTypeNameMatches).toList();
    return satisfy(
      HeimdallPredicate.noneOf(
        [
          HeimdallPredicate(
            'depend on any class with type name matching ${patternList.join(', ')}',
            (item, project) {
              final dependencies = declarationDependenciesFrom(item, project);
              return dependencies.any(
                (dependency) => predicates.any(
                  (predicate) => predicate.test(dependency.target, project),
                ),
              );
            },
          ),
        ],
        description: 'depend on no class with type name matching ${patternList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for dependency target type name regex rules.
extension ClassDependOnClassesThatTypeNameMatchingShouldRules on ClassShouldBuilder {
  /// Requires matching classes to depend on a class whose type name matches [pattern].
  HeimdallRule<CompilationUnitMember> dependOnClassesWithTypeNameMatching(
    RegExp pattern,
  ) {
    return satisfy(_classShouldDependOnTarget(_targetTypeNameMatches(pattern)));
  }

  /// Requires matching classes to not depend on a class whose type name matches [pattern].
  HeimdallRule<CompilationUnitMember> noDependOnClassesWithTypeNameMatching(
    RegExp pattern,
  ) {
    return satisfy(_classShouldNotDependOnTarget(_targetTypeNameMatches(pattern)));
  }

  /// Requires matching classes to depend on every target pattern in [patterns].
  HeimdallRule<CompilationUnitMember> dependOnAllClassesWithTypeNameMatching(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        patternList.map(_targetTypeNameMatches).map(_classShouldDependOnTarget),
        description: 'depend on all classes with type name matching ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to depend on at least one target pattern in [patterns].
  HeimdallRule<CompilationUnitMember> dependOnAnyClassesWithTypeNameMatching(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        patternList.map(_targetTypeNameMatches).map(_classShouldDependOnTarget),
        description: 'depend on any class with type name matching ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to depend on none of [patterns].
  HeimdallRule<CompilationUnitMember> dependOnNoClassesWithTypeNameMatching(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.noneOf(
        patternList.map(_targetTypeNameMatches).map(_classShouldDependOnTarget),
        description: 'depend on no class with type name matching ${patternList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _classDependsOnTarget(
  HeimdallPredicate<CompilationUnitMember> targetPredicate,
) {
  return HeimdallPredicate(
    'depend on classes with type name that ${targetPredicate.description}',
    (item, project) => targetDeclarations(
      item,
      project,
    ).any((target) => targetPredicate.test(target, project)),
  );
}

HeimdallPredicate<CompilationUnitMember> _classDoesNotDependOnTarget(
  HeimdallPredicate<CompilationUnitMember> targetPredicate,
) {
  return HeimdallPredicate(
    'not depend on classes with type name that ${targetPredicate.description}',
    (item, project) => !declarationDependenciesFrom(
      item,
      project,
    ).any((dependency) => targetPredicate.test(dependency.target, project)),
  );
}

HeimdallCondition<CompilationUnitMember> _classShouldDependOnTarget(
  HeimdallPredicate<CompilationUnitMember> targetPredicate,
) {
  return HeimdallCondition('depend on classes with type name that ${targetPredicate.description}', (item, project) {
    final dependency = declarationDependenciesFrom(
      item,
      project,
    ).where((dependency) => targetPredicate.test(dependency.target, project)).firstOrNull;
    final location = dependency == null ? null : item.sourceLocationAt(dependency.directive.offset);
    final findings = [
      if (dependency != null && location != null)
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: location.line,
          column: location.column,
          message: '${item.name} depends on matching ${dependency.target.name}',
        )
      else
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: item.line,
          message: '${item.name} does not depend on a matching class',
        ),
    ];

    return HeimdallFindings(
      subject: item,
      passed: dependency != null,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotDependOnTarget(
  HeimdallPredicate<CompilationUnitMember> targetPredicate,
) {
  return HeimdallCondition('not depend on classes with type name that ${targetPredicate.description}', (item, project) {
    final findings = declarationDependenciesFrom(item, project).where((dependency) => targetPredicate.test(dependency.target, project)).map((
      dependency,
    ) {
      final location = item.sourceLocationAt(dependency.directive.offset);
      return HeimdallValidationInfo(
        filePath: item.sourcePath,
        line: location.line,
        column: location.column,
        message: '${item.name} depends on forbidden ${dependency.target.name}',
      );
    }).toList();

    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<CompilationUnitMember> _targetTypeNameMatches(
  RegExp pattern,
) {
  return HeimdallPredicate(
    'matches ${pattern.pattern}',
    (item, _) => pattern.hasMatch(item.name),
  );
}
