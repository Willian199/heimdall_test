import 'package:heimdall_test/src/mapper/importer/path_matcher.dart';

/// Filter applied before a Dart file is parsed by Heimdall.
///
/// Use import options to narrow the analyzed source tree by skipping tests,
/// generated files, build folders, or any path that should not participate in
/// architecture rules.
///
/// Example:
/// ```dart
/// final project = const HeimdallFileImporter(
///   importOptions: [ExcludeTestsImportOption()],
/// ).importPath();
/// ```
abstract interface class ImportOption {
  /// Stable key used by the importer cache.
  String get cacheKey;

  /// Returns `true` when [absolutePath] should be imported.
  bool includes(String absolutePath);
}

/// Includes every discovered `.dart` file.
///
/// Use this option when no generated-file or test-file filtering is desired.
final class IncludeAllImportOption implements ImportOption {
  /// Creates an option that includes every discovered Dart file.
  const IncludeAllImportOption();

  @override
  String get cacheKey => 'include-all';

  @override
  bool includes(String absolutePath) => true;
}

/// Excludes test files from the analysis scope.
///
/// A file is excluded when it is under `/test/` or ends with `_test.dart`.
final class ExcludeTestsImportOption implements ImportOption {
  /// Creates an option that excludes test files.
  const ExcludeTestsImportOption();

  @override
  String get cacheKey => 'exclude-tests';

  @override
  bool includes(String absolutePath) {
    final normalized = normalizePath(absolutePath);
    return !normalized.contains('/test/') && !normalized.endsWith('_test.dart');
  }
}

/// Includes only Dart files under a `lib/` path segment.
///
final class IncludeLibraryImportOption implements ImportOption {
  /// Creates an option that includes only Dart files under `lib/`.
  const IncludeLibraryImportOption();

  @override
  String get cacheKey => 'include-library';

  @override
  bool includes(String absolutePath) {
    final normalized = normalizePath(absolutePath);
    return normalized.contains('/lib/') && normalized.endsWith('.dart');
  }
}

/// Excludes common generated Dart files.
///
/// Files ending in `.g.dart`, `.freezed.dart`, or `.gr.dart` are skipped.
final class ExcludeGeneratedDartImportOption implements ImportOption {
  /// Creates an option that excludes generated Dart files.
  const ExcludeGeneratedDartImportOption();

  @override
  String get cacheKey => 'exclude-generated-dart';

  @override
  bool includes(String absolutePath) {
    final normalized = normalizePath(absolutePath);
    return !normalized.endsWith('.g.dart') && !normalized.endsWith('.freezed.dart') && !normalized.endsWith('.gr.dart');
  }
}

/// Creates an import option from a custom path predicate.
final class PathPredicateImportOption implements ImportOption {
  /// Creates a path predicate import option.
  ///
  /// Supplying [cacheKey] is recommended when the importer cache is enabled.
  const PathPredicateImportOption(this.predicate, {String? cacheKey}) : _cacheKey = cacheKey;

  /// Function that decides whether an absolute path should be included.
  final bool Function(String absolutePath) predicate;

  final String? _cacheKey;

  @override
  String get cacheKey => _cacheKey ?? '$PathPredicateImportOption:${identityHashCode(predicate)}';

  @override
  bool includes(String absolutePath) => predicate(absolutePath);
}
