import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_location_queries.dart';

/// Creates a predicate that accepts classes declaring a matching constructor.
HeimdallPredicate<CompilationUnitMember> classHasConstructorName(String description, bool Function(String name) test) {
  return HeimdallPredicate(
    'have constructor name that $description',
    (item, _) => item.constructors.any(
      (constructor) => test((constructor as ClassMember).name),
    ),
  );
}

/// Creates a predicate that accepts classes with no matching constructor.
HeimdallPredicate<CompilationUnitMember> classDoesNotHaveConstructorName(String description, bool Function(String name) test) {
  return HeimdallPredicate(
    'not have constructor name that $description',
    (item, _) => _matchingConstructors(item, test).isEmpty,
  );
}

/// Creates a condition requiring classes to declare a matching constructor.
HeimdallCondition<CompilationUnitMember> classShouldHaveConstructorName(String nameDescription, bool Function(String name) test) {
  final description = 'have constructor name that $nameDescription';
  return HeimdallCondition(description, (item, _) {
    final matchingConstructor = _matchingConstructors(item, test).firstOrNull;
    final findings = matchingConstructor != null
        ? [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: constructorLocation(matchingConstructor).line,
              column: constructorLocation(matchingConstructor).column,
              message: '${item.name} declares matching constructor ${(matchingConstructor as ClassMember).name}',
            ),
          ]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} does not declare a matching constructor',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: matchingConstructor != null,
      findings: findings,
    );
  });
}

/// Creates a condition prohibiting classes from declaring a matching constructor.
HeimdallCondition<CompilationUnitMember> classShouldNotHaveConstructorName(String nameDescription, bool Function(String name) test) {
  final description = 'not have constructor name that $nameDescription';

  return HeimdallCondition(description, (item, _) {
    final findings = _matchingConstructors(item, test).map((constructor) {
      final location = constructorLocation(constructor);

      return HeimdallValidationInfo(
        filePath: item.sourcePath,
        line: location.line,
        column: location.column,
        message: '${item.name} declares prohibited constructor ${(constructor as ClassMember).name}',
      );
    }).toList();

    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

Iterable<ConstructorDeclaration> _matchingConstructors(
  CompilationUnitMember item,
  bool Function(String name) test,
) {
  return item.constructors.where(
    (constructor) => test((constructor as ClassMember).name),
  );
}
