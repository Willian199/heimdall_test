import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for class type name suffix rules.
extension ClassHaveTypeNameEndingWithPredicateRules on ClassPredicateBuilder {
  /// Selects declarations whose names end with [suffix].
  ClassPredicateBuilder haveTypeNameEndingWith(String suffix) {
    return satisfy(HeimdallPredicate('have type name ending with $suffix', (item, _) => item.name.endsWith(suffix)));
  }

  /// Selects declarations whose names do not end with [suffix].
  ClassPredicateBuilder noHaveTypeNameEndingWith(String suffix) {
    return satisfy(HeimdallPredicate('not have type name ending with $suffix', (item, _) => !item.name.endsWith(suffix)));
  }

  /// Selects declarations whose names end with at least one suffix in [suffixes].
  ClassPredicateBuilder haveTypeNameEndingWithAny(Iterable<String> suffixes) {
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
  ClassPredicateBuilder haveTypeNameEndingWithAll(Iterable<String> suffixes) {
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
  ClassPredicateBuilder haveTypeNameEndingWithNone(Iterable<String> suffixes) {
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
  HeimdallRule<CompilationUnitMember> noHaveTypeNameEndingWith(String suffix) {
    return satisfy(_classShouldNotHaveTypeNameEndingWith(suffix));
  }

  /// Requires matching class type names to end with at least one suffix in [suffixes].
  HeimdallRule<CompilationUnitMember> haveTypeNameEndingWithAny(
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
  HeimdallRule<CompilationUnitMember> haveTypeNameEndingWithAll(
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
  HeimdallRule<CompilationUnitMember> haveTypeNameEndingWithNone(
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
    final location = matches ? item.sourceLocationAt(_declarationNameOffset(item)) : null;
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

int _declarationNameOffset(CompilationUnitMember item) {
  return switch (item) {
    ClassDeclaration(:final namePart) => namePart.offset,
    MixinDeclaration(:final name) => name.offset,
    EnumDeclaration(:final namePart) => namePart.offset,
    ExtensionDeclaration(:final name?) => name.offset,
    ExtensionTypeDeclaration(:final primaryConstructor) => primaryConstructor.typeName.offset,
    TypeAlias(:final name) => name.offset,
    FunctionDeclaration(:final name) => name.offset,
    TopLevelVariableDeclaration(:final variables) => variables.variables.first.name.offset,
    _ => item.offset,
  };
}
