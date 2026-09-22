import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for classes whose fields must be final.
extension ClassHaveFinalFieldsPredicateRules on ClassPredicateBuilder {
  /// Selects classes that declare only final fields.
  ClassPredicateBuilder haveOnlyFinalFields() {
    return satisfy(_classHasOnlyFinalFields());
  }

  /// Selects classes with no fields or at least one non-final field.
  ClassPredicateBuilder notHaveOnlyFinalFields() {
    return satisfy(_classDoesNotHaveOnlyFinalFields());
  }

  /// Selects classes where every field in [fieldNames] is final.
  ClassPredicateBuilder haveFinalFieldsNamedAllOf(Iterable<String> fieldNames) {
    final fieldList = fieldNames.toNonEmptyList('fieldNames');
    return satisfy(
      HeimdallPredicate.allOf(
        fieldList.map(_classHasFinalField),
        description: 'have all final fields ${fieldList.join(', ')}',
      ),
    );
  }

  /// Selects classes where at least one field in [fieldNames] is final.
  ClassPredicateBuilder haveFinalFieldNamedAnyOf(Iterable<String> fieldNames) {
    final fieldList = fieldNames.toNonEmptyList('fieldNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        fieldList.map(_classHasFinalField),
        description: 'have any final field ${fieldList.join(', ')}',
      ),
    );
  }

  /// Selects classes where none of [fieldNames] is final.
  ClassPredicateBuilder haveNoFinalFieldsNamed(Iterable<String> fieldNames) {
    final fieldList = fieldNames.toNonEmptyList('fieldNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        fieldList.map(_classHasFinalField),
        description: 'have no final fields ${fieldList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for classes that must expose only final fields.
extension ClassHaveFinalFieldsShouldRules on ClassShouldBuilder {
  /// Requires matching classes to declare only final fields.
  HeimdallRule<CompilationUnitMember> haveOnlyFinalFields() {
    return satisfy(_classShouldHaveOnlyFinalFields());
  }

  /// Requires no fields or at least one non-final field.
  HeimdallRule<CompilationUnitMember> notHaveOnlyFinalFields() {
    return satisfy(_classShouldNotHaveOnlyFinalFields());
  }

  /// Requires every field in [fieldNames] to be final.
  HeimdallRule<CompilationUnitMember> haveFinalFieldsNamedAllOf(
    Iterable<String> fieldNames,
  ) {
    final fieldList = fieldNames.toNonEmptyList('fieldNames');
    return satisfy(
      HeimdallCondition.allOf(
        fieldList.map(_classShouldHaveFinalField),
        description: 'have all final fields ${fieldList.join(', ')}',
      ),
    );
  }

  /// Requires at least one field in [fieldNames] to be final.
  HeimdallRule<CompilationUnitMember> haveFinalFieldNamedAnyOf(
    Iterable<String> fieldNames,
  ) {
    final fieldList = fieldNames.toNonEmptyList('fieldNames');
    return satisfy(
      HeimdallCondition.anyOf(
        fieldList.map(_classShouldHaveFinalField),
        description: 'have any final field ${fieldList.join(', ')}',
      ),
    );
  }

  /// Requires none of [fieldNames] to be final.
  HeimdallRule<CompilationUnitMember> haveNoFinalFieldsNamed(
    Iterable<String> fieldNames,
  ) {
    final fieldList = fieldNames.toNonEmptyList('fieldNames');
    return satisfy(
      HeimdallCondition.noneOf(
        fieldList.map(_classShouldHaveFinalField),
        description: 'have no final fields ${fieldList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<CompilationUnitMember> _classShouldHaveOnlyFinalFields() {
  return HeimdallCondition('have only final fields', (item, _) {
    final fields = item.fields;
    final findings = fields.isEmpty
        ? [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} declares no fields',
            ),
          ]
        : fields
              .where((member) => !member.isFinal)
              .map(
                (member) => HeimdallValidationInfo(
                  filePath: item.sourcePath,
                  line: member.line,
                  message: '${item.name}.${member.name} is not final',
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

HeimdallCondition<CompilationUnitMember> _classShouldNotHaveOnlyFinalFields() {
  return HeimdallCondition('not have only final fields', (item, _) {
    final fields = item.fields;
    final findings = fields.isEmpty || fields.any((member) => !member.isFinal)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} declares only final fields',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldHaveFinalField(
  String fieldName,
) {
  return HeimdallCondition('have final field $fieldName', (item, _) {
    final findings = _hasFinalField(item, fieldName)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} does not declare final field $fieldName',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<CompilationUnitMember> _classHasOnlyFinalFields() {
  return HeimdallPredicate(
    'have only final fields',
    (item, _) {
      final fields = item.fields;
      return fields.isNotEmpty && fields.every((member) => member.isFinal);
    },
  );
}

HeimdallPredicate<CompilationUnitMember> _classDoesNotHaveOnlyFinalFields() {
  return HeimdallPredicate(
    'not have only final fields',
    (item, _) {
      final fields = item.fields;
      return fields.isEmpty || fields.any((member) => !member.isFinal);
    },
  );
}

HeimdallPredicate<CompilationUnitMember> _classHasFinalField(
  String fieldName,
) {
  return HeimdallPredicate(
    'have final field $fieldName',
    (item, _) => _hasFinalField(item, fieldName),
  );
}

bool _hasFinalField(CompilationUnitMember item, String fieldName) {
  return item.fields.any(
    (field) =>
        field.isFinal &&
        field.fields.variables.any(
          (variable) => variable.name.lexeme == fieldName,
        ),
  );
}
