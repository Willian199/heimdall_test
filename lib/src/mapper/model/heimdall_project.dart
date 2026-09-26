import 'package:heimdall_test/heimdall_test.dart';
import 'package:path/path.dart' as p;

/// Imported view of a Dart project or source subtree.
///
/// A project groups the [files] read by [HeimdallFileImporter], exposes
/// shortcuts for declarations and dependencies, and resolves local directives to
/// their target files when possible.
///
/// Example:
/// ```dart
/// final project = const HeimdallFileImporter().importPath();
///
/// for (final declaration in project.declarationsInPath('feature')) {
///   print('${declaration.name} in ${declaration.relativePath}');
/// }
/// ```
final class HeimdallProject {
  /// Creates an imported project model from already parsed source files.
  factory HeimdallProject({
    required String rootPath,
    required String? packageName,
    required List<HeimdallSourceFile> files,
    String? packageRootPath,
  }) {
    final project = HeimdallProject._(
      rootPath: rootPath,
      packageRootPath: packageRootPath,
      packageName: packageName,
      files: files,
    ).._resolveDependencies();
    return project;
  }

  HeimdallProject._({
    required this.rootPath,
    required this.packageName,
    required List<HeimdallSourceFile> files,
    String? packageRootPath,
  }) : packageRootPath = packageRootPath ?? rootPath,
       files = List.unmodifiable(files);

  /// Absolute root path used for the import.
  final String rootPath;

  /// Absolute package root path, where `pubspec.yaml` lives.
  final String packageRootPath;

  /// Cached directory URI for lexical package-boundary checks.
  late final Uri packageRootUri = Uri.directory(packageRootPath);

  /// Package name read from `pubspec.yaml`, when available.
  final String? packageName;

  /// Imported Dart source files.
  final List<HeimdallSourceFile> files;

  final Map<HeimdallSourceFile, List<CompilationUnitMember>> _exportedTypeDeclarationsCache = {};

  /// Imported files indexed by absolute path.
  late final Map<String, HeimdallSourceFile> filesByPath = Map.unmodifiable({
    for (final file in files) file.absolutePath: file,
  });

  /// Imported files that contain parse errors.
  late final List<HeimdallSourceFile> filesWithParseErrors = List.unmodifiable(files.where((file) => file.hasErrors));

  /// Parse errors reported across imported files.
  late final List<HeimdallParseError> parseErrors = List.unmodifiable([
    for (final file in files) ...file.parseErrors,
  ]);

  /// Total parse error count across imported files.
  late final int parseErrorCount = parseErrors.length;

  /// Files with caller-supplied semantic diagnostics. The default importer
  /// only parses source and leaves this list empty.
  late final List<HeimdallSourceFile> filesWithAnalysisDiagnostics = List.unmodifiable(
    files.where((file) => file.analysisDiagnostics.isNotEmpty),
  );

  /// Caller-supplied semantic diagnostics across imported files.
  late final List<HeimdallAnalysisDiagnostic> analysisDiagnostics = List.unmodifiable([
    for (final file in files) ...file.analysisDiagnostics,
  ]);

  /// Total caller-supplied semantic diagnostic count across imported files.
  late final int analysisDiagnosticCount = analysisDiagnostics.length;

  /// All top-level declarations found in imported files.
  ///
  /// Items are real analyzer nodes enriched by [HeimdallDeclaration].
  late final List<CompilationUnitMember> declarations = List.unmodifiable([
    for (final file in files) ...file.declarations,
  ]);

  /// Public top-level declarations found in imported files.
  late final List<CompilationUnitMember> publicDeclarations = List.unmodifiable([
    for (final file in files) ...file.publicDeclarations,
  ]);

  /// Private top-level declarations found in imported files.
  late final List<CompilationUnitMember> privateDeclarations = List.unmodifiable([
    for (final file in files) ...file.privateDeclarations,
  ]);

  /// Declarations that represent Dart types.
  ///
  /// This is the source used by `Heimdall.classes()`, preventing functions,
  /// typedefs, and top-level variables from being evaluated as classes.
  late final List<CompilationUnitMember> typeDeclarations = List.unmodifiable([
    for (final file in files) ...file.typeDeclarations,
  ]);

  /// Public type declarations found in imported files.
  late final List<CompilationUnitMember> publicTypeDeclarations = List.unmodifiable([
    for (final file in files) ...file.publicTypeDeclarations,
  ]);

  /// Private type declarations found in imported files.
  late final List<CompilationUnitMember> privateTypeDeclarations = List.unmodifiable([
    for (final file in files) ...file.privateTypeDeclarations,
  ]);

  /// Class declarations found in imported files.
  late final List<ClassDeclaration> classDeclarations = List.unmodifiable([
    for (final file in files) ...file.classDeclarations,
  ]);

  /// Public class declarations found in imported files.
  late final List<ClassDeclaration> publicClassDeclarations = List.unmodifiable([
    for (final file in files) ...file.publicClassDeclarations,
  ]);

  /// Private class declarations found in imported files.
  late final List<ClassDeclaration> privateClassDeclarations = List.unmodifiable([
    for (final file in files) ...file.privateClassDeclarations,
  ]);

  /// Abstract class declarations found in imported files.
  late final List<ClassDeclaration> abstractClasses = List.unmodifiable([
    for (final file in files) ...file.abstractClasses,
  ]);

  /// Sealed class declarations found in imported files.
  late final List<ClassDeclaration> sealedClasses = List.unmodifiable([
    for (final file in files) ...file.sealedClasses,
  ]);

  /// Base class declarations found in imported files.
  late final List<ClassDeclaration> baseClasses = List.unmodifiable([
    for (final file in files) ...file.baseClasses,
  ]);

  /// Interface class declarations found in imported files.
  late final List<ClassDeclaration> interfaceClasses = List.unmodifiable([
    for (final file in files) ...file.interfaceClasses,
  ]);

  /// Final class declarations found in imported files.
  late final List<ClassDeclaration> finalClasses = List.unmodifiable([
    for (final file in files) ...file.finalClasses,
  ]);

  /// Mixin declarations found in imported files.
  late final List<MixinDeclaration> mixinDeclarations = List.unmodifiable([
    for (final file in files) ...file.mixinDeclarations,
  ]);

  /// Public mixin declarations found in imported files.
  late final List<MixinDeclaration> publicMixinDeclarations = List.unmodifiable([
    for (final file in files) ...file.publicMixinDeclarations,
  ]);

  /// Private mixin declarations found in imported files.
  late final List<MixinDeclaration> privateMixinDeclarations = List.unmodifiable([
    for (final file in files) ...file.privateMixinDeclarations,
  ]);

  /// Enum declarations found in imported files.
  late final List<EnumDeclaration> enumDeclarations = List.unmodifiable([
    for (final file in files) ...file.enumDeclarations,
  ]);

  /// Public enum declarations found in imported files.
  late final List<EnumDeclaration> publicEnumDeclarations = List.unmodifiable([
    for (final file in files) ...file.publicEnumDeclarations,
  ]);

  /// Private enum declarations found in imported files.
  late final List<EnumDeclaration> privateEnumDeclarations = List.unmodifiable([
    for (final file in files) ...file.privateEnumDeclarations,
  ]);

  /// Extension declarations found in imported files.
  late final List<ExtensionDeclaration> extensionDeclarations = List.unmodifiable([
    for (final file in files) ...file.extensionDeclarations,
  ]);

  /// Public extension declarations found in imported files.
  late final List<ExtensionDeclaration> publicExtensionDeclarations = List.unmodifiable([
    for (final file in files) ...file.publicExtensionDeclarations,
  ]);

  /// Private extension declarations found in imported files.
  late final List<ExtensionDeclaration> privateExtensionDeclarations = List.unmodifiable([
    for (final file in files) ...file.privateExtensionDeclarations,
  ]);

  /// Extension type declarations found in imported files.
  late final List<ExtensionTypeDeclaration> extensionTypeDeclarations = List.unmodifiable([
    for (final file in files) ...file.extensionTypeDeclarations,
  ]);

  /// Public extension type declarations found in imported files.
  late final List<ExtensionTypeDeclaration> publicExtensionTypeDeclarations = List.unmodifiable([
    for (final file in files) ...file.publicExtensionTypeDeclarations,
  ]);

  /// Private extension type declarations found in imported files.
  late final List<ExtensionTypeDeclaration> privateExtensionTypeDeclarations = List.unmodifiable([
    for (final file in files) ...file.privateExtensionTypeDeclarations,
  ]);

  /// Type aliases found in imported files.
  late final List<TypeAlias> typeAliases = List.unmodifiable([
    for (final file in files) ...file.typeAliases,
  ]);

  /// Public type aliases found in imported files.
  late final List<TypeAlias> publicTypeAliases = List.unmodifiable([
    for (final file in files) ...file.publicTypeAliases,
  ]);

  /// Private type aliases found in imported files.
  late final List<TypeAlias> privateTypeAliases = List.unmodifiable([
    for (final file in files) ...file.privateTypeAliases,
  ]);

  /// Top-level functions found in imported files.
  late final List<FunctionDeclaration> topLevelFunctions = List.unmodifiable([
    for (final file in files) ...file.topLevelFunctions,
  ]);

  /// Public top-level functions found in imported files.
  late final List<FunctionDeclaration> publicTopLevelFunctions = List.unmodifiable([
    for (final file in files) ...file.publicTopLevelFunctions,
  ]);

  /// Private top-level functions found in imported files.
  late final List<FunctionDeclaration> privateTopLevelFunctions = List.unmodifiable([
    for (final file in files) ...file.privateTopLevelFunctions,
  ]);

  /// Top-level variable declarations found in imported files.
  late final List<TopLevelVariableDeclaration> topLevelVariables = List.unmodifiable([
    for (final file in files) ...file.topLevelVariables,
  ]);

  /// Individual public top-level variables found in imported files.
  late final List<VariableDeclaration> publicTopLevelVariableDeclarations = List.unmodifiable([
    for (final file in files) ...file.publicTopLevelVariableDeclarations,
  ]);

  /// Individual private top-level variables found in imported files.
  late final List<VariableDeclaration> privateTopLevelVariableDeclarations = List.unmodifiable([
    for (final file in files) ...file.privateTopLevelVariableDeclarations,
  ]);

  /// Top-level declarations that have annotations.
  late final List<CompilationUnitMember> annotatedDeclarations = List.unmodifiable([
    for (final file in files) ...file.annotatedDeclarations,
  ]);

  /// Type declarations that have annotations.
  late final List<CompilationUnitMember> annotatedTypeDeclarations = List.unmodifiable([
    for (final file in files) ...file.annotatedTypeDeclarations,
  ]);

  /// Class members found in imported type declarations.
  late final List<ClassMember> classMembers = List.unmodifiable([
    for (final file in files) ...file.classMembers,
  ]);

  /// Method declarations found in imported type declarations.
  late final List<MethodDeclaration> methods = List.unmodifiable([
    for (final file in files) ...file.methods,
  ]);

  /// Public method declarations found in imported type declarations.
  late final List<MethodDeclaration> publicMethods = List.unmodifiable([
    for (final file in files) ...file.publicMethods,
  ]);

  /// Private method declarations found in imported type declarations.
  late final List<MethodDeclaration> privateMethods = List.unmodifiable([
    for (final file in files) ...file.privateMethods,
  ]);

  /// Static method declarations found in imported type declarations.
  late final List<MethodDeclaration> staticMethods = List.unmodifiable([
    for (final file in files) ...file.staticMethods,
  ]);

  /// Instance method declarations found in imported type declarations.
  late final List<MethodDeclaration> instanceMethods = List.unmodifiable([
    for (final file in files) ...file.instanceMethods,
  ]);

  /// Field declarations found in imported type declarations.
  late final List<FieldDeclaration> fields = List.unmodifiable([
    for (final file in files) ...file.fields,
  ]);

  /// Public field declarations found in imported type declarations.
  late final List<FieldDeclaration> publicFields = List.unmodifiable([
    for (final file in files) ...file.publicFields,
  ]);

  /// Private field declarations found in imported type declarations.
  late final List<FieldDeclaration> privateFields = List.unmodifiable([
    for (final file in files) ...file.privateFields,
  ]);

  /// Individual public field variables found in imported type declarations.
  late final List<VariableDeclaration> publicFieldVariables = List.unmodifiable([
    for (final file in files) ...file.publicFieldVariables,
  ]);

  /// Individual private field variables found in imported type declarations.
  late final List<VariableDeclaration> privateFieldVariables = List.unmodifiable([
    for (final file in files) ...file.privateFieldVariables,
  ]);

  /// Static field declarations found in imported type declarations.
  late final List<FieldDeclaration> staticFields = List.unmodifiable([
    for (final file in files) ...file.staticFields,
  ]);

  /// Instance field declarations found in imported type declarations.
  late final List<FieldDeclaration> instanceFields = List.unmodifiable([
    for (final file in files) ...file.instanceFields,
  ]);

  /// Final field declarations found in imported type declarations.
  late final List<FieldDeclaration> finalFields = List.unmodifiable([
    for (final file in files) ...file.finalFields,
  ]);

  /// Mutable field declarations found in imported type declarations.
  late final List<FieldDeclaration> mutableFields = List.unmodifiable([
    for (final file in files) ...file.mutableFields,
  ]);

  /// Const field declarations found in imported type declarations.
  late final List<FieldDeclaration> constFields = List.unmodifiable([
    for (final file in files) ...file.constFields,
  ]);

  /// Constructor declarations found in imported type declarations.
  late final List<ConstructorDeclaration> constructors = List.unmodifiable([
    for (final file in files) ...file.constructors,
  ]);

  /// Executable class members found in imported type declarations.
  late final List<ClassMember> codeUnits = List.unmodifiable([
    for (final file in files) ...file.codeUnits,
  ]);

  /// Public constructor declarations found in imported type declarations.
  late final List<ConstructorDeclaration> publicConstructors = List.unmodifiable([
    for (final file in files) ...file.publicConstructors,
  ]);

  /// Private constructor declarations found in imported type declarations.
  late final List<ConstructorDeclaration> privateConstructors = List.unmodifiable([
    for (final file in files) ...file.privateConstructors,
  ]);

  /// Const constructor declarations found in imported type declarations.
  late final List<ConstructorDeclaration> constConstructors = List.unmodifiable([
    for (final file in files) ...file.constConstructors,
  ]);

  /// Factory constructor declarations found in imported type declarations.
  late final List<ConstructorDeclaration> factoryConstructors = List.unmodifiable([
    for (final file in files) ...file.factoryConstructors,
  ]);

  /// Class members that have annotations.
  late final List<ClassMember> annotatedMembers = List.unmodifiable([
    for (final file in files) ...file.annotatedMembers,
  ]);

  /// All dependency directives found in imported files.
  ///
  /// Includes imports, exports, parts, and part-of directives, all as real
  /// analyzer [Directive] nodes enriched by [HeimdallDependency].
  late final List<Directive> dependencies = List.unmodifiable([
    for (final file in files) ...file.dependencies,
  ]);

  /// All import directives found in imported files.
  late final List<ImportDirective> importDirectives = List.unmodifiable([
    for (final file in files) ...file.importDirectives,
  ]);

  /// All export directives found in imported files.
  late final List<ExportDirective> exportDirectives = List.unmodifiable([
    for (final file in files) ...file.exportDirectives,
  ]);

  /// All part directives found in imported files.
  late final List<PartDirective> partDirectives = List.unmodifiable([
    for (final file in files) ...file.partDirectives,
  ]);

  /// All part-of directives found in imported files.
  late final List<PartOfDirective> partOfDirectives = List.unmodifiable([
    for (final file in files) ...file.partOfDirectives,
  ]);

  /// All `dart:` imports found in imported files.
  late final List<ImportDirective> dartImports = List.unmodifiable([
    for (final file in files) ...file.dartImports,
  ]);

  /// All `package:` imports found in imported files.
  late final List<ImportDirective> packageImports = List.unmodifiable([
    for (final file in files) ...file.packageImports,
  ]);

  /// All relative imports found in imported files.
  late final List<ImportDirective> relativeImports = List.unmodifiable([
    for (final file in files) ...file.relativeImports,
  ]);

  /// Relative imports that go to a parent directory.
  late final List<ImportDirective> relativeUpwardImports = List.unmodifiable([
    for (final file in files) ...file.relativeUpwardImports,
  ]);

  /// Relative imports that stay in the current directory.
  late final List<ImportDirective> relativeSameDirectoryImports = List.unmodifiable([
    for (final file in files) ...file.relativeSameDirectoryImports,
  ]);

  /// Package imports that target this package.
  late final List<ImportDirective> internalPackageImports = List.unmodifiable(
    packageImports.where(_isInternalPackageDirective),
  );

  /// Package imports that target another package.
  late final List<ImportDirective> externalPackageImports = List.unmodifiable(
    packageImports.where((directive) => !_isInternalPackageDirective(directive)),
  );

  /// Package imports that target a `src/` path.
  late final List<ImportDirective> packageSrcImports = List.unmodifiable(packageImports.where(_isPackageSrcDirective));

  /// Imports resolved to imported local files.
  late final List<ImportDirective> resolvedImports = List.unmodifiable([
    for (final file in files) ...file.resolvedImports,
  ]);

  /// Local imports not resolved to imported files.
  late final List<ImportDirective> unresolvedLocalImports = List.unmodifiable([
    for (final file in files) ...file.unresolvedLocalImports,
  ]);

  /// Imports that point outside the imported source set.
  late final List<ImportDirective> externalImports = List.unmodifiable([
    for (final file in files) ...file.externalImports,
  ]);

  /// All prefixed imports found in imported files.
  late final List<ImportDirective> prefixedImports = List.unmodifiable([
    for (final file in files) ...file.prefixedImports,
  ]);

  /// All deferred imports found in imported files.
  late final List<ImportDirective> deferredImports = List.unmodifiable([
    for (final file in files) ...file.deferredImports,
  ]);

  /// All imports with combinators found in imported files.
  late final List<ImportDirective> combinatorImports = List.unmodifiable([
    for (final file in files) ...file.combinatorImports,
  ]);

  /// All `dart:` exports found in imported files.
  late final List<ExportDirective> dartExports = List.unmodifiable([
    for (final file in files) ...file.dartExports,
  ]);

  /// All `package:` exports found in imported files.
  late final List<ExportDirective> packageExports = List.unmodifiable([
    for (final file in files) ...file.packageExports,
  ]);

  /// All relative exports found in imported files.
  late final List<ExportDirective> relativeExports = List.unmodifiable([
    for (final file in files) ...file.relativeExports,
  ]);

  /// Exports resolved to imported local files.
  late final List<ExportDirective> resolvedExports = List.unmodifiable([
    for (final file in files) ...file.resolvedExports,
  ]);

  /// Local exports not resolved to imported files.
  late final List<ExportDirective> unresolvedLocalExports = List.unmodifiable([
    for (final file in files) ...file.unresolvedLocalExports,
  ]);

  /// Exports that point outside the imported source set.
  late final List<ExportDirective> externalExports = List.unmodifiable([
    for (final file in files) ...file.externalExports,
  ]);

  /// All exports with combinators found in imported files.
  late final List<ExportDirective> combinatorExports = List.unmodifiable([
    for (final file in files) ...file.combinatorExports,
  ]);

  /// Part directives resolved to imported part files.
  late final List<PartDirective> resolvedParts = List.unmodifiable([
    for (final file in files) ...file.resolvedParts,
  ]);

  /// Part directives not resolved to imported part files.
  late final List<PartDirective> unresolvedParts = List.unmodifiable([
    for (final file in files) ...file.unresolvedParts,
  ]);

  /// Finds an imported file by path relative to [rootPath].
  HeimdallSourceFile? fileByRelativePath(String relativePath) {
    final normalized = p.normalize(p.join(rootPath, relativePath));
    return filesByPath[normalized];
  }

  /// Returns declarations whose `relativePath` satisfies [pathPattern].
  ///
  /// The pattern uses the same semantics as [pathMatches].
  List<CompilationUnitMember> declarationsInPath(String pathPattern) {
    return List.unmodifiable(
      declarations.where((declaration) {
        return pathMatches(declaration.relativePath, pathPattern);
      }),
    );
  }

  /// Returns type-reference declarations exported by [file].
  ///
  /// Includes public type declarations and aliases from the file, public
  /// declarations from `part` files, and declarations exported by local barrels,
  /// following transitive local exports and respecting `show`/`hide`
  /// combinators.
  List<CompilationUnitMember> exportedTypeDeclarationsOf(
    HeimdallSourceFile file,
  ) {
    final cached = _exportedTypeDeclarationsCache[file];
    if (cached != null) {
      return cached;
    }

    List<CompilationUnitMember> collect(
      HeimdallSourceFile current,
      Set<String> visiting,
    ) {
      if (visiting.contains(current.absolutePath)) {
        return const [];
      }
      final nextVisiting = {...visiting, current.absolutePath};
      final declarations = [
        ...current.publicTypeDeclarations,
        ...current.publicTypeAliases,
        for (final part in current.partDirectives)
          for (final targetFile in part.targetFiles) ...collect(targetFile, nextVisiting).where(_isVisibleTypeReferenceDeclaration),
        for (final export in current.exportDirectives)
          for (final targetFile in export.targetFiles)
            ..._applyCombinators(
              collect(targetFile, nextVisiting),
              export.combinators,
            ),
      ];
      return _dedupeDeclarations(declarations);
    }

    // Recursive results can be incomplete when an ancestor closes a cycle.
    // Only cache the complete traversal from the requested root.
    return _exportedTypeDeclarationsCache[file] = collect(file, const {});
  }

  bool _isVisibleTypeReferenceDeclaration(CompilationUnitMember declaration) {
    return declaration.isPublic && (declaration.isTypeDeclaration || declaration is TypeAlias);
  }

  /// Returns type declarations visible through a local directive.
  ///
  /// For imports and exports, applies the directive's own combinators to the
  /// exported API of the target file.
  List<CompilationUnitMember> visibleTypeDeclarationsThrough(
    Directive directive,
  ) {
    final exported = _dedupeDeclarations([
      for (final targetFile in directive.targetFiles) ...visibleTypeDeclarationsThroughTarget(directive, targetFile),
    ]);
    if (exported.isEmpty) {
      return const [];
    }
    return exported;
  }

  /// Returns type declarations visible through one resolved target branch.
  List<CompilationUnitMember> visibleTypeDeclarationsThroughTarget(
    Directive directive,
    HeimdallSourceFile targetFile,
  ) {
    // A part belongs to the same library, so its private declarations are
    // visible to the owning file even though they are not exported to imports.
    if (directive is PartDirective) {
      return List.unmodifiable([
        ...targetFile.typeDeclarations,
        ...targetFile.typeAliases,
      ]);
    }
    final exported = exportedTypeDeclarationsOf(targetFile);
    if (directive is ImportDirective) {
      return _applyCombinators(exported, directive.combinators);
    }
    if (directive is ExportDirective) {
      return _applyCombinators(exported, directive.combinators);
    }
    return exported;
  }

  void _resolveDependencies() {
    for (final file in files) {
      for (final dependency in file.dependencies) {
        final namedPartOf = dependency is PartOfDirective && dependency.uri == null;
        final primaryPath = namedPartOf ? null : _resolveUri(file.absolutePath, dependency.targetUri);
        final resolvedTargets = namedPartOf
            ? const <({String uri, String path, HeimdallSourceFile? file})>[]
            : [
                for (final uri in dependency.targetUris)
                  if (_resolveUri(file.absolutePath, uri) case final path?) (uri: uri, path: path, file: filesByPath[path]),
              ];
        attachDependencyTarget(
          directive: dependency,
          targetPath: primaryPath,
          targetFile: primaryPath == null ? null : filesByPath[primaryPath],
          targetPaths: _dedupeStrings(resolvedTargets.map((target) => target.path)),
          targetFiles: _dedupeFiles(resolvedTargets.map((target) => target.file).whereType<HeimdallSourceFile>()),
          resolvedTargets: [
            for (final target in resolvedTargets)
              if (target.file case final targetFile?)
                HeimdallDependencyTarget(
                  uri: target.uri,
                  path: target.path,
                  file: targetFile,
                ),
          ],
        );
      }
    }
  }

  String? _resolveUri(String originPath, String? uri) {
    if (uri == null || uri.isEmpty) {
      return null;
    }
    final parsed = Uri.tryParse(uri);
    if (parsed == null || parsed.hasQuery || parsed.hasFragment) {
      return null;
    }
    if (parsed.scheme == 'dart') {
      return null;
    }
    if (parsed.scheme == 'package') {
      if (parsed.pathSegments.isEmpty || parsed.pathSegments.first != packageName) {
        return null;
      }
      final rest = parsed.pathSegments.skip(1).join('/');
      return p.normalize(p.join(packageRootPath, 'lib', rest));
    }
    if (parsed.hasScheme || parsed.path.isEmpty) {
      return null;
    }
    return p.normalize(p.join(p.dirname(originPath), parsed.path));
  }

  bool _isInternalPackageDirective(UriBasedDirective directive) {
    final name = packageName;
    if (name == null) {
      return false;
    }
    return directive.targetUris
        .map(Uri.tryParse)
        .whereType<Uri>()
        .any(
          (uri) => uri.scheme == 'package' && uri.pathSegments.firstOrNull == name,
        );
  }

  bool _isPackageSrcDirective(UriBasedDirective directive) {
    return directive.targetUris
        .map(Uri.tryParse)
        .whereType<Uri>()
        .any(
          (uri) => uri.scheme == 'package' && uri.pathSegments.length > 1 && uri.pathSegments[1] == 'src',
        );
  }
}

List<String> _dedupeStrings(Iterable<String> values) {
  return List.unmodifiable(values.toSet());
}

List<HeimdallSourceFile> _dedupeFiles(Iterable<HeimdallSourceFile> files) {
  final seen = <String>{};
  return List.unmodifiable([
    for (final file in files)
      if (seen.add(file.absolutePath)) file,
  ]);
}

List<CompilationUnitMember> _applyCombinators(
  Iterable<CompilationUnitMember> declarations,
  NodeList<Combinator> combinators,
) {
  var visible = declarations.toList();
  for (final combinator in combinators) {
    if (combinator is ShowCombinator) {
      final shown = combinator.shownNames.map((name) => name.name).toSet();
      visible = visible.where((declaration) => shown.contains(declaration.name)).toList();
    } else if (combinator is HideCombinator) {
      final hidden = combinator.hiddenNames.map((name) => name.name).toSet();
      visible = visible.where((declaration) => !hidden.contains(declaration.name)).toList();
    }
  }
  return List.unmodifiable(visible);
}

List<CompilationUnitMember> _dedupeDeclarations(
  Iterable<CompilationUnitMember> declarations,
) {
  final seen = <String>{};
  return List.unmodifiable([
    for (final declaration in declarations)
      if (seen.add('${declaration.sourcePath}:${declaration.name}')) declaration,
  ]);
}
