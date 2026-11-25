// Shared query-only type resolution; reference ASTs never become subjects.
// ignore_for_file: public_member_api_docs

import 'package:heimdall_test/src/core.dart';
import 'package:heimdall_test/src/util/enum/declaration_symbol_kind.dart';
import 'package:heimdall_test/src/util/extension/extension_type_declaration_extension.dart';

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
  final _referenceVisible = <(ReferenceLibrary, String?, String), List<ReferenceTypeDeclaration>>{};
  // A name only selects candidates inside one library. Each candidate retains
  // its AST identity and library; homonyms from other libraries stay distinct.
  final _libraryTypes = <ReferenceLibrary, Map<String, List<ReferenceTypeDeclaration>>>{};

  List<ReferenceTypeDeclaration> visible(CompilationUnitMember origin, String name, {String? prefix}) {
    return _visible.putIfAbsent((origin.sourcePath, prefix, name), () {
      final scope = _project.libraryScopes.scopeOf(origin);
      if (prefix == null) {
        final local = scope.typesByName[name];
        if (local != null) {
          return [for (final declaration in local) (declaration: declaration, library: null)];
        }
        if (scope.names.contains(name)) {
          return const [];
        }
      }
      final imports = scope.dependencies.whereType<ImportDirective>();
      final imported = {
        for (final directive in imports)
          if (directive.prefix?.name == prefix && _allows(directive.combinators, name)) ..._through(directive, name, {}),
      };
      if (imported.isNotEmpty || prefix != null) {
        return List.unmodifiable(imported);
      }
      return List.unmodifiable({for (final library in _configuredSdkLibraries(imports)) ...exported(library, name)});
    });
  }

  /// Checks a compiler-provided name whose library has no source declaration.
  /// The caller supplies both the name and its library URI.
  bool isIntrinsicVisible(CompilationUnitMember origin, String name, String libraryUri, {String? prefix}) {
    final scope = _project.libraryScopes.scopeOf(origin);
    if (prefix == null && scope.names.contains(name) || visible(origin, name, prefix: prefix).isNotEmpty) {
      return false;
    }
    final library = _project.referenceLibraries.library(libraryUri);
    if (library == null || library.units.isEmpty) {
      return false;
    }
    bool exports(Object source, Set<Object> visiting) {
      if (!visiting.add(source)) {
        return false;
      }
      if (source == library) {
        return true;
      }
      final directives = switch (source) {
        HeimdallSourceFile() => source.exportDirectives,
        ReferenceLibrary() => source.units.expand((unit) => unit.directives).whereType<ExportDirective>(),
        _ => const <ExportDirective>[],
      };
      for (final directive in directives.where((directive) => _allows(directive.combinators, name))) {
        for (final uri in _uris(directive)) {
          if (source is HeimdallSourceFile &&
              directive.resolvedTargets
                  .where((target) => target.uri == uri)
                  .map((target) => target.file)
                  .whereType<HeimdallSourceFile>()
                  .any((file) => exports(file, {...visiting}))) {
            return true;
          }
          final resolved = source is ReferenceLibrary ? Uri.parse(source.uri).resolve(uri).toString() : uri;
          final reference = _project.referenceLibraries.library(resolved);
          if (reference != null && exports(reference, {...visiting})) {
            return true;
          }
        }
      }
      return false;
    }

    final imports = scope.dependencies.whereType<ImportDirective>();
    for (final directive in imports.where((directive) => directive.prefix?.name == prefix && _allows(directive.combinators, name))) {
      for (final uri in directive.targetUris) {
        final files = directive.resolvedTargets.where((target) => target.uri == uri).map((target) => target.file).whereType<HeimdallSourceFile>();
        if (files.any((file) => exports(file, {}))) {
          return true;
        }
        final reference = _project.referenceLibraries.library(uri);
        if (reference != null && exports(reference, {})) {
          return true;
        }
      }
    }
    return prefix == null && _configuredSdkLibraries(imports).contains(library);
  }

  /// Resolves names in a consultation AST without attaching validation context.
  List<ReferenceTypeDeclaration> inLibrary(ReferenceLibrary library, String name, {String? prefix}) =>
      _referenceVisible.putIfAbsent((library, prefix, name), () => _inLibrary(library, name, prefix: prefix));

  List<ReferenceTypeDeclaration> _inLibrary(ReferenceLibrary library, String name, {String? prefix}) {
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
    if (imported.isNotEmpty || prefix != null) {
      return List.unmodifiable(imported);
    }
    return List.unmodifiable({for (final reference in _configuredSdkLibraries(imports)) ...exported(reference, name)});
  }

  Iterable<ReferenceLibrary> _configuredSdkLibraries(Iterable<ImportDirective> imports) {
    final explicit = imports.expand(_uris).toSet();
    return _project.referenceOptions.sdkLibraries
        .where((uri) => !explicit.contains(uri))
        .map(_project.referenceLibraries.library)
        .whereType<ReferenceLibrary>();
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
      final local = _libraryTypes.putIfAbsent(source, () => _indexLibraryTypes(source))[name] ?? const <ReferenceTypeDeclaration>[];
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

  Map<String, List<ReferenceTypeDeclaration>> _indexLibraryTypes(ReferenceLibrary library) {
    final types = <String, List<ReferenceTypeDeclaration>>{};
    for (final unit in library.units) {
      for (final declaration in unit.declarations) {
        final name = _name(declaration);
        if (name != null) {
          (types[name] ??= []).add((declaration: declaration, library: library));
        }
      }
    }
    return types;
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
  ExtensionTypeDeclaration() => declaration.extensionTypePrimaryConstructor.typeName.lexeme,
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
