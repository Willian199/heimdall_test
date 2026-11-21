import 'package:analyzer/dart/element/element.dart';
import 'package:heimdall_test/src/core.dart';

/// The namespace category of an individual top-level symbol.
enum DeclarationSymbolKind {
  /// A type or type alias.
  type,

  /// A top-level function.
  function,

  /// A top-level getter.
  getter,

  /// A top-level setter.
  setter,

  /// One variable, independently of others in the same declaration.
  variable,
}

/// Internal association between a visible name and its original declaration.
final class DeclarationSymbol {
  const DeclarationSymbol._(this.declaration, this.name, this.kind, this.element);

  /// The original AST declaration, retaining its source location.
  final CompilationUnitMember declaration;

  /// Individual name used by import and export combinators.
  final String name;

  /// Whether this symbol denotes a type, function, accessor, or variable.
  final DeclarationSymbolKind kind;

  /// Semantic element when the caller supplied a resolved AST.
  final Element? element;

  bool get _isPublic => !name.startsWith('_') && !name.startsWith('<');
}

/// Shared, project-scoped import/export namespaces for types and values.
///
/// Only completed root traversals are cached: intermediate results in an export
/// cycle depend on the traversal path and must not be reused for other roots.
final class DeclarationNamespaceIndex {
  /// Creates lazy namespaces for one imported project snapshot.
  DeclarationNamespaceIndex();

  final _declared = <HeimdallSourceFile, List<DeclarationSymbol>>{};
  final _exported = <HeimdallSourceFile, List<DeclarationSymbol>>{};
  final _visible = <(Directive, HeimdallSourceFile), List<DeclarationSymbol>>{};

  /// All names declared in a file, including private symbols in `part` files.
  List<DeclarationSymbol> declaredSymbols(HeimdallSourceFile file) => _declared.putIfAbsent(file, () {
    return List.unmodifiable([
      for (final declaration in [...file.typeDeclarations, ...file.typeAliases])
        DeclarationSymbol._(declaration, declaration.name, DeclarationSymbolKind.type, declaration.declaredFragment?.element),
      for (final declaration in file.topLevelFunctions)
        DeclarationSymbol._(
          declaration,
          declaration.name.lexeme,
          declaration.isSetter
              ? DeclarationSymbolKind.setter
              : declaration.isGetter
              ? DeclarationSymbolKind.getter
              : DeclarationSymbolKind.function,
          declaration.declaredFragment?.element,
        ),
      for (final declaration in file.topLevelVariables)
        for (final variable in declaration.variables.variables)
          DeclarationSymbol._(declaration, variable.name.lexeme, DeclarationSymbolKind.variable, variable.declaredFragment?.element),
    ]);
  });

  /// Public symbols reachable through the library's parts and reexports.
  List<DeclarationSymbol> exportedSymbols(HeimdallSourceFile file) => _exported.putIfAbsent(file, () => _collect(file, {}));

  List<DeclarationSymbol> _collect(HeimdallSourceFile file, Set<HeimdallSourceFile> visiting) {
    if (visiting.contains(file)) {
      return const [];
    }
    final nextVisiting = {...visiting, file};
    return List.unmodifiable({
      ...declaredSymbols(file).where((symbol) => symbol._isPublic),
      for (final part in file.partDirectives)
        for (final target in part.targetFiles) ..._collect(target, nextVisiting),
      for (final export in file.exportDirectives)
        for (final target in export.targetFiles) ..._applyCombinators(_collect(target, nextVisiting), export.combinators),
    });
  }

  /// Names visible through a specific conditional branch of a directive.
  List<DeclarationSymbol> visibleSymbols(Directive directive, HeimdallSourceFile target) => _visible.putIfAbsent((directive, target), () {
    if (directive is PartDirective) {
      return declaredSymbols(target);
    }
    final symbols = exportedSymbols(target);
    return switch (directive) {
      ImportDirective(:final combinators) || ExportDirective(:final combinators) => _applyCombinators(symbols, combinators),
      _ => symbols,
    };
  });

  List<DeclarationSymbol> _applyCombinators(Iterable<DeclarationSymbol> symbols, NodeList<Combinator> combinators) {
    var visible = symbols;
    for (final combinator in combinators) {
      if (combinator is ShowCombinator) {
        final names = combinator.shownNames.map((name) => name.name).toSet();
        visible = visible.where((symbol) => names.contains(symbol.name));
      } else if (combinator is HideCombinator) {
        final names = combinator.hiddenNames.map((name) => name.name).toSet();
        visible = visible.where((symbol) => !names.contains(symbol.name));
      }
    }
    return List.unmodifiable(visible);
  }
}
