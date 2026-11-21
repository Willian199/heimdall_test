import 'dart:convert';

import 'package:path/path.dart' as p;

const _defaultSdkLibraries = ['dart:core', 'dart:async', 'dart:collection', 'dart:typed_data'];

/// Allowlist for lazy, query-only library imports.
///
/// These libraries never become validation subjects. Selecting a package permits
/// queries for its libraries; it does not eagerly scan the package or implicitly
/// permit its dependencies. Parts are read as part of their owning library.
final class ReferenceImportOptions {
  /// Creates an immutable allowlist. Library entries must be `dart:` or
  /// `package:` URIs; package entries are package names, not paths.
  factory ReferenceImportOptions({
    Iterable<String> sdkLibraries = _defaultSdkLibraries,
    Iterable<String> packageLibraries = const [],
    Iterable<String> packages = const [],
    String? sdkPath,
  }) {
    final sdk = sdkLibraries.toSet().toList();
    final libraries = packageLibraries.toSet().toList()..sort();
    final names = packages.toSet().toList()..sort();
    for (final value in sdk) {
      if (!_validLibrary(value, 'dart')) {
        throw ArgumentError.value(value, 'sdkLibraries', 'Expected a dart: library URI');
      }
    }
    for (final value in libraries) {
      if (!_validLibrary(value, 'package')) {
        throw ArgumentError.value(value, 'packageLibraries', 'Expected a package: library URI');
      }
    }
    for (final name in names) {
      if (!_packageName.hasMatch(name)) {
        throw ArgumentError.value(name, 'packages', 'Expected a package name');
      }
    }
    return ReferenceImportOptions._(
      sdkLibraries: List.unmodifiable(sdk),
      packageLibraries: List.unmodifiable(libraries),
      packages: List.unmodifiable(names),
      sdkPath: sdkPath == null ? null : p.normalize(p.absolute(sdkPath)),
    );
  }

  /// Preserves the SDK libraries used for native member queries by default.
  const ReferenceImportOptions.defaults() : sdkLibraries = _defaultSdkLibraries, packageLibraries = const [], packages = const [], sdkPath = null;

  /// Disables all external library reading.
  const ReferenceImportOptions.none() : sdkLibraries = const [], packageLibraries = const [], packages = const [], sdkPath = null;

  const ReferenceImportOptions._({required this.sdkLibraries, required this.packageLibraries, required this.packages, required this.sdkPath});

  static final _packageName = RegExp(r'^[a-z_][a-z0-9_]*$');

  /// Exact SDK library URIs available for consultation.
  final List<String> sdkLibraries;

  /// Exact package library URIs available for consultation.
  final List<String> packageLibraries;

  /// Packages whose libraries may be consulted on demand.
  final List<String> packages;

  /// Explicit Dart SDK directory, useful when running under Flutter.
  final String? sdkPath;

  /// Stable cache identity, independent of allowlist ordering and duplicates.
  String get cacheKey {
    // Lookup order may prioritize common libraries; cache identity is unordered.
    final sdk = sdkLibraries.toList()..sort();
    return jsonEncode([sdk, packageLibraries, packages, sdkPath]);
  }

  /// Whether [value] is a valid, explicitly permitted library URI.
  bool allows(String value) {
    if (_validLibrary(value, 'dart')) {
      return sdkLibraries.contains(value);
    }
    if (!_validLibrary(value, 'package')) {
      return false;
    }
    return packageLibraries.contains(value) || packages.contains(Uri.parse(value).pathSegments.first);
  }

  static bool _validLibrary(String value, String scheme) {
    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme != scheme || uri.hasAuthority || uri.hasQuery || uri.hasFragment || uri.toString() != value) {
      return false;
    }
    final segments = uri.pathSegments;
    if (segments.isEmpty || segments.any((part) => part.isEmpty || part == '.' || part == '..' || part.contains(r'\') || part.contains('/'))) {
      return false;
    }
    return scheme == 'dart'
        ? segments.length == 1 && RegExp(r'^[a-z_][a-z0-9_]*$').hasMatch(segments.single)
        : segments.length > 1 && _packageName.hasMatch(segments.first) && segments.last.endsWith('.dart');
  }
}
