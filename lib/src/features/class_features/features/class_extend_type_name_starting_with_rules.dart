import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_rule_predicates.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';

/// Predicate-side DSL for class superclass prefix rules.
extension ClassExtendTypeNameStartingWithPredicateRules on ClassPredicateBuilder {
  /// Selects classes that extend a type whose name starts with [prefix].
  ClassPredicateBuilder extendTypeNameStartingWith(String prefix) {
    return satisfy(classExtendsTypeNameStartingWith(prefix));
  }

  /// Selects classes that do not extend a type whose name starts with [prefix].
  ClassPredicateBuilder notExtendTypeNameStartingWith(String prefix) {
    return satisfy(_classDoesNotExtendTypeNameStartingWith(prefix));
  }

  /// Selects classes that extend a type name starting with at least one prefix in [prefixes].
  ClassPredicateBuilder extendTypeNameStartingWithAnyOf(Iterable<String> prefixes) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        prefixList.map(classExtendsTypeNameStartingWith),
        description: 'extend type name starting with any of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Selects classes that extend type names starting with every prefix in [prefixes].
  ClassPredicateBuilder extendTypeNameStartingWithAllOf(Iterable<String> prefixes) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.allOf(
        prefixList.map(classExtendsTypeNameStartingWith),
        description: 'extend type names starting with all of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Selects classes that extend no type name starting with [prefixes].
  ClassPredicateBuilder extendTypeNameStartingWithNoneOf(Iterable<String> prefixes) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        prefixList.map(classExtendsTypeNameStartingWith),
        description: 'extend type name starting with none of ${prefixList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for class superclass prefix rules.
extension ClassExtendTypeNameStartingWithShouldRules on ClassShouldBuilder {
  /// Requires matching classes to extend a type whose name starts with [prefix].
  HeimdallRule<CompilationUnitMember> extendTypeNameStartingWith(String prefix) {
    return satisfy(_classShouldExtendTypeNameStartingWith(prefix));
  }

  /// Requires matching classes to not extend a type whose name starts with [prefix].
  HeimdallRule<CompilationUnitMember> notExtendTypeNameStartingWith(String prefix) {
    return satisfy(_classShouldNotExtendTypeNameStartingWith(prefix));
  }

  /// Requires matching classes to extend a type name starting with at least one prefix in [prefixes].
  HeimdallRule<CompilationUnitMember> extendTypeNameStartingWithAnyOf(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.anyOf(
        prefixList.map(_classShouldExtendTypeNameStartingWith),
        description: 'extend type name starting with any of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to extend type names starting with every prefix in [prefixes].
  HeimdallRule<CompilationUnitMember> extendTypeNameStartingWithAllOf(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.allOf(
        prefixList.map(_classShouldExtendTypeNameStartingWith),
        description: 'extend type names starting with all of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to extend no type name starting with [prefixes].
  HeimdallRule<CompilationUnitMember> extendTypeNameStartingWithNoneOf(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.noneOf(
        prefixList.map(_classShouldExtendTypeNameStartingWith),
        description: 'extend type name starting with none of ${prefixList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _classDoesNotExtendTypeNameStartingWith(
  String prefix,
) {
  return HeimdallPredicate(
    'not extend type name starting with $prefix',
    (item, project) => !extendsTypeNamedWhere(
      item,
      project,
      (typeName) => typeName.startsWith(prefix),
    ),
  );
}

HeimdallCondition<CompilationUnitMember> _classShouldExtendTypeNameStartingWith(
  String prefix,
) {
  return HeimdallCondition('extend type name starting with $prefix', (item, project) {
    final findings =
        extendsTypeNamedWhere(
          item,
          project,
          (typeName) => typeName.startsWith(prefix),
        )
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} should extend a type name starting with $prefix',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotExtendTypeNameStartingWith(
  String prefix,
) {
  return HeimdallCondition('not extend type name starting with $prefix', (item, project) {
    final findings =
        !extendsTypeNamedWhere(
          item,
          project,
          (typeName) => typeName.startsWith(prefix),
        )
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} should not extend a type name starting with $prefix',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
