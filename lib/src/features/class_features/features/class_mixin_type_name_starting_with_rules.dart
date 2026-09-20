import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_type_queries.dart';

/// Predicate-side DSL for class mixin prefix rules.
extension ClassMixinTypeNameStartingWithPredicateRules on ClassPredicateBuilder {
  /// Selects classes that mix in a type whose name starts with [prefix].
  ClassPredicateBuilder mixinTypeNameStartingWith(String prefix) {
    return satisfy(_classMixesInTypeNameStartingWith(prefix));
  }

  /// Selects classes that do not mix in a type whose name starts with [prefix].
  ClassPredicateBuilder noMixinTypeNameStartingWith(String prefix) {
    return satisfy(_classDoesNotMixinTypeNameStartingWith(prefix));
  }

  /// Selects classes that mix in a type name starting with at least one prefix in [prefixes].
  ClassPredicateBuilder mixinTypeNameStartingWithAny(Iterable<String> prefixes) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.anyOf(
        prefixList.map(_classMixesInTypeNameStartingWith),
        description: 'mixin type name starting with any of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Selects classes that mix in type names starting with every prefix in [prefixes].
  ClassPredicateBuilder mixinTypeNameStartingWithAll(Iterable<String> prefixes) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.allOf(
        prefixList.map(_classMixesInTypeNameStartingWith),
        description: 'mixin type names starting with all of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Selects classes that mix in no type name starting with [prefixes].
  ClassPredicateBuilder mixinTypeNameStartingWithNone(Iterable<String> prefixes) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallPredicate.noneOf(
        prefixList.map(_classMixesInTypeNameStartingWith),
        description: 'mixin type name starting with none of ${prefixList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for class mixin prefix rules.
extension ClassMixinTypeNameStartingWithShouldRules on ClassShouldBuilder {
  /// Requires matching classes to mix in a type whose name starts with [prefix].
  HeimdallRule<CompilationUnitMember> mixinTypeNameStartingWith(String prefix) {
    return satisfy(_classShouldMixinTypeNameStartingWith(prefix));
  }

  /// Requires matching classes to not mix in a type whose name starts with [prefix].
  HeimdallRule<CompilationUnitMember> noMixinTypeNameStartingWith(String prefix) {
    return satisfy(_classShouldNotMixinTypeNameStartingWith(prefix));
  }

  /// Requires matching classes to mix in a type name starting with at least one prefix in [prefixes].
  HeimdallRule<CompilationUnitMember> mixinTypeNameStartingWithAny(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.anyOf(
        prefixList.map(_classShouldMixinTypeNameStartingWith),
        description: 'mixin type name starting with any of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to mix in type names starting with every prefix in [prefixes].
  HeimdallRule<CompilationUnitMember> mixinTypeNameStartingWithAll(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.allOf(
        prefixList.map(_classShouldMixinTypeNameStartingWith),
        description: 'mixin type names starting with all of ${prefixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to mix in no type name starting with [prefixes].
  HeimdallRule<CompilationUnitMember> mixinTypeNameStartingWithNone(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.noneOf(
        prefixList.map(_classShouldMixinTypeNameStartingWith),
        description: 'mixin type name starting with none of ${prefixList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _classMixesInTypeNameStartingWith(
  String prefix,
) {
  return HeimdallPredicate(
    'mixin type name starting with $prefix',
    (item, project) => mixesInTypeNamedWhere(
      item,
      project,
      (typeName) => typeName.startsWith(prefix),
    ),
  );
}

HeimdallPredicate<CompilationUnitMember> _classDoesNotMixinTypeNameStartingWith(
  String prefix,
) {
  return HeimdallPredicate(
    'not mixin type name starting with $prefix',
    (item, project) => !mixesInTypeNamedWhere(
      item,
      project,
      (typeName) => typeName.startsWith(prefix),
    ),
  );
}

HeimdallCondition<CompilationUnitMember> _classShouldMixinTypeNameStartingWith(
  String prefix,
) {
  return HeimdallCondition('mixin type name starting with $prefix', (item, project) {
    final findings =
        mixesInTypeNamedWhere(
          item,
          project,
          (typeName) => typeName.startsWith(prefix),
        )
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} should mixin a type name starting with $prefix',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotMixinTypeNameStartingWith(
  String prefix,
) {
  return HeimdallCondition('not mixin type name starting with $prefix', (item, project) {
    final findings =
        !mixesInTypeNamedWhere(
          item,
          project,
          (typeName) => typeName.startsWith(prefix),
        )
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} should not mixin a type name starting with $prefix',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}
