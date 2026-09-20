import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';

/// Predicate-side DSL for exact class mixin rules.
extension ClassMixinPredicateRules on ClassPredicateBuilder {
  /// Selects classes that mix in [typeName].
  ClassPredicateBuilder mixin(String typeName) => satisfy(_classMixesIn(typeName));

  /// Selects classes that do not mix in [typeName].
  ClassPredicateBuilder noMixin(String typeName) {
    return satisfy(
      HeimdallPredicate(
        'not contain mixin $typeName',
        (item, project) => !mixesInType(item, typeName, project),
      ),
    );
  }

  /// Selects classes that mix in at least one type in [typeNames].
  ClassPredicateBuilder mixinAny(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        typeList.map(_classMixesIn),
        description: 'mixin any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects classes that mix in every type in [typeNames].
  ClassPredicateBuilder mixinAll(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.allOf(
        typeList.map(_classMixesIn),
        description: 'mixin all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects classes that mix in none of [typeNames].
  ClassPredicateBuilder mixinNone(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        typeList.map(_classMixesIn),
        description: 'mixin none of ${typeList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for exact class mixin rules.
extension ClassMixinShouldRules on ClassShouldBuilder {
  /// Requires matching classes to mix in [typeName].
  HeimdallRule<CompilationUnitMember> mixin(String typeName) {
    return satisfy(_classShouldMixin(typeName));
  }

  /// Requires matching classes to not mix in [typeName].
  HeimdallRule<CompilationUnitMember> noMixin(String typeName) {
    return satisfy(_classShouldNotMixin(typeName));
  }

  /// Requires matching classes to mix in at least one type in [typeNames].
  HeimdallRule<CompilationUnitMember> mixinAny(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.anyOf(
        typeList.map(_classShouldMixin),
        description: 'mixin any of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to mix in every type in [typeNames].
  HeimdallRule<CompilationUnitMember> mixinAll(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.allOf(
        typeList.map(_classShouldMixin),
        description: 'mixin all of ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to mix in none of [typeNames].
  HeimdallRule<CompilationUnitMember> mixinNone(Iterable<String> typeNames) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.noneOf(
        typeList.map(_classShouldMixin),
        description: 'mixin none of ${typeList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _classMixesIn(String typeName) {
  return HeimdallPredicate(
    'mixin $typeName',
    (item, project) => mixesInType(item, typeName, project),
  );
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
