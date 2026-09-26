import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/mapper/importer/import_cache.dart';
import 'package:heimdall_test/src/mapper/importer/import_options.dart';
import 'package:heimdall_test/src/mapper/importer/package_context.dart';
import 'package:heimdall_test/src/mapper/importer/path_matcher.dart';
import 'package:heimdall_test/src/mapper/importer/source_file_parser.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_project.dart';
import 'package:path/path.dart' as p;

/// Imports a Dart source tree into Heimdall's project model.
///
/// The importer does not create replacement models for declarations or
/// directives. It keeps the real analyzer nodes, such as
/// [CompilationUnitMember] and [Directive], and attaches file, line, and
/// dependency context that rules use to produce useful findings.
///
/// Example:
/// ```dart
/// final project = const HeimdallFileImporter(
///   importOptions: [ExcludeTestsImportOption()],
/// ).importPath();
///
/// final report = Heimdall.classes().should().resideInPath('lib').check(project);
/// ```
final class HeimdallFileImporter {
  /// Creates a Dart source importer.
  ///
  /// [importOptions] filter files before parsing. When [useCache] is `true`,
  /// [importPath] reuses the first imported project for the same root path and
  /// import option keys.
  const HeimdallFileImporter({
    this.importOptions = const [ExcludeGeneratedDartImportOption()],
    this.useCache = true,
  });

  /// Filters applied before files are parsed.
  final List<ImportOption> importOptions;

  /// When `true`, reuses previous imports without checking whether files changed.
  ///
  /// If source files change inside the same process, call [clearCache] or create
  /// an importer with `useCache: false`.
  final bool useCache;

  /// Clears all cached imports.
  static void clearCache() => HeimdallImportCache.clear();

  /// Imports every `.dart` file under [rootPath].
  ///
  /// The returned project contains files, declarations, and directives already
  /// enriched by Heimdall extensions.
  HeimdallProject importPath([String rootPath = 'lib']) {
    final root = p.normalize(p.absolute(rootPath));
    final cached = HeimdallImportCache.read(
      rootPath: root,
      importOptions: importOptions,
    );
    if (useCache && cached != null) {
      return cached;
    }

    final context = ImportPackageContext.resolve(root);
    const parser = HeimdallSourceFileParser();
    final sourceFiles =
        _discoverDartFiles(root)
            .where((file) => _includedByOptions(file, context.packageRootPath))
            .map(
              (file) => parser.parse(
                root,
                file,
                featureSet: context.featureSet,
              ),
            )
            .toList()
          ..sort((a, b) => a.relativePath.compareTo(b.relativePath));

    final project = HeimdallProject(
      rootPath: root,
      packageRootPath: context.packageRootPath,
      packageName: context.packageName,
      files: sourceFiles,
    );

    if (useCache) {
      HeimdallImportCache.write(
        rootPath: root,
        importOptions: importOptions,
        project: project,
      );
    }
    return project;
  }

  List<File> _discoverDartFiles(String root) {
    return Directory(root).listSync(recursive: true).whereType<File>().where((file) => file.path.endsWith('.dart')).toList()
      ..sort((a, b) => a.path.compareTo(b.path));
  }

  bool _includedByOptions(File file, String packageRootPath) {
    final packageRelativePath = normalizePath(p.relative(file.path, from: packageRootPath));
    return importOptions.every((option) {
      if (option is PackageRelativeImportOption) {
        return option.includesRelativePath(packageRelativePath);
      }
      return option.includes(file.path);
    });
  }
}
