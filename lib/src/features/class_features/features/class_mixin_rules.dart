import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_rule_predicates.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';

/// Predicate-side DSL for exact class mixin rules.
extension ClassMixinPredicateRules on ClassPredicateBuilder {
  /// Selects classes that mix in [typeName].
  ClassPredicateBuilder applyMixin(String typeName) => satisfy(classMixesIn(typeName));

  /// Selects classes that do not mix in [typeName].
  ClassPredicateBuilder notApplyMixin(String typeName) {
    return satisfy(
      HeimdallPredicate(
        'not contain mixin $typeName',
        (item, project) => !mixesInType(item, typeName, project),
      ),
    );
  }

  /// Selects classes that mix in at least one type in [typeNames].
  ClassPredicateBuilder applyMixinAnyOf(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        typeList.map(classMixesIn),
        description: 'mixin any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects classes that mix in every type in [typeNames].
  ClassPredicateBuilder applyMixinAllOf(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.allOf(
        typeList.map(classMixesIn),
        description: 'mixin all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects classes that mix in none of [typeNames].
  ClassPredicateBuilder applyMixinNoneOf(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        typeList.map(classMixesIn),
        description: 'mixin none of ${typeList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for exact class mixin rules.
extension ClassMixinShouldRules on ClassShouldBuilder {
  /// Requires matching classes to mix in [typeName].
  HeimdallRule<CompilationUnitMember> applyMixin(String typeName) {
    return satisfy(_classShouldMixin(typeName));
  }

  /// Requires matching classes to not mix in [typeName].
  HeimdallRule<CompilationUnitMember> notApplyMixin(String typeName) {
    return satisfy(_classShouldNotMixin(typeName));
  }

  /// Requires matching classes to mix in at least one type in [typeNames].
  HeimdallRule<CompilationUnitMember> applyMixinAnyOf(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.anyOf(
        typeList.map(_classShouldMixin),
        description: 'mixin any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to mix in every type in [typeNames].
  HeimdallRule<CompilationUnitMember> applyMixinAllOf(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.allOf(
        typeList.map(_classShouldMixin),
        description: 'mixin all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to mix in none of [typeNames].
  HeimdallRule<CompilationUnitMember> applyMixinNoneOf(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.noneOf(
        typeList.map(_classShouldMixin),
        description: 'mixin none of ${typeList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<CompilationUnitMember> _classShouldMixin(String typeName) {
  return HeimdallCondition('contain mixin $typeName', (item, project) {
    final findings = mixesInType(item, typeName, project)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} should mixin $typeName',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotMixin(String typeName) {
  return HeimdallCondition('not contain mixin $typeName', (item, project) {
    final findings = !mixesInType(item, typeName, project)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} should not contain mixin $typeName',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
