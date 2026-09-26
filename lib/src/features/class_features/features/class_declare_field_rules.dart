import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for declared field rules.
extension ClassDeclareFieldPredicateRules on ClassPredicateBuilder {
  /// Selects classes that declare a field named [fieldName].
  ClassPredicateBuilder declareField(String fieldName) {
    return satisfy(_classDeclaresField(fieldName));
  }

  /// Selects classes that do not declare a field named [fieldName].
  ClassPredicateBuilder notDeclareField(String fieldName) {
    return satisfy(
      HeimdallPredicate(
        'not declare field $fieldName',
        (item, _) => !_declaresField(item, fieldName),
      ),
    );
  }

  /// Selects classes that declare every field in [fieldNames].
  ClassPredicateBuilder declareAllFields(Iterable<String> fieldNames) {
    final fieldList = fieldNames.toNonEmptyList('fieldNames');
    return satisfy(
      HeimdallPredicate.allOf(
        fieldList.map(_classDeclaresField),
        description: 'declare all fields ${fieldList.join(', ')}',
      ),
    );
  }

  /// Selects classes that declare at least one field in [fieldNames].
  ClassPredicateBuilder declareAnyField(Iterable<String> fieldNames) {
    final fieldList = fieldNames.toNonEmptyList('fieldNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        fieldList.map(_classDeclaresField),
        description: 'declare any fields ${fieldList.join(', ')}',
      ),
    );
  }

  /// Selects classes that declare none of [fieldNames].
  ClassPredicateBuilder declareNoFields(Iterable<String> fieldNames) {
    final fieldList = fieldNames.toNonEmptyList('fieldNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        fieldList.map(_classDeclaresField),
        description: 'declare no fields ${fieldList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for declared field rules.
extension ClassDeclareFieldShouldRules on ClassShouldBuilder {
  /// Requires matching classes to declare a field named [fieldName].
  HeimdallRule<CompilationUnitMember> declareField(String fieldName) {
    return satisfy(_classShouldDeclareField(fieldName));
  }

  /// Requires matching classes to not declare a field named [fieldName].
  HeimdallRule<CompilationUnitMember> notDeclareField(String fieldName) {
    return satisfy(_classShouldNotDeclareField(fieldName));
  }

  /// Requires matching classes to declare every field in [fieldNames].
  HeimdallRule<CompilationUnitMember> declareAllFields(
    Iterable<String> fieldNames,
  ) {
    final fieldList = fieldNames.toNonEmptyList('fieldNames');
    return satisfy(
      HeimdallCondition.allOf(
        fieldList.map(_classShouldDeclareField),
        description: 'declare all fields ${fieldList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to declare at least one field in [fieldNames].
  HeimdallRule<CompilationUnitMember> declareAnyField(
    Iterable<String> fieldNames,
  ) {
    final fieldList = fieldNames.toNonEmptyList('fieldNames');
    return satisfy(
      HeimdallCondition.anyOf(
        fieldList.map(_classShouldDeclareField),
        description: 'declare any fields ${fieldList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to declare none of [fieldNames].
  HeimdallRule<CompilationUnitMember> declareNoFields(
    Iterable<String> fieldNames,
  ) {
    final fieldList = fieldNames.toNonEmptyList('fieldNames');
    return satisfy(
      HeimdallCondition.noneOf(
        fieldList.map(_classShouldDeclareField),
        description: 'declare no fields ${fieldList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<CompilationUnitMember> _classShouldDeclareField(
  String fieldName,
) {
  return HeimdallCondition('declare field $fieldName', (item, _) {
    final findings = _declaresField(item, fieldName)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} does not declare field $fieldName',
            ),
          ];

    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotDeclareField(
  String fieldName,
) {
  return HeimdallCondition('not declare field $fieldName', (item, _) {
    final findings = _matchingFieldVariables(item, fieldName)
        .map(
          (match) => HeimdallValidationInfo(
            filePath: item.sourcePath,
            line: match.line,
            column: match.column,
            message: '${item.name} declares prohibited field $fieldName',
          ),
        )
        .toList();

    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<CompilationUnitMember> _classDeclaresField(
  String fieldName,
) {
  return HeimdallPredicate(
    'declare field $fieldName',
    (item, _) => _declaresField(item, fieldName),
  );
}

bool _declaresField(CompilationUnitMember item, String fieldName) {
  return item.fieldVariables.any((variable) => variable.name.lexeme == fieldName);
}

Iterable<({int line, int column})> _matchingFieldVariables(
  CompilationUnitMember item,
  String fieldName,
) sync* {
  for (final variable in item.fieldVariables) {
    if (variable.name.lexeme != fieldName) {
      continue;
    }
    
    yield item.sourceLocationAt(variable.name.offset);
  }
}
