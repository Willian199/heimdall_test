import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/mapper/importer/dart_sdk_path.dart';
import 'package:heimdall_test/src/mapper/importer/reference_import_options.dart';

/// One lazy SDK/package library reader owned by an imported project snapshot.
///
/// Consultation ASTs and indexes remain here, separate from validation files,
/// declarations, namespaces and dependency graphs. No transitive imports or
/// exports are loaded implicitly. Analyzer sessions are disposed after parsing.
final class ReferenceLibraryImporter {
  /// Creates a query-only importer in the package's analysis context.
  ReferenceLibraryImporter(this._packageRoot, this.options);

  final String _packageRoot;

  /// Immutable allowlist used by this snapshot.
  final ReferenceImportOptions options;

  late final _libraries = <String, ReferenceLibrary>{};

  /// Returns a lazy handle to an allowed library, without reading it yet.
  ///
  /// Returns null for denied URIs. Allowed but unavailable libraries have no
  /// units. Those results are cached too; use a fresh project after changes.
  ReferenceLibrary? library(String uri) {
    if (!options.allows(uri)) {
      return null;
    }
    return _libraries.putIfAbsent(uri, () => ReferenceLibrary._(uri, _packageRoot, options.sdkPath));
  }

  /// Whether an allowed SDK type or its ancestors declares [member].
  ///
  /// Package homonyms cannot mask SDK types. This preserves the native-member
  /// lookup used by extension queries while sharing the library import/cache.
  bool hasSdkInstanceMember(String type, String member) {
    final visited = <String>{};
    bool visit(String name) {
      if (!visited.add(name)) {
        return false;
      }
      for (final uri in options.sdkLibraries) {
        final declaration = library(uri)?.types[name];
        if (declaration != null) {
          return declaration.instanceMembers.contains(member) ||
              declaration.parents.any((parent) => visit(parent.name.lexeme)) ||
              name != 'Object' && visit('Object');
        }
      }
      return false;
    }

    return visit(type);
  }
}

/// Parsed consultation library, identified by its full URI rather than a name.
final class ReferenceLibrary {
  ReferenceLibrary._(this.uri, this._packageRoot, this._sdkPath);

  final String _packageRoot;
  final String? _sdkPath;

  /// Library identity, including SDK library or package name and library path.
  final String uri;

  /// Parsed library and part units for future type-aware queries.
  /// These nodes have no Heimdall validation context attached.
  late final List<CompilationUnit> units = _readUnits();

  /// Classes indexed once when this library is first consulted.
  late final Map<String, ReferenceType> types = Map.unmodifiable({
    for (final unit in units)
      for (final declaration in unit.declarations.whereType<ClassDeclaration>()) declaration.namePart.typeName.lexeme: ReferenceType._(declaration),
  });

  List<CompilationUnit> _readUnits() {
    final sdkPath = resolveDartSdkPath(Platform.resolvedExecutable, sdkPath: _sdkPath);
    final collection = AnalysisContextCollection(includedPaths: [_packageRoot], sdkPath: sdkPath);
    try {
      final session = collection.contextFor(_packageRoot).currentSession;
      final path = session.uriConverter.uriToPath(Uri.parse(uri));
      if (path == null) {
        return const [];
      }
      final parsed = session.getParsedLibrary(path);
      if (parsed is! ParsedLibraryResult) {
        return const [];
      }
      return List.unmodifiable([for (final unit in parsed.units) unit.unit]);
    } finally {
      // Parsing is synchronous; no analysis session survives in the snapshot.
      unawaited(collection.dispose());
    }
  }
}

/// Preprocessed class metadata shared by consultation queries.
final class ReferenceType {
  ReferenceType._(this.declaration);

  /// Original declaration, preserving generic parameters and annotations.
  final ClassDeclaration declaration;

  /// Instance member names; static members and constructors are excluded.
  late final Set<String> instanceMembers = Set.unmodifiable({
    if (declaration.body case BlockClassBody(:final members))
      for (final member in members) ...[
        if (member is MethodDeclaration && !member.isStatic) member.name.lexeme,
        if (member is FieldDeclaration && !member.isStatic)
          for (final variable in member.fields.variables) variable.name.lexeme,
      ],
  });

  /// Parent syntax, preserving prefixes and generic arguments for future queries.
  late final List<NamedType> parents = List.unmodifiable([
    ...?declaration.withClause?.mixinTypes.reversed,
    if (declaration.extendsClause case final clause?) clause.superclass,
    ...?declaration.implementsClause?.interfaces,
  ]);
}
