import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for top-level class count rules.
extension FileTopLevelStructurePredicateRules on FilePredicateBuilder {
  /// Selects files with at most [count] top-level class declarations.
  FilePredicateBuilder haveAtMostTopLevelClasses(int count) {
    return satisfy(_fileHasAtMostTopLevelClasses(count));
  }

  /// Selects files with more than [count] top-level class declarations.
  FilePredicateBuilder haveMoreThanTopLevelClasses(int count) {
    return satisfy(_fileHasMoreThanTopLevelClasses(count));
  }

  /// Selects files that satisfy every top-level class limit in [counts].
  FilePredicateBuilder haveAtMostAllTopLevelClasses(Iterable<int> counts) {
    final countList = counts.toNonEmptyList('counts');
    return satisfy(
      HeimdallPredicate.allOf(
        countList.map(_fileHasAtMostTopLevelClasses),
        description: 'satisfy all top-level class limits ${countList.join(', ')}',
      ),
    );
  }

  /// Selects files that satisfy at least one top-level class limit in [counts].
  FilePredicateBuilder haveAtMostAnyTopLevelClasses(Iterable<int> counts) {
    final countList = counts.toNonEmptyList('counts');
    return satisfy(
      HeimdallPredicate.anyOf(
        countList.map(_fileHasAtMostTopLevelClasses),
        description: 'satisfy any top-level class limit ${countList.join(', ')}',
      ),
    );
  }

  /// Selects files that satisfy none of the top-level class limits in [counts].
  FilePredicateBuilder haveAtMostNoTopLevelClasses(Iterable<int> counts) {
    final countList = counts.toNonEmptyList('counts');
    return satisfy(
      HeimdallPredicate.noneOf(
        countList.map(_fileHasAtMostTopLevelClasses),
        description: 'satisfy no top-level class limits ${countList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for top-level class count rules.
extension FileTopLevelStructureShouldRules on FileShouldBuilder {
  /// Requires matching files to have at most [count] top-level class declarations.
  HeimdallRule<HeimdallSourceFile> haveAtMostTopLevelClasses(int count) {
    return satisfy(_fileShouldHaveAtMostTopLevelClasses(count));
  }

  /// Requires matching files to have more than [count] top-level class declarations.
  HeimdallRule<HeimdallSourceFile> haveMoreThanTopLevelClasses(int count) {
    return satisfy(_fileShouldHaveMoreThanTopLevelClasses(count));
  }

  /// Requires matching files to satisfy every top-level class limit in [counts].
  HeimdallRule<HeimdallSourceFile> haveAtMostAllTopLevelClasses(
    Iterable<int> counts,
  ) {
    final countList = counts.toNonEmptyList('counts');
    return satisfy(
      HeimdallCondition.allOf(
        countList.map(_fileShouldHaveAtMostTopLevelClasses),
        description: 'satisfy all top-level class limits ${countList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to satisfy at least one top-level class limit in [counts].
  HeimdallRule<HeimdallSourceFile> haveAtMostAnyTopLevelClasses(
    Iterable<int> counts,
  ) {
    final countList = counts.toNonEmptyList('counts');
    return satisfy(
      HeimdallCondition.anyOf(
        countList.map(_fileShouldHaveAtMostTopLevelClasses),
        description: 'satisfy any top-level class limit ${countList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to satisfy none of the top-level class limits in [counts].
  HeimdallRule<HeimdallSourceFile> haveAtMostNoTopLevelClasses(
    Iterable<int> counts,
  ) {
    final countList = counts.toNonEmptyList('counts');
    return satisfy(
      HeimdallCondition.noneOf(
        countList.map(_fileShouldHaveAtMostTopLevelClasses),
        description: 'satisfy no top-level class limits ${countList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<HeimdallSourceFile> _fileHasAtMostTopLevelClasses(int count) {
  return HeimdallPredicate(
    'have at most $count top-level classes',
    (item, _) => item.classDeclarations.length <= count,
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldHaveAtMostTopLevelClasses(
  int count,
) {
  return HeimdallCondition('have at most $count top-level classes', (item, _) {
    final classes = item.classDeclarations;
    final findings = classes.length <= count
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              message: 'declares ${classes.length} top-level classes',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<HeimdallSourceFile> _fileHasMoreThanTopLevelClasses(
  int count,
) {
  return HeimdallPredicate(
    'have more than $count top-level classes',
    (item, _) => item.classDeclarations.length > count,
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldHaveMoreThanTopLevelClasses(
  int count,
) {
  return HeimdallCondition('have more than $count top-level classes', (
    item,
    _,
  ) {
    final classes = item.classDeclarations;
    final findings = classes.length > count
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              line: classes.isEmpty ? 1 : classes.last.line,
              column: 1,
              message: 'should declare more than $count top-level classes',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
