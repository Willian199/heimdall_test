import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';

/// Predicate-side DSL for class mixin suffix rules.
extension ClassMixinTypeNameEndingWithPredicateRules on ClassPredicateBuilder {
  /// Selects classes that mix in a type whose name ends with [suffix].
  ClassPredicateBuilder mixinTypeNameEndingWith(String suffix) {
    return satisfy(_classMixesInTypeNameEndingWith(suffix));
  }

  /// Selects classes that do not mix in a type whose name ends with [suffix].
  ClassPredicateBuilder noMixinTypeNameEndingWith(String suffix) {
    return satisfy(_classDoesNotMixinTypeNameEndingWith(suffix));
  }

  /// Selects classes that mix in a type name ending with at least one suffix in [suffixes].
  ClassPredicateBuilder mixinTypeNameEndingWithAny(Iterable<String> suffixes) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        suffixList.map(_classMixesInTypeNameEndingWith),
        description: 'mixin type name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects classes that mix in type names ending with every suffix in [suffixes].
  ClassPredicateBuilder mixinTypeNameEndingWithAll(Iterable<String> suffixes) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.allOf(
        suffixList.map(_classMixesInTypeNameEndingWith),
        description: 'mixin type names ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Selects classes that mix in no type name ending with [suffixes].
  ClassPredicateBuilder mixinTypeNameEndingWithNone(Iterable<String> suffixes) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        suffixList.map(_classMixesInTypeNameEndingWith),
        description: 'mixin type name ending with none of ${suffixList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for class mixin suffix rules.
extension ClassMixinTypeNameEndingWithShouldRules on ClassShouldBuilder {
  /// Requires matching classes to mix in a type whose name ends with [suffix].
  HeimdallRule<CompilationUnitMember> mixinTypeNameEndingWith(String suffix) {
    return satisfy(_classShouldMixinTypeNameEndingWith(suffix));
  }

  /// Requires matching classes to not mix in a type whose name ends with [suffix].
  HeimdallRule<CompilationUnitMember> noMixinTypeNameEndingWith(String suffix) {
    return satisfy(_classShouldNotMixinTypeNameEndingWith(suffix));
  }

  /// Requires matching classes to mix in a type name ending with at least one suffix in [suffixes].
  HeimdallRule<CompilationUnitMember> mixinTypeNameEndingWithAny(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.anyOf(
        suffixList.map(_classShouldMixinTypeNameEndingWith),
        description: 'mixin type name ending with any of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to mix in type names ending with every suffix in [suffixes].
  HeimdallRule<CompilationUnitMember> mixinTypeNameEndingWithAll(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.allOf(
        suffixList.map(_classShouldMixinTypeNameEndingWith),
        description: 'mixin type names ending with all of ${suffixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to mix in no type name ending with [suffixes].
  HeimdallRule<CompilationUnitMember> mixinTypeNameEndingWithNone(
    Iterable<String> suffixes,
  ) {
    final suffixList = suffixes.toNonEmptyList('suffixes');
    return satisfy(
      HeimdallCondition.noneOf(
        suffixList.map(_classShouldMixinTypeNameEndingWith),
        description: 'mixin type name ending with none of ${suffixList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _classMixesInTypeNameEndingWith(
  String suffix,
) {
  return HeimdallPredicate(
    'mixin type name ending with $suffix',
    (item, project) => mixesInTypeNamedWhere(
      item,
      project,
      (typeName) => typeName.endsWith(suffix),
    ),
  );
}

HeimdallPredicate<CompilationUnitMember> _classDoesNotMixinTypeNameEndingWith(
  String suffix,
) {
  return HeimdallPredicate(
    'not mixin type name ending with $suffix',
    (item, project) => !mixesInTypeNamedWhere(
      item,
      project,
      (typeName) => typeName.endsWith(suffix),
    ),
  );
}

HeimdallCondition<CompilationUnitMember> _classShouldMixinTypeNameEndingWith(
  String suffix,
) {
  return HeimdallCondition('mixin type name ending with $suffix', (item, project) {
    final findings =
        mixesInTypeNamedWhere(
          item,
          project,
          (typeName) => typeName.endsWith(suffix),
        )
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} should mixin a type name ending with $suffix',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotMixinTypeNameEndingWith(
  String suffix,
) {
  return HeimdallCondition('not mixin type name ending with $suffix', (item, project) {
    final findings =
        !mixesInTypeNamedWhere(
          item,
          project,
          (typeName) => typeName.endsWith(suffix),
        )
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} should not mixin a type name ending with $suffix',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
