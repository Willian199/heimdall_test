import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_location_queries.dart';

/// Predicate-side DSL for class type name suffix rules.
extension ClassHaveTypeNameEndingWithPredicateRules on ClassPredicateBuilder {
  /// Selects declarations whose names end with [suffix].
  ClassPredicateBuilder haveTypeNameEndingWith(String suffix) {
    return satisfy(HeimdallPredicate('have type name ending with $suffix', (item, _) => item.name.endsWith(suffix)));
  }

  /// Selects declarations whose names do not end with [suffix].
  ClassPredicateBuilder notHaveTypeNameEndingWith(String suffix) {
    return satisfy(HeimdallPredicate('not have type name ending with $suffix', (item, _) => !item.name.endsWith(suffix)));
  }

  /// Selects declarations whose names end with at least one suffix in [suffixes].
  ClassPredicateBuilder haveTypeNameEndingWithAnyOf(Iterable<String> suffixes) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        suffixList.map(
          (suffix) => HeimdallPredicate<CompilationUnitMember>('have type name ending with $suffix', (item, _) => item.name.endsWith(suffix)),
        ),
        description: 'have type name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects declarations whose names end with every suffix in [suffixes].
  ClassPredicateBuilder haveTypeNameEndingWithAllOf(Iterable<String> suffixes) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.allOf(
        suffixList.map(
          (suffix) => HeimdallPredicate<CompilationUnitMember>('have type name ending with $suffix', (item, _) => item.name.endsWith(suffix)),
        ),
        description: 'have type name ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects declarations whose names end with none of [suffixes].
  ClassPredicateBuilder haveTypeNameEndingWithNoneOf(Iterable<String> suffixes) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        suffixList.map(
          (suffix) => HeimdallPredicate<CompilationUnitMember>('have type name ending with $suffix', (item, _) => item.name.endsWith(suffix)),
        ),
        description: 'have type name ending with none of ${suffixList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for class type name suffix rules.
extension ClassHaveTypeNameEndingWithShouldRules on ClassShouldBuilder {
  /// Requires matching class type names to end with [suffix].
  HeimdallRule<CompilationUnitMember> haveTypeNameEndingWith(String suffix) {
    return satisfy(_classShouldHaveTypeNameEndingWith(suffix));
  }

  /// Requires matching class type names to not end with [suffix].
  HeimdallRule<CompilationUnitMember> notHaveTypeNameEndingWith(String suffix) {
    return satisfy(_classShouldNotHaveTypeNameEndingWith(suffix));
  }

  /// Requires matching class type names to end with at least one suffix in [suffixes].
  HeimdallRule<CompilationUnitMember> haveTypeNameEndingWithAnyOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.anyOf(
        suffixList.map(_classShouldHaveTypeNameEndingWith),
        description: 'have type name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires matching class type names to end with every suffix in [suffixes].
  HeimdallRule<CompilationUnitMember> haveTypeNameEndingWithAllOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.allOf(
        suffixList.map(_classShouldHaveTypeNameEndingWith),
        description: 'have type name ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires matching class type names to end with none of [suffixes].
  HeimdallRule<CompilationUnitMember> haveTypeNameEndingWithNoneOf(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.noneOf(
        suffixList.map(_classShouldHaveTypeNameEndingWith),
        description: 'have type name ending with none of ${suffixList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<CompilationUnitMember> _classShouldHaveTypeNameEndingWith(
  String suffix,
) {
  return HeimdallCondition('have type name ending with $suffix', (item, _) {
    final findings = item.name.endsWith(suffix)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} should end with $suffix',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotHaveTypeNameEndingWith(
  String suffix,
) {
  return HeimdallCondition('not have type name ending with $suffix', (item, _) {
    final matches = item.name.endsWith(suffix);
    final location = matches ? item.sourceLocationAt(declarationNameOffset(item)) : null;
    final findings = location == null
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: location.line,
              column: location.column,
              message: '${item.name} has prohibited type name ending with $suffix',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
