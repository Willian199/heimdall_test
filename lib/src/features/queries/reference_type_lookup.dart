// Internal, query-only type resolution; reference ASTs never become subjects.
// ignore_for_file: public_member_api_docs

import 'package:heimdall_test/src/core.dart';
import 'package:heimdall_test/src/mapper/model/declaration_namespace_index.dart';

typedef ReferenceTypeDeclaration = ({CompilationUnitMember declaration, ReferenceLibrary? library});

/// Looks up a name through project namespaces and allowlisted reference sources.
///
/// Conditional branches are kept as separate candidates. Only completed root
/// traversals are cached, so export cycles cannot cache incomplete namespaces.
final class ReferenceTypeLookup {
  ReferenceTypeLookup(this._project);

  final HeimdallProject _project;
  final _visible = <(String, String?, String), List<ReferenceTypeDeclaration>>{};
  final _exported = <(Object, String), List<ReferenceTypeDeclaration>>{};

  List<ReferenceTypeDeclaration> visible(CompilationUnitMember origin, String name, {String? prefix}) {
    return _visible.putIfAbsent((origin.sourcePath, prefix, name), () {
      final scope = _project.libraryScopes.scopeOf(origin);
      if (prefix == null) {
        final local = [
          for (final file in scope.files)
            for (final symbol in _project.declarationNamespace.declaredSymbols(file))
              if (symbol.name == name && symbol.kind == DeclarationSymbolKind.type) (declaration: symbol.declaration, library: null),
        ];
        if (local.isNotEmpty || scope.names.contains(name)) {
          return local;
        }
      }
      final imports = scope.dependencies.whereType<ImportDirective>();
      final imported = {
        for (final directive in imports)
          if (directive.prefix?.name == prefix && _allows(directive.combinators, name)) ..._through(directive, name, {}),
      };
      if (imported.isNotEmpty || prefix != null || imports.any((directive) => directive.targetUris.contains('dart:core'))) {
        return List.unmodifiable(imported);
      }
      // An explicit dart:core import suppresses the implicit core namespace,
      // including when it is prefixed or excludes this name with combinators.
      final core = _project.referenceLibraries.library('dart:core');
      return core == null ? const [] : exported(core, name);
    });
  }

  /// Resolves names in a consultation AST without attaching validation context.
  List<ReferenceTypeDeclaration> inLibrary(ReferenceLibrary library, String name, {String? prefix}) {
    if (prefix == null) {
      final own = exported(library, name);
      if (own.isNotEmpty) {
        return own;
      }
    }
    final imports = library.units.expand((unit) => unit.directives).whereType<ImportDirective>();
    final imported = {
      for (final directive in imports)
        if (directive.prefix?.name == prefix && _allows(directive.combinators, name))
          for (final uri in _uris(directive)) ..._referenceUri(uri, library, name, {}),
    };
    if (imported.isNotEmpty || prefix != null || imports.any((directive) => _uris(directive).contains('dart:core'))) {
      return List.unmodifiable(imported);
    }
    final core = _project.referenceLibraries.library('dart:core');
    return core == null ? const [] : exported(core, name);
  }

  List<ReferenceTypeDeclaration> exported(Object source, String name) {
    return _exported.putIfAbsent((source, name), () => List.unmodifiable(_collect(source, name, {})));
  }

  List<ReferenceTypeDeclaration> _collect(Object source, String name, Set<Object> visiting) {
    if (name.startsWith('_') || visiting.contains(source)) {
      return const [];
    }
    final next = {...visiting, source};
    if (source is HeimdallSourceFile) {
      final symbols = [
        ..._project.declarationNamespace.declaredSymbols(source),
        for (final part in source.partDirectives)
          for (final file in part.targetFiles) ..._project.declarationNamespace.declaredSymbols(file),
      ].where((symbol) => symbol.name == name);
      if (symbols.isNotEmpty) {
        return [
          for (final symbol in symbols)
            if (symbol.kind == DeclarationSymbolKind.type) (declaration: symbol.declaration, library: null),
        ];
      }
      return [
        for (final directive in source.exportDirectives)
          if (_allows(directive.combinators, name)) ..._through(directive, name, next),
      ];
    }
    if (source is ReferenceLibrary) {
      final local = [
        for (final unit in source.units)
          for (final declaration in unit.declarations)
            if ((declaration is ClassDeclaration ||
                    declaration is ClassTypeAlias ||
                    declaration is EnumDeclaration ||
                    declaration is MixinDeclaration ||
                    declaration is ExtensionTypeDeclaration ||
                    declaration is TypeAlias) &&
                _name(declaration) == name)
              (declaration: declaration, library: source),
      ];
      if (local.isNotEmpty) {
        return local;
      }
      return [
        for (final directive in source.units.expand((unit) => unit.directives).whereType<ExportDirective>())
          if (_allows(directive.combinators, name))
            for (final uri in _uris(directive)) ..._referenceUri(uri, source, name, next),
      ];
    }
    return const [];
  }

  Iterable<ReferenceTypeDeclaration> _through(UriBasedDirective directive, String name, Set<Object> visiting) sync* {
    for (final uri in directive.targetUris) {
      final files = directive.resolvedTargets.where((target) => target.uri == uri).map((target) => target.file).whereType<HeimdallSourceFile>();
      if (files.isNotEmpty) {
        for (final file in files) {
          yield* _collect(file, name, visiting);
        }
      } else {
        final library = _project.referenceLibraries.library(uri);
        if (library != null) {
          yield* _collect(library, name, visiting);
        }
      }
    }
  }

  Iterable<ReferenceTypeDeclaration> _referenceUri(String uri, ReferenceLibrary source, String name, Set<Object> visiting) {
    final resolved = Uri.parse(source.uri).resolve(uri).toString();
    final library = _project.referenceLibraries.library(resolved);
    return library == null ? const [] : _collect(library, name, visiting);
  }
}

String? _name(CompilationUnitMember declaration) => switch (declaration) {
  ClassDeclaration() => declaration.namePart.typeName.lexeme,
  TypeAlias() => declaration.name.lexeme,
  EnumDeclaration() => declaration.namePart.typeName.lexeme,
  MixinDeclaration() => declaration.name.lexeme,
  ExtensionTypeDeclaration() => declaration.primaryConstructor.typeName.lexeme,
  _ => null,
};

Iterable<String> _uris(UriBasedDirective directive) sync* {
  if (directive.uri.stringValue case final uri?) {
    yield uri;
  }
  final configurations = switch (directive) {
    ImportDirective() => directive.configurations,
    ExportDirective() => directive.configurations,
    _ => const <Configuration>[],
  };
  for (final configuration in configurations) {
    if (configuration.uri.stringValue case final uri?) {
      yield uri;
    }
  }
}

bool _allows(Iterable<Combinator> combinators, String name) => combinators.every(
  (combinator) => switch (combinator) {
    ShowCombinator() => combinator.shownNames.any((identifier) => identifier.name == name),
    HideCombinator() => !combinator.hiddenNames.any((identifier) => identifier.name == name),
  },
);
