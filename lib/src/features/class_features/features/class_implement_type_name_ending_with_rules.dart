import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';

/// Predicate-side DSL for implemented type suffix rules.
extension ClassImplementTypeNameEndingWithPredicateRules on ClassPredicateBuilder {
  /// Selects classes that implement a type whose name ends with [suffix].
  ClassPredicateBuilder implementTypeNameEndingWith(String suffix) {
    return satisfy(_classImplementsTypeNameEndingWith(suffix));
  }

  /// Selects classes that do not implement a type whose name ends with [suffix].
  ClassPredicateBuilder noImplementTypeNameEndingWith(String suffix) {
    return satisfy(_classDoesNotImplementTypeNameEndingWith(suffix));
  }

  /// Selects classes that implement a type name ending with at least one suffix in [suffixes].
  ClassPredicateBuilder implementTypeNameEndingWithAny(Iterable<String> suffixes) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        suffixList.map(_classImplementsTypeNameEndingWith),
        description: 'implement type name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects classes that implement type names ending with every suffix in [suffixes].
  ClassPredicateBuilder implementTypeNameEndingWithAll(Iterable<String> suffixes) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.allOf(
        suffixList.map(_classImplementsTypeNameEndingWith),
        description: 'implement type names ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects classes that implement no type name ending with [suffixes].
  ClassPredicateBuilder implementTypeNameEndingWithNone(Iterable<String> suffixes) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        suffixList.map(_classImplementsTypeNameEndingWith),
        description: 'implement type name ending with none of ${suffixList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for implemented type suffix rules.
extension ClassImplementTypeNameEndingWithShouldRules on ClassShouldBuilder {
  /// Requires matching classes to implement a type whose name ends with [suffix].
  HeimdallRule<CompilationUnitMember> implementTypeNameEndingWith(String suffix) {
    return satisfy(_classShouldImplementTypeNameEndingWith(suffix));
  }

  /// Requires matching classes to not implement a type whose name ends with [suffix].
  HeimdallRule<CompilationUnitMember> noImplementTypeNameEndingWith(String suffix) {
    return satisfy(_classShouldNotImplementTypeNameEndingWith(suffix));
  }

  /// Requires matching classes to implement a type name ending with at least one suffix in [suffixes].
  HeimdallRule<CompilationUnitMember> implementTypeNameEndingWithAny(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.anyOf(
        suffixList.map(_classShouldImplementTypeNameEndingWith),
        description: 'implement type name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to implement type names ending with every suffix in [suffixes].
  HeimdallRule<CompilationUnitMember> implementTypeNameEndingWithAll(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.allOf(
        suffixList.map(_classShouldImplementTypeNameEndingWith),
        description: 'implement type names ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to implement no type name ending with [suffixes].
  HeimdallRule<CompilationUnitMember> implementTypeNameEndingWithNone(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.noneOf(
        suffixList.map(_classShouldImplementTypeNameEndingWith),
        description: 'implement type name ending with none of ${suffixList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _classImplementsTypeNameEndingWith(
  String suffix,
) {
  return HeimdallPredicate(
    'implement type name ending with $suffix',
    (item, project) => implementsTypeNamedWhere(
      item,
      project,
      (typeName) => typeName.endsWith(suffix),
    ),
  );
}

HeimdallPredicate<CompilationUnitMember> _classDoesNotImplementTypeNameEndingWith(
  String suffix,
) {
  return HeimdallPredicate(
    'not implement type name ending with $suffix',
    (item, project) => !implementsTypeNamedWhere(
      item,
      project,
      (typeName) => typeName.endsWith(suffix),
    ),
  );
}

HeimdallCondition<CompilationUnitMember> _classShouldImplementTypeNameEndingWith(
  String suffix,
) {
  return HeimdallCondition('implement type name ending with $suffix', (item, project) {
    final findings =
        implementsTypeNamedWhere(
          item,
          project,
          (typeName) => typeName.endsWith(suffix),
        )
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} should implement a type name ending with $suffix',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotImplementTypeNameEndingWith(
  String suffix,
) {
  return HeimdallCondition('not implement type name ending with $suffix', (item, project) {
    final findings =
        !implementsTypeNamedWhere(
          item,
          project,
          (typeName) => typeName.endsWith(suffix),
        )
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} should not implement a type name ending with $suffix',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
