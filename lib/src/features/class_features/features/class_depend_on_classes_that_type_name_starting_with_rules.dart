import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/class_features/helpers/class_dependency_rule_helpers.dart';
import 'package:heimdall_test/src/features/queries/declaration_dependency_queries.dart';

/// Predicate-side DSL for dependency target type name prefix rules.
extension ClassDependOnClassesThatTypeNameStartingWithPredicateRules on ClassPredicateBuilder {
  /// Selects declarations that depend on a class whose type name starts with [prefix].
  ClassPredicateBuilder dependOnClassesWithTypeNameStartingWith(String prefix) {
    return satisfy(classDependsOnTarget(_targetTypeNameStartsWith(prefix)));
  }

  /// Selects declarations that do not depend on a class whose type name starts with [prefix].
  ClassPredicateBuilder notDependOnClassesWithTypeNameStartingWith(String prefix) {
    return satisfy(classDoesNotDependOnTarget(_targetTypeNameStartsWith(prefix)));
  }

  /// Selects declarations that depend on every target prefix in [prefixes].
  ClassPredicateBuilder dependOnAllClassesWithTypeNameStartingWith(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    final predicates = prefixList.map(_targetTypeNameStartsWith).toList();
    return satisfy(
      HeimdallPredicate.allOf(
        [
          HeimdallPredicate(
            'depend on all classes with type name starting with ${prefixList.join(', ')}',
            (item, project) {
              final targets = targetDeclarations(item, project);
              return predicates.every(
                (predicate) => targets.any((target) => predicate.test(target, project)),
              );
            },
          ),
        ],
        description: 'depend on all classes with type name starting with ${prefixList.join(', ')}',
      ),
    );
  }

  /// Selects declarations that depend on at least one target prefix in [prefixes].
  ClassPredicateBuilder dependOnAnyClassesWithTypeNameStartingWith(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    final predicates = prefixList.map(_targetTypeNameStartsWith).toList();
    return satisfy(
      HeimdallPredicate.anyOf(
        [
          HeimdallPredicate(
            'depend on any class with type name starting with ${prefixList.join(', ')}',
            (item, project) {
              final targets = targetDeclarations(item, project);
              return predicates.any(
                (predicate) => targets.any((target) => predicate.test(target, project)),
              );
            },
          ),
        ],
        description: 'depend on any class with type name starting with ${prefixList.join(', ')}',
      ),
    );
  }

  /// Selects declarations that depend on none of [prefixes].
  ClassPredicateBuilder dependOnNoClassesWithTypeNameStartingWith(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    final predicates = prefixList.map(_targetTypeNameStartsWith).toList();
    return satisfy(
      HeimdallPredicate.noneOf(
        [
          HeimdallPredicate(
            'depend on any class with type name starting with ${prefixList.join(', ')}',
            (item, project) {
              final dependencies = declarationDependenciesFrom(item, project);
              return dependencies.any(
                (dependency) => predicates.any(
                  (predicate) => predicate.test(dependency.target, project),
                ),
              );
            },
          ),
        ],
        description: 'depend on no class with type name starting with ${prefixList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for dependency target type name prefix rules.
extension ClassDependOnClassesThatTypeNameStartingWithShouldRules on ClassShouldBuilder {
  /// Requires matching classes to depend on a class whose type name starts with [prefix].
  HeimdallRule<CompilationUnitMember> dependOnClassesWithTypeNameStartingWith(
    String prefix,
  ) {
    return satisfy(classShouldDependOnTarget(_targetTypeNameStartsWith(prefix)));
  }

  /// Requires matching classes to not depend on a class whose type name starts with [prefix].
  HeimdallRule<CompilationUnitMember> notDependOnClassesWithTypeNameStartingWith(
    String prefix,
  ) {
    return satisfy(classShouldNotDependOnTarget(_targetTypeNameStartsWith(prefix)));
  }

  /// Requires matching classes to depend on every target prefix in [prefixes].
  HeimdallRule<CompilationUnitMember> dependOnAllClassesWithTypeNameStartingWith(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.allOf(
        prefixList.map(_targetTypeNameStartsWith).map(classShouldDependOnTarget),
        description: 'depend on all classes with type name starting with ${prefixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to depend on at least one target prefix in [prefixes].
  HeimdallRule<CompilationUnitMember> dependOnAnyClassesWithTypeNameStartingWith(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.anyOf(
        prefixList.map(_targetTypeNameStartsWith).map(classShouldDependOnTarget),
        description: 'depend on any class with type name starting with ${prefixList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to depend on none of [prefixes].
  HeimdallRule<CompilationUnitMember> dependOnNoClassesWithTypeNameStartingWith(
    Iterable<String> prefixes,
  ) {
    final prefixList = prefixes.toNonEmptyList('prefixes');
    return satisfy(
      HeimdallCondition.noneOf(
        prefixList.map(_targetTypeNameStartsWith).map(classShouldDependOnTarget),
        description: 'depend on no class with type name starting with ${prefixList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _targetTypeNameStartsWith(
  String prefix,
) {
  return HeimdallPredicate(
    'starts with $prefix',
    (item, _) => item.name.startsWith(prefix),
  );
}
