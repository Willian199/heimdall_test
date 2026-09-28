import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/features/queries/declaration_lookup_queries.dart';
import 'package:heimdall_test/src/features/queries/generic_assignability_queries.dart';
import 'package:heimdall_test/src/features/queries/type_annotation_queries.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_declaration.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_member.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_project.dart';

final _typeParameterReferencePattern = RegExp(r'[A-Za-z_$][A-Za-z0-9_$]*(?:\.[A-Za-z_$][A-Za-z0-9_$]*)*\??');

/// Returns whether [member] receives a parameter whose resolved type name satisfies [test].
bool memberReceivesResolvedParameterTypeNameWhere(
  ClassMember member,
  HeimdallProject project,
  bool Function(String typeName) test,
) {
  return member.parameters.any((parameter) {
    final typeName = _resolvedParameterTypeName(
      parameter,
      member: member,
      project: project,
    );
    return typeName != null && test(typeName);
  });
}

/// Returns whether [member] receives a parameter whose resolved type is assignable to [typeName].
bool memberReceivesParameterAssignableTo(
  ClassMember member,
  HeimdallProject project,
  String typeName,
) {
  return member.parameters.any((parameter) {
    var parameterTypeName = _resolvedParameterTypeName(
      parameter,
      member: member,
      project: project,
    );

    if (parameterTypeName == null) {
      return false;
    }

    if (member is MethodDeclaration) {
      for (final formal in member.typeParameters?.typeParameters ?? <TypeParameter>[]) {
        if (parameterTypeName == formal.name.lexeme) {
          parameterTypeName = formal.bound?.toSource() ?? 'Object?';
        }
      }
    }

    CompilationUnitMember? actualSource;
    final inner = parameter is DefaultFormalParameter ? parameter.parameter : parameter;

    if (inner is SuperFormalParameter && inner.type == null && member.owner is ClassDeclaration) {
      final owner = member.owner as ClassDeclaration;
      final parent = owner.extendsClause?.superclass;

      if (parent != null && parameterTypeName!.contains('.')) {
        actualSource = declarationNamedFrom(owner, project, namedTypeReferenceName(parent));
      }
    }

    return instantiatedTypeIsAssignableTo(
      member.owner,
      parameterTypeName!,
      typeName,
      project,
      actualSource: actualSource,
    );
  });
}

String? _resolvedParameterTypeName(
  FormalParameter parameter, {
  required ClassMember member,
  required HeimdallProject project,
  Set<String>? visited,
}) {
  final explicitType = _parameterTypeName(parameter);
  if (explicitType != null) {
    return explicitType;
  }

  final inner = parameter is DefaultFormalParameter ? parameter.parameter : parameter;
  return switch (inner) {
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

String? _parameterTypeName(FormalParameter parameter) {
  final inner = parameter is DefaultFormalParameter ? parameter.parameter : parameter;
  return switch (inner) {
    SimpleFormalParameter(:final type) => typeAnnotationName(type),
    FieldFormalParameter(:final type) => typeAnnotationName(type),
    SuperFormalParameter(:final type) => typeAnnotationName(type),
    FunctionTypedFormalParameter() => 'Function${inner.question == null ? '' : '?'}',
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
    final NamedType type => namedTypeReferenceName(type),
    null => null,
  };
  if (superclassName == null) {
    return null;
  }

  final superclass = declarationNamedFrom(owner, project, superclassName);
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
      _typeParameterReferencePattern,
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
