import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/declaration_dependency_queries.dart';
import 'package:heimdall_test/src/features/queries/declaration_lookup_queries.dart';

/// Public signature hygiene checks for [HeimdallCodeSight].
extension HeimdallPublicDynamicSignatureRule on HeimdallCodeSight {
  /// Ensures public declarations in [pathPattern] do not expose `dynamic`.
  ///
  /// Raw generics are resolved from visible declarations first. Otherwise,
  /// standard unbounded generics from dart:core, dart:async and dart:collection
  /// (such as List, Map, Future and Stream) are recognized by name. Prefixed
  /// SDK names require an import of one of those libraries under that prefix.
  /// [externalGenericTypeNames] adds names such as `Bloc` or `Response` whose
  /// omitted arguments should count as dynamic. Unqualified names also match
  /// prefixed uses; use `http.Response` to restrict a name to that prefix.
  /// SDK and external package sources are not read. Visible local declarations
  /// and lexical type parameters take precedence over these name lists.
  /// Wildcard parameters are always ignored, including explicit annotations.
  /// Local inference is conservative: unknown types do not produce findings.
  /// It follows same-file calls, visible class members, collection elements,
  /// indexing, await/yield, and direct generic argument inference. It does not
  /// perform full analyzer type resolution or flow-sensitive promotion.
  ///
  /// Use [ignoredPathPatterns] to skip generated, legacy, or intentionally
  /// dynamic files. Patterns use the same semantics as [pathMatches]; a pattern
  /// without `.dart` also matches the same path with `.dart` appended.
  ///
  /// Use [ignoredDeclarationNames] and [ignoredDeclarationNamePatterns] to skip
  /// specific public declarations inside otherwise validated files.
  ///
  /// [ignoredTypes] exempts written type signatures, including nested
  /// occurrences, for example `{'Map<String, dynamic>'}`. Whitespace and outer
  /// nullability are ignored. A name alone, such as `Map` or `List`, exempts all
  /// its type arguments. Import prefixes still must match (`core.Map` differs
  /// from `Map`), as must type arguments when supplied. This is not a wildcard
  /// or semantic type-equivalence match.
  HeimdallRule<CompilationUnitMember> publicSignaturesShouldNotUseDynamic({
    String pathPattern = '**',
    List<String> ignoredPathPatterns = const [],
    Set<String> ignoredDeclarationNames = const {},
    List<RegExp> ignoredDeclarationNamePatterns = const [],
    Set<String> ignoredTypes = const {},
    List<String> externalGenericTypeNames = const [],
  }) {
    final ignoredTypeKeys = {for (final type in ignoredTypes) _typeKey(type)};
    final externalTypeNames = externalGenericTypeNames.toSet();
    final resolvers = Expando<_RawGenericTypeResolver>();
    return HeimdallRule(
      descriptionPrefix: 'public signatures',
      selector: (project) => project.declarations.where(
        (declaration) =>
            (declaration is TopLevelVariableDeclaration
                ? declaration.variables.variables.any((variable) => !variable.name.lexeme.startsWith('_'))
                : declaration.isPublic) &&
            pathMatches(declaration.relativePath, pathPattern) &&
            !_isIgnoredPublicSignatureDeclaration(
              declaration,
              ignoredPathPatterns: ignoredPathPatterns,
              ignoredDeclarationNames: ignoredDeclarationNames,
              ignoredDeclarationNamePatterns: ignoredDeclarationNamePatterns,
            ),
      ),
      predicate: const HeimdallPredicate(
        'public declarations',
        _allDeclarations,
      ),
      condition: HeimdallCondition('not use dynamic', (
        item,
        project,
      ) {
        final resolver = resolvers[project] ??= _RawGenericTypeResolver(project, ignoredTypeKeys, externalTypeNames);
        final findings = _publicDynamicSignatureFindings(item, project, resolver);
        return HeimdallFindings(
          subject: item,
          passed: findings.isEmpty,
          findings: findings,
        );
      }),
    );
  }
}

bool _allDeclarations(CompilationUnitMember _, HeimdallProject project) => true;

bool _isIgnoredPublicSignatureDeclaration(
  CompilationUnitMember declaration, {
  required List<String> ignoredPathPatterns,
  required Set<String> ignoredDeclarationNames,
  required List<RegExp> ignoredDeclarationNamePatterns,
}) {
  return ignoredPathPatterns.any(
        (pattern) => _pathMatchesSignatureIgnore(
          declaration.relativePath,
          pattern,
        ),
      ) ||
      ignoredDeclarationNames.contains(declaration.name) ||
      ignoredDeclarationNamePatterns.any(
        (pattern) => pattern.hasMatch(declaration.name),
      );
}

bool _pathMatchesSignatureIgnore(String relativePath, String pattern) {
  final normalizedPattern = normalizePath(pattern);
  if (pathMatches(relativePath, normalizedPattern)) {
    return true;
  }
  if (normalizedPattern.endsWith('.dart')) {
    return false;
  }
  return pathMatches(relativePath, '$normalizedPattern.dart');
}

List<HeimdallValidationInfo> _publicDynamicSignatureFindings(
  CompilationUnitMember declaration,
  HeimdallProject project,
  _RawGenericTypeResolver rawGenericTypes,
) {
  final findings = <HeimdallValidationInfo>[];
  _addSignatureHeaderFindings(findings, declaration, project, rawGenericTypes);
  if (declaration is FunctionDeclaration) {
    _addReturnTypeFinding(
      findings,
      filePath: declaration.sourcePath,
      line: declaration.line,
      type: declaration.returnType,
      inferredStatus: declaration.returnType == null ? rawGenericTypes.bodyStatus(declaration.functionExpression.body, declaration) : null,
      name: declaration.name.lexeme,
      project: project,
      origin: declaration,
      rawGenericTypes: rawGenericTypes,
    );
    _addParameterFindings(
      findings,
      project: project,
      origin: declaration,
      rawGenericTypes: rawGenericTypes,
      filePath: declaration.sourcePath,
      lineFor: (node) => declaration.sourceLocationAt(node.offset).line,
      ownerName: declaration.name.lexeme,
      parameters: declaration.functionExpression.parameters?.parameters ?? const [],
    );
  } else if (declaration is TopLevelVariableDeclaration) {
    for (final variable in declaration.variables.variables) {
      if (variable.name.lexeme.startsWith('_')) {
        continue;
      }
      _addVariableTypeFinding(
        findings,
        filePath: declaration.sourcePath,
        line: declaration.sourceLocationAt(variable.offset).line,
        type: declaration.variables.type,
        variable: variable,
        name: variable.name.lexeme,
        project: project,
        origin: declaration,
        rawGenericTypes: rawGenericTypes,
      );
    }
  } else if (declaration is TypeAlias) {
    _addTypeAliasFindings(
      findings,
      declaration,
      project,
      rawGenericTypes: rawGenericTypes,
    );
  }

  for (final field in declaration.fields) {
    for (final variable in field.fields.variables) {
      if (variable.name.lexeme.startsWith('_')) {
        continue;
      }
      _addVariableTypeFinding(
        findings,
        filePath: field.sourcePath,
        line: field.sourceLocationAt(variable.offset).line,
        type: field.fields.type,
        variable: variable,
        name: variable.name.lexeme,
        project: project,
        origin: declaration,
        rawGenericTypes: rawGenericTypes,
      );
    }
  }

  for (final method in declaration.methods) {
    if (!method.isPublic) {
      continue;
    }
    final ClassMember methodMember = method;
    _addReturnTypeFinding(
      findings,
      filePath: method.sourcePath,
      line: method.line,
      type: method.returnType,
      inferredStatus: method.returnType == null ? rawGenericTypes.methodReturnStatus(method, declaration) : null,
      name: method.name.lexeme,
      project: project,
      origin: declaration,
      rawGenericTypes: rawGenericTypes,
    );
    _addParameterFindings(
      findings,
      project: project,
      origin: declaration,
      rawGenericTypes: rawGenericTypes,
      filePath: method.sourcePath,
      lineFor: (node) => method.sourceLocationAt(node.offset).line,
      ownerName: method.name.lexeme,
      member: methodMember,
      parameters: methodMember.parameters,
    );
  }

  for (final constructor in declaration.constructors) {
    if (!constructor.isPublic) {
      continue;
    }
    final ClassMember constructorMember = constructor;
    _addParameterFindings(
      findings,
      project: project,
      origin: declaration,
      rawGenericTypes: rawGenericTypes,
      filePath: constructor.sourcePath,
      lineFor: (node) => constructor.sourceLocationAt(node.offset).line,
      ownerName: _constructorDisplayName(declaration, constructor.name?.lexeme),
      member: constructorMember,
      parameters: constructorMember.parameters,
    );
  }

  return findings;
}

void _addTypeAliasFindings(
  List<HeimdallValidationInfo> findings,
  TypeAlias declaration,
  HeimdallProject project, {
  required _RawGenericTypeResolver rawGenericTypes,
}) {
  switch (declaration) {
    case GenericTypeAlias(:final type):
      if (rawGenericTypes.isIgnoredType(type)) {
        return;
      }
      if (type is GenericFunctionType) {
        _addFunctionTypeAliasFindings(
          findings,
          declaration,
          project,
          rawGenericTypes: rawGenericTypes,
          returnType: type.returnType,
          parameters: type.parameters.parameters,
        );
      } else {
        _addVariableTypeFinding(
          findings,
          filePath: declaration.sourcePath,
          line: declaration.line,
          type: type,
          name: declaration.name.lexeme,
          project: project,
          origin: declaration,
          rawGenericTypes: rawGenericTypes,
        );
      }
    case FunctionTypeAlias(:final returnType, :final parameters):
      _addFunctionTypeAliasFindings(
        findings,
        declaration,
        project,
        rawGenericTypes: rawGenericTypes,
        returnType: returnType,
        parameters: parameters.parameters,
      );
  }
}

void _addFunctionTypeAliasFindings(
  List<HeimdallValidationInfo> findings,
  TypeAlias declaration,
  HeimdallProject project, {
  required _RawGenericTypeResolver rawGenericTypes,
  required TypeAnnotation? returnType,
  required Iterable<FormalParameter> parameters,
}) {
  _addReturnTypeFinding(
    findings,
    filePath: declaration.sourcePath,
    line: declaration.line,
    type: returnType,
    inferredStatus: returnType == null ? _DynamicStatus.dynamicType : null,
    name: declaration.name.lexeme,
    project: project,
    origin: declaration,
    rawGenericTypes: rawGenericTypes,
  );
  _addParameterFindings(
    findings,
    project: project,
    origin: declaration,
    rawGenericTypes: rawGenericTypes,
    filePath: declaration.sourcePath,
    lineFor: (node) => declaration.sourceLocationAt(node.offset).line,
    ownerName: declaration.name.lexeme,
    parameters: parameters,
  );
}

void _addReturnTypeFinding(
  List<HeimdallValidationInfo> findings, {
  required String filePath,
  required int line,
  required TypeAnnotation? type,
  required String name,
  required HeimdallProject project,
  required CompilationUnitMember origin,
  required _RawGenericTypeResolver rawGenericTypes,
  _DynamicStatus? inferredStatus,
}) {
  if (inferredStatus != _DynamicStatus.dynamicType &&
      !_typeContainsPublicDynamic(
        type,
        project: project,
        origin: origin,
        rawGenericTypes: rawGenericTypes,
      )) {
    return;
  }
  findings.add(
    HeimdallValidationInfo(
      filePath: filePath,
      line: line,
      message: '$name has public dynamic return type',
    ),
  );
}

void _addParameterFindings(
  List<HeimdallValidationInfo> findings, {
  required HeimdallProject project,
  required CompilationUnitMember origin,
  required _RawGenericTypeResolver rawGenericTypes,
  required String filePath,
  required int Function(AstNode node) lineFor,
  required String ownerName,
  required Iterable<FormalParameter> parameters,
  ClassMember? member,
}) {
  for (final parameter in parameters) {
    if (!_isDynamicParameter(
      parameter,
      project: project,
      origin: origin,
      rawGenericTypes: rawGenericTypes,
      member: member,
    )) {
      continue;
    }
    findings.add(
      HeimdallValidationInfo(
        filePath: filePath,
        line: lineFor(parameter),
        message: '$ownerName has public dynamic parameter ${parameter.name?.lexeme ?? '<unnamed>'}',
      ),
    );
  }
}

void _addVariableTypeFinding(
  List<HeimdallValidationInfo> findings, {
  required String filePath,
  required int line,
  required TypeAnnotation? type,
  required String name,
  required HeimdallProject project,
  required CompilationUnitMember origin,
  required _RawGenericTypeResolver rawGenericTypes,
  VariableDeclaration? variable,
}) {
  if (!(type == null && variable != null
      ? rawGenericTypes.variableStatus(variable, origin) == _DynamicStatus.dynamicType
      : _typeContainsPublicDynamic(
          type,
          project: project,
          origin: origin,
          rawGenericTypes: rawGenericTypes,
        ))) {
    return;
  }
  findings.add(
    HeimdallValidationInfo(
      filePath: filePath,
      line: line,
      message: '$name has public dynamic type',
    ),
  );
}

bool _isDynamicParameter(
  FormalParameter parameter, {
  required HeimdallProject project,
  required CompilationUnitMember origin,
  required _RawGenericTypeResolver rawGenericTypes,
  ClassMember? member,
}) => rawGenericTypes.parameterStatus(parameter, origin, member: member) == _DynamicStatus.dynamicType;
bool _isWildcardParameter(FormalParameter parameter) => parameter.name?.lexeme == '_';

String _constructorDisplayName(CompilationUnitMember declaration, String? name) {
  return name == null || name == 'new' ? declaration.name : '${declaration.name}.$name';
}

FormalParameter _normalParameter(FormalParameter parameter) {
  return parameter is DefaultFormalParameter ? parameter.parameter : parameter;
}

TypeAnnotation? _formalParameterType(FormalParameter parameter) {
  return switch (parameter) {
    SimpleFormalParameter(:final type) => type,
    FieldFormalParameter(:final type) => type,
    SuperFormalParameter(:final type) => type,
    FunctionTypedFormalParameter(:final returnType) => returnType,
    _ => null,
  };
}

bool _typeContainsPublicDynamic(
  TypeAnnotation? type, {
  required HeimdallProject project,
  required CompilationUnitMember origin,
  required _RawGenericTypeResolver rawGenericTypes,
}) => rawGenericTypes.typeStatus(type, origin) == _DynamicStatus.dynamicType;

enum _DynamicStatus { dynamicType, known, unknown }

bool _containsNode(AstNode scope, AstNode node) => scope.offset <= node.offset && node.end <= scope.end;

bool _patternDeclaresName(AstNode pattern, String name) {
  if (pattern is DeclaredVariablePattern && pattern.name.lexeme == name || pattern is DeclaredIdentifier && pattern.name.lexeme == name) {
    return true;
  }
  return pattern.childEntities.whereType<AstNode>().any((child) => _patternDeclaresName(child, name));
}

// SDK types whose omitted, unbounded arguments default to dynamic.
// Bounded types such as Expando<T extends Object> are deliberately excluded.
const _sdkDynamicGenericTypeNames = {
  // dart:core
  'Comparable', 'Comparator', 'Finalizer', 'Iterable', 'Iterator',
  'List', 'Map', 'MapEntry', 'Set', 'Sink',
  // dart:async
  'Completer', 'EventSink', 'Future', 'FutureOr', 'MultiStreamController',
  'ParallelWaitError', 'Stream', 'StreamConsumer', 'StreamController',
  'StreamIterator', 'StreamSink', 'StreamSubscription', 'StreamTransformer',
  'StreamTransformerBase', 'StreamView', 'SynchronousStreamController',
  'ZoneCallback', 'ZoneUnaryCallback', 'ZoneBinaryCallback',
  // dart:collection
  'DoubleLinkedQueue', 'HashMap', 'HashSet', 'HasNextIterator',
  'IterableBase', 'IterableMixin', 'LinkedHashMap', 'LinkedHashSet',
  'ListBase', 'ListMixin', 'ListQueue', 'MapBase', 'MapMixin', 'MapView',
  'Queue', 'SetBase', 'SetMixin', 'SplayTreeMap', 'SplayTreeSet',
  'UnmodifiableListView', 'UnmodifiableMapBase', 'UnmodifiableMapView',
  'UnmodifiableSetView',
};

final _typeWhitespace = RegExp(r'\s+');

String _typeKey(String type) {
  final key = type.replaceAll(_typeWhitespace, '');
  return key.endsWith('?') ? key.substring(0, key.length - 1) : key;
}

_DynamicStatus _combine(Iterable<_DynamicStatus> values) {
  var result = _DynamicStatus.known;
  for (final value in values) {
    if (value == _DynamicStatus.dynamicType) {
      return value;
    }
    if (value == _DynamicStatus.unknown) {
      result = value;
    }
  }
  return result;
}

/// Resolves imported project declarations, cached per rule and project.
final class _RawGenericTypeResolver {
  _RawGenericTypeResolver(this._project, this._ignoredTypeKeys, this._externalGenericTypeNames);

  final HeimdallProject _project;
  final Set<String> _ignoredTypeKeys;
  final Set<String> _externalGenericTypeNames;
  final Expando<String> _typeKeys = Expando<String>();

  bool isIgnoredType(TypeAnnotation type) {
    if (_ignoredTypeKeys.isEmpty) {
      return false;
    }
    final key = _typeKeys[type] ??= _typeKey(type.toSource());
    if (_ignoredTypeKeys.contains(key)) {
      return true;
    }
    if (type is! NamedType) {
      return false;
    }
    final prefix = type.importPrefix?.name.lexeme;
    final name = prefix == null ? type.name.lexeme : '$prefix.${type.name.lexeme}';
    return _ignoredTypeKeys.contains(name);
  }

  bool _isIgnoredLiteralType(String name, TypeArgumentList? arguments) {
    if (_ignoredTypeKeys.contains(name)) {
      return true;
    }
    // Empty literals without a contextual type infer dynamic arguments.
    final signature = arguments?.toSource() ?? (name == 'Map' ? '<dynamic, dynamic>' : '<dynamic>');
    return _ignoredTypeKeys.contains(_typeKey('$name$signature'));
  }

  final Map<({String sourcePath, String? importPrefix}), _VisibleTypeReferenceIndex> _indexes = {};

  final Set<AstNode> _active = {};
  final Set<AstNode> _expressionActive = {};
  final Set<AstNode> _typeActive = {};
  Map<TypeParameter, _DynamicStatus> _bindings = {};

  _DynamicStatus typeStatus(TypeAnnotation? type, CompilationUnitMember origin) {
    if (type == null) {
      return _DynamicStatus.unknown;
    }
    if (isIgnoredType(type)) {
      return _DynamicStatus.known;
    }
    if (type is RecordTypeAnnotation) {
      return _combine([
        for (final field in type.positionalFields) typeStatus(field.type, origin),
        for (final field in type.namedFields?.fields ?? <RecordTypeAnnotationNamedField>[]) typeStatus(field.type, origin),
      ]);
    }
    if (type is GenericFunctionType) {
      return _combine([
        if (type.returnType == null) _DynamicStatus.dynamicType else typeStatus(type.returnType, origin),
        for (final parameter in type.parameters.parameters) parameterStatus(parameter, origin),
        for (final parameter in type.typeParameters?.typeParameters ?? <TypeParameter>[])
          if (parameter.bound != null) typeStatus(parameter.bound, origin),
      ]);
    }
    if (type is! NamedType) {
      return _DynamicStatus.unknown;
    }
    if (type.importPrefix == null && type.name.lexeme == 'dynamic') {
      return _DynamicStatus.dynamicType;
    }
    final arguments = type.typeArguments?.arguments;
    final argumentStatus = _combine([for (final argument in arguments ?? <TypeAnnotation>[]) typeStatus(argument, origin)]);
    if (argumentStatus == _DynamicStatus.dynamicType) {
      return argumentStatus;
    }
    if (type.importPrefix == null) {
      for (var scope = type.parent; scope != null; scope = scope.parent) {
        for (final parameter in _parametersOf(scope)) {
          if (parameter.name.lexeme == type.name.lexeme) {
            return _bindings[parameter] ?? _DynamicStatus.known;
          }
        }
      }
    }
    final index = _indexFor(origin, type.importPrefix?.name.lexeme);
    final declaration = index.aliases[type.name.lexeme] ?? index.declarations[type.name.lexeme];
    if (declaration == null) {
      final name = type.name.lexeme;
      final prefix = type.importPrefix?.name.lexeme;
      final recognized =
          _sdkDynamicGenericTypeNames.contains(name) && (prefix == null || _isSdkImportPrefix(origin, prefix)) ||
          _externalGenericTypeNames.contains(name) ||
          (prefix != null && _externalGenericTypeNames.contains('$prefix.$name'));
      return arguments == null && recognized ? _DynamicStatus.dynamicType : _DynamicStatus.unknown;
    }
    if (!_active.add(declaration)) {
      return _DynamicStatus.unknown;
    }
    try {
      return _withBindings(declaration, arguments, origin, () {
        if (declaration is GenericTypeAlias) {
          return typeStatus(declaration.type, declaration);
        }
        if (declaration is FunctionTypeAlias) {
          return _combine([
            if (declaration.returnType == null) _DynamicStatus.dynamicType else typeStatus(declaration.returnType, declaration),
            for (final parameter in declaration.parameters.parameters) parameterStatus(parameter, declaration),
          ]);
        }
        return _combine(_parametersOf(declaration).map((parameter) => _bindings[parameter] ?? _DynamicStatus.unknown));
      });
    } finally {
      _active.remove(declaration);
    }
  }

  bool _isSdkImportPrefix(CompilationUnitMember origin, String prefix) {
    return dependenciesFrom(origin, _project).whereType<ImportDirective>().any(
      (directive) =>
          directive.prefix?.name == prefix && directive.targetUris.any((uri) => const {'dart:core', 'dart:async', 'dart:collection'}.contains(uri)),
    );
  }

  _DynamicStatus _withBindings(
    CompilationUnitMember declaration,
    List<TypeAnnotation>? arguments,
    CompilationUnitMember origin,
    _DynamicStatus Function() inspect,
  ) {
    final parameters = _parametersOf(declaration).toList();
    final previous = _bindings;
    final explicit = [for (final argument in arguments ?? <TypeAnnotation>[]) typeStatus(argument, origin)];
    _bindings = {...previous};
    try {
      // Resolve references between bounds recursively, without guessing cycles.
      final evaluating = <TypeParameter>{};
      _DynamicStatus defaultFor(TypeParameter parameter) {
        if (_bindings.containsKey(parameter)) {
          return _bindings[parameter]!;
        }
        if (!evaluating.add(parameter)) {
          return _DynamicStatus.unknown;
        }
        final bound = parameter.bound;
        for (final other in parameters) {
          if (other != parameter && !_bindings.containsKey(other) && !evaluating.contains(other)) {
            _bindings[other] = defaultFor(other);
          }
        }
        final status = bound == null ? _DynamicStatus.dynamicType : typeStatus(bound, declaration);
        evaluating.remove(parameter);
        return status;
      }

      for (var i = 0; i < parameters.length; i++) {
        if (arguments != null) {
          _bindings[parameters[i]] = i < explicit.length ? explicit[i] : _DynamicStatus.unknown;
        }
      }
      for (final parameter in parameters) {
        _bindings[parameter] = _bindings[parameter] ?? defaultFor(parameter);
      }
      return inspect();
    } finally {
      _bindings = previous;
    }
  }

  _DynamicStatus variableStatus(VariableDeclaration variable, CompilationUnitMember origin) {
    if (!_active.add(variable)) {
      return _DynamicStatus.unknown;
    }
    try {
      final list = variable.parent;
      if (list is VariableDeclarationList && list.type != null) {
        return typeStatus(list.type, origin);
      }
      return variable.initializer == null ? _DynamicStatus.dynamicType : expressionStatus(variable.initializer!, origin);
    } finally {
      _active.remove(variable);
    }
  }

  _DynamicStatus expressionStatus(Expression expression, CompilationUnitMember origin) {
    if (!_expressionActive.add(expression)) {
      return _DynamicStatus.unknown;
    }
    try {
      return _expressionStatus(expression, origin);
    } finally {
      _expressionActive.remove(expression);
    }
  }

  _DynamicStatus _expressionStatus(Expression expression, CompilationUnitMember origin) {
    if (expression is ParenthesizedExpression) {
      return expressionStatus(expression.expression, origin);
    }
    if (expression is AwaitExpression) {
      return expressionStatus(expression.expression, origin);
    }
    if (expression is PostfixExpression && expression.operator.lexeme == '!') {
      return expressionStatus(expression.operand, origin);
    }
    if (expression is PostfixExpression) {
      return expressionStatus(expression.operand, origin);
    }
    if (expression is PrefixExpression) {
      return expressionStatus(expression.operand, origin);
    }
    if (expression is BinaryExpression) {
      return _combine([expressionStatus(expression.leftOperand, origin), expressionStatus(expression.rightOperand, origin)]);
    }
    if (expression is AssignmentExpression) {
      return _combine([expressionStatus(expression.leftHandSide, origin), expressionStatus(expression.rightHandSide, origin)]);
    }
    if (expression is CascadeExpression) {
      return expressionStatus(expression.target, origin);
    }
    if (expression is AsExpression) {
      return typeStatus(expression.type, origin);
    }
    if (expression is MethodInvocation) {
      return _invocationStatus(expression, origin);
    }
    if (expression is FunctionExpressionInvocation) {
      return _callValue(expression.function, origin);
    }
    if (expression is PropertyAccess) {
      final target = expression.realTarget;
      return _memberStatus(target, expression.propertyName.name, origin);
    }
    if (expression is PrefixedIdentifier) {
      return _memberStatus(expression.prefix, expression.identifier.name, origin);
    }
    if (expression is IndexExpression) {
      return _indexStatus(expression.realTarget, origin);
    }
    if (expression is ListLiteral) {
      final arguments = expression.typeArguments;
      if ((arguments != null || expression.elements.isEmpty) && _isIgnoredLiteralType('List', arguments)) {
        return _DynamicStatus.known;
      }
      return arguments != null
          ? _combine(arguments.arguments.map((type) => typeStatus(type, origin)))
          : expression.elements.isEmpty
          ? _DynamicStatus.dynamicType
          : _collectionStatus('List', expression.elements, origin);
    }
    if (expression is SetOrMapLiteral) {
      final arguments = expression.typeArguments;
      final name = arguments == null || arguments.arguments.length == 2 ? 'Map' : 'Set';
      if ((arguments != null || expression.elements.isEmpty) && _isIgnoredLiteralType(name, arguments)) {
        return _DynamicStatus.known;
      }
      return arguments != null
          ? _combine(arguments.arguments.map((type) => typeStatus(type, origin)))
          : expression.elements.isEmpty
          ? _DynamicStatus.dynamicType
          : _collectionStatus(expression.elements.any((element) => element is MapLiteralEntry) ? 'Map' : 'Set', expression.elements, origin);
    }
    if (expression is RecordLiteral) {
      return _combine(expression.fields.map((field) => expressionStatus(field is NamedExpression ? field.expression : field, origin)));
    }
    if (expression is InstanceCreationExpression) {
      final sdk = _sdkConstructorStatus(
        expression.constructorName.type.name.lexeme,
        expression.constructorName.name?.name,
        expression.constructorName.type.typeArguments,
        expression.argumentList,
        origin,
      );
      if (sdk != null) {
        return sdk;
      }
      if (expression.constructorName.type.typeArguments == null) {
        final type = expression.constructorName.type;
        final declaration = _indexFor(origin, type.importPrefix?.name.lexeme).declarations[type.name.lexeme];
        if (declaration != null) {
          return _constructorStatus(declaration, expression.constructorName.name?.name, expression.argumentList, origin);
        }
      }
      // Constructor inference can supply omitted arguments. Do not treat the
      // constructor name alone as proof of implicit dynamic.
      return expression.constructorName.type.typeArguments == null ? _DynamicStatus.unknown : typeStatus(expression.constructorName.type, origin);
    }
    if (expression is FunctionExpression) {
      return _combine([
        for (final parameter in expression.parameters?.parameters ?? <FormalParameter>[]) parameterStatus(parameter, origin),
        bodyStatus(expression.body, origin),
      ]);
    }
    if (expression is ConditionalExpression) {
      return _combine([expressionStatus(expression.thenExpression, origin), expressionStatus(expression.elseExpression, origin)]);
    }
    if (expression is SwitchExpression) {
      return _combine(expression.cases.map((branch) => expressionStatus(branch.expression, origin)));
    }
    if (expression is SimpleIdentifier) {
      final value = _lookupValue(expression.name, expression, origin);
      if (value != null) {
        return _valueStatus(value, origin);
      }
      return _DynamicStatus.unknown;
    }
    if (expression is Literal) {
      return _DynamicStatus.known;
    }
    return _DynamicStatus.unknown;
  }

  AstNode? _lookupValue(String name, AstNode use, CompilationUnitMember origin) {
    for (var scope = use.parent; scope != null; scope = scope.parent) {
      if (scope is Block) {
        for (final statement in scope.statements.reversed) {
          if (statement is FunctionDeclarationStatement && statement.functionDeclaration.name.lexeme == name) {
            return statement.functionDeclaration;
          }
          if (statement.offset >= use.offset) {
            continue;
          }
          if (statement is VariableDeclarationStatement) {
            for (final variable in statement.variables.variables) {
              if (variable.name.lexeme == name) {
                return variable;
              }
            }
          }
          if (statement is PatternVariableDeclarationStatement && _patternDeclaresName(statement.declaration.pattern, name)) {
            return statement.declaration.expression;
          }
        }
      }
      if (scope is IfStatement &&
          scope.caseClause != null &&
          _containsNode(scope.thenStatement, use) &&
          _patternDeclaresName(scope.caseClause!, name)) {
        return scope.expression;
      }
      if (scope is IfElement && scope.caseClause != null && _containsNode(scope.thenElement, use) && _patternDeclaresName(scope.caseClause!, name)) {
        return scope.expression;
      }
      if (scope is SwitchPatternCase && _patternDeclaresName(scope.guardedPattern.pattern, name)) {
        for (var parent = scope.parent; parent != null; parent = parent.parent) {
          if (parent is SwitchStatement) {
            return parent.expression;
          }
        }
      }
      if (scope is SwitchExpressionCase && _patternDeclaresName(scope.guardedPattern.pattern, name)) {
        for (var parent = scope.parent; parent != null; parent = parent.parent) {
          if (parent is SwitchExpression) {
            return parent.expression;
          }
        }
      }
      if (scope is ForStatement || scope is ForElement) {
        final parts = scope is ForStatement ? scope.forLoopParts : (scope as ForElement).forLoopParts;
        if (parts is ForEachParts && !_containsNode(parts.iterable, use)) {
          if (parts is ForEachPartsWithDeclaration && parts.loopVariable.name.lexeme == name ||
              parts is ForEachPartsWithPattern && _patternDeclaresName(parts.pattern, name)) {
            return parts.iterable;
          }
        }
        if (parts is ForPartsWithDeclarations) {
          for (final variable in parts.variables.variables) {
            if (variable.name.lexeme == name) {
              return variable;
            }
          }
        }
        if (parts is ForPartsWithPattern && _patternDeclaresName(parts.variables.pattern, name)) {
          return parts.variables.expression;
        }
      }
      final parameters = switch (scope) {
        FunctionExpression(:final parameters) => parameters,
        MethodDeclaration(:final parameters) => parameters,
        ConstructorDeclaration(:final parameters) => parameters,
        _ => null,
      };
      for (final parameter in parameters?.parameters ?? <FormalParameter>[]) {
        if (parameter.name?.lexeme == name) {
          return parameter;
        }
      }
    }
    for (final variable in origin.fieldVariables) {
      if (variable.name.lexeme == name) {
        return variable;
      }
    }
    for (final method in origin.methods) {
      if (method.name.lexeme == name) {
        return method;
      }
    }
    for (final declaration in _project.filesByPath[origin.sourcePath]?.declarations ?? <CompilationUnitMember>[]) {
      if (declaration is FunctionDeclaration && declaration.name.lexeme == name) {
        return declaration;
      }
      if (declaration is TopLevelVariableDeclaration) {
        for (final variable in declaration.variables.variables) {
          if (variable.name.lexeme == name) {
            return variable;
          }
        }
      }
    }
    return null;
  }

  CompilationUnitMember _owner(AstNode node, CompilationUnitMember fallback) {
    var result = fallback;
    for (AstNode? parent = node; parent != null; parent = parent.parent) {
      if (parent is CompilationUnitMember) {
        result = parent;
      }
    }
    return result;
  }

  _DynamicStatus _valueStatus(AstNode value, CompilationUnitMember origin) {
    final owner = _owner(value, origin);
    if (value is Expression) {
      return expressionStatus(value, owner);
    }
    if (value is VariableDeclaration) {
      return variableStatus(value, owner);
    }
    if (value is FormalParameter) {
      ClassMember? member;
      for (var node = value.parent; node != null; node = node.parent) {
        if (node is ClassMember) {
          member = node;
          break;
        }
      }
      return parameterStatus(value, owner, member: member);
    }
    if (value is MethodDeclaration) {
      return methodReturnStatus(value, owner);
    }
    if (value is FunctionDeclaration) {
      return _combine([
        _functionReturnStatus(value, owner),
        for (final parameter in value.functionExpression.parameters?.parameters ?? <FormalParameter>[]) parameterStatus(parameter, owner),
      ]);
    }
    return _DynamicStatus.unknown;
  }

  _DynamicStatus _functionReturnStatus(FunctionDeclaration function, CompilationUnitMember origin) {
    return function.returnType == null ? bodyStatus(function.functionExpression.body, origin) : typeStatus(function.returnType, origin);
  }

  _DynamicStatus _callValue(Expression expression, CompilationUnitMember origin) {
    if (expression is ParenthesizedExpression) {
      return _callValue(expression.expression, origin);
    }
    if (expression is FunctionExpression) {
      return bodyStatus(expression.body, origin);
    }
    final type = _expressionType(expression, origin);
    if (type != null) {
      if (type.type is GenericFunctionType) {
        return typeStatus((type.type as GenericFunctionType).returnType, type.origin);
      }
      if (type.type is NamedType && (type.type as NamedType).name.lexeme == 'dynamic') {
        return _DynamicStatus.dynamicType;
      }
    }
    if (expression is SimpleIdentifier) {
      final value = _lookupValue(expression.name, expression, origin);
      if (value is VariableDeclaration && value.initializer != null && value.initializer is FunctionExpression) {
        return bodyStatus((value.initializer! as FunctionExpression).body, _owner(value, origin));
      }
    }
    return _DynamicStatus.unknown;
  }

  _DynamicStatus _invocationStatus(MethodInvocation invocation, CompilationUnitMember origin) {
    final target = invocation.realTarget;
    final name = invocation.methodName.name;
    if (target == null) {
      final value = _lookupValue(name, invocation, origin);
      if (value is FunctionDeclaration) {
        return _withCallBindings(
          value,
          invocation.typeArguments,
          value.functionExpression.parameters,
          invocation.argumentList,
          origin,
          () => _functionReturnStatus(value, _owner(value, origin)),
        );
      }
      if (value is MethodDeclaration) {
        return _withCallBindings(
          value,
          invocation.typeArguments,
          value.parameters,
          invocation.argumentList,
          origin,
          () => methodReturnStatus(value, _owner(value, origin)),
        );
      }
      if (value != null) {
        return _callValue(invocation.methodName, origin);
      }
      final declaration = _indexFor(origin, null).declarations[name];
      if (declaration != null) {
        return _constructorStatus(declaration, null, invocation.argumentList, origin, types: invocation.typeArguments);
      }
      return _DynamicStatus.unknown;
    }
    if (target is SimpleIdentifier && _lookupValue(target.name, invocation, origin) == null) {
      final sdk = _sdkConstructorStatus(target.name, name, invocation.typeArguments, invocation.argumentList, origin);
      if (sdk != null) {
        return sdk;
      }
      final declaration = _indexFor(origin, null).declarations[target.name];
      if (declaration != null) {
        return _declaredMemberStatus(declaration, name, call: true, invocation: invocation);
      }
    }
    return _memberStatus(target, name, origin, call: true, invocation: invocation);
  }

  _DynamicStatus _withCallBindings(
    AstNode declaration,
    TypeArgumentList? types,
    FormalParameterList? parameters,
    ArgumentList arguments,
    CompilationUnitMember origin,
    _DynamicStatus Function() inspect,
  ) {
    final previous = _bindings;
    _bindings = {...previous};
    try {
      final genericParameters = _parametersOf(declaration).toList();
      for (var i = 0; i < genericParameters.length; i++) {
        final generic = genericParameters[i];
        if (types != null && i < types.arguments.length) {
          _bindings[generic] = typeStatus(types.arguments[i], origin);
          continue;
        }
        final inferred = <_DynamicStatus>[];
        var position = 0;
        for (final formal in parameters?.parameters ?? <FormalParameter>[]) {
          final normal = _normalParameter(formal);
          var type = _formalParameterType(normal);
          if (normal is FieldFormalParameter && declaration is CompilationUnitMember) {
            for (final field in declaration.fieldVariables) {
              if (field.name.lexeme == normal.name.lexeme && field.parent is VariableDeclarationList) {
                type = (field.parent! as VariableDeclarationList).type;
              }
            }
          }
          Expression? argument;
          if (formal.isNamed) {
            argument = arguments.arguments
                .whereType<NamedExpression>()
                .where((value) => value.name.label.name == formal.name?.lexeme)
                .firstOrNull
                ?.expression;
          } else {
            final positional = arguments.arguments.where((value) => value is! NamedExpression).toList();
            if (position < positional.length) {
              argument = positional[position];
            }
            position++;
          }
          if (type is NamedType && type.importPrefix == null && type.name.lexeme == generic.name.lexeme && argument != null) {
            inferred.add(expressionStatus(argument, origin));
          }
        }
        _bindings[generic] = inferred.isEmpty ? _DynamicStatus.unknown : _combine(inferred);
      }
      return inspect();
    } finally {
      _bindings = previous;
    }
  }

  _DynamicStatus _constructorStatus(
    CompilationUnitMember declaration,
    String? name,
    ArgumentList arguments,
    CompilationUnitMember origin, {
    TypeArgumentList? types,
  }) {
    if (_ignoredTypeKeys.contains(declaration.name)) {
      return _DynamicStatus.known;
    }
    if (types != null && _isIgnoredLiteralType(declaration.name, types)) {
      return _DynamicStatus.known;
    }
    final constructor = declaration.constructors.where((constructor) => constructor.name?.lexeme == name).firstOrNull;
    return _withCallBindings(
      declaration,
      types,
      constructor?.parameters,
      arguments,
      origin,
      () => _combine(_parametersOf(declaration).map((parameter) => _bindings[parameter] ?? _DynamicStatus.unknown)),
    );
  }

  _DynamicStatus? _sdkConstructorStatus(
    String name,
    String? constructor,
    TypeArgumentList? arguments,
    ArgumentList values,
    CompilationUnitMember origin,
  ) {
    final index = _indexFor(origin, null);
    if (index.declarations.containsKey(name) || index.aliases.containsKey(name)) {
      return null;
    }
    if (!((name == 'Future' || name == 'Stream') && constructor == 'value')) {
      return null;
    }
    if (_ignoredTypeKeys.contains(name)) {
      return _DynamicStatus.known;
    }
    if (arguments != null) {
      if (_isIgnoredLiteralType(name, arguments)) {
        return _DynamicStatus.known;
      }
      return _combine(arguments.arguments.map((type) => typeStatus(type, origin)));
    }
    if (values.arguments.isEmpty) {
      return _DynamicStatus.unknown;
    }
    final value = values.arguments.first;
    final key = _expressionKey(value, origin);
    if (key != null && _ignoredTypeKeys.contains('$name<$key>')) {
      return _DynamicStatus.known;
    }
    return expressionStatus(value, origin);
  }

  ({TypeAnnotation type, CompilationUnitMember origin})? _expressionType(Expression expression, CompilationUnitMember origin) {
    if (!_typeActive.add(expression)) {
      return null;
    }
    try {
      if (expression is ParenthesizedExpression) {
        return _expressionType(expression.expression, origin);
      }
      if (expression is AsExpression) {
        return (type: expression.type, origin: origin);
      }
      if (expression is InstanceCreationExpression) {
        return (type: expression.constructorName.type, origin: origin);
      }
      AstNode? value;
      if (expression is SimpleIdentifier) {
        value = _lookupValue(expression.name, expression, origin);
      }
      if (expression is MethodInvocation && expression.target == null) {
        value = _lookupValue(expression.methodName.name, expression, origin);
        if (value is FunctionDeclaration && value.returnType != null) {
          return (type: value.returnType!, origin: _owner(value, origin));
        }
        if (value is MethodDeclaration && value.returnType != null) {
          return (type: value.returnType!, origin: _owner(value, origin));
        }
        return null;
      }
      if (value is VariableDeclaration) {
        final list = value.parent;
        final owner = _owner(value, origin);
        if (list is VariableDeclarationList && list.type != null) {
          return (type: list.type!, origin: owner);
        }
        if (value.initializer != null) {
          return _expressionType(value.initializer!, owner);
        }
      }
      if (value is FormalParameter) {
        final type = _formalParameterType(_normalParameter(value));
        if (type != null) {
          return (type: type, origin: _owner(value, origin));
        }
      }
      return null;
    } finally {
      _typeActive.remove(expression);
    }
  }

  _DynamicStatus _memberStatus(Expression target, String name, CompilationUnitMember origin, {bool call = false, MethodInvocation? invocation}) {
    final targetType = _expressionType(target, origin)?.type;
    if (targetType is NamedType && !call) {
      final arguments = targetType.typeArguments?.arguments;
      if (arguments != null && arguments.isNotEmpty) {
        if ({'first', 'last', 'single', 'current', 'values', 'keys'}.contains(name)) {
          return typeStatus(name == 'keys' ? arguments.first : arguments.last, origin);
        }
      }
    }
    if ((targetType == null || targetType is NamedType && targetType.name.lexeme == 'dynamic') &&
        expressionStatus(target, origin) == _DynamicStatus.dynamicType) {
      return _DynamicStatus.dynamicType;
    }
    if (target is ThisExpression) {
      return _declaredMemberStatus(origin, name, call: call, invocation: invocation);
    }
    final reference = _expressionType(target, origin);
    if (reference == null) {
      if (target is MethodInvocation && target.target == null && _lookupValue(target.methodName.name, target, origin) == null) {
        final declaration = _indexFor(origin, null).declarations[target.methodName.name];
        if (declaration != null) {
          final constructor = declaration.constructors.where((constructor) => constructor.name == null).firstOrNull;
          return _withCallBindings(
            declaration,
            target.typeArguments,
            constructor?.parameters,
            target.argumentList,
            origin,
            () => _declaredMemberStatus(declaration, name, call: call, invocation: invocation),
          );
        }
      }
      if (target is SimpleIdentifier) {
        final value = _lookupValue(target.name, target, origin);
        if (value is VariableDeclaration && value.initializer != null && _active.add(value)) {
          try {
            return _memberStatus(value.initializer!, name, _owner(value, origin), call: call, invocation: invocation);
          } finally {
            _active.remove(value);
          }
        }
      }
      return _DynamicStatus.unknown;
    }
    if (reference.type is! NamedType) {
      return _DynamicStatus.unknown;
    }
    final type = reference.type as NamedType;
    if (type.name.lexeme == 'dynamic' && type.importPrefix == null) {
      return _DynamicStatus.dynamicType;
    }
    return _inParent(type, reference.origin, (declaration) => _declaredMemberStatus(declaration, name, call: call, invocation: invocation));
  }

  _DynamicStatus _declaredMemberStatus(CompilationUnitMember declaration, String name, {bool call = false, MethodInvocation? invocation}) {
    if (!_active.add(declaration)) {
      return _DynamicStatus.unknown;
    }
    try {
      if (!call) {
        for (final field in declaration.fieldVariables) {
          if (field.name.lexeme == name) {
            return variableStatus(field, declaration);
          }
        }
      }
      for (final method in declaration.methods) {
        if (method.name.lexeme == name && (call || method.isGetter)) {
          if (invocation == null) {
            return methodReturnStatus(method, declaration);
          }
          return _withCallBindings(
            method,
            invocation.typeArguments,
            method.parameters,
            invocation.argumentList,
            _owner(invocation, declaration),
            () => methodReturnStatus(method, declaration),
          );
        }
      }
      for (final parent in _parentTypes(declaration)) {
        final status = _inParent(parent, declaration, (parent) => _declaredMemberStatus(parent, name, call: call, invocation: invocation));
        if (status != _DynamicStatus.unknown) {
          return status;
        }
      }
      return _DynamicStatus.unknown;
    } finally {
      _active.remove(declaration);
    }
  }

  _DynamicStatus _indexStatus(Expression? target, CompilationUnitMember origin) {
    if (target == null) {
      return _DynamicStatus.unknown;
    }
    final reference = _expressionType(target, origin);
    if (reference != null && reference.type is NamedType) {
      final type = reference.type as NamedType;
      if (type.name.lexeme == 'dynamic') {
        return _DynamicStatus.dynamicType;
      }
      final local = _indexFor(reference.origin, type.importPrefix?.name.lexeme).declarations[type.name.lexeme];
      if (local == null && {'List', 'Map'}.contains(type.name.lexeme)) {
        final arguments = type.typeArguments?.arguments;
        if (arguments == null) {
          return _DynamicStatus.dynamicType;
        }
        return typeStatus(arguments.last, reference.origin);
      }
      return _inParent(type, reference.origin, (declaration) => _declaredMemberStatus(declaration, '[]', call: true));
    }
    if (target is ListLiteral) {
      final arguments = target.typeArguments?.arguments;
      return arguments != null ? typeStatus(arguments.first, origin) : _combine(target.elements.map((element) => _elementStatus(element, origin)));
    }
    if (target is SetOrMapLiteral && target.typeArguments?.arguments.length == 2) {
      return typeStatus(target.typeArguments!.arguments.last, origin);
    }
    if (target is SetOrMapLiteral && target.typeArguments == null) {
      if (target.elements.isEmpty) {
        return _DynamicStatus.dynamicType;
      }
      return _combine(
        target.elements.map((element) => element is MapLiteralEntry ? expressionStatus(element.value, origin) : _DynamicStatus.unknown),
      );
    }
    if (target is SimpleIdentifier) {
      final value = _lookupValue(target.name, target, origin);
      if (value is VariableDeclaration && value.initializer != null && _active.add(value)) {
        try {
          return _indexStatus(value.initializer, _owner(value, origin));
        } finally {
          _active.remove(value);
        }
      }
    }
    return _DynamicStatus.unknown;
  }

  _DynamicStatus _collectionStatus(String name, Iterable<CollectionElement> elements, CompilationUnitMember origin) {
    if (_ignoredTypeKeys.contains(name)) {
      return _DynamicStatus.known;
    }
    final keys = <String>{};
    final values = <String>{};
    for (final element in elements) {
      if (element is MapLiteralEntry) {
        keys.add(_expressionKey(element.key, origin) ?? '?');
        values.add(_expressionKey(element.value, origin) ?? '?');
      } else if (element is Expression) {
        values.add(_expressionKey(element, origin) ?? '?');
      } else {
        values.add('?');
      }
    }
    if (values.length == 1 && !values.contains('?') && (name != 'Map' || keys.length == 1 && !keys.contains('?'))) {
      final key = name == 'Map' ? 'Map<${keys.single},${values.single}>' : '$name<${values.single}>';
      if (_ignoredTypeKeys.contains(key)) {
        return _DynamicStatus.known;
      }
    }
    return _combine(elements.map((element) => _elementStatus(element, origin)));
  }

  String? _expressionKey(Expression expression, CompilationUnitMember origin) {
    if (expression is StringLiteral) {
      return 'String';
    }
    if (expression is IntegerLiteral) {
      return 'int';
    }
    if (expression is DoubleLiteral) {
      return 'double';
    }
    if (expression is BooleanLiteral) {
      return 'bool';
    }
    final reference = _expressionType(expression, origin);
    return reference?.type.toSource().replaceAll(_typeWhitespace, '');
  }

  _DynamicStatus _elementStatus(CollectionElement element, CompilationUnitMember origin) {
    if (element is Expression) {
      return expressionStatus(element, origin);
    }
    if (element is MapLiteralEntry) {
      return _combine([expressionStatus(element.key, origin), expressionStatus(element.value, origin)]);
    }
    if (element is SpreadElement) {
      return expressionStatus(element.expression, origin);
    }
    if (element is IfElement) {
      return _combine([
        _elementStatus(element.thenElement, origin),
        if (element.elseElement != null) _elementStatus(element.elseElement!, origin),
      ]);
    }
    if (element is ForElement) {
      return _elementStatus(element.body, origin);
    }
    return _DynamicStatus.unknown;
  }

  _DynamicStatus bodyStatus(FunctionBody body, CompilationUnitMember origin) {
    if (body is ExpressionFunctionBody) {
      return expressionStatus(body.expression, origin);
    }
    if (body is! BlockFunctionBody) {
      return _DynamicStatus.unknown;
    }
    Iterable<_DynamicStatus> returns(AstNode node) sync* {
      if (node is FunctionExpression || node is FunctionDeclaration) {
        return;
      }
      if (node is ReturnStatement) {
        yield node.expression == null ? _DynamicStatus.known : expressionStatus(node.expression!, origin);
        return;
      }
      if (node is YieldStatement) {
        yield expressionStatus(node.expression, origin);
        return;
      }
      for (final child in node.childEntities.whereType<AstNode>()) {
        yield* returns(child);
      }
    }

    return _combine(returns(body.block));
  }

  _DynamicStatus methodReturnStatus(MethodDeclaration method, CompilationUnitMember origin) {
    if (method.returnType != null) {
      return typeStatus(method.returnType, origin);
    }
    if (!method.isStatic) {
      final inherited = _inheritedSignature(method, null, origin);
      if (inherited != null) {
        return inherited;
      }
    }
    return bodyStatus(method.body, origin);
  }

  _DynamicStatus parameterStatus(FormalParameter parameter, CompilationUnitMember origin, {ClassMember? member}) {
    final normal = _normalParameter(parameter);
    if (_isWildcardParameter(normal)) {
      return _DynamicStatus.known;
    }
    if (normal is FunctionTypedFormalParameter) {
      return _combine([
        if (normal.returnType == null) _DynamicStatus.dynamicType else typeStatus(normal.returnType, origin),
        for (final nested in normal.parameters.parameters) parameterStatus(nested, origin),
      ]);
    }
    final type = _formalParameterType(normal);
    if (type != null) {
      return typeStatus(type, origin);
    }
    if (!_active.add(normal)) {
      return _DynamicStatus.unknown;
    }
    try {
      if (normal is FieldFormalParameter) {
        for (final variable in origin.fieldVariables) {
          if (variable.name.lexeme == normal.name.lexeme) {
            return variableStatus(variable, origin);
          }
        }
        return _DynamicStatus.unknown;
      }
      if (normal is SuperFormalParameter && member is ConstructorDeclaration && origin is ClassDeclaration) {
        final superclass = origin.extendsClause?.superclass;
        if (superclass == null) {
          return _DynamicStatus.unknown;
        }
        return _inParent(superclass, origin, (parent) {
          final invocation = member.initializers.whereType<SuperConstructorInvocation>().firstOrNull;
          final constructorName = invocation?.constructorName?.name ?? '';
          final constructor = parent.constructors.where((candidate) => (candidate.name?.lexeme ?? '') == constructorName).firstOrNull;
          if (constructor == null) {
            return _DynamicStatus.unknown;
          }
          final target = _matchingParameter(parameter, member.parameters.parameters, constructor.parameters.parameters);
          return target == null ? _DynamicStatus.unknown : parameterStatus(target, parent, member: constructor);
        });
      }
      if (member is MethodDeclaration && !member.isStatic) {
        final inherited = _inheritedSignature(member, parameter, origin);
        if (inherited != null) {
          return inherited;
        }
      }
      return _DynamicStatus.dynamicType;
    } finally {
      _active.remove(normal);
    }
  }

  _DynamicStatus _inParent(NamedType type, CompilationUnitMember origin, _DynamicStatus Function(CompilationUnitMember) inspect) {
    final index = _indexFor(origin, type.importPrefix?.name.lexeme);
    final alias = index.aliases[type.name.lexeme];
    if (alias is GenericTypeAlias && alias.type is NamedType) {
      if (!_active.add(alias)) {
        return _DynamicStatus.unknown;
      }
      try {
        return _withBindings(alias, type.typeArguments?.arguments, origin, () => _inParent(alias.type as NamedType, alias, inspect));
      } finally {
        _active.remove(alias);
      }
    }
    final parent = index.declarations[type.name.lexeme];
    if (parent == null) {
      return _DynamicStatus.unknown;
    }
    return _withBindings(parent, type.typeArguments?.arguments, origin, () => inspect(parent));
  }

  _DynamicStatus? _inheritedSignature(MethodDeclaration method, FormalParameter? parameter, CompilationUnitMember origin) {
    final parents = _parentTypes(origin).toList();
    if (parents.isEmpty) {
      return null;
    }
    final matches = <_DynamicStatus>[];
    for (final type in parents) {
      var found = true;
      final status = _inParent(type, origin, (parent) {
        if (!_active.add(parent)) {
          return _DynamicStatus.unknown;
        }
        try {
          final inherited = parent.methods.where((candidate) => candidate.name.lexeme == method.name.lexeme && !candidate.isStatic).firstOrNull;
          if (inherited == null) {
            final ancestor = _inheritedSignature(method, parameter, parent);
            found = ancestor != null;
            return ancestor ?? _DynamicStatus.unknown;
          }
          if (parameter == null) {
            return methodReturnStatus(inherited, parent);
          }
          final target = _matchingParameter(parameter, method.parameters?.parameters ?? [], inherited.parameters?.parameters ?? []);
          return target == null ? _DynamicStatus.unknown : parameterStatus(target, parent, member: inherited);
        } finally {
          _active.remove(parent);
        }
      });
      if (found) {
        matches.add(status);
      }
    }
    return matches.isEmpty ? null : _combine(matches);
  }

  _VisibleTypeReferenceIndex _indexFor(
    CompilationUnitMember origin,
    String? importPrefix,
  ) {
    final key = (
      sourcePath: origin.sourcePath,
      importPrefix: importPrefix,
    );
    return _indexes.putIfAbsent(
      key,
      () => _VisibleTypeReferenceIndex(
        visibleTypeReferenceDeclarationsFrom(
          origin,
          _project,
          importPrefix: importPrefix,
        ),
      ),
    );
  }
}

final class _VisibleTypeReferenceIndex {
  _VisibleTypeReferenceIndex(Iterable<CompilationUnitMember> declarations) {
    for (final declaration in declarations) {
      if (declaration case final TypeAlias alias) {
        aliases.putIfAbsent(alias.name.lexeme, () => alias);
      } else {
        this.declarations.putIfAbsent(declaration.name, () => declaration);
      }
    }
  }

  final Map<String, TypeAlias> aliases = {};
  final Map<String, CompilationUnitMember> declarations = {};
}

Iterable<TypeParameter> _parametersOf(AstNode node) {
  final parameters = switch (node) {
    ClassDeclaration(:final namePart) => namePart.typeParameters,
    EnumDeclaration(:final namePart) => namePart.typeParameters,
    ExtensionTypeDeclaration(:final primaryConstructor) => primaryConstructor.typeParameters,
    FunctionDeclaration(:final functionExpression) => functionExpression.typeParameters,
    _ => node.childEntities.whereType<TypeParameterList>().firstOrNull,
  };
  return parameters?.typeParameters ?? const <TypeParameter>[];
}

Iterable<NamedType> _parentTypes(CompilationUnitMember declaration) sync* {
  for (final node in declaration.childEntities.whereType<AstNode>()) {
    if (node is ExtendsClause || node is ImplementsClause || node is WithClause || node is MixinOnClause) {
      yield* node.childEntities.whereType<NamedType>();
    }
  }
  if (declaration is ClassTypeAlias) {
    yield declaration.superclass;
  }
}

FormalParameter? _matchingParameter(FormalParameter parameter, List<FormalParameter> source, List<FormalParameter> target) {
  if (parameter.isNamed) {
    return target.where((candidate) => candidate.isNamed && candidate.name?.lexeme == parameter.name?.lexeme).firstOrNull;
  }
  final sourcePositional = source.where((candidate) => !candidate.isNamed).toList();
  final position = sourcePositional.indexOf(parameter);
  final targetPositional = target.where((candidate) => !candidate.isNamed).toList();
  return position < 0 || position >= targetPositional.length ? null : targetPositional[position];
}

void _addSignatureHeaderFindings(
  List<HeimdallValidationInfo> findings,
  CompilationUnitMember declaration,
  HeimdallProject project,
  _RawGenericTypeResolver resolver,
) {
  void inspect(TypeAnnotation type, String position) {
    if (resolver.typeStatus(type, declaration) != _DynamicStatus.dynamicType) {
      return;
    }
    findings.add(
      HeimdallValidationInfo(
        filePath: declaration.sourcePath,
        line: declaration.sourceLocationAt(type.offset).line,
        message: '${declaration.name} has public dynamic $position: ${type.toSource()}',
      ),
    );
  }

  void visit(AstNode node) {
    if (node is FunctionBody || node is Expression || node is Annotation) {
      return;
    }
    if (node is TypeAnnotation && resolver.isIgnoredType(node)) {
      return;
    }
    if (node is ClassMember && !node.isPublic) {
      return;
    }
    if (node is FormalParameter && _isWildcardParameter(_normalParameter(node))) {
      return;
    }
    if (node is FunctionDeclaration && node.functionExpression.typeParameters != null) {
      visit(node.functionExpression.typeParameters!);
    }
    if (node is PrimaryConstructorDeclaration) {
      final name = node.constructorName?.name.lexeme ?? 'new';
      if (!name.startsWith('_')) {
        _addParameterFindings(
          findings,
          project: project,
          origin: declaration,
          rawGenericTypes: resolver,
          filePath: declaration.sourcePath,
          lineFor: (parameter) => declaration.sourceLocationAt(parameter.offset).line,
          ownerName: _constructorDisplayName(declaration, name),
          parameters: node.formalParameters.parameters,
        );
      }
    }
    if (node is TypeParameter && node.bound != null) {
      inspect(node.bound!, 'type parameter bound');
    }
    if (node is ExtendsClause || node is ImplementsClause || node is WithClause || node is MixinOnClause || node is ExtensionOnClause) {
      for (final type in node.childEntities.whereType<TypeAnnotation>()) {
        inspect(type, 'supertype or extension target');
      }
    }
    node.childEntities.whereType<AstNode>().forEach(visit);
  }

  visit(declaration);
  if (declaration is ClassTypeAlias) {
    inspect(declaration.superclass, 'supertype');
  }
}
