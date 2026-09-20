import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';

/// Predicate-side DSL for assignability prefix rules.
extension ClassAssignableToTypeNameStartingWithPredicateRules on ClassPredicateBuilder {
  /// Selects declarations assignable to a type whose name starts with [prefix].
  ClassPredicateBuilder areAssignableToTypeNameStartingWith(String prefix) {
    return satisfy(_classAssignableToTypeNameStartingWith(prefix));
  }

  /// Selects declarations not assignable to a type whose name starts with [prefix].
  ClassPredicateBuilder noAreAssignableToTypeNameStartingWith(String prefix) {
    return satisfy(_classNotAssignableToTypeNameStartingWith(prefix));
  }

  /// Selects declarations assignable to a type name starting with at least one prefix in [prefixes].
  ClassPredicateBuilder areAssignableToTypeNameStartingWithAny(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        prefixList.map(_classAssignableToTypeNameStartingWith),
        description: 'are assignable to type name starting with any of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Selects declarations assignable to type names starting with every prefix in [prefixes].
  ClassPredicateBuilder areAssignableToTypeNameStartingWithAll(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.allOf(
        prefixList.map(_classAssignableToTypeNameStartingWith),
        description: 'are assignable to type names starting with all of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Selects declarations assignable to no type name starting with [prefixes].
  ClassPredicateBuilder areAssignableToTypeNameStartingWithNone(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        prefixList.map(_classAssignableToTypeNameStartingWith),
        description: 'are assignable to type name starting with none of ${prefixList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for assignability prefix rules.
extension ClassAssignableToTypeNameStartingWithShouldRules on ClassShouldBuilder {
  /// Requires matching classes to be assignable to a type whose name starts with [prefix].
  HeimdallRule<CompilationUnitMember> beAssignableToTypeNameStartingWith(
    String prefix,
  ) {
    return satisfy(_classShouldBeAssignableToTypeNameStartingWith(prefix));
  }

  /// Requires matching classes to not be assignable to a type whose name starts with [prefix].
  HeimdallRule<CompilationUnitMember> noBeAssignableToTypeNameStartingWith(
    String prefix,
  ) {
    return satisfy(_classShouldNotBeAssignableToTypeNameStartingWith(prefix));
  }

  /// Requires matching classes to be assignable to a type name starting with at least one prefix in [prefixes].
  HeimdallRule<CompilationUnitMember> beAssignableToTypeNameStartingWithAny(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.anyOf(
        prefixList.map(_classShouldBeAssignableToTypeNameStartingWith),
        description: 'be assignable to type name starting with any of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to be assignable to type names starting with every prefix in [prefixes].
  HeimdallRule<CompilationUnitMember> beAssignableToTypeNameStartingWithAll(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.allOf(
        prefixList.map(_classShouldBeAssignableToTypeNameStartingWith),
        description: 'be assignable to type names starting with all of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to be assignable to no type name starting with [prefixes].
  HeimdallRule<CompilationUnitMember> beAssignableToTypeNameStartingWithNone(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.noneOf(
        prefixList.map(_classShouldBeAssignableToTypeNameStartingWith),
        description: 'be assignable to type name starting with none of ${prefixList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _classAssignableToTypeNameStartingWith(
  String prefix,
) {
  return HeimdallPredicate(
    'are assignable to type name starting with $prefix',
    (item, project) => isAssignableToTypeNamedWhere(
      item,
      project,
      (typeName) => typeName.startsWith(prefix),
    ),
  );
}

HeimdallPredicate<CompilationUnitMember> _classNotAssignableToTypeNameStartingWith(
  String prefix,
) {
  return HeimdallPredicate(
    'are not assignable to type name starting with $prefix',
    (item, project) => !isAssignableToTypeNamedWhere(
      item,
      project,
      (typeName) => typeName.startsWith(prefix),
    ),
  );
}

HeimdallCondition<CompilationUnitMember> _classShouldBeAssignableToTypeNameStartingWith(String prefix) {
  return HeimdallCondition('be assignable to type name starting with $prefix', (
    item,
    project,
  ) {
    final findings =
        isAssignableToTypeNamedWhere(
          item,
          project,
          (typeName) => typeName.startsWith(prefix),
        )
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} should be assignable to a type name starting with $prefix',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotBeAssignableToTypeNameStartingWith(String prefix) {
  return HeimdallCondition('not be assignable to type name starting with $prefix', (
    item,
    project,
  ) {
    final findings =
        !isAssignableToTypeNamedWhere(
          item,
          project,
          (typeName) => typeName.startsWith(prefix),
        )
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} should not be assignable to a type name starting with $prefix',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
