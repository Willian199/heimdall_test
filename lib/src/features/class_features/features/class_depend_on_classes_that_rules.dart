import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_dependency_queries.dart';

/// Predicate-side DSL for positive class declaration dependency rules.
extension ClassDependOnClassesThatPredicateRules on ClassPredicateBuilder {
  /// Selects declarations that depend on targets matching [targetPredicate].
  ClassPredicateBuilder dependOnClassesThat(
    HeimdallPredicate<CompilationUnitMember> targetPredicate,
  ) {
    return satisfy(_classDependsOnClassesThat(targetPredicate));
  }

  /// Selects declarations that do not depend on targets matching [targetPredicate].
  ClassPredicateBuilder notDependOnClassesThat(
    HeimdallPredicate<CompilationUnitMember> targetPredicate,
  ) {
    return satisfy(
      HeimdallPredicate(
        'not depend on classes that ${targetPredicate.description}',
        (item, project) => !declarationDependenciesFrom(
          item,
          project,
        ).any((dependency) => targetPredicate.test(dependency.target, project)),
      ),
    );
  }

  /// Selects declarations that depend on all target predicate groups in [targetPredicates].
  ClassPredicateBuilder dependOnClassesMatchingAllOf(
    Iterable<HeimdallPredicate<CompilationUnitMember>> targetPredicates,
  ) {
    final predicateList = targetPredicates.toNonEmptyList('targetPredicates');
    return satisfy(
      HeimdallPredicate.allOf(
        [
          HeimdallPredicate(
            'depend on all classes that ${predicateList.map((predicate) => predicate.description).join(', ')}',
            (item, project) {
              final targets = targetDeclarations(item, project);
              return predicateList.every(
                (predicate) => targets.any((target) => predicate.test(target, project)),
              );
            },
          ),
        ],
        description: 'depend on all classes that ${predicateList.map((predicate) => predicate.description).join(', ')}',
      ),
    );
  }

  /// Selects declarations that depend on at least one target predicate in [targetPredicates].
  ClassPredicateBuilder dependOnClassesMatchingAnyOf(
    Iterable<HeimdallPredicate<CompilationUnitMember>> targetPredicates,
  ) {
    final predicateList = targetPredicates.toNonEmptyList('targetPredicates');
    return satisfy(
      HeimdallPredicate.anyOf(
        [
          HeimdallPredicate(
            'depend on any classes that ${predicateList.map((predicate) => predicate.description).join(', ')}',
            (item, project) {
              final targets = targetDeclarations(item, project);
              return predicateList.any(
                (predicate) => targets.any((target) => predicate.test(target, project)),
              );
            },
          ),
        ],
        description: 'depend on any classes that ${predicateList.map((predicate) => predicate.description).join(', ')}',
      ),
    );
  }

  /// Selects declarations that depend on none of [targetPredicates].
  ClassPredicateBuilder dependOnClassesMatchingNoneOf(
    Iterable<HeimdallPredicate<CompilationUnitMember>> targetPredicates,
  ) {
    final predicateList = targetPredicates.toNonEmptyList('targetPredicates');
    return satisfy(
      HeimdallPredicate.noneOf(
        [
          HeimdallPredicate(
            'depend on any classes that ${predicateList.map((predicate) => predicate.description).join(', ')}',
            (item, project) {
              final dependencies = declarationDependenciesFrom(item, project);
              return dependencies.any(
                (dependency) => predicateList.any(
                  (predicate) => predicate.test(dependency.target, project),
                ),
              );
            },
          ),
        ],
        description: 'depend on no classes that ${predicateList.map((predicate) => predicate.description).join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for positive class declaration dependency rules.
extension ClassDependOnClassesThatShouldRules on ClassShouldBuilder {
  /// Requires matching classes to depend on classes selected by [targetPredicate].
  HeimdallRule<CompilationUnitMember> dependOnClassesThat(
    HeimdallPredicate<CompilationUnitMember> targetPredicate,
  ) {
    return satisfy(_classShouldDependOnClassesThat(targetPredicate));
  }

  /// Requires matching classes to not depend on classes selected by [targetPredicate].
  HeimdallRule<CompilationUnitMember> notDependOnClassesThat(
    HeimdallPredicate<CompilationUnitMember> targetPredicate,
  ) {
    return satisfy(_classShouldNotDependOnClassesThat(targetPredicate));
  }

  /// Requires matching classes to depend on all target predicate groups in [targetPredicates].
  HeimdallRule<CompilationUnitMember> dependOnClassesMatchingAllOf(
    Iterable<HeimdallPredicate<CompilationUnitMember>> targetPredicates,
  ) {
    final predicateList = targetPredicates.toNonEmptyList('targetPredicates');
    return satisfy(
      HeimdallCondition.allOf(
        predicateList.map(_classShouldDependOnClassesThat),
        description: 'depend on all classes that ${predicateList.map((predicate) => predicate.description).join(', ')}',
      ),
    );
  }

  /// Requires matching classes to depend on at least one target predicate in [targetPredicates].
  HeimdallRule<CompilationUnitMember> dependOnClassesMatchingAnyOf(
    Iterable<HeimdallPredicate<CompilationUnitMember>> targetPredicates,
  ) {
    final predicateList = targetPredicates.toNonEmptyList('targetPredicates');
    return satisfy(
      HeimdallCondition.anyOf(
        predicateList.map(_classShouldDependOnClassesThat),
        description: 'depend on any classes that ${predicateList.map((predicate) => predicate.description).join(', ')}',
      ),
    );
  }

  /// Requires matching classes to depend on none of [targetPredicates].
  HeimdallRule<CompilationUnitMember> dependOnClassesMatchingNoneOf(
    Iterable<HeimdallPredicate<CompilationUnitMember>> targetPredicates,
  ) {
    final predicateList = targetPredicates.toNonEmptyList('targetPredicates');
    return satisfy(
      HeimdallCondition.noneOf(
        predicateList.map(_classShouldDependOnClassesThat),
        description: 'depend on no classes that ${predicateList.map((predicate) => predicate.description).join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _classDependsOnClassesThat(
  HeimdallPredicate<CompilationUnitMember> targetPredicate,
) {
  return HeimdallPredicate(
    'depend on classes that ${targetPredicate.description}',
    (item, project) => targetDeclarations(
      item,
      project,
    ).any((target) => targetPredicate.test(target, project)),
  );
}

HeimdallCondition<CompilationUnitMember> _classShouldDependOnClassesThat(
  HeimdallPredicate<CompilationUnitMember> targetPredicate,
) {
  return HeimdallCondition('depend on classes that ${targetPredicate.description}', (item, project) {
    final matches = targetDeclarations(
      item,
      project,
    ).where((target) => targetPredicate.test(target, project)).toList();
    final findings = matches.isNotEmpty
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

HeimdallCondition<CompilationUnitMember> _classShouldNotDependOnClassesThat(
  HeimdallPredicate<CompilationUnitMember> targetPredicate,
) {
  return HeimdallCondition('not depend on classes that ${targetPredicate.description}', (item, project) {
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
