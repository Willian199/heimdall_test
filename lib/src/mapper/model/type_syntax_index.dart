import 'package:analyzer/dart/ast/ast.dart';

/// Syntax-only metadata shared by queries over an imported project snapshot.
///
/// Bindings and inferred types depend on the caller and are never stored here.
/// Consultation ASTs use the same index without acquiring validation context.
final class TypeSyntaxIndex {
  /// Creates a lazy index; unrelated rules do not pay for type traversal.
  TypeSyntaxIndex();

  final _parameters = Expando<List<TypeParameter>>();
  final _parameterNames = Expando<Map<String, TypeParameter>>();
  final _lexicalParameters = <NamedType, TypeParameter?>{};
  final _parents = Expando<List<NamedType>>();
  final _memberParents = Expando<List<NamedType>>();

  /// Generic parameters declared directly on [node], in source order.
  List<TypeParameter> parametersOf(AstNode node) => _parameters[node] ??= List.unmodifiable(
    switch (node) {
          ClassDeclaration(:final namePart) => namePart.typeParameters,
          EnumDeclaration(:final namePart) => namePart.typeParameters,
          ExtensionTypeDeclaration(:final primaryConstructor) => primaryConstructor.typeParameters,
          FunctionDeclaration(:final functionExpression) => functionExpression.typeParameters,
          _ => node.childEntities.whereType<TypeParameterList>().firstOrNull,
        }?.typeParameters ??
        const <TypeParameter>[],
  );

  /// Finds a directly declared parameter without rescanning parameter lists.
  TypeParameter? parameterNamed(AstNode node, String name) =>
      (_parameterNames[node] ??= {for (final parameter in parametersOf(node)) parameter.name.lexeme: parameter})[name];

  /// Resolves lexical shadowing once for each written type annotation.
  TypeParameter? parameterOf(NamedType type) => _lexicalParameters.putIfAbsent(type, () {
    if (type.importPrefix == null) {
      for (var scope = type.parent; scope != null; scope = scope.parent) {
        final parameter = parameterNamed(scope, type.name.lexeme);
        if (parameter != null) {
          return parameter;
        }
      }
    }
    return null;
  });

  /// Declared hierarchy edges, preserving the order used for type matching.
  List<NamedType> parentsOf(CompilationUnitMember declaration) => _parents[declaration] ??= List.unmodifiable([
    if (declaration is ClassTypeAlias) declaration.superclass,
    for (final clause in declaration.childEntities.whereType<AstNode>())
      if (clause is ExtendsClause || clause is ImplementsClause || clause is WithClause || clause is MixinOnClause)
        ...clause.childEntities.whereType<NamedType>(),
  ]);

  /// Member lookup order: last mixin, superclass, then interface constraints.
  List<NamedType> memberParentsOf(CompilationUnitMember declaration) => _memberParents[declaration] ??= _indexMemberParents(declaration);

  List<NamedType> _indexMemberParents(CompilationUnitMember declaration) {
    final clauses = declaration.childEntities.whereType<AstNode>().toList();
    return List.unmodifiable([
      for (final clause in clauses.whereType<WithClause>()) ...clause.mixinTypes.reversed,
      for (final clause in clauses.whereType<ExtendsClause>()) clause.superclass,
      if (declaration is ClassTypeAlias) declaration.superclass,
      for (final clause in clauses)
        if (clause is ImplementsClause || clause is MixinOnClause) ...clause.childEntities.whereType<NamedType>(),
    ]);
  }
}
