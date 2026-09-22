import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_rule_predicates.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';

/// Predicate-side DSL for class inheritance rules.
extension ClassExtendPredicateRules on ClassPredicateBuilder {
  /// Selects classes that extend [typeName].
  ClassPredicateBuilder extend(String typeName) {
    return satisfy(classExtends(typeName));
  }

  /// Selects classes that do not extend [typeName].
  ClassPredicateBuilder notExtend(String typeName) {
    return satisfy(
      HeimdallPredicate(
        'not extend $typeName',
        (item, project) => !extendsType(item, typeName, project),
      ),
    );
  }

  /// Selects classes that extend at least one type in [typeNames].
  ClassPredicateBuilder extendAnyOf(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        typeList.map(classExtends),
        description: 'extend any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects classes that extend every type in [typeNames].
  ClassPredicateBuilder extendAllOf(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.allOf(
        typeList.map(classExtends),
        description: 'extend all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects classes that extend none of [typeNames].
  ClassPredicateBuilder extendNoneOf(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        typeList.map(classExtends),
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
  HeimdallRule<CompilationUnitMember> notExtend(String typeName) {
    return satisfy(_classShouldNotExtend(typeName));
  }

  /// Requires matching classes to extend at least one type in [typeNames].
  HeimdallRule<CompilationUnitMember> extendAnyOf(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.anyOf(
        typeList.map(_classShouldExtend),
        description: 'extend any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to extend every type in [typeNames].
  HeimdallRule<CompilationUnitMember> extendAllOf(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.allOf(
        typeList.map(_classShouldExtend),
        description: 'extend all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to extend none of [typeNames].
  HeimdallRule<CompilationUnitMember> extendNoneOf(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.noneOf(
        typeList.map(_classShouldExtend),
        description: 'extend none of ${typeList.join(', ')}',
      ),
    );
  }
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
