import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';

/// Predicate-side DSL for class inheritance rules.
extension ClassExtendPredicateRules on ClassPredicateBuilder {
  /// Selects classes that extend [typeName].
  ClassPredicateBuilder extend(String typeName) {
    return satisfy(_classExtends(typeName));
  }

  /// Selects classes that do not extend [typeName].
  ClassPredicateBuilder noExtend(String typeName) {
    return satisfy(
      HeimdallPredicate(
        'not extend $typeName',
        (item, project) => !extendsType(item, typeName, project),
      ),
    );
  }

  /// Selects classes that extend at least one type in [typeNames].
  ClassPredicateBuilder extendAny(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        typeList.map(_classExtends),
        description: 'extend any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects classes that extend every type in [typeNames].
  ClassPredicateBuilder extendAll(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.allOf(
        typeList.map(_classExtends),
        description: 'extend all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects classes that extend none of [typeNames].
  ClassPredicateBuilder extendNone(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        typeList.map(_classExtends),
        description: 'extend none of ${typeList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for class inheritance rules.
extension ClassExtendShouldRules on ClassShouldBuilder {
  /// Requires matching classes to extend [typeName].
  HeimdallRule<CompilationUnitMember> extend(String typeName) {
    return satisfy(_classShouldExtend(typeName));
  }

  /// Requires matching classes to not extend [typeName].
  HeimdallRule<CompilationUnitMember> noExtend(String typeName) {
    return satisfy(_classShouldNotExtend(typeName));
  }

  /// Requires matching classes to extend at least one type in [typeNames].
  HeimdallRule<CompilationUnitMember> extendAny(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.anyOf(
        typeList.map(_classShouldExtend),
        description: 'extend any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to extend every type in [typeNames].
  HeimdallRule<CompilationUnitMember> extendAll(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.allOf(
        typeList.map(_classShouldExtend),
        description: 'extend all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to extend none of [typeNames].
  HeimdallRule<CompilationUnitMember> extendNone(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.noneOf(
        typeList.map(_classShouldExtend),
        description: 'extend none of ${typeList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _classExtends(String typeName) {
  return HeimdallPredicate(
    'extend $typeName',
    (item, project) => extendsType(item, typeName, project),
  );
}

HeimdallCondition<CompilationUnitMember> _classShouldExtend(String typeName) {
  return HeimdallCondition('extend $typeName', (item, project) {
    final findings = extendsType(item, typeName, project)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} should extend $typeName',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotExtend(String typeName) {
  return HeimdallCondition('not extend $typeName', (item, project) {
    final findings = !extendsType(item, typeName, project)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} should not extend $typeName',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
