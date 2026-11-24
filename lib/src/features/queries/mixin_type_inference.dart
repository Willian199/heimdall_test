import 'package:heimdall_test/src/core.dart';
import 'package:heimdall_test/src/features/queries/reference_type_lookup.dart';
import 'package:heimdall_test/src/mapper/model/type_syntax_index.dart';

/// A type argument together with its namespace and hierarchy substitutions.
/// A null [type] represents an omitted, unbounded argument (`dynamic`).
final class MixinTypeArgument {
  /// Preserves syntax ownership while carrying substitutions across type edges.
  const MixinTypeArgument(this.type, this.origin, [this.bindings = const {}]);

  /// Original annotation; nodes are never reparented or resolved in another file.
  final TypeAnnotation? type;

  /// Namespace in which [type] was written, including consultation libraries.
  final ReferenceTypeDeclaration origin;

  /// Instantiated parameters; null values indicate unavailable type information.
  final Map<TypeParameter, MixinTypeArgument?> bindings;
}

/// Discovers omitted mixin arguments from `on` constraints and prior supertypes.
/// Uses the same visibility and reference allowlists as signature type lookup.
final class MixinTypeInference {
  /// Reuses the rule's scoped type lookup.
  MixinTypeInference(this._types, this._syntax);

  final ReferenceTypeLookup _types;
  final TypeSyntaxIndex _syntax;
  final _fieldIndexes = Expando<Map<String, TypeAnnotation?>>();

  List<TypeParameter> _parameters(AstNode node) => _syntax.parametersOf(node);

  TypeParameter? _parameter(TypeAnnotation? type) => type is NamedType ? _syntax.parameterOf(type) : null;

  List<NamedType> _parents(CompilationUnitMember declaration) => _syntax.parentsOf(declaration);

  Map<String, TypeAnnotation?>? _fields(TypeAnnotation? type) {
    if (type is! RecordTypeAnnotation && type is! GenericFunctionType) {
      return null;
    }
    return _fieldIndexes[type!] ??= Map.unmodifiable(_structuralFields(type)!);
  }

  /// Distinguishes a dynamic argument from a type that only contains dynamic.
  /// Substitutions and aliases retain their declaration's lexical namespace.
  bool? isDynamic(MixinTypeArgument? argument, Map<TypeParameter, bool?> bindings) {
    final use = _expandAliases(argument, {});
    if (use == null) {
      return null;
    }
    final parameter = _parameter(use.type);
    if (parameter != null) {
      return bindings[parameter];
    }
    final type = use.type;
    return type == null || type is NamedType && type.importPrefix == null && type.name.lexeme == 'dynamic';
  }

  /// Returns arguments for a raw `with` application, in declaration order.
  /// Null entries are conservative unknowns, distinct from default `dynamic`.
  List<MixinTypeArgument?> argumentsFor(NamedType application, ReferenceTypeDeclaration origin, ReferenceTypeDeclaration declaration) {
    final use = MixinTypeArgument(application, origin);
    final bindings = _arguments(use, declaration, {});
    return [for (final parameter in _parameters(declaration.declaration)) bindings[parameter]];
  }

  List<ReferenceTypeDeclaration> _visible(MixinTypeArgument use) {
    final type = use.type;
    if (type is! NamedType || _parameter(type) != null) {
      return const [];
    }
    final library = use.origin.library;
    return library == null
        ? _types.visible(use.origin.declaration, type.name.lexeme, prefix: type.importPrefix?.name.lexeme)
        : _types.inLibrary(library, type.name.lexeme, prefix: type.importPrefix?.name.lexeme);
  }

  Map<TypeParameter, MixinTypeArgument?> _arguments(
    MixinTypeArgument use,
    ReferenceTypeDeclaration reference,
    Set<CompilationUnitMember> active,
  ) {
    final declaration = reference.declaration;
    final parameters = _parameters(declaration);
    final type = use.type;
    final explicit = type is NamedType ? type.typeArguments?.arguments : null;
    final bindings = <TypeParameter, MixinTypeArgument?>{};
    if (explicit != null) {
      for (var i = 0; i < parameters.length; i++) {
        bindings[parameters[i]] = i < explicit.length ? MixinTypeArgument(explicit[i], use.origin, use.bindings) : null;
      }
    } else if (declaration is MixinDeclaration && parameters.isNotEmpty && type?.parent is WithClause) {
      if (!active.add(declaration)) {
        return {for (final parameter in parameters) parameter: null};
      }
      try {
        final predecessors = _predecessors(use).toList();
        final parameterSet = parameters.toSet();
        for (final type in declaration.onClause?.superclassConstraints ?? <NamedType>[]) {
          final constraint = MixinTypeArgument(type, reference);
          var matched = false;
          for (final predecessor in predecessors) {
            final inferred = {...bindings};
            if (_match(predecessor, constraint, parameterSet, inferred, active, {})) {
              bindings.addAll(inferred);
              matched = true;
              break;
            }
          }
          if (!matched) {
            // Missing sources or unsupported shapes cannot prove dynamic.
            for (final parameter in _usedParameters(constraint, {})) {
              if (parameters.contains(parameter)) {
                bindings.putIfAbsent(parameter, () => null);
              }
            }
          }
        }
      } finally {
        active.remove(declaration);
      }
    }
    for (final parameter in parameters) {
      if (!bindings.containsKey(parameter)) {
        bindings[parameter] = MixinTypeArgument(parameter.bound, reference, bindings);
      }
    }
    return bindings;
  }

  Iterable<MixinTypeArgument> _predecessors(MixinTypeArgument use) sync* {
    final clause = use.type?.parent;
    final owner = clause?.parent;
    final superclass = switch (owner) {
      ClassDeclaration() => owner.extendsClause?.superclass,
      ClassTypeAlias() => owner.superclass,
      _ => null,
    };
    if (superclass != null) {
      yield MixinTypeArgument(superclass, use.origin, use.bindings);
    }
    if (clause is WithClause) {
      for (final mixin in clause.mixinTypes) {
        if (identical(mixin, use.type)) {
          break;
        }
        yield MixinTypeArgument(mixin, use.origin, use.bindings);
      }
    }
  }

  MixinTypeArgument? _substitute(MixinTypeArgument? use) {
    var current = use;
    final seen = <TypeParameter>{};
    while (current != null) {
      final parameter = _parameter(current.type);
      if (parameter == null || !current.bindings.containsKey(parameter)) {
        return current;
      }
      if (!seen.add(parameter)) {
        return null;
      }
      current = current.bindings[parameter];
    }
    return null;
  }

  MixinTypeArgument? _expandAliases(MixinTypeArgument? argument, Set<CompilationUnitMember> active) {
    var use = _substitute(argument);
    final seen = <TypeAnnotation>{};
    while (use != null) {
      final declarations = _visible(use);
      if (declarations.length != 1 || declarations.single.declaration is! GenericTypeAlias) {
        return use;
      }
      if (!seen.add(use.type!)) {
        return null;
      }
      final reference = declarations.single;
      use = _substitute(MixinTypeArgument((reference.declaration as GenericTypeAlias).type, reference, _arguments(use, reference, active)));
    }
    return null;
  }

  Iterable<TypeParameter> _usedParameters(MixinTypeArgument? argument, Set<TypeParameter> seen) sync* {
    final use = _substitute(argument);
    if (use == null) {
      return;
    }
    final parameter = _parameter(use.type);
    if (parameter != null && seen.add(parameter)) {
      yield parameter;
    }
    for (final child in use.type?.childEntities.whereType<AstNode>() ?? <AstNode>[]) {
      if (child is TypeAnnotation) {
        yield* _usedParameters(MixinTypeArgument(child, use.origin, use.bindings), seen);
      } else {
        for (final type in _annotations(child)) {
          yield* _usedParameters(MixinTypeArgument(type, use.origin, use.bindings), seen);
        }
      }
    }
  }

  bool _match(
    MixinTypeArgument? valueArgument,
    MixinTypeArgument? patternArgument,
    Set<TypeParameter> parameters,
    Map<TypeParameter, MixinTypeArgument?> inferred,
    Set<CompilationUnitMember> active,
    Set<CompilationUnitMember> hierarchy,
  ) {
    final actual = _expandAliases(valueArgument, active);
    final expected = _expandAliases(patternArgument, active);
    if (actual == null || expected == null) {
      return false;
    }
    final parameter = _parameter(expected.type);
    if (parameter != null && parameters.contains(parameter)) {
      // Valid mixin constraints determine each parameter consistently.
      final type = actual.type;
      final topType =
          type is NamedType &&
          type.question != null &&
          type.name.lexeme == 'Object' &&
          _visible(actual).any((reference) => reference.library?.uri == 'dart:core');
      inferred[parameter] = topType ? MixinTypeArgument(null, actual.origin) : actual;
      return true;
    }
    if (!_usedParameters(expected, {}).any(parameters.contains)) {
      return true;
    }
    final value = actual.type;
    final pattern = expected.type;
    final candidates = _visible(actual);
    final targets = _visible(expected);
    final values = _fields(value);
    final patterns = _fields(pattern);
    if (values != null &&
        patterns != null &&
        (value is RecordTypeAnnotation && pattern is RecordTypeAnnotation || value is GenericFunctionType && pattern is GenericFunctionType)) {
      return values.length == patterns.length &&
          patterns.entries.every(
            (entry) =>
                values.containsKey(entry.key) &&
                _match(
                  MixinTypeArgument(values[entry.key], actual.origin, actual.bindings),
                  MixinTypeArgument(entry.value, expected.origin, expected.bindings),
                  parameters,
                  inferred,
                  active,
                  {...hierarchy},
                ),
          );
    }
    if (value is! NamedType || pattern is! NamedType) {
      return false;
    }
    if (targets.length != 1) {
      return false;
    }
    final target = targets.single;
    if (candidates.length != 1) {
      return false;
    }
    final source = candidates.single;
    final declaration = source.declaration;
    if (hierarchy.contains(declaration)) {
      return false;
    }
    final arguments = _arguments(actual, source, active);
    if (identical(declaration, target.declaration)) {
      final patternArguments = pattern.typeArguments?.arguments ?? <TypeAnnotation>[];
      if (patternArguments.isEmpty) {
        return true;
      }
      final valueParameters = _parameters(declaration);
      if (valueParameters.length != patternArguments.length) {
        return false;
      }
      for (var i = 0; i < patternArguments.length; i++) {
        if (!_match(
          arguments[valueParameters[i]],
          MixinTypeArgument(patternArguments[i], expected.origin, expected.bindings),
          parameters,
          inferred,
          active,
          {...hierarchy},
        )) {
          return false;
        }
      }
      return true;
    }
    for (final parent in _parents(declaration)) {
      final attempt = {...inferred};
      if (_match(
        MixinTypeArgument(parent, source, arguments),
        expected,
        parameters,
        attempt,
        active,
        {...hierarchy, declaration},
      )) {
        inferred.addAll(attempt);
        return true;
      }
    }
    return false;
  }
}

Map<String, TypeAnnotation?>? _structuralFields(TypeAnnotation? type) {
  if (type is RecordTypeAnnotation) {
    return {
      for (var i = 0; i < type.positionalFields.length; i++) '$i': type.positionalFields[i].type,
      for (final field in type.namedFields?.fields ?? <RecordTypeAnnotationNamedField>[]) field.name.lexeme: field.type,
    };
  }
  if (type is GenericFunctionType) {
    var position = 0;
    return {
      'return': type.returnType,
      for (final parameter in type.parameters.parameters)
        parameter.isNamed ? 'named:${parameter.name?.lexeme}' : '${position++}': switch (parameter) {
          SimpleFormalParameter() => parameter.type,
          DefaultFormalParameter(:final parameter) when parameter is SimpleFormalParameter => parameter.type,
          _ => null,
        },
    };
  }
  return null;
}

Iterable<TypeAnnotation> _annotations(AstNode node) sync* {
  if (node is TypeAnnotation) {
    yield node;
  } else {
    for (final child in node.childEntities.whereType<AstNode>()) {
      yield* _annotations(child);
    }
  }
}
