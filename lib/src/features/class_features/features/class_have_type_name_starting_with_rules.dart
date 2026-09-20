import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for class type name prefix rules.
extension ClassHaveTypeNameStartingWithPredicateRules on ClassPredicateBuilder {
  /// Selects declarations whose names start with [prefix].
  ClassPredicateBuilder haveTypeNameStartingWith(String prefix) {
    return satisfy(HeimdallPredicate('have type name starting with $prefix', (item, _) => item.name.startsWith(prefix)));
  }

  /// Selects declarations whose names do not start with [prefix].
  ClassPredicateBuilder noHaveTypeNameStartingWith(String prefix) {
    return satisfy(HeimdallPredicate('not have type name starting with $prefix', (item, _) => !item.name.startsWith(prefix)));
  }

  /// Selects declarations whose names start with at least one prefix in [prefixes].
  ClassPredicateBuilder haveTypeNameStartingWithAny(Iterable<String> prefixes) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        prefixList.map(
          (prefix) => HeimdallPredicate<CompilationUnitMember>('have type name starting with $prefix', (item, _) => item.name.startsWith(prefix)),
        ),
        description: 'have type name starting with any of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Selects declarations whose names start with every prefix in [prefixes].
  ClassPredicateBuilder haveTypeNameStartingWithAll(Iterable<String> prefixes) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.allOf(
        prefixList.map(
          (prefix) => HeimdallPredicate<CompilationUnitMember>('have type name starting with $prefix', (item, _) => item.name.startsWith(prefix)),
        ),
        description: 'have type name starting with all of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Selects declarations whose names start with none of [prefixes].
  ClassPredicateBuilder haveTypeNameStartingWithNone(Iterable<String> prefixes) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        prefixList.map(
          (prefix) => HeimdallPredicate<CompilationUnitMember>('have type name starting with $prefix', (item, _) => item.name.startsWith(prefix)),
        ),
        description: 'have type name starting with none of ${prefixList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for class type name prefix rules.
extension ClassHaveTypeNameStartingWithShouldRules on ClassShouldBuilder {
  /// Requires matching class type names to start with [prefix].
  HeimdallRule<CompilationUnitMember> haveTypeNameStartingWith(String prefix) {
    return satisfy(_classShouldHaveTypeNameStartingWith(prefix));
  }

  /// Requires matching class type names to not start with [prefix].
  HeimdallRule<CompilationUnitMember> noHaveTypeNameStartingWith(String prefix) {
    return satisfy(_classShouldNotHaveTypeNameStartingWith(prefix));
  }

  /// Requires matching class type names to start with at least one prefix in [prefixes].
  HeimdallRule<CompilationUnitMember> haveTypeNameStartingWithAny(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.anyOf(
        prefixList.map(_classShouldHaveTypeNameStartingWith),
        description: 'have type name starting with any of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Requires matching class type names to start with every prefix in [prefixes].
  HeimdallRule<CompilationUnitMember> haveTypeNameStartingWithAll(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.allOf(
        prefixList.map(_classShouldHaveTypeNameStartingWith),
        description: 'have type name starting with all of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Requires matching class type names to start with none of [prefixes].
  HeimdallRule<CompilationUnitMember> haveTypeNameStartingWithNone(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.noneOf(
        prefixList.map(_classShouldHaveTypeNameStartingWith),
        description: 'have type name starting with none of ${prefixList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<CompilationUnitMember> _classShouldHaveTypeNameStartingWith(
  String prefix,
) {
  return HeimdallCondition('have type name starting with $prefix', (item, _) {
    final findings = item.name.startsWith(prefix)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} should start with $prefix',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotHaveTypeNameStartingWith(
  String prefix,
) {
  return HeimdallCondition('not have type name starting with $prefix', (item, _) {
    final matches = item.name.startsWith(prefix);
    final location = matches ? item.sourceLocationAt(_declarationNameOffset(item)) : null;
    final findings = location == null
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: location.line,
              column: location.column,
              message: '${item.name} has prohibited type name starting with $prefix',
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
