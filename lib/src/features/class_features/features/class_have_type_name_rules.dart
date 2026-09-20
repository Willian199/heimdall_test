import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for exact class type name rules.
extension ClassHaveTypeNamePredicateRules on ClassPredicateBuilder {
  /// Selects declarations with exactly [name].
  ClassPredicateBuilder haveTypeName(String name) => satisfy(_classHasTypeName(name));

  /// Selects declarations whose type name is not [name].
  ClassPredicateBuilder noHaveTypeName(String name) {
    return satisfy(_classDoesNotHaveTypeName(name));
  }

  /// Selects declarations with any name in [names].
  ClassPredicateBuilder haveTypeNameAny(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.anyOf(
        nameList.map(_classHasTypeName),
        description: 'have any type name ${nameList.join(', ')}',
      ),
    );
  }

  /// Selects declarations with every name in [names].
  ClassPredicateBuilder haveTypeNameAll(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.allOf(
        nameList.map(_classHasTypeName),
        description: 'have all type names ${nameList.join(', ')}',
      ),
    );
  }

  /// Selects declarations with none of [names].
  ClassPredicateBuilder haveTypeNameNone(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallPredicate.noneOf(
        nameList.map(_classHasTypeName),
        description: 'have no type names ${nameList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for exact class type name rules.
extension ClassHaveTypeNameShouldRules on ClassShouldBuilder {
  /// Requires matching class type names to equal [name].
  HeimdallRule<CompilationUnitMember> haveTypeName(String name) {
    return satisfy(_classShouldHaveTypeName(name));
  }

  /// Requires matching class type names to not equal [name].
  HeimdallRule<CompilationUnitMember> noHaveTypeName(String name) {
    return satisfy(_classShouldNotHaveTypeName(name));
  }

  /// Requires matching class type names to equal at least one name in [names].
  HeimdallRule<CompilationUnitMember> haveTypeNameAny(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.anyOf(
        nameList.map(_classShouldHaveTypeName),
        description: 'have any type name ${nameList.join(', ')}',
      ),
    );
  }

  /// Requires matching class type names to equal every name in [names].
  HeimdallRule<CompilationUnitMember> haveTypeNameAll(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.allOf(
        nameList.map(_classShouldHaveTypeName),
        description: 'have all type names ${nameList.join(', ')}',
      ),
    );
  }

  /// Requires matching class type names to equal none of [names].
  HeimdallRule<CompilationUnitMember> haveTypeNameNone(Iterable<String> names) {
    final nameList = names.toNonEmptyList('names');
    return satisfy(
      HeimdallCondition.noneOf(
        nameList.map(_classShouldHaveTypeName),
        description: 'have no type names ${nameList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _classHasTypeName(String name) {
  return HeimdallPredicate('have type name $name', (item, _) => item.name == name);
}

HeimdallPredicate<CompilationUnitMember> _classDoesNotHaveTypeName(String name) {
  return HeimdallPredicate('not have type name $name', (item, _) => item.name != name);
}

HeimdallCondition<CompilationUnitMember> _classShouldHaveTypeName(String name) {
  return HeimdallCondition('have type name $name', (item, _) {
    final findings = item.name == name
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} should have type name $name',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotHaveTypeName(String name) {
  return HeimdallCondition('not have type name $name', (item, _) {
    final matches = item.name == name;
    final location = matches ? item.sourceLocationAt(_declarationNameOffset(item)) : null;
    final findings = location == null
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: location.line,
              column: location.column,
              message: '${item.name} has prohibited type name $name',
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
