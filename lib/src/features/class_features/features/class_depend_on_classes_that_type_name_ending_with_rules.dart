import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_dependency_queries.dart';

/// Predicate-side DSL for dependency target type name suffix rules.
extension ClassDependOnClassesThatTypeNameEndingWithPredicateRules on ClassPredicateBuilder {
  /// Selects declarations that depend on a class whose type name ends with [suffix].
  ClassPredicateBuilder dependOnClassesWithTypeNameEndingWith(String suffix) {
    return satisfy(_classDependsOnTarget(_targetTypeNameEndsWith(suffix)));
  }

  /// Selects declarations that do not depend on a class whose type name ends with [suffix].
  ClassPredicateBuilder noDependOnClassesWithTypeNameEndingWith(String suffix) {
    return satisfy(_classDoesNotDependOnTarget(_targetTypeNameEndsWith(suffix)));
  }

  /// Selects declarations that depend on every target suffix in [suffixes].
  ClassPredicateBuilder dependOnAllClassesWithTypeNameEndingWith(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    final predicates = suffixList.map(_targetTypeNameEndsWith).toList();
    return satisfy(
      HeimdallPredicate.allOf(
        [
          HeimdallPredicate(
            'depend on all classes with type name ending with ${suffixList.join(', ')}',
            (item, project) {
              final targets = targetDeclarations(item, project);
              return predicates.every(
                (predicate) => targets.any((target) => predicate.test(target, project)),
              );
            },
          ),
        ],
        description: 'depend on all classes with type name ending with ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects declarations that depend on at least one target suffix in [suffixes].
  ClassPredicateBuilder dependOnAnyClassesWithTypeNameEndingWith(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    final predicates = suffixList.map(_targetTypeNameEndsWith).toList();
    return satisfy(
      HeimdallPredicate.anyOf(
        [
          HeimdallPredicate(
            'depend on any class with type name ending with ${suffixList.join(', ')}',
            (item, project) {
              final targets = targetDeclarations(item, project);
              return predicates.any(
                (predicate) => targets.any((target) => predicate.test(target, project)),
              );
            },
          ),
        ],
        description: 'depend on any class with type name ending with ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects declarations that depend on none of [suffixes].
  ClassPredicateBuilder dependOnNoClassesWithTypeNameEndingWith(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    final predicates = suffixList.map(_targetTypeNameEndsWith).toList();
    return satisfy(
      HeimdallPredicate.noneOf(
        [
          HeimdallPredicate(
            'depend on any class with type name ending with ${suffixList.join(', ')}',
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
        description: 'depend on no class with type name ending with ${suffixList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for dependency target type name suffix rules.
extension ClassDependOnClassesThatTypeNameEndingWithShouldRules on ClassShouldBuilder {
  /// Requires matching classes to depend on a class whose type name ends with [suffix].
  HeimdallRule<CompilationUnitMember> dependOnClassesWithTypeNameEndingWith(
    String suffix,
  ) {
    return satisfy(_classShouldDependOnTarget(_targetTypeNameEndsWith(suffix)));
  }

  /// Requires matching classes to not depend on a class whose type name ends with [suffix].
  HeimdallRule<CompilationUnitMember> noDependOnClassesWithTypeNameEndingWith(
    String suffix,
  ) {
    return satisfy(_classShouldNotDependOnTarget(_targetTypeNameEndsWith(suffix)));
  }

  /// Requires matching classes to depend on every target suffix in [suffixes].
  HeimdallRule<CompilationUnitMember> dependOnAllClassesWithTypeNameEndingWith(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.allOf(
        suffixList.map(_targetTypeNameEndsWith).map(_classShouldDependOnTarget),
        description: 'depend on all classes with type name ending with ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to depend on at least one target suffix in [suffixes].
  HeimdallRule<CompilationUnitMember> dependOnAnyClassesWithTypeNameEndingWith(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.anyOf(
        suffixList.map(_targetTypeNameEndsWith).map(_classShouldDependOnTarget),
        description: 'depend on any class with type name ending with ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to depend on none of [suffixes].
  HeimdallRule<CompilationUnitMember> dependOnNoClassesWithTypeNameEndingWith(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.noneOf(
        suffixList.map(_targetTypeNameEndsWith).map(_classShouldDependOnTarget),
        description: 'depend on no class with type name ending with ${suffixList.join(', ')}',
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
    final findings =
        targetDeclarations(
          item,
          project,
        ).any((target) => targetPredicate.test(target, project))
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} does not depend on a matching class',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotDependOnTarget(
  HeimdallPredicate<CompilationUnitMember> targetPredicate,
) {
  return HeimdallCondition('not depend on classes with type name that ${targetPredicate.description}', (item, project) {
    final findings = declarationDependenciesFrom(item, project)
        .where((dependency) => targetPredicate.test(dependency.target, project))
        .map(
          (dependency) => HeimdallValidationInfo(
            filePath: item.sourcePath,
            line: dependency.directive.line,
            message: '${item.name} depends on forbidden ${dependency.target.name}',
          ),
        )
        .toList();
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<CompilationUnitMember> _targetTypeNameEndsWith(
  String suffix,
) {
  return HeimdallPredicate(
    'ends with $suffix',
    (item, _) => item.name.endsWith(suffix),
  );
}
