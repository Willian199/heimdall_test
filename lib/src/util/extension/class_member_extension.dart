import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/util/extension/type_annotation_extension.dart';

abstract final class _RegexPatterns {
  static final whitespace = RegExp(r'\s+');
}

/// Shared queries for [ClassMember] nodes.
extension ClassMemberExtension on ClassMember {
  /// The name available before member context is attached.
  String get syntaxName => switch (this) {
    FieldDeclaration(:final fields) => fields.variables.map((variable) => variable.name.lexeme).join(', '),
    MethodDeclaration(:final name) => name.lexeme,
    ConstructorDeclaration(:final name) => name?.lexeme ?? 'new',
    _ => toSource().split(_RegexPatterns.whitespace).take(3).join(' '),
  };

  /// Explicit method return type or field type, when present.
  String? get explicitTypeName => switch (this) {
    MethodDeclaration(:final returnType) => returnType.typeName,
    FieldDeclaration(:final fields) => fields.type.typeName,
    _ => null,
  };

  /// Executable parameters, without requiring imported member context.
  List<FormalParameter> get formalParameters => switch (this) {
    MethodDeclaration(:final parameters) => parameters?.parameters ?? const [],
    ConstructorDeclaration(:final parameters) => parameters.parameters,
    _ => const [],
  };

  /// Parameter defaults, initializers and bodies that contain executable code.
  List<AstNode> get executableSyntaxRoots => switch (this) {
    MethodDeclaration(:final parameters, :final body) => [?parameters, body],
    ConstructorDeclaration(:final parameters, :final initializers, :final body) => [parameters, ...initializers, body],
    FieldDeclaration(:final fields) => fields.variables.map((variable) => variable.initializer).whereType<Expression>().toList(),
    _ => const [],
  };

  /// The explicit field type, excluding methods and constructors.
  String? get declaredFieldTypeName => switch (this) {
    FieldDeclaration(:final fields) => fields.type.typeName,
    _ => null,
  };

  /// Returns the explicit return type of a method (including accessors).
  ///
  /// Fields and constructors have no return type. Missing annotations are not
  /// inferred; named types retain their prefix, generic arguments and nullability.
  String? get returnTypeName => switch (this) {
    MethodDeclaration(:final returnType) => returnType.typeName,
    _ => null,
  };
}
