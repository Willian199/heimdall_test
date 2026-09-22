import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for public field rules.
extension ClassHavePublicFieldsPredicateRules on ClassPredicateBuilder {
  /// Selects classes where every declared field is public.
  ClassPredicateBuilder haveOnlyPublicFields() {
    return satisfy(_classHasOnlyPublicFields());
  }

  /// Selects classes with no fields or at least one private field.
  ClassPredicateBuilder notHaveOnlyPublicFields() {
    return satisfy(_classDoesNotHaveOnlyPublicFields());
  }

  /// Selects classes where every field in [fieldNames] is public.
  ClassPredicateBuilder havePublicFieldsNamedAllOf(Iterable<String> fieldNames) {
    final fieldList = fieldNames.toNonEmptyList('fieldNames');
    return satisfy(
      HeimdallPredicate.allOf(
        fieldList.map(_classHasPublicField),
        description: 'have all public fields ${fieldList.join(', ')}',
      ),
    );
  }

  /// Selects classes where at least one field in [fieldNames] is public.
  ClassPredicateBuilder havePublicFieldNamedAnyOf(Iterable<String> fieldNames) {
    final fieldList = fieldNames.toNonEmptyList('fieldNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        fieldList.map(_classHasPublicField),
        description: 'have any public field ${fieldList.join(', ')}',
      ),
    );
  }

  /// Selects classes where none of [fieldNames] is public.
  ClassPredicateBuilder haveNoPublicFieldsNamed(Iterable<String> fieldNames) {
    final fieldList = fieldNames.toNonEmptyList('fieldNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        fieldList.map(_classHasPublicField),
        description: 'have no public fields ${fieldList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for public field rules.
extension ClassHavePublicFieldsShouldRules on ClassShouldBuilder {
  /// Requires matching classes to declare only public fields.
  HeimdallRule<CompilationUnitMember> haveOnlyPublicFields() {
    return satisfy(_classShouldHaveOnlyPublicFields());
  }

  /// Requires matching classes to have at least one private field.
  HeimdallRule<CompilationUnitMember> notHaveOnlyPublicFields() {
    return satisfy(_classShouldNotHaveOnlyPublicFields());
  }

  /// Requires every field in [fieldNames] to be public.
  HeimdallRule<CompilationUnitMember> havePublicFieldsNamedAllOf(
    Iterable<String> fieldNames,
  ) {
    final fieldList = fieldNames.toNonEmptyList('fieldNames');
    return satisfy(
      HeimdallCondition.allOf(
        fieldList.map(_classShouldHavePublicField),
        description: 'have all public fields ${fieldList.join(', ')}',
      ),
    );
  }

  /// Requires at least one field in [fieldNames] to be public.
  HeimdallRule<CompilationUnitMember> havePublicFieldNamedAnyOf(
    Iterable<String> fieldNames,
  ) {
    final fieldList = fieldNames.toNonEmptyList('fieldNames');
    return satisfy(
      HeimdallCondition.anyOf(
        fieldList.map(_classShouldHavePublicField),
        description: 'have any public field ${fieldList.join(', ')}',
      ),
    );
  }

  /// Requires none of [fieldNames] to be public.
  HeimdallRule<CompilationUnitMember> haveNoPublicFieldsNamed(
    Iterable<String> fieldNames,
  ) {
    final fieldList = fieldNames.toNonEmptyList('fieldNames');
    return satisfy(
      HeimdallCondition.noneOf(
        fieldList.map(_classShouldHavePublicField),
        description: 'have no public fields ${fieldList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<CompilationUnitMember> _classShouldHaveOnlyPublicFields() {
  return HeimdallCondition('have only public fields', (item, _) {
    final fieldVariables = item.fieldVariables;
    final findings = fieldVariables.isEmpty
        ? [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} declares no fields',
            ),
          ]
        : fieldVariables.where(_isPrivateFieldVariable).map(
            (variable) {
              final location = item.sourceLocationAt(variable.name.offset);
              return HeimdallValidationInfo(
                filePath: item.sourcePath,
                line: location.line,
                column: location.column,
                message: '${item.name}.${variable.name.lexeme} is not public',
              );
            },
          ).toList();
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotHaveOnlyPublicFields() {
  return HeimdallCondition('not have only public fields', (item, _) {
    final fieldVariables = item.fieldVariables;
    final findings = fieldVariables.isEmpty || fieldVariables.any(_isPrivateFieldVariable)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} declares only public fields',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldHavePublicField(
  String fieldName,
) {
  return HeimdallCondition('have public field $fieldName', (item, _) {
    final findings = _hasPublicField(item, fieldName)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} does not declare public field $fieldName',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<CompilationUnitMember> _classHasOnlyPublicFields() {
  return HeimdallPredicate(
    'have only public fields',
    (item, _) {
      final fieldVariables = item.fieldVariables;
      return fieldVariables.isNotEmpty && fieldVariables.every((variable) => !variable.name.lexeme.startsWith('_'));
    },
  );
}

HeimdallPredicate<CompilationUnitMember> _classDoesNotHaveOnlyPublicFields() {
  return HeimdallPredicate(
    'not have only public fields',
    (item, _) {
      final fieldVariables = item.fieldVariables;
      return fieldVariables.isEmpty || fieldVariables.any(_isPrivateFieldVariable);
    },
  );
}

HeimdallPredicate<CompilationUnitMember> _classHasPublicField(
  String fieldName,
) {
  return HeimdallPredicate(
    'have public field $fieldName',
    (item, _) => _hasPublicField(item, fieldName),
  );
}

bool _hasPublicField(CompilationUnitMember item, String fieldName) {
  return item.fieldVariables.any(
    (variable) => variable.name.lexeme == fieldName && !fieldName.startsWith('_'),
  );
}

bool _isPrivateFieldVariable(VariableDeclaration variable) => variable.name.lexeme.startsWith('_');
