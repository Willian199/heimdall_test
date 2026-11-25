import 'package:analyzer/dart/ast/ast.dart';

/// Shared queries for [AstNode] nodes.
extension AstNodeExtension on AstNode {
  /// Whether [node] is inside this node's source range.
  bool containsNode(AstNode node) => offset <= node.offset && node.end <= end;

  /// Whether this subtree declares a variable named [name].
  bool declaresName(String name) => switch (this) {
    VariableDeclaration(name: final declaredName) ||
    DeclaredIdentifier(name: final declaredName) ||
    DeclaredVariablePattern(name: final declaredName) when declaredName.lexeme == name => true,
    _ => childEntities.whereType<AstNode>().any((child) => child.declaresName(name)),
  };

  /// Whether this pattern subtree binds [name], excluding variable declarations.
  bool declaresPatternName(String name) => switch (this) {
    DeclaredVariablePattern(name: final declaredName) || DeclaredIdentifier(name: final declaredName) when declaredName.lexeme == name => true,
    _ => childEntities.whereType<AstNode>().any((child) => child.declaresPatternName(name)),
  };
}
