import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for top-level member structure rules.
extension FileTopLevelMemberPredicateRules on FilePredicateBuilder {
  /// Selects files with at most one top-level class declaration.
  FilePredicateBuilder haveAtMostOneTopLevelClass() {
    return satisfy(_fileHasAtMostOneTopLevelClass());
  }

  /// Selects files with more than one top-level class declaration.
  FilePredicateBuilder haveMoreThanOneTopLevelClass() {
    return satisfy(_fileHasMoreThanOneTopLevelClass());
  }

  /// Selects files without top-level variable declarations.
  FilePredicateBuilder haveNoTopLevelVariables() {
    return satisfy(_fileHasNoTopLevelVariables());
  }

  /// Selects files without top-level function declarations.
  FilePredicateBuilder haveNoTopLevelFunctions() {
    return satisfy(_fileHasNoTopLevelFunctions());
  }

  /// Selects files with no top-level variables and no top-level functions.
  FilePredicateBuilder haveNoTopLevelExecutableMembers() {
    return satisfy(
      HeimdallPredicate.allOf([
        _fileHasNoTopLevelVariables(),
        _fileHasNoTopLevelFunctions(),
      ], description: 'have no top-level executable members'),
    );
  }
}

/// Condition-side DSL for top-level member structure rules.
extension FileTopLevelMemberShouldRules on FileShouldBuilder {
  /// Requires matching files to have at most one top-level class declaration.
  HeimdallRule<HeimdallSourceFile> haveAtMostOneTopLevelClass() {
    return haveAtMostTopLevelClasses(1);
  }

  /// Requires matching files to have more than one top-level class declaration.
  HeimdallRule<HeimdallSourceFile> haveMoreThanOneTopLevelClass() {
    return satisfy(_fileShouldHaveMoreThanOneTopLevelClass());
  }

  /// Requires matching files to have no top-level variable declarations.
  HeimdallRule<HeimdallSourceFile> haveNoTopLevelVariables() {
    return satisfy(_fileShouldHaveNoTopLevelVariables());
  }

  /// Requires matching files to have no top-level function declarations.
  HeimdallRule<HeimdallSourceFile> haveNoTopLevelFunctions() {
    return satisfy(_fileShouldHaveNoTopLevelFunctions());
  }

  /// Requires matching files to have no top-level variables and no top-level functions.
  HeimdallRule<HeimdallSourceFile> haveNoTopLevelExecutableMembers() {
    return satisfy(
      HeimdallCondition.allOf([
        _fileShouldHaveNoTopLevelVariables(),
        _fileShouldHaveNoTopLevelFunctions(),
      ], description: 'have no top-level executable members'),
    );
  }
}

HeimdallPredicate<HeimdallSourceFile> _fileHasAtMostOneTopLevelClass() {
  return HeimdallPredicate(
    'have at most one top-level class',
    (item, _) => item.classDeclarations.length <= 1,
  );
}

HeimdallPredicate<HeimdallSourceFile> _fileHasNoTopLevelVariables() {
  return HeimdallPredicate(
    'have no top-level variables',
    (item, _) => item.topLevelVariables.isEmpty,
  );
}

HeimdallPredicate<HeimdallSourceFile> _fileHasNoTopLevelFunctions() {
  return HeimdallPredicate(
    'have no top-level functions',
    (item, _) => item.topLevelFunctions.isEmpty,
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldHaveNoTopLevelVariables() {
  return HeimdallCondition('have no top-level variables', (item, _) {
    final findings = item.topLevelVariables
        .map(
          (declaration) => HeimdallValidationInfo(
            filePath: item.absolutePath,
            message: 'declares top-level variable ${declaration.variables.variables.map((variable) => variable.name.lexeme).join(', ')}',
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

HeimdallCondition<HeimdallSourceFile> _fileShouldHaveNoTopLevelFunctions() {
  return HeimdallCondition('have no top-level functions', (item, _) {
    final findings = item.topLevelFunctions
        .map(
          (declaration) => HeimdallValidationInfo(
            filePath: item.absolutePath,
            message: 'declares top-level function ${declaration.name.lexeme}',
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

HeimdallPredicate<HeimdallSourceFile> _fileHasMoreThanOneTopLevelClass() {
  return HeimdallPredicate(
    'have more than one top-level class',
    (item, _) => item.classDeclarations.length > 1,
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldHaveMoreThanOneTopLevelClass() {
  return HeimdallCondition('have more than one top-level class', (item, _) {
    final classes = item.classDeclarations;
    final findings = classes.length > 1
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              line: classes.isEmpty ? 1 : classes.single.line,
              column: 1,
              message: 'should declare more than one top-level class',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
