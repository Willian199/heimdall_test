import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/class_features/helpers/class_dependency_rule_helpers.dart';
import 'package:heimdall_test/src/features/queries/declaration_dependency_queries.dart';

/// Predicate-side DSL for dependency target type name rules.
extension ClassDependOnClassesThatTypeNamePredicateRules on ClassPredicateBuilder {
  /// Selects declarations that depend on a class named [typeName].
  ClassPredicateBuilder dependOnClassesWithTypeName(String typeName) {
    return satisfy(classDependsOnTarget(_typeNameEquals(typeName)));
  }

  /// Selects declarations that do not depend on a class named [typeName].
  ClassPredicateBuilder notDependOnClassesWithTypeName(String typeName) {
    return satisfy(classDoesNotDependOnTarget(_typeNameEquals(typeName)));
  }

  /// Selects declarations that depend on every target type name in [typeNames].
  ClassPredicateBuilder dependOnAllClassesWithTypeName(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    final predicates = typeList.map(_typeNameEquals).toList();
    return satisfy(
      HeimdallPredicate.allOf(
        [
          HeimdallPredicate(
            'depend on all classes with type name ${typeList.join(', ')}',
            (item, project) {
              final targets = targetDeclarations(item, project);
              return predicates.every(
                (predicate) => targets.any((target) => predicate.test(target, project)),
              );
            },
          ),
        ],
        description: 'depend on all classes with type name ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects declarations that depend on at least one target type name in [typeNames].
  ClassPredicateBuilder dependOnAnyClassesWithTypeName(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    final predicates = typeList.map(_typeNameEquals).toList();
    return satisfy(
      HeimdallPredicate.anyOf(
        [
          HeimdallPredicate(
            'depend on any class with type name ${typeList.join(', ')}',
            (item, project) {
              final targets = targetDeclarations(item, project);
              return predicates.any(
                (predicate) => targets.any((target) => predicate.test(target, project)),
              );
            },
          ),
        ],
        description: 'depend on any class with type name ${typeList.join(', ')}',
      ),
    );
  }

  /// Selects declarations that depend on none of [typeNames].
  ClassPredicateBuilder dependOnNoClassesWithTypeName(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    final predicates = typeList.map(_typeNameEquals).toList();
    return satisfy(
      HeimdallPredicate.noneOf(
        [
          HeimdallPredicate(
            'depend on any class with type name ${typeList.join(', ')}',
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
        description: 'depend on no class with type name ${typeList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for dependency target type name rules.
extension ClassDependOnClassesThatTypeNameShouldRules on ClassShouldBuilder {
  /// Requires matching classes to depend on a class named [typeName].
  HeimdallRule<CompilationUnitMember> dependOnClassesWithTypeName(
    String typeName,
  ) {
    return satisfy(classShouldDependOnTarget(_typeNameEquals(typeName)));
  }

  /// Requires matching classes to not depend on a class named [typeName].
  HeimdallRule<CompilationUnitMember> notDependOnClassesWithTypeName(
    String typeName,
  ) {
    return satisfy(classShouldNotDependOnTarget(_typeNameEquals(typeName)));
  }

  /// Requires matching classes to depend on every target type name in [typeNames].
  HeimdallRule<CompilationUnitMember> dependOnAllClassesWithTypeName(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.allOf(
        typeList.map(_typeNameEquals).map(classShouldDependOnTarget),
        description: 'depend on all classes with type name ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to depend on at least one target type name in [typeNames].
  HeimdallRule<CompilationUnitMember> dependOnAnyClassesWithTypeName(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.anyOf(
        typeList.map(_typeNameEquals).map(classShouldDependOnTarget),
        description: 'depend on any class with type name ${typeList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to depend on none of [typeNames].
  HeimdallRule<CompilationUnitMember> dependOnNoClassesWithTypeName(
    Iterable<String> typeNames,
  ) {
    final typeList = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.noneOf(
        typeList.map(_typeNameEquals).map(classShouldDependOnTarget),
        description: 'depend on no class with type name ${typeList.join(', ')}',
      ),
    );
  }
}

HeimdallPredicate<CompilationUnitMember> _typeNameEquals(String typeName) {
  return HeimdallPredicate(
    'equals $typeName',
    (item, _) => item.name == typeName,
  );
}
