import 'package:heimdall_test/src/mapper/importer/import_options.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_project.dart';
import 'package:meta/meta.dart';

/// Process-local cache for imported Heimdall projects.
///
/// The cache key is based on the normalized import root and import option keys.
final class HeimdallImportCache {
  HeimdallImportCache._();

  static final Map<_ImportCacheKey, HeimdallProject> _projects = {};

  /// Returns a cached project for [rootPath] and [importOptions], when present.
  static HeimdallProject? read({
    required String rootPath,
    required List<ImportOption> importOptions,
  }) {
    return _projects[_ImportCacheKey(
      rootPath: rootPath,
      importOptionsKey: _importOptionsKey(importOptions),
    )];
  }

  /// Stores [project] for [rootPath] and [importOptions].
  static void write({
    required String rootPath,
    required List<ImportOption> importOptions,
    required HeimdallProject project,
  }) {
    _projects[_ImportCacheKey(
          rootPath: rootPath,
          importOptionsKey: _importOptionsKey(importOptions),
        )] =
        project;
  }

  /// Clears every cached import.
  static void clear() => _projects.clear();
}

String _importOptionsKey(List<ImportOption> options) {
  return options.map((option) => option.cacheKey).join('|');
}

@immutable
final class _ImportCacheKey {
  const _ImportCacheKey({
    required this.rootPath,
    required this.importOptionsKey,
  });

  final String rootPath;
  final String importOptionsKey;

  @override
  bool operator ==(Object other) {
    return other is _ImportCacheKey && other.rootPath == rootPath && other.importOptionsKey == importOptionsKey;
  }

  @override
  int get hashCode => Object.hash(rootPath, importOptionsKey);
}
