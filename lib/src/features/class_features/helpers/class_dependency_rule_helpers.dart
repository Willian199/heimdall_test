import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_dependency_queries.dart';

/// Matches declarations with a dependency satisfying [targetPredicate].
HeimdallPredicate<CompilationUnitMember> classDependsOnTarget(
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

/// Matches declarations without a dependency satisfying [targetPredicate].
HeimdallPredicate<CompilationUnitMember> classDoesNotDependOnTarget(
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

/// Requires a dependency satisfying [targetPredicate].
HeimdallCondition<CompilationUnitMember> classShouldDependOnTarget(
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

/// Reports each forbidden dependency at its originating directive's source line.
HeimdallCondition<CompilationUnitMember> classShouldNotDependOnTarget(
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
