import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_rule_predicates.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';

/// Predicate-side DSL for exact assignability rules.
extension ClassAssignableToPredicateRules on ClassPredicateBuilder {
  /// Selects declarations assignable to [typeName].
  ClassPredicateBuilder areAssignableTo(String typeName) {
    return satisfy(classAssignableTo(typeName));
  }

  /// Selects declarations that are not assignable to [typeName].
  ClassPredicateBuilder areNotAssignableTo(String typeName) {
    return satisfy(
      HeimdallPredicate(
        'are not assignable to $typeName',
        (item, project) => !isAssignableTo(item, typeName, project),
      ),
    );
  }

  /// Selects declarations assignable to at least one type in [typeNames].
  ClassPredicateBuilder areAssignableToAnyOf(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        typeList.map(classAssignableTo),
        description: 'are assignable to any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects declarations assignable to every type in [typeNames].
  ClassPredicateBuilder areAssignableToAllOf(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.allOf(
        typeList.map(classAssignableTo),
        description: 'are assignable to all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects declarations assignable to none of [typeNames].
  ClassPredicateBuilder areAssignableToNoneOf(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        typeList.map(classAssignableTo),
        description: 'are assignable to none of ${typeList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for exact assignability rules.
extension ClassAssignableToShouldRules on ClassShouldBuilder {
  /// Requires matching classes to be assignable to [typeName].
  HeimdallRule<CompilationUnitMember> beAssignableTo(String typeName) {
    return satisfy(_classShouldBeAssignableTo(typeName));
  }

  /// Requires matching classes to not be assignable to [typeName].
  HeimdallRule<CompilationUnitMember> notBeAssignableTo(String typeName) {
    return satisfy(_classShouldNotBeAssignableTo(typeName));
  }

  /// Requires matching classes to be assignable to at least one type in [typeNames].
  HeimdallRule<CompilationUnitMember> beAssignableToAnyOf(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.anyOf(
        typeList.map(_classShouldBeAssignableTo),
        description: 'be assignable to any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to be assignable to every type in [typeNames].
  HeimdallRule<CompilationUnitMember> beAssignableToAllOf(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.allOf(
        typeList.map(_classShouldBeAssignableTo),
        description: 'be assignable to all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to be assignable to none of [typeNames].
  HeimdallRule<CompilationUnitMember> beAssignableToNoneOf(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.noneOf(
        typeList.map(_classShouldBeAssignableTo),
        description: 'be assignable to none of ${typeList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<CompilationUnitMember> _classShouldBeAssignableTo(
  String typeName,
) {
  return HeimdallCondition('be assignable to $typeName', (item, project) {
    final findings = isAssignableTo(item, typeName, project)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} should be assignable to $typeName',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotBeAssignableTo(
  String typeName,
) {
  return HeimdallCondition('not be assignable to $typeName', (item, project) {
    final findings = !isAssignableTo(item, typeName, project)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} should not be assignable to $typeName',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
