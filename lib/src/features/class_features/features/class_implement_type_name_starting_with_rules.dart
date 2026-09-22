import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';

/// Predicate-side DSL for implemented type prefix rules.
extension ClassImplementStartingWithPredicateRules on ClassPredicateBuilder {
  /// Selects classes that implement a type whose name starts with [prefix].
  ClassPredicateBuilder implementTypeNameStartingWith(String prefix) {
    return satisfy(_classImplementsStartingWith(prefix));
  }

  /// Selects classes that do not implement a type whose name starts with [prefix].
  ClassPredicateBuilder notImplementTypeNameStartingWith(String prefix) {
    return satisfy(_classDoesNotImplementStartingWith(prefix));
  }

  /// Selects classes that implement a type name starting with at least one prefix in [prefixes].
  ClassPredicateBuilder implementTypeNameStartingWithAnyOf(Iterable<String> prefixes) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        prefixList.map(_classImplementsStartingWith),
        description: 'implement starting with any of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Selects classes that implement type names starting with every prefix in [prefixes].
  ClassPredicateBuilder implementTypeNameStartingWithAllOf(Iterable<String> prefixes) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.allOf(
        prefixList.map(_classImplementsStartingWith),
        description: 'implement starting with all of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Selects classes that implement no type name starting with [prefixes].
  ClassPredicateBuilder implementTypeNameStartingWithNoneOf(Iterable<String> prefixes) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        prefixList.map(_classImplementsStartingWith),
        description: 'implement starting with none of ${prefixList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for implemented type prefix rules.
extension ClassImplementStartingWithShouldRules on ClassShouldBuilder {
  /// Requires matching classes to implement a type whose name starts with [prefix].
  HeimdallRule<CompilationUnitMember> implementTypeNameStartingWith(String prefix) {
    return satisfy(_classShouldImplementStartingWith(prefix));
  }

  /// Requires matching classes to not implement a type whose name starts with [prefix].
  HeimdallRule<CompilationUnitMember> notImplementTypeNameStartingWith(String prefix) {
    return satisfy(_classShouldNotImplementStartingWith(prefix));
  }

  /// Requires matching classes to implement a type name starting with at least one prefix in [prefixes].
  HeimdallRule<CompilationUnitMember> implementTypeNameStartingWithAnyOf(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.anyOf(
        prefixList.map(_classShouldImplementStartingWith),
        description: 'implement starting with any of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to implement type names starting with every prefix in [prefixes].
  HeimdallRule<CompilationUnitMember> implementTypeNameStartingWithAllOf(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.allOf(
        prefixList.map(_classShouldImplementStartingWith),
        description: 'implement starting with all of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to implement no type name starting with [prefixes].
  HeimdallRule<CompilationUnitMember> implementTypeNameStartingWithNoneOf(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.noneOf(
        prefixList.map(_classShouldImplementStartingWith),
        description: 'implement starting with none of ${prefixList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _classImplementsStartingWith(
  String prefix,
) {
  return HeimdallPredicate(
    'implement starting with $prefix',
    (item, project) => implementsTypeNamedWhere(
      item,
      project,
      (typeName) => typeName.startsWith(prefix),
    ),
  );
}

HeimdallPredicate<CompilationUnitMember> _classDoesNotImplementStartingWith(
  String prefix,
) {
  return HeimdallPredicate(
    'not implement starting with $prefix',
    (item, project) => !implementsTypeNamedWhere(
      item,
      project,
      (typeName) => typeName.startsWith(prefix),
    ),
  );
}

HeimdallCondition<CompilationUnitMember> _classShouldImplementStartingWith(
  String prefix,
) {
  return HeimdallCondition('implement starting with $prefix', (item, project) {
    final findings =
        implementsTypeNamedWhere(
          item,
          project,
          (typeName) => typeName.startsWith(prefix),
        )
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} should implement a type name starting with $prefix',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotImplementStartingWith(
  String prefix,
) {
  return HeimdallCondition('not implement starting with $prefix', (item, project) {
    final findings =
        !implementsTypeNamedWhere(
          item,
          project,
          (typeName) => typeName.startsWith(prefix),
        )
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} should not implement a type name starting with $prefix',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
