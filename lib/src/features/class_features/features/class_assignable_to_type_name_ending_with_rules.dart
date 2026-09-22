import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_rule_predicates.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';

/// Predicate-side DSL for assignability suffix rules.
extension ClassAssignableToTypeNameEndingWithPredicateRules on ClassPredicateBuilder {
  /// Selects declarations assignable to a type whose name ends with [suffix].
  ClassPredicateBuilder areAssignableToTypeNameEndingWith(String suffix) {
    return satisfy(classAssignableToTypeNameEndingWith(suffix));
  }

  /// Selects declarations not assignable to a type whose name ends with [suffix].
  ClassPredicateBuilder areNotAssignableToTypeNameEndingWith(String suffix) {
    return satisfy(_classNotAssignableToTypeNameEndingWith(suffix));
  }

  /// Selects declarations assignable to a type name ending with at least one suffix in [suffixes].
  ClassPredicateBuilder areAssignableToTypeNameEndingWithAnyOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        suffixList.map(classAssignableToTypeNameEndingWith),
        description: 'are assignable to type name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects declarations assignable to type names ending with every suffix in [suffixes].
  ClassPredicateBuilder areAssignableToTypeNameEndingWithAllOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.allOf(
        suffixList.map(classAssignableToTypeNameEndingWith),
        description: 'are assignable to type names ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects declarations assignable to no type name ending with [suffixes].
  ClassPredicateBuilder areAssignableToTypeNameEndingWithNoneOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        suffixList.map(classAssignableToTypeNameEndingWith),
        description: 'are assignable to type name ending with none of ${suffixList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for assignability suffix rules.
extension ClassAssignableToTypeNameEndingWithShouldRules on ClassShouldBuilder {
  /// Requires matching classes to be assignable to a type whose name ends with [suffix].
  HeimdallRule<CompilationUnitMember> beAssignableToTypeNameEndingWith(
    String suffix,
  ) {
    return satisfy(_classShouldBeAssignableToTypeNameEndingWith(suffix));
  }

  /// Requires matching classes to not be assignable to a type whose name ends with [suffix].
  HeimdallRule<CompilationUnitMember> notBeAssignableToTypeNameEndingWith(
    String suffix,
  ) {
    return satisfy(_classShouldNotBeAssignableToTypeNameEndingWith(suffix));
  }

  /// Requires matching classes to be assignable to a type name ending with at least one suffix in [suffixes].
  HeimdallRule<CompilationUnitMember> beAssignableToTypeNameEndingWithAnyOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.anyOf(
        suffixList.map(_classShouldBeAssignableToTypeNameEndingWith),
        description: 'be assignable to type name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to be assignable to type names ending with every suffix in [suffixes].
  HeimdallRule<CompilationUnitMember> beAssignableToTypeNameEndingWithAllOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.allOf(
        suffixList.map(_classShouldBeAssignableToTypeNameEndingWith),
        description: 'be assignable to type names ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to be assignable to no type name ending with [suffixes].
  HeimdallRule<CompilationUnitMember> beAssignableToTypeNameEndingWithNoneOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.noneOf(
        suffixList.map(_classShouldBeAssignableToTypeNameEndingWith),
        description: 'be assignable to type name ending with none of ${suffixList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _classNotAssignableToTypeNameEndingWith(
  String suffix,
) {
  return HeimdallPredicate(
    'are not assignable to type name ending with $suffix',
    (item, project) => !isAssignableToTypeNamedWhere(
      item,
      project,
      (typeName) => typeName.endsWith(suffix),
    ),
  );
}

HeimdallCondition<CompilationUnitMember> _classShouldBeAssignableToTypeNameEndingWith(String suffix) {
  return HeimdallCondition('be assignable to type name ending with $suffix', (
    item,
    project,
  ) {
    final findings =
        isAssignableToTypeNamedWhere(
          item,
          project,
          (typeName) => typeName.endsWith(suffix),
        )
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} should be assignable to a type name ending with $suffix',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotBeAssignableToTypeNameEndingWith(String suffix) {
  return HeimdallCondition('not be assignable to type name ending with $suffix', (
    item,
    project,
  ) {
    final findings =
        !isAssignableToTypeNamedWhere(
          item,
          project,
          (typeName) => typeName.endsWith(suffix),
        )
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} should not be assignable to a type name ending with $suffix',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
