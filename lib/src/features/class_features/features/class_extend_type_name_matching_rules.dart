import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';

/// Predicate-side DSL for superclass type name regex rules.
extension ClassExtendTypeNameMatchingPredicateRules on ClassPredicateBuilder {
  /// Selects classes that extend a type whose name matches [pattern].
  ClassPredicateBuilder extendTypeNameMatching(RegExp pattern) {
    return satisfy(_classExtendsTypeNameMatching(pattern));
  }

  /// Selects classes that do not extend a type whose name matches [pattern].
  ClassPredicateBuilder notExtendTypeNameMatching(RegExp pattern) {
    return satisfy(_classDoesNotExtendTypeNameMatching(pattern));
  }

  /// Selects classes that extend a type name matching at least one regex in [patterns].
  ClassPredicateBuilder extendTypeNameMatchingAnyOf(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.anyOf(
        patternList.map(_classExtendsTypeNameMatching),
        description: 'extend type name matching any of ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects classes that extend types matching every regex in [patterns].
  ClassPredicateBuilder extendTypeNameMatchingAllOf(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.allOf(
        patternList.map(_classExtendsTypeNameMatching),
        description: 'extend types matching all of ${patternList.join(', ')}',
      ),
    );
  }

  /// Selects classes that extend no type name matching [patterns].
  ClassPredicateBuilder extendTypeNameMatchingNoneOf(Iterable<RegExp> patterns) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallPredicate.noneOf(
        patternList.map(_classExtendsTypeNameMatching),
        description: 'extend type name matching none of ${patternList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for superclass type name regex rules.
extension ClassExtendTypeNameMatchingShouldRules on ClassShouldBuilder {
  /// Requires matching classes to extend a type whose name matches [pattern].
  HeimdallRule<CompilationUnitMember> extendTypeNameMatching(RegExp pattern) {
    return satisfy(_classShouldExtendTypeNameMatching(pattern));
  }

  /// Requires matching classes to not extend a type whose name matches [pattern].
  HeimdallRule<CompilationUnitMember> notExtendTypeNameMatching(RegExp pattern) {
    return satisfy(_classShouldNotExtendTypeNameMatching(pattern));
  }

  /// Requires matching classes to extend a type name matching at least one regex in [patterns].
  HeimdallRule<CompilationUnitMember> extendTypeNameMatchingAnyOf(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.anyOf(
        patternList.map(_classShouldExtendTypeNameMatching),
        description: 'extend type name matching any of ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to extend types matching every regex in [patterns].
  HeimdallRule<CompilationUnitMember> extendTypeNameMatchingAllOf(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.allOf(
        patternList.map(_classShouldExtendTypeNameMatching),
        description: 'extend types matching all of ${patternList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to extend no type name matching [patterns].
  HeimdallRule<CompilationUnitMember> extendTypeNameMatchingNoneOf(
    Iterable<RegExp> patterns,
  ) {
    final patternList = patterns.toNonEmptyList('patterns');
    return satisfy(
      HeimdallCondition.noneOf(
        patternList.map(_classShouldExtendTypeNameMatching),
        description: 'extend type name matching none of ${patternList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _classExtendsTypeNameMatching(
  RegExp pattern,
) {
  return HeimdallPredicate(
    'extend type name matching ${pattern.pattern}',
    (item, project) => extendsTypeNamedWhere(
      item,
      project,
      (typeName) => pattern.hasMatch(typeName),
    ),
  );
}

HeimdallPredicate<CompilationUnitMember> _classDoesNotExtendTypeNameMatching(
  RegExp pattern,
) {
  return HeimdallPredicate(
    'not extend type name matching ${pattern.pattern}',
    (item, project) => !extendsTypeNamedWhere(
      item,
      project,
      (typeName) => pattern.hasMatch(typeName),
    ),
  );
}

HeimdallCondition<CompilationUnitMember> _classShouldExtendTypeNameMatching(
  RegExp pattern,
) {
  return HeimdallCondition('extend type name matching ${pattern.pattern}', (
    item,
    project,
  ) {
    final matches = extendsTypeNamedWhere(
      item,
      project,
      (typeName) => pattern.hasMatch(typeName),
    );
    final findings = [
      if (matches)
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: item.line,
          message: '${item.name} extends a type name matching ${pattern.pattern}',
        )
      else
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: item.line,
          message: '${item.name} should extend a type name matching ${pattern.pattern}',
        ),
    ];

    return HeimdallFindings(
      subject: item,
      passed: matches,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotExtendTypeNameMatching(
  RegExp pattern,
) {
  return HeimdallCondition('not extend type name matching ${pattern.pattern}', (
    item,
    project,
  ) {
    final matches = extendsTypeNamedWhere(
      item,
      project,
      (typeName) => pattern.hasMatch(typeName),
    );
    final findings = [
      if (matches)
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: item.line,
          message: '${item.name} should not extend a type name matching ${pattern.pattern}',
        ),
    ];

    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
