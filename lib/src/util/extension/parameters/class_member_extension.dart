import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_declaration.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_member.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_project.dart';
import 'package:heimdall_test/src/util/extension/assignability/compilation_unit_member_extension.dart';
import 'package:heimdall_test/src/util/extension/formal_parameter_extension.dart';
import 'package:heimdall_test/src/util/extension/lookup/compilation_unit_member_extension.dart';
import 'package:heimdall_test/src/util/extension/named_type_extension.dart';

abstract final class _RegexPatterns {
  static final typeParameterReference = RegExp(r'[A-Za-z_$][A-Za-z0-9_$]*(?:\.[A-Za-z_$][A-Za-z0-9_$]*)*\??');
}

/// Parameters queries for [ClassMember] nodes.
extension ClassMemberParametersExtension on ClassMember {
  /// Returns whether this node receives a parameter whose resolved type name satisfies [test].
  bool receivesResolvedParameterTypeNameWhere(
    HeimdallProject project,
    bool Function(String typeName) test,
  ) {
    return parameters.any((parameter) {
      final typeName = _resolvedParameterTypeName(
        parameter,
        member: this,
        project: project,
      );
      return typeName != null && test(typeName);
    });
  }

  /// Returns whether this node receives a parameter whose resolved type is assignable to [typeName].
  bool receivesParameterAssignableTo(
    HeimdallProject project,
    String typeName,
  ) {
    return parameters.any((parameter) {
      var parameterTypeName = _resolvedParameterTypeName(
        parameter,
        member: this,
        project: project,
      );

      if (parameterTypeName == null) {
        return false;
      }

      if (this case MethodDeclaration(:final typeParameters)) {
        for (final formal in typeParameters?.typeParameters ?? <TypeParameter>[]) {
          if (parameterTypeName == formal.name.lexeme) {
            parameterTypeName = formal.bound?.toSource() ?? 'Object?';
          }
        }
      }

      CompilationUnitMember? actualSource;
      if (parameter is SuperFormalParameter && parameter.type == null && owner is ClassDeclaration) {
        final owner = this.owner as ClassDeclaration;
        final parent = owner.extendsClause?.superclass;

        if (parent != null && parameterTypeName!.contains('.')) {
          actualSource = owner.declarationNamed(project, parent.referenceName);
        }
      }

      return owner.instantiatedTypeIsAssignableTo(parameterTypeName!, typeName, project, actualSource: actualSource);
    });
  }
}

String? _resolvedParameterTypeName(
  FormalParameter parameter, {
  required ClassMember member,
  required HeimdallProject project,
  Set<String>? visited,
}) {
  final explicitType = parameter.declaredTypeName;
  if (explicitType != null) {
    return explicitType;
  }

  return switch (parameter) {
    FieldFormalParameter(:final name) => _fieldTypeName(member.owner, name.lexeme),
    SuperFormalParameter(:final name) => _superParameterTypeName(
      member,
      project,
      name.lexeme,
      visited ?? <String>{},
    ),
    _ => null,
  };
}

String? _fieldTypeName(CompilationUnitMember owner, String fieldName) {
  for (final member in owner.fields) {
    if (member.fields.variables.any((variable) => variable.name.lexeme == fieldName)) {
      return member.type;
    }
  }
  return null;
}

String? _superParameterTypeName(
  ClassMember member,
  HeimdallProject project,
  String parameterName,
  Set<String> visited,
) {
  final owner = member.owner;
  if (owner is! ClassDeclaration || member is! ConstructorDeclaration) {
    return null;
  }

  final superclassName = switch (owner.extendsClause?.superclass) {
    final NamedType type => type.referenceName,
    null => null,
  };
  if (superclassName == null) {
    return null;
  }

  final superclass = owner.declarationNamed(project, superclassName);
  if (superclass == null) {
    return null;
  }

  final constructorName = _superConstructorName(member);
  final targetConstructor = _constructorNamed(superclass, constructorName);
  if (targetConstructor == null) {
    return null;
  }

  final key = '${superclass.sourcePath}:${superclass.name}:$constructorName:$parameterName';
  if (!visited.add(key)) {
    return null;
  }

  final childParameter = (member as ClassMember).parameters.firstWhere((parameter) => parameter.name?.lexeme == parameterName);
  final positional = (member as ClassMember).parameters.where((parameter) => parameter.isPositional).toList();
  final targetPositional = (targetConstructor as ClassMember).parameters.where((parameter) => parameter.isPositional).toList();
  final position = positional.indexOf(childParameter);
  for (final parameter in (targetConstructor as ClassMember).parameters) {
    if (childParameter.isNamed
        ? parameter.name?.lexeme != parameterName
        : position < 0 || position >= targetPositional.length || !identical(parameter, targetPositional[position])) {
      continue;
    }
    final inheritedType = _resolvedParameterTypeName(
      parameter,
      member: targetConstructor,
      project: project,
      visited: visited,
    );
    if (inheritedType == null || superclass is! ClassDeclaration) {
      return inheritedType;
    }
    final typeParameters = superclass.namePart.typeParameters?.typeParameters;
    final typeArguments = owner.extendsClause?.superclass.typeArguments?.arguments;
    if (typeParameters == null) {
      return inheritedType;
    }
    final substitutions = <String, String>{
      for (var i = 0; i < typeParameters.length; i++)
        typeParameters[i].name.lexeme: typeArguments != null && i < typeArguments.length
            ? typeArguments[i].toSource()
            : typeParameters[i].bound?.toSource() ?? 'dynamic',
    };
    return inheritedType.replaceAllMapped(
      _RegexPatterns.typeParameterReference,
      (match) {
        final name = match[0]!;
        final nullable = name.endsWith('?');
        final replacement = substitutions[nullable ? name.substring(0, name.length - 1) : name];
        if (replacement == null) {
          return name;
        }
        return nullable && !replacement.endsWith('?') ? '$replacement?' : replacement;
      },
    );
  }
  return null;
}

ConstructorDeclaration? _constructorNamed(
  CompilationUnitMember declaration,
  String constructorName,
) {
  for (final constructor in declaration.constructors) {
    if ((constructor.name?.lexeme ?? '') == constructorName) {
      return constructor;
    }
  }
  return null;
}

String _superConstructorName(ConstructorDeclaration constructor) {
  for (final initializer in constructor.initializers) {
    if (initializer is SuperConstructorInvocation) {
      return initializer.constructorName?.name ?? '';
    }
  }
  return '';
}
