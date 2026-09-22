import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_rule_predicates.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';

/// Predicate-side DSL for exact class implementation rules.
extension ClassImplementPredicateRules on ClassPredicateBuilder {
  /// Selects classes that implement [typeName].
  ClassPredicateBuilder implement(String typeName) {
    return satisfy(classImplements(typeName));
  }

  /// Selects classes that do not implement [typeName].
  ClassPredicateBuilder notImplement(String typeName) {
    return satisfy(_classDoesNotImplement(typeName));
  }

  /// Selects classes that implement at least one type in [typeNames].
  ClassPredicateBuilder implementAnyOf(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        typeList.map(classImplements),
        description: 'implement any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects classes that implement every type in [typeNames].
  ClassPredicateBuilder implementAllOf(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.allOf(
        typeList.map(classImplements),
        description: 'implement all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects classes that implement none of [typeNames].
  ClassPredicateBuilder implementNoneOf(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        typeList.map(classImplements),
        description: 'implement none of ${typeList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for exact class implementation rules.
extension ClassImplementShouldRules on ClassShouldBuilder {
  /// Requires matching classes to implement [typeName].
  HeimdallRule<CompilationUnitMember> implement(String typeName) {
    return satisfy(_classShouldImplement(typeName));
  }

  /// Requires matching classes to not implement [typeName].
  HeimdallRule<CompilationUnitMember> notImplement(String typeName) {
    return satisfy(_classShouldNotImplement(typeName));
  }

  /// Requires matching classes to implement at least one type in [typeNames].
  HeimdallRule<CompilationUnitMember> implementAnyOf(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.anyOf(
        typeList.map(_classShouldImplement),
        description: 'implement any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to implement every type in [typeNames].
  HeimdallRule<CompilationUnitMember> implementAllOf(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.allOf(
        typeList.map(_classShouldImplement),
        description: 'implement all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to implement none of [typeNames].
  HeimdallRule<CompilationUnitMember> implementNoneOf(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.noneOf(
        typeList.map(_classShouldImplement),
        description: 'implement none of ${typeList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _classDoesNotImplement(String typeName) {
  return HeimdallPredicate(
    'not implement $typeName',
    (item, project) => !implementsType(item, typeName, project),
  );
}

HeimdallCondition<CompilationUnitMember> _classShouldImplement(
  String typeName,
) {
  return HeimdallCondition('implement $typeName', (item, project) {
    final findings = implementsType(item, typeName, project)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} should implement $typeName',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotImplement(
  String typeName,
) {
  return HeimdallCondition('not implement $typeName', (item, project) {
    final findings = !implementsType(item, typeName, project)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} should not implement $typeName',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
