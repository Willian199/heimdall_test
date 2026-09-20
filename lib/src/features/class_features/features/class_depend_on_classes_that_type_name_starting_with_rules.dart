import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_dependency_queries.dart';

/// Predicate-side DSL for dependency target type name prefix rules.
extension ClassDependOnClassesThatTypeNameStartingWithPredicateRules on ClassPredicateBuilder {
  /// Selects declarations that depend on a class whose type name starts with [prefix].
  ClassPredicateBuilder dependOnClassesWithTypeNameStartingWith(String prefix) {
    return satisfy(_classDependsOnTarget(_targetTypeNameStartsWith(prefix)));
  }

  /// Selects declarations that do not depend on a class whose type name starts with [prefix].
  ClassPredicateBuilder noDependOnClassesWithTypeNameStartingWith(String prefix) {
    return satisfy(_classDoesNotDependOnTarget(_targetTypeNameStartsWith(prefix)));
  }

  /// Selects declarations that depend on every target prefix in [prefixes].
  ClassPredicateBuilder dependOnAllClassesWithTypeNameStartingWith(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    final predicates = prefixList.map(_targetTypeNameStartsWith).toList();
    return satisfy(
      HeimdallPredicate.allOf(
        [
          HeimdallPredicate(
            'depend on all classes with type name starting with ${prefixList.join(', ')}',
            (item, project) {
              final targets = targetDeclarations(item, project);
              return predicates.every(
                (predicate) => targets.any((target) => predicate.test(target, project)),
              );
            },
          ),
        ],
        description: 'depend on all classes with type name starting with ${prefixList.join(', ')}',
      ),
    );
  }

  /// Selects declarations that depend on at least one target prefix in [prefixes].
  ClassPredicateBuilder dependOnAnyClassesWithTypeNameStartingWith(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    final predicates = prefixList.map(_targetTypeNameStartsWith).toList();
    return satisfy(
      HeimdallPredicate.anyOf(
        [
          HeimdallPredicate(
            'depend on any class with type name starting with ${prefixList.join(', ')}',
            (item, project) {
              final targets = targetDeclarations(item, project);
              return predicates.any(
                (predicate) => targets.any((target) => predicate.test(target, project)),
              );
            },
          ),
        ],
        description: 'depend on any class with type name starting with ${prefixList.join(', ')}',
      ),
    );
  }

  /// Selects declarations that depend on none of [prefixes].
  ClassPredicateBuilder dependOnNoClassesWithTypeNameStartingWith(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    final predicates = prefixList.map(_targetTypeNameStartsWith).toList();
    return satisfy(
      HeimdallPredicate.noneOf(
        [
          HeimdallPredicate(
            'depend on any class with type name starting with ${prefixList.join(', ')}',
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
        description: 'depend on no class with type name starting with ${prefixList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for dependency target type name prefix rules.
extension ClassDependOnClassesThatTypeNameStartingWithShouldRules on ClassShouldBuilder {
  /// Requires matching classes to depend on a class whose type name starts with [prefix].
  HeimdallRule<CompilationUnitMember> dependOnClassesWithTypeNameStartingWith(
    String prefix,
  ) {
    return satisfy(_classShouldDependOnTarget(_targetTypeNameStartsWith(prefix)));
  }

  /// Requires matching classes to not depend on a class whose type name starts with [prefix].
  HeimdallRule<CompilationUnitMember> noDependOnClassesWithTypeNameStartingWith(
    String prefix,
  ) {
    return satisfy(_classShouldNotDependOnTarget(_targetTypeNameStartsWith(prefix)));
  }

  /// Requires matching classes to depend on every target prefix in [prefixes].
  HeimdallRule<CompilationUnitMember> dependOnAllClassesWithTypeNameStartingWith(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.allOf(
        prefixList.map(_targetTypeNameStartsWith).map(_classShouldDependOnTarget),
        description: 'depend on all classes with type name starting with ${prefixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to depend on at least one target prefix in [prefixes].
  HeimdallRule<CompilationUnitMember> dependOnAnyClassesWithTypeNameStartingWith(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.anyOf(
        prefixList.map(_targetTypeNameStartsWith).map(_classShouldDependOnTarget),
        description: 'depend on any class with type name starting with ${prefixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to depend on none of [prefixes].
  HeimdallRule<CompilationUnitMember> dependOnNoClassesWithTypeNameStartingWith(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.noneOf(
        prefixList.map(_targetTypeNameStartsWith).map(_classShouldDependOnTarget),
        description: 'depend on no class with type name starting with ${prefixList.join(', ')}',
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

HeimdallPredicate<CompilationUnitMember> _targetTypeNameStartsWith(
  String prefix,
) {
  return HeimdallPredicate(
    'starts with $prefix',
    (item, _) => item.name.startsWith(prefix),
  );
}
