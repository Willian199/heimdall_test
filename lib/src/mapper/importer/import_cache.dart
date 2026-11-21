import 'package:heimdall_test/src/mapper/importer/import_options.dart';
import 'package:heimdall_test/src/mapper/importer/reference_import_options.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_project.dart';
import 'package:meta/meta.dart';

/// Process-local cache for imported Heimdall projects.
///
/// The key includes the normalized root, file options and consultation options.
final class HeimdallImportCache {
  HeimdallImportCache._();

  static final Map<_ImportCacheKey, HeimdallProject> _projects = {};

  /// Returns a cached project for [rootPath] and [importOptions], when present.
  static HeimdallProject? read({
    required String rootPath,
    required List<ImportOption> importOptions,
    required ReferenceImportOptions referenceOptions,
  }) {
    return _projects[_ImportCacheKey(
      rootPath: rootPath,
      importOptionsKey: _importOptionsKey(importOptions),
      referenceOptionsKey: referenceOptions.cacheKey,
    )];
  }

  /// Stores [project] for [rootPath] and [importOptions].
  static void write({
    required String rootPath,
    required List<ImportOption> importOptions,
    required ReferenceImportOptions referenceOptions,
    required HeimdallProject project,
  }) {
    _projects[_ImportCacheKey(
          rootPath: rootPath,
          importOptionsKey: _importOptionsKey(importOptions),
          referenceOptionsKey: referenceOptions.cacheKey,
        )] =
        project;
  }

  /// Clears every cached import.
  static void clear() => _projects.clear();
}

String _importOptionsKey(List<ImportOption> options) {
  return options.map((option) => '${option.cacheKey.length}:${option.cacheKey}').join('|');
}

@immutable
final class _ImportCacheKey {
  const _ImportCacheKey({
    required this.rootPath,
    required this.importOptionsKey,
    required this.referenceOptionsKey,
  });

  final String rootPath;
  final String importOptionsKey;
  final String referenceOptionsKey;

  @override
  bool operator ==(Object other) {
    return other is _ImportCacheKey &&
        other.rootPath == rootPath &&
        other.importOptionsKey == importOptionsKey &&
        other.referenceOptionsKey == referenceOptionsKey;
  }

  @override
  int get hashCode => Object.hash(rootPath, importOptionsKey, referenceOptionsKey);
}
