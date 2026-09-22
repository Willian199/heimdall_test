import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_rule_predicates.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';

/// Predicate-side DSL for class superclass suffix rules.
extension ClassExtendTypeNameEndingWithPredicateRules on ClassPredicateBuilder {
  /// Selects classes that extend a type whose name ends with [suffix].
  ClassPredicateBuilder extendTypeNameEndingWith(String suffix) {
    return satisfy(classExtendsTypeNameEndingWith(suffix));
  }

  /// Selects classes that do not extend a type whose name ends with [suffix].
  ClassPredicateBuilder notExtendTypeNameEndingWith(String suffix) {
    return satisfy(_classDoesNotExtendTypeNameEndingWith(suffix));
  }

  /// Selects classes that extend a type name ending with at least one suffix in [suffixes].
  ClassPredicateBuilder extendTypeNameEndingWithAnyOf(Iterable<String> suffixes) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        suffixList.map(classExtendsTypeNameEndingWith),
        description: 'extend type name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects classes that extend type names ending with every suffix in [suffixes].
  ClassPredicateBuilder extendTypeNameEndingWithAllOf(Iterable<String> suffixes) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.allOf(
        suffixList.map(classExtendsTypeNameEndingWith),
        description: 'extend type names ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects classes that extend no type name ending with [suffixes].
  ClassPredicateBuilder extendTypeNameEndingWithNoneOf(Iterable<String> suffixes) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        suffixList.map(classExtendsTypeNameEndingWith),
        description: 'extend type name ending with none of ${suffixList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for class superclass suffix rules.
extension ClassExtendTypeNameEndingWithShouldRules on ClassShouldBuilder {
  /// Requires matching classes to extend a type whose name ends with [suffix].
  HeimdallRule<CompilationUnitMember> extendTypeNameEndingWith(String suffix) {
    return satisfy(_classShouldExtendTypeNameEndingWith(suffix));
  }

  /// Requires matching classes to not extend a type whose name ends with [suffix].
  HeimdallRule<CompilationUnitMember> notExtendTypeNameEndingWith(String suffix) {
    return satisfy(_classShouldNotExtendTypeNameEndingWith(suffix));
  }

  /// Requires matching classes to extend a type name ending with at least one suffix in [suffixes].
  HeimdallRule<CompilationUnitMember> extendTypeNameEndingWithAnyOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.anyOf(
        suffixList.map(_classShouldExtendTypeNameEndingWith),
        description: 'extend type name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to extend type names ending with every suffix in [suffixes].
  HeimdallRule<CompilationUnitMember> extendTypeNameEndingWithAllOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.allOf(
        suffixList.map(_classShouldExtendTypeNameEndingWith),
        description: 'extend type names ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to extend no type name ending with [suffixes].
  HeimdallRule<CompilationUnitMember> extendTypeNameEndingWithNoneOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.noneOf(
        suffixList.map(_classShouldExtendTypeNameEndingWith),
        description: 'extend type name ending with none of ${suffixList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _classDoesNotExtendTypeNameEndingWith(
  String suffix,
) {
  return HeimdallPredicate(
    'not extend type name ending with $suffix',
    (item, project) => !extendsTypeNamedWhere(
      item,
      project,
      (typeName) => typeName.endsWith(suffix),
    ),
  );
}

HeimdallCondition<CompilationUnitMember> _classShouldExtendTypeNameEndingWith(
  String suffix,
) {
  return HeimdallCondition('extend type name ending with $suffix', (item, project) {
    final findings =
        extendsTypeNamedWhere(
          item,
          project,
          (typeName) => typeName.endsWith(suffix),
        )
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} should extend a type name ending with $suffix',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotExtendTypeNameEndingWith(
  String suffix,
) {
  return HeimdallCondition('not extend type name ending with $suffix', (item, project) {
    final findings =
        !extendsTypeNamedWhere(
          item,
          project,
          (typeName) => typeName.endsWith(suffix),
        )
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} should not extend a type name ending with $suffix',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
