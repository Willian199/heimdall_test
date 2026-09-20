import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_dependency_queries.dart';

/// Predicate-side DSL for exclusive class declaration dependency rules.
extension ClassOnlyDependOnClassesThatPredicateRules on ClassPredicateBuilder {
  /// Selects declarations whose dependency targets all match [targetPredicate].
  ClassPredicateBuilder onlyDependOnClassesThat(
    HeimdallPredicate<CompilationUnitMember> targetPredicate,
  ) {
    return satisfy(_classOnlyDependsOnClassesThat(targetPredicate));
  }

  /// Selects declarations that have at least one dependency outside [targetPredicate].
  ClassPredicateBuilder noOnlyDependOnClassesThat(
    HeimdallPredicate<CompilationUnitMember> targetPredicate,
  ) {
    return satisfy(_classDoesNotOnlyDependOnClassesThat(targetPredicate));
  }

  /// Selects declarations whose dependency targets all match every predicate group in [targetPredicates].
  ClassPredicateBuilder onlyDependOnAllClassesThat(
    Iterable<HeimdallPredicate<CompilationUnitMember>> targetPredicates,
  ) {
    final predicateList = targetPredicates.toNonEmptyList('targetPredicates');
    return satisfy(
      HeimdallPredicate.allOf(
        predicateList.map(_classOnlyDependsOnClassesThat),
        description: 'only depend on all classes that ${predicateList.map((predicate) => predicate.description).join(', ')}',
      ),
    );
  }

  /// Selects declarations whose dependency targets all match at least one predicate in [targetPredicates].
  ClassPredicateBuilder onlyDependOnAnyClassesThat(
    Iterable<HeimdallPredicate<CompilationUnitMember>> targetPredicates,
  ) {
    final predicateList = targetPredicates.toNonEmptyList('targetPredicates');
    final description = 'only depend on any classes that ${_predicateDescriptions(predicateList)}';
    return satisfy(
      _classOnlyDependsOnClassesThat(
        HeimdallPredicate.anyOf(
          predicateList,
          description: 'any of ${_predicateDescriptions(predicateList)}',
        ),
        description: description,
      ),
    );
  }

  /// Selects declarations whose dependency targets all match none of [targetPredicates].
  ClassPredicateBuilder onlyDependOnNoClassesThat(
    Iterable<HeimdallPredicate<CompilationUnitMember>> targetPredicates,
  ) {
    final predicateList = targetPredicates.toNonEmptyList('targetPredicates');
    return satisfy(
      _classOnlyDependsOnClassesThat(
        _noTargetPredicate(predicateList),
        description: 'only depend on no classes that ${_predicateDescriptions(predicateList)}',
      ),
    );
  }
}

/// Condition-side DSL for exclusive class declaration dependency rules.
extension ClassOnlyDependOnClassesThatShouldRules on ClassShouldBuilder {
  /// Requires every dependency target to match [targetPredicate].
  HeimdallRule<CompilationUnitMember> onlyDependOnClassesThat(
    HeimdallPredicate<CompilationUnitMember> targetPredicate,
  ) {
    return satisfy(_classShouldOnlyDependOnClassesThat(targetPredicate));
  }

  /// Requires matching classes to have at least one dependency outside [targetPredicate].
  HeimdallRule<CompilationUnitMember> noOnlyDependOnClassesThat(
    HeimdallPredicate<CompilationUnitMember> targetPredicate,
  ) {
    return satisfy(_classShouldNotOnlyDependOnClassesThat(targetPredicate));
  }

  /// Requires every dependency target to match every predicate group in [targetPredicates].
  HeimdallRule<CompilationUnitMember> onlyDependOnAllClassesThat(
    Iterable<HeimdallPredicate<CompilationUnitMember>> targetPredicates,
  ) {
    final predicateList = targetPredicates.toNonEmptyList('targetPredicates');
    return satisfy(
      HeimdallCondition.allOf(
        predicateList.map(_classShouldOnlyDependOnClassesThat),
        description: 'only depend on all classes that ${predicateList.map((predicate) => predicate.description).join(', ')}',
      ),
    );
  }

  /// Requires every dependency target to match at least one predicate in [targetPredicates].
  HeimdallRule<CompilationUnitMember> onlyDependOnAnyClassesThat(
    Iterable<HeimdallPredicate<CompilationUnitMember>> targetPredicates,
  ) {
    final predicateList = targetPredicates.toNonEmptyList('targetPredicates');
    final description = 'only depend on any classes that ${_predicateDescriptions(predicateList)}';
    return satisfy(
      HeimdallCondition.anyOf(
        [
          _classShouldOnlyDependOnClassesThat(
            HeimdallPredicate.anyOf(
              predicateList,
              description: 'any of ${_predicateDescriptions(predicateList)}',
            ),
            description: description,
          ),
        ],
        description: description,
      ),
    );
  }

  /// Requires every dependency target to match none of [targetPredicates].
  HeimdallRule<CompilationUnitMember> onlyDependOnNoClassesThat(
    Iterable<HeimdallPredicate<CompilationUnitMember>> targetPredicates,
  ) {
    final predicateList = targetPredicates.toNonEmptyList('targetPredicates');
    return satisfy(
      _classShouldOnlyDependOnClassesThat(
        _noTargetPredicate(predicateList),
        description: 'only depend on no classes that ${_predicateDescriptions(predicateList)}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _classOnlyDependsOnClassesThat(
  HeimdallPredicate<CompilationUnitMember> targetPredicate, {
  String? description,
}) {
  return HeimdallPredicate(
    description ?? 'only depend on classes that ${targetPredicate.description}',
    (item, project) {
      final targets = targetDeclarations(item, project).toList();
      return targets.isNotEmpty && targets.every((target) => targetPredicate.test(target, project));
    },
  );
}

HeimdallPredicate<CompilationUnitMember> _classDoesNotOnlyDependOnClassesThat(
  HeimdallPredicate<CompilationUnitMember> targetPredicate,
) {
  return HeimdallPredicate(
    'not only depend on classes that ${targetPredicate.description}',
    (item, project) {
      final targets = targetDeclarations(item, project).toList();
      return targets.isEmpty || targets.any((target) => !targetPredicate.test(target, project));
    },
  );
}

HeimdallCondition<CompilationUnitMember> _classShouldOnlyDependOnClassesThat(
  HeimdallPredicate<CompilationUnitMember> targetPredicate, {
  String? description,
}) {
  final desc = description ?? 'only depend on classes that ${targetPredicate.description}';
  return HeimdallCondition(desc, (item, project) {
    final targets = targetDeclarations(item, project).toList();
    final findings = targets.isEmpty
        ? [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} does not depend on any class',
            ),
          ]
        : targets
              .where((target) => !targetPredicate.test(target, project))
              .map(
                (target) => HeimdallValidationInfo(
                  filePath: item.sourcePath,
                  line: item.line,
                  message: '${item.name} depends on disallowed ${target.name}',
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

HeimdallCondition<CompilationUnitMember> _classShouldNotOnlyDependOnClassesThat(
  HeimdallPredicate<CompilationUnitMember> targetPredicate,
) {
  return HeimdallCondition('not only depend on classes that ${targetPredicate.description}', (item, project) {
    final targets = targetDeclarations(item, project).toList();
    final findings = targets.isEmpty || targets.any((target) => !targetPredicate.test(target, project))
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} only depends on matching classes',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<CompilationUnitMember> _noTargetPredicate(
  List<HeimdallPredicate<CompilationUnitMember>> predicates,
) {
  return HeimdallPredicate.noneOf(
    predicates,
    description: 'none of ${_predicateDescriptions(predicates)}',
  );
}

String _predicateDescriptions(
  Iterable<HeimdallPredicate<CompilationUnitMember>> predicates,
) {
  return predicates.map((predicate) => predicate.description).join(', ');
}
