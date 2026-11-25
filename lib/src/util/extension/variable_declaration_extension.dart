import 'package:analyzer/dart/ast/ast.dart';

/// Shared queries for [VariableDeclaration] nodes.
extension VariableDeclarationExtension on VariableDeclaration {
  /// Whether the declared name starts with an underscore.
  bool get isPrivateDeclaration => name.lexeme.startsWith('_');

  /// Whether the declared name is public.
  bool get isPublicDeclaration => !isPrivateDeclaration;
}
