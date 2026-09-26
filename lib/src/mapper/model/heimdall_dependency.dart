import 'package:analyzer/source/line_info.dart';
import 'package:heimdall_test/heimdall_test.dart';

final _contexts = Expando<_DependencyContext>('heimdall.dependencyContext');
final _targets = Expando<_DependencyTarget>('heimdall.dependencyTarget');

/// Adds Heimdall dependency metadata to [Directive].
///
/// Imports, exports, parts, and part-ofs remain real analyzer directives. This
/// extension exposes the data dependency rules need, such as target URI,
/// resolved target file, and source line.
///
/// Example:
/// ```dart
/// final forbidden = file.dependencies.where(
///   (directive) => directive.targetUri == 'dart:mirrors',
/// );
/// ```
extension HeimdallDependency on Directive {
  /// Absolute path of the file where this directive was declared.
  String get originPath => _context.originPath;

  /// Textual URI of the directive.
  ///
  /// For [UriBasedDirective], this uses `uri.stringValue`. For
  /// [PartOfDirective], this uses the URI when present or the library name.
  String? get targetUri => _context.targetUri;

  /// Every URI that this directive may load.
  ///
  /// The primary URI is first, followed by conditional import or export URIs.
  List<String> get targetUris => _context.targetUris;

  /// Conditional import or export URIs, excluding [targetUri].
  List<String> get conditionalTargetUris => _context.conditionalTargetUris;

  /// One-based source line of the directive.
  int get line => _context.line;

  /// Absolute path resolved from the target URI, when local to the project.
  String? get targetPath => _targets[this]?.targetPath;

  /// Absolute paths resolved from every local URI in [targetUris].
  List<String> get targetPaths => _targets[this]?.targetPaths ?? const [];

  /// Resolved imported, exported, or parted file, when it is in scope.
  HeimdallSourceFile? get targetFile => _targets[this]?.targetFile;

  /// Imported files resolved from every URI in [targetUris].
  List<HeimdallSourceFile> get targetFiles => _targets[this]?.targetFiles ?? const [];

  /// Resolved targets preserving the URI, absolute path, and imported file.
  List<HeimdallDependencyTarget> get resolvedTargets => _targets[this]?.resolvedTargets ?? const [];

  _DependencyContext get _context {
    final context = _contexts[this];
    if (context == null) {
      throw StateError(
        'Directive has no Heimdall dependency context attached.',
      );
    }
    return context;
  }
}

/// Attaches origin context to an analyzer directive.
///
/// Called by the importer so [originPath] and source-line lookups can work.
void attachDependencyContext({
  required Directive directive,
  required String originPath,
  required LineInfo lineInfo,
}) {
  if (_contexts[directive] != null) {
    throw StateError('Directive already has Heimdall dependency context attached.');
  }
  _contexts[directive] = _DependencyContext(
    directive: directive,
    originPath: originPath,
    lineInfo: lineInfo,
  );
}

/// Attaches target URI resolution to a directive.
///
/// Called by `HeimdallProject.resolveDependencies()`.
void attachDependencyTarget({
  required Directive directive,
  required String? targetPath,
  required HeimdallSourceFile? targetFile,
  List<String> targetPaths = const [],
  List<HeimdallSourceFile> targetFiles = const [],
  List<HeimdallDependencyTarget> resolvedTargets = const [],
}) {
  if (_targets[directive] != null) {
    throw StateError('Directive already has Heimdall dependency target attached.');
  }
  _targets[directive] = _DependencyTarget(
    targetPath: targetPath,
    targetFile: targetFile,
    targetPaths: List.unmodifiable(targetPaths),
    targetFiles: List.unmodifiable(targetFiles),
    resolvedTargets: List.unmodifiable(resolvedTargets),
  );
}

/// One resolved URI branch of an import, export, or part directive.
final class HeimdallDependencyTarget {
  /// Creates an association between the source [uri], resolved [path], and [file].
  const HeimdallDependencyTarget({
    required this.uri,
    required this.path,
    required this.file,
  });

  /// URI text declared in source code.
  final String uri;

  /// Absolute path resolved from [uri].
  final String path;

  /// Imported target file.
  final HeimdallSourceFile file;
}

final class _DependencyContext {
  _DependencyContext({
    required Directive directive,
    required this.originPath,
    required LineInfo lineInfo,
  }) : targetUri = _targetUriOf(directive),
       targetUris = List.unmodifiable(_targetUrisOf(directive)),
       conditionalTargetUris = List.unmodifiable(_conditionalTargetUrisOf(directive)),
       line = lineInfo.getLocation(directive.offset).lineNumber;

  final String originPath;
  final String? targetUri;
  final List<String> targetUris;
  final List<String> conditionalTargetUris;
  final int line;
}

final class _DependencyTarget {
  const _DependencyTarget({
    required this.targetPath,
    required this.targetFile,
    required this.targetPaths,
    required this.targetFiles,
    required this.resolvedTargets,
  });

  final String? targetPath;
  final HeimdallSourceFile? targetFile;
  final List<String> targetPaths;
  final List<HeimdallSourceFile> targetFiles;
  final List<HeimdallDependencyTarget> resolvedTargets;
}

String? _targetUriOf(Directive directive) {
  if (directive is UriBasedDirective) {
    return directive.uri.stringValue;
  }
  if (directive is PartOfDirective) {
    return directive.uri?.stringValue ?? directive.libraryName?.toSource();
  }
  return null;
}

List<String> _targetUrisOf(Directive directive) {
  return [
    ?_targetUriOf(directive),
    ..._conditionalTargetUrisOf(directive),
  ];
}

List<String> _conditionalTargetUrisOf(Directive directive) {
  if (directive is! NamespaceDirective) {
    return const [];
  }
  return [
    for (final configuration in directive.configurations) ?configuration.uri.stringValue,
  ];
}
