import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:heimdall_test/src/core.dart';
import 'package:heimdall_test/src/features/queries/declaration_lookup_queries.dart';
import 'package:heimdall_test/src/features/queries/sdk_type_queries.dart';
import 'package:heimdall_test/src/features/queries/type_annotation_queries.dart';

/// Checks instantiated types while carrying substitutions over hierarchy edges.
bool instantiatedTypeIsAssignableTo(
  CompilationUnitMember source,
  String actual,
  String expected,
  HeimdallProject project, {
  CompilationUnitMember? actualSource,
}) => _assignable(_TypeUse.parse(actual, actualSource ?? source), _TypeUse.parse(expected, source), project, {});

/// Follows a declared relationship while preserving type arguments and scopes.
bool instantiatedTypeHasRelationship(CompilationUnitMember source, String expected, HeimdallProject project, {required String relationship}) {
  final target = _TypeUse.parse(expected, source);
  final visiting = <CompilationUnitMember>{};
  _TypeUse expand(_TypeUse type) {
    var current = type;
    final seen = <CompilationUnitMember>{};
    while (true) {
      final declaration = _declaration(current, project);
      if (declaration is! GenericTypeAlias || !seen.add(declaration)) {
        return current;
      }
      current = _TypeUse.parse(declaration.type.toSource(), declaration).substitute(_bindings(current, declaration));
    }
  }

  bool matches(_TypeUse type) {
    final expandedType = expand(type);
    final expandedTarget = expand(target);
    final declaration = _declaration(expandedType, project);
    final targetDeclaration = _declaration(expandedTarget, project);
    if (declaration != null && targetDeclaration != null ? !identical(declaration, targetDeclaration) : expandedType.name != expandedTarget.name) {
      return false;
    }
    return expandedTarget.arguments.isEmpty ||
        (_assignable(expandedType, expandedTarget, project, {}, allowDynamicDowncast: false) &&
            _assignable(expandedTarget, expandedType, project, {}, allowDynamicDowncast: false));
  }

  bool visit(_TypeUse type) {
    final expandedType = expand(type);
    final declaration = _declaration(expandedType, project);
    if (declaration == null || !visiting.add(declaration)) {
      return false;
    }
    try {
      final bindings = _bindings(expandedType, declaration);
      _TypeUse use(NamedType parent) => _TypeUse.parse(parent.toSource(), declaration).substitute(bindings);
      final superclass = switch (declaration) {
        ClassDeclaration() => declaration.extendsClause?.superclass,
        ClassTypeAlias() => declaration.superclass,
        _ => null,
      };
      if (relationship == 'extends') {
        return superclass != null && (matches(use(superclass)) || visit(use(superclass)));
      }
      for (final clause in declaration.childEntities.whereType<AstNode>()) {
        if (clause is WithClause || relationship == 'implements' && clause is ImplementsClause) {
          for (final parent in clause.childEntities.whereType<NamedType>()) {
            final parentType = use(parent);
            if (matches(parentType) || relationship == 'implements' && _assignable(parentType, target, project, {}, allowDynamicDowncast: false)) {
              return true;
            }
          }
        }
      }
      return superclass != null && visit(use(superclass));
    } finally {
      visiting.remove(declaration);
    }
  }

  return visit(_TypeUse.parse(source.name, source));
}

final class _TypeUse {
  const _TypeUse(this.name, this.arguments, this.nullable, this.source);

  factory _TypeUse.parse(String text, CompilationUnitMember source) {
    var value = text.trim();
    final nullable = value.endsWith('?');
    if (nullable) {
      value = value.substring(0, value.length - 1);
    }
    if (value.startsWith('(') ||
        RegExp(r'\bFunction\s*[<(]').hasMatch(value) && (!value.contains('<') || value.indexOf('Function') < value.indexOf('<'))) {
      return _TypeUse(value, const [], nullable, source);
    }
    final start = value.indexOf('<');
    if (start < 0 || !value.endsWith('>')) {
      return _TypeUse(value, const [], nullable, source);
    }
    final arguments = <_TypeUse>[];
    var depth = 0;
    var offset = start + 1;
    for (var i = offset; i < value.length - 1; i++) {
      final char = value[i];
      if ('<({'.contains(char)) {
        depth++;
      }
      if ('>)}'.contains(char)) {
        depth--;
      }
      if (char == ',' && depth == 0) {
        arguments.add(_TypeUse.parse(value.substring(offset, i), source));
        offset = i + 1;
      }
    }
    arguments.add(_TypeUse.parse(value.substring(offset, value.length - 1), source));
    return _TypeUse(value.substring(0, start), arguments, nullable, source);
  }

  final String name;
  final List<_TypeUse> arguments;
  final bool nullable;
  final CompilationUnitMember source;

  String get text => '$name${arguments.isEmpty ? '' : '<${arguments.map((item) => item.text).join(', ')}>'}${nullable ? '?' : ''}';

  _TypeUse substitute(Map<String, _TypeUse> bindings) {
    final bound = bindings[name];
    if (bound != null && arguments.isEmpty) {
      return _TypeUse(bound.name, bound.arguments, nullable || bound.nullable, bound.source);
    }
    final replaced = name.replaceAllMapped(RegExp(r'\b[A-Za-z_$][\w$]*(?:\.[A-Za-z_$][\w$]*)*\b'), (match) => bindings[match[0]]?.text ?? match[0]!);
    return _TypeUse(replaced, arguments.map((argument) => argument.substitute(bindings)).toList(), nullable, source);
  }
}

CompilationUnitMember? _declaration(_TypeUse type, HeimdallProject project) {
  final dot = type.name.indexOf('.');
  final prefix = dot < 0 ? null : type.name.substring(0, dot);
  final name = dot < 0 ? type.name : type.name.substring(dot + 1);
  return visibleTypeReferenceDeclarationsFrom(
    type.source,
    project,
    importPrefix: prefix,
  ).where((declaration) => declaration.name == name).firstOrNull;
}

Map<String, _TypeUse> _bindings(_TypeUse type, CompilationUnitMember declaration) {
  final parameters = switch (declaration) {
    ClassDeclaration() => declaration.namePart.typeParameters,
    EnumDeclaration() => declaration.namePart.typeParameters,
    ExtensionTypeDeclaration() => declaration.primaryConstructor.typeParameters,
    _ => declaration.childEntities.whereType<TypeParameterList>().firstOrNull,
  };
  final formals = parameters?.typeParameters ?? <TypeParameter>[];
  final bindings = <String, _TypeUse>{};
  for (var i = 0; i < formals.length; i++) {
    bindings[formals[i].name.lexeme] = i < type.arguments.length
        ? type.arguments[i]
        : _TypeUse.parse(formals[i].bound?.toSource() ?? 'dynamic', declaration).substitute(bindings);
  }
  return bindings;
}

bool _assignable(_TypeUse actual, _TypeUse expected, HeimdallProject project, Set<String> visiting, {bool allowDynamicDowncast = true}) {
  final declaration = _declaration(actual, project);
  final expectedDeclaration = _declaration(expected, project);
  final key = '${actual.source.sourcePath}:${actual.text}->${expected.source.sourcePath}:${expected.text}';
  if (!visiting.add(key)) {
    return false;
  }
  try {
    if (declaration is ExtensionDeclaration || expectedDeclaration is ExtensionDeclaration) {
      return false;
    }
    if (declaration is GenericTypeAlias) {
      final target = declaration.type.toSource();
      final expanded = _TypeUse.parse(target, declaration).substitute(_bindings(actual, declaration));
      return _assignable(
        _TypeUse(expanded.name, expanded.arguments, actual.nullable || expanded.nullable, expanded.source),
        expected,
        project,
        visiting,
        allowDynamicDowncast: allowDynamicDowncast,
      );
    }
    if (expectedDeclaration is GenericTypeAlias) {
      final target = expectedDeclaration.type.toSource();
      final expanded = _TypeUse.parse(target, expectedDeclaration).substitute(_bindings(expected, expectedDeclaration));
      return _assignable(
        actual,
        _TypeUse(expanded.name, expanded.arguments, expected.nullable || expanded.nullable, expanded.source),
        project,
        visiting,
        allowDynamicDowncast: allowDynamicDowncast,
      );
    }
    final a = sdkTypeName(actual.source, actual.name, project) ?? actual.name;
    final e = sdkTypeName(expected.source, expected.name, project) ?? expected.name;
    final actualSdk = declaration == null && sdkTypeName(actual.source, actual.name, project) != null;
    final expectedSdk = expectedDeclaration == null && sdkTypeName(expected.source, expected.name, project) != null;
    if (expected.name == 'dynamic' || expected.name == 'void') {
      return true;
    }
    if (actualSdk && a == 'Never' && !actual.nullable) {
      return true;
    }
    if (expectedSdk && e == 'FutureOr' && expected.arguments.length == 1) {
      if (_assignable(actual, expected.arguments.single, project, visiting, allowDynamicDowncast: allowDynamicDowncast)) {
        return true;
      }
      if (actualSdk && a == 'Future') {
        return _assignable(
          actual.arguments.firstOrNull ?? _TypeUse.parse('dynamic', actual.source),
          expected.arguments.single,
          project,
          visiting,
          allowDynamicDowncast: false,
        );
      }
      return false;
    }
    if ((actual.nullable || actualSdk && a == 'Null') && !(expected.nullable || expectedSdk && e == 'Null')) {
      return false;
    }
    if (actualSdk && (a == 'Null' || a == 'Never' && actual.nullable) && (expected.nullable || expectedSdk && e == 'Null')) {
      return true;
    }
    // A dynamic value permits a checked assignment, but dynamic type arguments
    // do not make Generic<dynamic> a subtype of Generic<String>.
    if (actual.name == 'dynamic' && !allowDynamicDowncast) {
      return expectedSdk && e == 'Object' && expected.nullable;
    }
    if (expectedSdk && e == 'Object' || actual.name == 'dynamic') {
      if (declaration is ExtensionTypeDeclaration && !expected.nullable) {
        return declaration.implementsClause?.interfaces.any(
              (type) =>
                  _assignable(_TypeUse.parse(type.toSource(), declaration).substitute(_bindings(actual, declaration)), expected, project, visiting),
            ) ??
            false;
      }
      return actual.name != 'void';
    }
    final structural = _structuralAssignable(actual, expected, project, visiting, expectedSdk ? e : null);
    if (structural != null) {
      return structural;
    }
    final same = declaration != null && expectedDeclaration != null
        ? identical(declaration, expectedDeclaration)
        : expectedDeclaration == null &&
              (declaration != null
                  ? !expected.name.contains('.') && declaration.name == expected.name
                  : (actualSdk && expectedSdk ? a == e : actual.name == expected.name));
    if (same) {
      if (expected.arguments.isEmpty) {
        return true;
      }
      final arguments = actual.arguments.isEmpty
          ? (declaration != null
                ? _bindings(actual, declaration).values.toList()
                : [for (var i = 0; i < (_sdkArity[a] ?? 0); i++) _TypeUse.parse('dynamic', actual.source)])
          : actual.arguments;
      return arguments.length == expected.arguments.length &&
          List.generate(
            arguments.length,
            (i) => _assignable(arguments[i], expected.arguments[i], project, {}, allowDynamicDowncast: false),
          ).every((matches) => matches);
    }
    if (declaration == null) {
      final parameters = actual.source.childEntities.whereType<TypeParameterList>().expand((item) => item.typeParameters);
      final classParameters = switch (actual.source) {
        ClassDeclaration(:final namePart) => namePart.typeParameters?.typeParameters ?? <TypeParameter>[],
        ExtensionTypeDeclaration(:final primaryConstructor) => primaryConstructor.typeParameters?.typeParameters ?? <TypeParameter>[],
        EnumDeclaration(:final namePart) => namePart.typeParameters?.typeParameters ?? <TypeParameter>[],
        _ => <TypeParameter>[],
      };
      final bound = [...parameters, ...classParameters].where((item) => item.name.lexeme == actual.name).firstOrNull;
      if (bound != null) {
        return _assignable(
          _TypeUse.parse(bound.bound?.toSource() ?? 'Object?', actual.source),
          expected,
          project,
          visiting,
          allowDynamicDowncast: allowDynamicDowncast,
        );
      }
      if (!actualSdk) {
        return false;
      }
      final args = actual.arguments.isEmpty
          ? [for (var i = 0; i < (_sdkArity[a] ?? 0); i++) _TypeUse.parse('dynamic', actual.source)]
          : actual.arguments;
      for (final parent in _sdkParents[a] ?? <String>[]) {
        // Keep the SDK import prefix when following an SDK hierarchy edge.
        final prefix = actual.name.contains('.') ? '${actual.name.split('.').first}.' : '';
        final name = parent.split('<').first;
        if (expectedSdk && e == name) {
          final parentArgs = parent.contains('<int>')
              ? [_TypeUse.parse('int', actual.source)]
              : parent.contains('<double>')
              ? [_TypeUse.parse('double', actual.source)]
              : parent.contains('<num>')
              ? [_TypeUse.parse('num', actual.source)]
              : parent.contains('<String>')
              ? [_TypeUse.parse('String', actual.source)]
              : parent.contains('<')
              ? args
              : <_TypeUse>[];
          if (expected.arguments.isEmpty ||
              parentArgs.length == expected.arguments.length &&
                  List.generate(
                    parentArgs.length,
                    (i) => _assignable(parentArgs[i], expected.arguments[i], project, {}, allowDynamicDowncast: false),
                  ).every((value) => value)) {
            return true;
          }
        }
        if (name != a &&
            _assignable(
              _TypeUse('$prefix$name', parent.contains('<') ? args : const [], false, actual.source),
              expected,
              project,
              visiting,
              allowDynamicDowncast: false,
            )) {
          return true;
        }
      }
      return false;
    }
    final bindings = _bindings(actual, declaration);
    final parents = <NamedType>[
      if (declaration is ClassTypeAlias) declaration.superclass,
      for (final child in declaration.childEntities.whereType<AstNode>())
        if (child is ExtendsClause || child is ImplementsClause || child is WithClause || child is MixinOnClause)
          ...child.childEntities.whereType<NamedType>(),
    ];
    for (final parent in parents) {
      final name = typeAnnotationName(parent);
      if (name != null &&
          _assignable(
            _TypeUse.parse(name, declaration).substitute(bindings),
            expected,
            project,
            visiting,
            allowDynamicDowncast: allowDynamicDowncast,
          )) {
        return true;
      }
    }
    return declaration is EnumDeclaration && expected.name == 'Enum';
  } finally {
    visiting.remove(key);
  }
}

const _sdkArity = {
  'List': 1,
  'Set': 1,
  'Iterable': 1,
  'Iterator': 1,
  'Queue': 1,
  'HashSet': 1,
  'LinkedHashSet': 1,
  'Map': 2,
  'HashMap': 2,
  'LinkedHashMap': 2,
  'Future': 1,
  'FutureOr': 1,
  'Comparable': 1,
};
const _sdkParents = {
  'int': ['num', 'Comparable<num>'],
  'double': ['num', 'Comparable<num>'],
  'num': ['Comparable<num>'],
  'String': ['Pattern', 'Comparable<String>'],
  'List': ['Iterable<T>'],
  'Set': ['Iterable<T>'],
  'Queue': ['Iterable<T>'],
  'HashSet': ['Set<T>', 'Iterable<T>'],
  'LinkedHashSet': ['Set<T>', 'Iterable<T>'],
  'SplayTreeSet': ['Set<T>', 'Iterable<T>'],
  'HashMap': ['Map<K,V>'],
  'LinkedHashMap': ['Map<K,V>'],
  'SplayTreeMap': ['Map<K,V>'],
  'Uint8List': ['List<int>', 'Iterable<int>'],
  'Int8List': ['List<int>', 'Iterable<int>'],
  'Uint16List': ['List<int>', 'Iterable<int>'],
  'Int16List': ['List<int>', 'Iterable<int>'],
  'Uint32List': ['List<int>', 'Iterable<int>'],
  'Int32List': ['List<int>', 'Iterable<int>'],
  'Uint64List': ['List<int>', 'Iterable<int>'],
  'Int64List': ['List<int>', 'Iterable<int>'],
  'Uint8ClampedList': ['List<int>', 'Iterable<int>'],
  'Float32List': ['List<double>', 'Iterable<double>'],
  'Float64List': ['List<double>', 'Iterable<double>'],
};

TypeAnnotation? _structuralType(_TypeUse type) {
  if (!type.name.startsWith('(') && !type.name.contains('Function')) {
    return null;
  }
  final unit = parseString(content: 'typedef _T = ${type.text};', throwIfDiagnostics: false).unit;
  return unit.declarations.whereType<GenericTypeAlias>().firstOrNull?.type;
}

bool? _structuralAssignable(_TypeUse actual, _TypeUse expected, HeimdallProject project, Set<String> visiting, String? expectedSdk) {
  final a = _structuralType(actual);
  final e = _structuralType(expected);
  final actualBindings = <String, _TypeUse>{};
  final expectedBindings = <String, _TypeUse>{};
  bool check(TypeAnnotation? left, TypeAnnotation? right, {bool reverse = false}) => _assignable(
    _TypeUse.parse(left?.toSource() ?? 'dynamic', reverse ? expected.source : actual.source).substitute(reverse ? expectedBindings : actualBindings),
    _TypeUse.parse(right?.toSource() ?? 'dynamic', reverse ? actual.source : expected.source).substitute(reverse ? actualBindings : expectedBindings),
    project,
    visiting,
    allowDynamicDowncast: false,
  );
  if (a is RecordTypeAnnotation) {
    if (expectedSdk == 'Record') {
      return true;
    }
    if (e is! RecordTypeAnnotation || a.positionalFields.length != e.positionalFields.length) {
      return false;
    }
    for (var i = 0; i < a.positionalFields.length; i++) {
      if (!check(a.positionalFields[i].type, e.positionalFields[i].type)) {
        return false;
      }
    }
    final named = {for (final field in a.namedFields?.fields ?? <RecordTypeAnnotationNamedField>[]) field.name.lexeme: field.type};
    final target = e.namedFields?.fields ?? <RecordTypeAnnotationNamedField>[];
    return named.length == target.length &&
        target.every((field) => named.containsKey(field.name.lexeme) && check(named[field.name.lexeme], field.type));
  }
  if (a is GenericFunctionType) {
    if (expectedSdk == 'Function') {
      return true;
    }
    if (e is! GenericFunctionType) {
      return false;
    }
    final aFormals = a.typeParameters?.typeParameters ?? <TypeParameter>[];
    final eFormals = e.typeParameters?.typeParameters ?? <TypeParameter>[];
    if (aFormals.length != eFormals.length) {
      return false;
    }
    for (var i = 0; i < aFormals.length; i++) {
      final binding = _TypeUse('_heimdallFunctionTypeParameter$i', const [], false, actual.source);
      actualBindings[aFormals[i].name.lexeme] = binding;
      expectedBindings[eFormals[i].name.lexeme] = binding;
    }
    for (var i = 0; i < aFormals.length; i++) {
      final aBound = _TypeUse.parse(aFormals[i].bound?.toSource() ?? 'Object?', actual.source).substitute(actualBindings);
      final eBound = _TypeUse.parse(eFormals[i].bound?.toSource() ?? 'Object?', expected.source).substitute(expectedBindings);
      if (!_assignable(aBound, eBound, project, visiting, allowDynamicDowncast: false) ||
          !_assignable(eBound, aBound, project, visiting, allowDynamicDowncast: false)) {
        return false;
      }
    }
    if (!check(a.returnType, e.returnType)) {
      return false;
    }
    TypeAnnotation? type(FormalParameter p) => (p is DefaultFormalParameter ? p.parameter : p).childEntities.whereType<TypeAnnotation>().firstOrNull;
    final ap = a.parameters.parameters.where((p) => p.isPositional).toList();
    final ep = e.parameters.parameters.where((p) => p.isPositional).toList();
    if (ap.length < ep.length || ap.where((p) => p.isRequiredPositional).length > ep.where((p) => p.isRequiredPositional).length) {
      return false;
    }
    for (var i = 0; i < ep.length; i++) {
      if (!check(type(ep[i]), type(ap[i]), reverse: true)) {
        return false;
      }
    }
    final an = {for (final p in a.parameters.parameters.where((p) => p.isNamed)) p.name?.lexeme: p};
    final en = {for (final p in e.parameters.parameters.where((p) => p.isNamed)) p.name?.lexeme: p};
    return an.values.where((p) => p.isRequiredNamed).every((p) => en[p.name?.lexeme]?.isRequiredNamed ?? false) &&
        en.entries.every((entry) => an.containsKey(entry.key) && check(type(entry.value), type(an[entry.key]!), reverse: true));
  }
  return e is GenericFunctionType || e is RecordTypeAnnotation ? false : null;
}
