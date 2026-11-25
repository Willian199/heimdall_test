import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/util/extension/class_body_extension.dart';
import 'package:heimdall_test/src/util/extension/extension_type_declaration_extension.dart';

abstract final class _RegexPatterns {
  static final whitespace = RegExp(r'\s+');
}

/// Shared queries for [CompilationUnitMember] nodes.
extension CompilationUnitMemberExtension on CompilationUnitMember {
  /// Returns the declared name's offset, falling back to the declaration start.
  int get nameOffset {
    return switch (this) {
      ClassDeclaration(:final namePart) => namePart.offset,
      MixinDeclaration(:final name) => name.offset,
      EnumDeclaration(:final namePart) => namePart.offset,
      ExtensionDeclaration(:final name?) => name.offset,
      ExtensionTypeDeclaration(:final extensionTypePrimaryConstructor) => extensionTypePrimaryConstructor.typeName.offset,
      TypeAlias(:final name) => name.offset,
      FunctionDeclaration(:final name) => name.offset,
      TopLevelVariableDeclaration(:final variables) => variables.variables.first.name.offset,
      _ => offset,
    };
  }

  /// The declared name, or a short source representation for unnamed nodes.
  String get syntaxName => switch (this) {
    ClassDeclaration(:final namePart) => namePart.typeName.lexeme,
    MixinDeclaration(:final name) => name.lexeme,
    EnumDeclaration(:final namePart) => namePart.typeName.lexeme,
    ExtensionDeclaration(:final name) => name?.lexeme ?? '<anonymous extension>',
    ExtensionTypeDeclaration(:final extensionTypePrimaryConstructor) => extensionTypePrimaryConstructor.typeName.lexeme,
    TypeAlias(:final name) => name.lexeme,
    FunctionDeclaration(:final name) => name.lexeme,
    TopLevelVariableDeclaration(:final variables) => variables.variables.map((variable) => variable.name.lexeme).join(', '),
    _ => toSource().split(_RegexPatterns.whitespace).take(3).join(' '),
  };

  /// Members of the declaration body, including empty-body declarations.
  List<ClassMember> get syntaxMembers => switch (this) {
    ClassDeclaration(:final body) => body.syntaxMembers,
    MixinDeclaration(:final body) => body.members,
    EnumDeclaration(:final body) => body.members,
    ExtensionDeclaration(:final body) => body.members,
    ExtensionTypeDeclaration(:final body) => body.syntaxMembers,
    _ => const [],
  };
}
