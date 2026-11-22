import 'package:analyzer/dart/element/element.dart';
import 'package:heimdall_test/src/core.dart';
import 'package:heimdall_test/src/features/queries/declaration_lookup_queries.dart';
import 'package:heimdall_test/src/features/queries/generic_assignability_queries.dart';
import 'package:heimdall_test/src/features/queries/sdk_type_queries.dart';
import 'package:heimdall_test/src/features/queries/type_annotation_queries.dart';
import 'package:heimdall_test/src/features/queries/value_reference_queries.dart';

typedef _ReceiverType = ({String name, CompilationUnitMember source});
typedef _Access = ({Expression receiver, String name, Element? element, bool read, bool write, bool nullAware});

/// Finds implicit extension accesses using the importer's cached expressions.
///
/// Resolved elements are authoritative. For parsed sources, only receivers with
/// a recoverable static type participate; dynamic dispatch is never inferred to
/// be an extension call. Candidates must be visible, applicable and most specific.
final class ExtensionReferenceIndex {
  /// Collects accesses and visible extensions for the imported declaration.
  ExtensionReferenceIndex(this._item, this._project) {
    final scope = _project.libraryScopes.scopeOf(_item);
    _extensions.addAll(scope.files.expand((file) => file.extensionDeclarations).where((extension) => extension.onClause != null));
    for (final directive in scope.dependencies.whereType<ImportDirective>()) {
      for (final branch in directive.resolvedTargets) {
        for (final symbol in _project.declarationNamespace.visibleSymbols(directive, branch.file)) {
          final declaration = symbol.declaration;
          if (declaration is ExtensionDeclaration && declaration.onClause != null && !scope.typeNames.contains(symbol.name)) {
            _extensions.add(declaration);
            (_origins[declaration] ??= {}).add((directive, branch.file));
          }
        }
      }
    }
    final file = _project.filesByPath[_item.sourcePath];
    for (final expression in file?.expressionsInDeclaration(_item) ?? const <Expression>[]) {
      switch (expression) {
        case MethodInvocation(:final realTarget, :final methodName, :final isNullAware) when realTarget != null:
          _accesses.add((receiver: realTarget, name: methodName.name, element: methodName.element, read: true, write: false, nullAware: isNullAware));
        case PropertyAccess(:final realTarget, :final propertyName):
          _accesses.add((
            receiver: realTarget,
            name: propertyName.name,
            element: propertyName.element,
            read: propertyName.inGetterContext(),
            write: propertyName.inSetterContext(),
            nullAware: expression.isNullAware,
          ));
        case PrefixedIdentifier(:final prefix, :final identifier):
          _accesses.add((
            receiver: prefix,
            name: identifier.name,
            element: identifier.element,
            read: identifier.inGetterContext(),
            write: identifier.inSetterContext(),
            nullAware: false,
          ));
        case BinaryExpression(:final leftOperand, :final operator, :final element):
          _accesses.add((receiver: leftOperand, name: operator.lexeme, element: element, read: true, write: false, nullAware: false));
        case IndexExpression(:final realTarget, :final element, :final isNullAware):
          if (expression.inGetterContext()) {
            _accesses.add((receiver: realTarget, name: '[]', element: element, read: true, write: false, nullAware: isNullAware));
          }
          if (expression.inSetterContext()) {
            _accesses.add((receiver: realTarget, name: '[]=', element: element, read: false, write: true, nullAware: isNullAware));
          }
      }
    }
  }

  static final _nullableSuffix = RegExp(r'\?$');
  static final _identifier = RegExp(r'^[A-Za-z_$][\w$]*$');

  final CompilationUnitMember _item;
  final HeimdallProject _project;
  final _extensions = <ExtensionDeclaration>{};
  final _origins = <ExtensionDeclaration, Set<(ImportDirective, HeimdallSourceFile)>>{};
  final _accesses = <_Access>[];
  final _types = <Expression, _ReceiverType?>{};
  final _resolving = <Expression>{};
  final _matches = <_Access, Set<ExtensionDeclaration>>{};

  /// Whether [extension] supplies a member used implicitly by the declaration.
  bool references(ExtensionDeclaration extension) => _accesses.any(
    (access) => (_matches[access] ??= _resolve(access)).contains(extension),
  );

  Set<ExtensionDeclaration> _resolve(_Access access) {
    final element = access.element;
    if (element != null) {
      return {
        for (final extension in _extensions)
          if (extension.declaredFragment?.element == element.enclosingElement) extension,
      };
    }
    final providing = _extensions.where((extension) => _provides(extension, access)).toList();
    if (providing.isEmpty) {
      return {};
    }
    var receiver = _type(access.receiver);
    if (receiver == null || receiver.name == 'dynamic' || receiver.name == 'void') {
      return {};
    }
    if (access.nullAware && receiver.name.endsWith('?')) {
      receiver = (name: receiver.name.substring(0, receiver.name.length - 1), source: receiver.source);
    }
    final declaration = declarationNamedFrom(receiver.source, _project, receiver.name.split('<').first.replaceAll('?', ''));
    if (declaration != null && _instanceMember(declaration, access.name, {}) != null) {
      return {};
    }
    final sdkType = sdkTypeName(receiver.source, receiver.name.split('<').first.replaceAll('?', ''), _project);
    if (sdkType != null && _project.referenceLibraries.hasSdkInstanceMember(sdkType, access.name)) {
      return {};
    }
    final applicable = <ExtensionApplicability>[];
    for (final extension in providing) {
      final match = extensionApplicabilityFor(extension, receiver.source, receiver.name, _project);
      if (match != null) {
        applicable.add(match);
      }
    }
    return {
      for (final candidate in applicable)
        if (!applicable.any(
          (other) => other != candidate && _canCoexist(other.extension, candidate.extension) && other.isMoreSpecificThan(candidate),
        ))
          candidate.extension,
    };
  }

  bool _provides(ExtensionDeclaration extension, _Access access) => extension.methods.any(
    (method) => !method.isStatic && method.name.lexeme == access.name && (!method.isGetter || access.read) && (!method.isSetter || access.write),
  );

  bool _canCoexist(ExtensionDeclaration left, ExtensionDeclaration right) {
    final leftOrigins = _origins[left];
    final rightOrigins = _origins[right];
    if (leftOrigins == null || rightOrigins == null) {
      return true;
    }
    return leftOrigins.any((a) => rightOrigins.any((b) => a.$1 != b.$1 || a.$2 == b.$2));
  }

  ClassMember? _instanceMember(CompilationUnitMember owner, String name, Set<CompilationUnitMember> visited) {
    if (!visited.add(owner)) {
      return null;
    }
    for (final method in owner.methods) {
      if (!method.isStatic && method.name.lexeme == name) {
        return method;
      }
    }
    for (final field in owner.fields) {
      if (!field.isStatic && field.fields.variables.any((variable) => variable.name.lexeme == name)) {
        return field;
      }
    }
    final parents = switch (owner) {
      ClassDeclaration(:final extendsClause, :final withClause, :final implementsClause) => [
        ...?withClause?.mixinTypes.reversed,
        if (extendsClause != null) extendsClause.superclass,
        ...?implementsClause?.interfaces,
      ],
      ClassTypeAlias(:final superclass, :final withClause) => [...withClause.mixinTypes.reversed, superclass],
      MixinDeclaration(:final onClause) => [...?onClause?.superclassConstraints],
      EnumDeclaration(:final withClause) => [...?withClause?.mixinTypes.reversed],
      _ => <NamedType>[],
    };
    for (final parent in parents) {
      final target = declarationNamedFrom(owner, _project, namedTypeReferenceName(parent));
      final member = target == null ? null : _instanceMember(target, name, visited);
      if (member != null) {
        return member;
      }
    }
    return null;
  }

  _ReceiverType? _type(Expression expression) {
    if (_types.containsKey(expression)) {
      return _types[expression];
    }
    if (!_resolving.add(expression)) {
      return null;
    }
    try {
      return _types[expression] = _inferType(expression);
    } finally {
      _resolving.remove(expression);
    }
  }

  CompilationUnitMember _source(AstNode node) {
    for (var current = node; current.parent != null; current = current.parent!) {
      if (current is CompilationUnitMember && current.parent is CompilationUnit) {
        return current;
      }
    }
    return _item;
  }

  _ReceiverType? _inferType(Expression expression) {
    final source = _source(expression);
    final resolved = expression.staticType;
    if (resolved != null) {
      return (name: resolved.getDisplayString(), source: source);
    }
    switch (expression) {
      case ParenthesizedExpression(:final expression):
        return _type(expression);
      case AsExpression(:final type):
        return (name: type.toSource(), source: source);
      case PostfixExpression(:final operand, :final operator) when operator.lexeme == '!':
        final type = _type(operand);
        return type == null ? null : (name: type.name.replaceFirst(_nullableSuffix, ''), source: type.source);
      case IntegerLiteral():
        return (name: 'int', source: source);
      case DoubleLiteral():
        return (name: 'double', source: source);
      case StringLiteral():
        return (name: 'String', source: source);
      case BooleanLiteral():
        return (name: 'bool', source: source);
      case InstanceCreationExpression(:final constructorName):
        return (name: constructorName.type.toSource(), source: source);
      case ThisExpression():
        return source is ExtensionDeclaration
            ? source.onClause == null
                  ? null
                  : (name: source.onClause!.extendedType.toSource(), source: source)
            : source.isTypeDeclaration
            ? (name: source.name, source: source)
            : null;
      case SimpleIdentifier():
        return _identifierType(expression, source);
      case PropertyAccess(:final realTarget, :final propertyName):
        return _memberType(realTarget, propertyName.name);
      case PrefixedIdentifier(:final prefix, :final identifier):
        final type = declarationNamedFrom(source, _project, prefix.name);
        if (type is EnumDeclaration && type.body.constants.any((constant) => constant.name.lexeme == identifier.name)) {
          return (name: type.namePart.typeName.lexeme, source: type);
        }
        if (!hasValueReceiver(prefix, prefix.name, _project)) {
          final imported = _importedValueType(source, identifier.name, prefix.name);
          if (imported != null) {
            return imported;
          }
        }
        return _memberType(prefix, identifier.name);
      case MethodInvocation(:final target, :final methodName):
        final reference = target == null ? methodName.name : '${target.toSource()}.${methodName.name}';
        final constructor = declarationNamedFrom(source, _project, reference);
        if (constructor != null && constructor is! ExtensionDeclaration) {
          return (name: '$reference${expression.typeArguments?.toSource() ?? ''}', source: source);
        }
        if (target != null) {
          final result = _memberType(target, methodName.name);
          if (result != null) {
            return result;
          }
        } else {
          if (isShadowedValue(methodName)) {
            return null;
          }
          for (final file in _project.libraryScopes.scopeOf(source).files) {
            for (final function in file.topLevelFunctions) {
              if (function.name.lexeme == methodName.name && function.returnType != null) {
                return (name: function.returnType!.toSource(), source: function);
              }
            }
          }
        }
        final prefix = target is SimpleIdentifier ? target.name : null;
        if (target is SimpleIdentifier && hasValueReceiver(target, target.name, _project)) {
          return null;
        }
        if (target == null || prefix != null) {
          for (final directive in _project.libraryScopes.scopeOf(source).dependencies.whereType<ImportDirective>()) {
            if (directive.prefix?.name != prefix) {
              continue;
            }
            for (final branch in directive.resolvedTargets) {
              for (final symbol in _project.declarationNamespace.visibleSymbols(directive, branch.file)) {
                final function = symbol.declaration;
                if (symbol.name == methodName.name && function is FunctionDeclaration && function.returnType != null) {
                  return (name: function.returnType!.toSource(), source: function);
                }
              }
            }
          }
        }
      default:
        return null;
    }
    return null;
  }

  _ReceiverType? _importedValueType(CompilationUnitMember source, String name, String? prefix) {
    final scope = _project.libraryScopes.scopeOf(source);
    if (prefix == null && scope.names.contains(name)) {
      return null;
    }
    for (final directive in scope.dependencies.whereType<ImportDirective>()) {
      if (directive.prefix?.name != prefix) {
        continue;
      }
      for (final branch in directive.resolvedTargets) {
        for (final symbol in _project.declarationNamespace.visibleSymbols(directive, branch.file)) {
          if (symbol.name != name) {
            continue;
          }
          final declaration = symbol.declaration;
          if (declaration is TopLevelVariableDeclaration) {
            for (final variable in declaration.variables.variables) {
              if (variable.name.lexeme == name) {
                return _variableType(variable);
              }
            }
          } else if (declaration is FunctionDeclaration && declaration.isGetter && declaration.returnType != null) {
            return (name: declaration.returnType!.toSource(), source: declaration);
          }
        }
      }
    }
    return null;
  }

  _ReceiverType? _memberType(Expression receiver, String name) {
    final type = _type(receiver);
    if (type == null || type.name == 'dynamic') {
      return null;
    }
    final owner = declarationNamedFrom(type.source, _project, type.name.split('<').first.replaceAll('?', ''));
    final member = owner == null ? null : _instanceMember(owner, name, {});
    if (member is MethodDeclaration && member.returnType != null) {
      return (name: member.returnType!.toSource(), source: _source(member));
    }
    if (member is FieldDeclaration) {
      for (final variable in member.fields.variables) {
        if (variable.name.lexeme == name) {
          return _variableType(variable);
        }
      }
    }
    return null;
  }

  _ReceiverType? _variableType(VariableDeclaration variable) {
    final parent = variable.parent;
    if (parent is VariableDeclarationList && parent.type != null) {
      return (name: parent.type!.toSource(), source: _source(variable));
    }
    return variable.initializer == null ? null : _type(variable.initializer!);
  }

  _ReceiverType _lexicalType(SimpleIdentifier reference, _ReceiverType type, AstNode binding) {
    var name = type.name;
    var source = type.source;
    final bareName = name.endsWith('?') ? name.substring(0, name.length - 1) : name;
    if (_identifier.hasMatch(bareName)) {
      for (var ancestor = reference.parent; ancestor != null; ancestor = ancestor.parent) {
        final parameters = switch (ancestor) {
          MethodDeclaration(:final typeParameters) || FunctionExpression(:final typeParameters) => typeParameters,
          ClassDeclaration(:final namePart) => namePart.typeParameters,
          ExtensionDeclaration(:final typeParameters) || MixinDeclaration(:final typeParameters) => typeParameters,
          _ => null,
        };
        final parameter = parameters?.typeParameters.where((parameter) => parameter.name.lexeme == bareName).firstOrNull;
        if (parameter != null) {
          final bound = parameter.bound?.toSource() ?? 'Object?';
          name = name.endsWith('?') && !bound.endsWith('?') ? '$bound?' : bound;
          source = _source(reference);
          break;
        }
      }
    }
    final file = _project.filesByPath[_source(reference).sourcePath];
    final promoted = file?.flowPromotions.promotedType(reference, name, binding);
    return (name: promoted?.name ?? name, source: promoted?.annotation == null ? source : _source(promoted!.annotation!));
  }

  _ReceiverType? _identifierType(SimpleIdentifier reference, CompilationUnitMember source) {
    for (var ancestor = reference.parent; ancestor != null; ancestor = ancestor.parent) {
      final parameters = switch (ancestor) {
        MethodDeclaration(:final parameters) || FunctionExpression(:final parameters) => parameters?.parameters,
        ConstructorDeclaration(:final parameters) => parameters.parameters,
        _ => null,
      };
      for (var parameter in parameters ?? <FormalParameter>[]) {
        if (parameter.name?.lexeme != reference.name) {
          continue;
        }
        if (parameter is DefaultFormalParameter) {
          parameter = parameter.parameter;
        }
        final annotation = switch (parameter) {
          SimpleFormalParameter(:final type) || FieldFormalParameter(:final type) || SuperFormalParameter(:final type) => type,
          _ => null,
        };
        if (annotation != null) {
          return _lexicalType(reference, (name: annotation.toSource(), source: source), parameter);
        }
        if (parameter is! FieldFormalParameter) {
          return null;
        }
        for (final variable in source.fieldVariables) {
          if (variable.name.lexeme == reference.name) {
            final type = _variableType(variable);
            return type == null ? null : _lexicalType(reference, type, parameter);
          }
        }
        return null;
      }
      if (ancestor is Block) {
        for (final statement in ancestor.statements.reversed) {
          if (statement.offset >= reference.offset) {
            continue;
          }
          if (statement is VariableDeclarationStatement) {
            for (final variable in statement.variables.variables) {
              if (variable.name.lexeme == reference.name) {
                final type = _variableType(variable);
                return type == null ? null : _lexicalType(reference, type, variable);
              }
            }
          }
        }
      }
    }
    if (isShadowedValue(reference)) {
      return null;
    }
    final member = _instanceMember(source, reference.name, {});
    if (member is MethodDeclaration && member.isGetter && member.returnType != null) {
      return (name: member.returnType!.toSource(), source: _source(member));
    }
    if (member is FieldDeclaration) {
      for (final variable in member.fields.variables) {
        if (variable.name.lexeme == reference.name) {
          return _variableType(variable);
        }
      }
    }
    for (final file in _project.libraryScopes.scopeOf(source).files) {
      for (final declaration in file.topLevelVariables) {
        for (final variable in declaration.variables.variables) {
          if (variable.name.lexeme == reference.name) {
            return _variableType(variable);
          }
        }
      }
    }
    return _importedValueType(source, reference.name, null);
  }
}
