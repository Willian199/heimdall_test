import 'package:heimdall_test/src/core.dart';

/// File-level library information shared by every declaration in that file.
final class LibraryScope {
  LibraryScope._(this.files, this.dependencies);

  /// Files sharing the library, starting with the requested source file.
  final List<HeimdallSourceFile> files;

  /// Imports and parts visible from this source file.
  final List<Directive> dependencies;

  /// Cached local type and alias names from the imported file collections.
  late final Set<String> typeNames = Set.unmodifiable({
    for (final file in files)
      for (final declaration in [...file.typeDeclarations, ...file.typeAliases]) declaration.name,
  });

  /// Cached local function, accessor, and individual variable names.
  late final Set<String> valueNames = Set.unmodifiable({
    for (final file in files) ...file.topLevelValueNames,
  });

  /// All local names that can shadow an unprefixed import.
  late final Set<String> names = Set.unmodifiable({...typeNames, ...valueNames});
}

/// Cached library scopes derived from the importer's resolved directives.
final class LibraryScopeIndex {
  /// Creates lazy scopes for one imported project snapshot.
  LibraryScopeIndex(this._project);

  final HeimdallProject _project;

  final _empty = LibraryScope._(const [], const []);
  final _scopes = <HeimdallSourceFile, LibraryScope>{};

  // Reverse the importer's resolved part targets once, rather than searching
  // every project file for each declaration evaluated in a part.
  late final Map<HeimdallSourceFile, Set<HeimdallSourceFile>> _owners = _indexOwners();

  Map<HeimdallSourceFile, Set<HeimdallSourceFile>> _indexOwners() {
    final owners = <HeimdallSourceFile, Set<HeimdallSourceFile>>{};
    for (final part in _project.resolvedParts) {
      final owner = _project.filesByPath[part.originPath];
      if (owner != null) {
        for (final target in part.targetFiles) {
          (owners[target] ??= {}).add(owner);
        }
      }
    }
    return owners;
  }

  /// Reuses the library files, directives and local names for [declaration].
  LibraryScope scopeOf(CompilationUnitMember declaration) {
    final file = _project.filesByPath[declaration.sourcePath];
    if (file == null) {
      return _empty;
    }
    return _scopes.putIfAbsent(file, () {
      final owners = file.partOfDirectives.isEmpty ? [file] : _owners[file] ?? const <HeimdallSourceFile>{};
      return LibraryScope._(
        List.unmodifiable({
          file,
          for (final owner in owners) ...[
            owner,
            for (final part in owner.resolvedParts) ...part.targetFiles,
          ],
        }),
        List.unmodifiable([
          ...file.importDirectives,
          ...file.partDirectives,
          if (file.partOfDirectives.isNotEmpty)
            for (final owner in owners) ...[
              ...owner.importDirectives,
              ...owner.partDirectives,
            ],
        ]),
      );
    });
  }
}
