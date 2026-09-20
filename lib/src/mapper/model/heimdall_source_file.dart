import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_declaration.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_dependency.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_member.dart';

/// Dart source file imported by Heimdall.
///
/// Stores the file path, loaded source text, top-level declarations, dependency
/// directives, and parse errors reported by the analyzer.
///
/// Example:
/// ```dart
/// final file = project.fileByRelativePath('lib/main.dart');
/// print(file?.declarations.length);
/// ```
final class HeimdallSourceFile {
  /// Creates a source file model from imported Dart source data.
  HeimdallSourceFile({
    required this.absolutePath,
    required this.relativePath,
    required this.content,
    required List<Directive> directives,
    required List<CompilationUnitMember> declarations,
    required List<Directive> dependencies,
    required List<HeimdallParseError> parseErrors,
    this.unit,
    List<HeimdallAnalysisDiagnostic> analysisDiagnostics = const [],
    List<ClassMember>? classMembers,
    LineInfo? lineInfo,
  }) : directives = List.unmodifiable(directives),
       declarations = List.unmodifiable(declarations),
       dependencies = List.unmodifiable(dependencies),
       parseErrors = List.unmodifiable(parseErrors),
       analysisDiagnostics = List.unmodifiable(analysisDiagnostics),
       _classMembers = classMembers == null ? null : List.unmodifiable(classMembers),
       _lineInfo = lineInfo;

  /// Absolute file path.
  final String absolutePath;

  /// Path relative to the imported root.
  final String relativePath;

  /// Source text loaded by `HeimdallFileImporter`.
  final String content;

  /// Resolved analyzer unit when this file came from the importer.
  ///
  /// This is nullable only for compatibility with manually constructed models.
  final CompilationUnit? unit;

  /// Whether this model contains a semantically resolved analyzer unit.
  bool get isResolved => unit != null;

  final LineInfo? _lineInfo;

  final List<ClassMember>? _classMembers;

  /// Top-level directives declared in this file.
  final List<Directive> directives;

  /// Source line information produced by the analyzer.
  late final LineInfo lineInfo = _lineInfo ?? LineInfo.fromContent(content);

  /// Library directive declared in this file, when present.
  late final LibraryDirective? libraryDirective = directives.whereType<LibraryDirective>().firstOrNull;

  /// Import directives declared in this file.
  late final List<ImportDirective> importDirectives = List.unmodifiable(directives.whereType<ImportDirective>());

  /// Export directives declared in this file.
  late final List<ExportDirective> exportDirectives = List.unmodifiable(directives.whereType<ExportDirective>());

  /// Part directives declared in this file.
  late final List<PartDirective> partDirectives = List.unmodifiable(directives.whereType<PartDirective>());

  /// Part-of directives declared in this file.
  late final List<PartOfDirective> partOfDirectives = List.unmodifiable(directives.whereType<PartOfDirective>());

  /// Directives that can expose type declarations to this file.
  late final List<Directive> typeReferenceDirectives = List.unmodifiable([
    ...importDirectives,
    ...exportDirectives,
    ...partDirectives,
  ]);

  /// Imports using a `dart:` URI.
  late final List<ImportDirective> dartImports = List.unmodifiable(importDirectives.where(_hasDartUri));

  /// Imports using a `package:` URI.
  late final List<ImportDirective> packageImports = List.unmodifiable(importDirectives.where(_hasPackageUri));

  /// Imports using a relative file URI.
  late final List<ImportDirective> relativeImports = List.unmodifiable(importDirectives.where(_hasRelativeUri));

  /// Relative imports that go to a parent directory.
  late final List<ImportDirective> relativeUpwardImports = List.unmodifiable(relativeImports.where(_hasUpwardRelativeUri));

  /// Relative imports that stay in the current directory.
  late final List<ImportDirective> relativeSameDirectoryImports = List.unmodifiable(relativeImports.where(_hasSameDirectoryRelativeUri));

  /// Imports resolved to an imported local file.
  late final List<ImportDirective> resolvedImports = List.unmodifiable(importDirectives.where((directive) => directive.targetFiles.isNotEmpty));

  /// Relative or package imports that were not resolved to an imported file.
  late final List<ImportDirective> unresolvedLocalImports = List.unmodifiable(importDirectives.where(_isUnresolvedLocalDirective));

  /// Imports that point outside the imported source set.
  late final List<ImportDirective> externalImports = List.unmodifiable(importDirectives.where((directive) => directive.targetFiles.isEmpty));

  /// Imports with `deferred` loading.
  late final List<ImportDirective> deferredImports = List.unmodifiable(importDirectives.where((directive) => directive.deferredKeyword != null));

  /// Imports that declare a prefix with `as`.
  late final List<ImportDirective> prefixedImports = List.unmodifiable(importDirectives.where((directive) => directive.prefix != null));

  /// Imports with `show` or `hide` combinators.
  late final List<ImportDirective> combinatorImports = List.unmodifiable(importDirectives.where((directive) => directive.combinators.isNotEmpty));

  /// Exports using a `dart:` URI.
  late final List<ExportDirective> dartExports = List.unmodifiable(exportDirectives.where(_hasDartUri));

  /// Exports using a `package:` URI.
  late final List<ExportDirective> packageExports = List.unmodifiable(exportDirectives.where(_hasPackageUri));

  /// Exports using a relative file URI.
  late final List<ExportDirective> relativeExports = List.unmodifiable(exportDirectives.where(_hasRelativeUri));

  /// Exports resolved to an imported local file.
  late final List<ExportDirective> resolvedExports = List.unmodifiable(exportDirectives.where((directive) => directive.targetFiles.isNotEmpty));

  /// Relative or package exports that were not resolved to an imported file.
  late final List<ExportDirective> unresolvedLocalExports = List.unmodifiable(exportDirectives.where(_isUnresolvedLocalDirective));

  /// Exports that point outside the imported source set.
  late final List<ExportDirective> externalExports = List.unmodifiable(exportDirectives.where((directive) => directive.targetFiles.isEmpty));

  /// Exports with `show` or `hide` combinators.
  late final List<ExportDirective> combinatorExports = List.unmodifiable(exportDirectives.where((directive) => directive.combinators.isNotEmpty));

  /// Part directives resolved to imported part files.
  late final List<PartDirective> resolvedParts = List.unmodifiable(partDirectives.where((directive) => directive.targetFiles.isNotEmpty));

  /// Part directives not resolved to imported part files.
  late final List<PartDirective> unresolvedParts = List.unmodifiable(partDirectives.where((directive) => directive.targetFiles.isEmpty));

  /// Top-level declarations declared in this file.
  final List<CompilationUnitMember> declarations;

  /// Public top-level declarations.
  late final List<CompilationUnitMember> publicDeclarations = List.unmodifiable(
    declarations.where((declaration) => declaration.isPublic),
  );

  /// Private top-level declarations.
  late final List<CompilationUnitMember> privateDeclarations = List.unmodifiable(
    declarations.where((declaration) => declaration.isPrivate),
  );

  /// Top-level declarations that represent Dart types.
  late final List<CompilationUnitMember> typeDeclarations = List.unmodifiable(
    declarations.where((declaration) => declaration.isTypeDeclaration),
  );

  /// Public type declarations.
  late final List<CompilationUnitMember> publicTypeDeclarations = List.unmodifiable(
    typeDeclarations.where((declaration) => declaration.isPublic),
  );

  /// Private type declarations.
  late final List<CompilationUnitMember> privateTypeDeclarations = List.unmodifiable(
    typeDeclarations.where((declaration) => declaration.isPrivate),
  );

  /// Class declarations in this file.
  late final List<ClassDeclaration> classDeclarations = List.unmodifiable(
    declarations.whereType<ClassDeclaration>(),
  );

  /// Public class declarations in this file.
  late final List<ClassDeclaration> publicClassDeclarations = List.unmodifiable(classDeclarations.where((declaration) => declaration.isPublic));

  /// Private class declarations in this file.
  late final List<ClassDeclaration> privateClassDeclarations = List.unmodifiable(classDeclarations.where((declaration) => declaration.isPrivate));

  /// Abstract class declarations in this file.
  late final List<ClassDeclaration> abstractClasses = List.unmodifiable(classDeclarations.where((declaration) => declaration.isAbstract));

  /// Sealed class declarations in this file.
  late final List<ClassDeclaration> sealedClasses = List.unmodifiable(classDeclarations.where((declaration) => declaration.isSealed));

  /// Base class declarations in this file.
  late final List<ClassDeclaration> baseClasses = List.unmodifiable(classDeclarations.where((declaration) => declaration.isBase));

  /// Interface class declarations in this file.
  late final List<ClassDeclaration> interfaceClasses = List.unmodifiable(classDeclarations.where((declaration) => declaration.isInterface));

  /// Final class declarations in this file.
  late final List<ClassDeclaration> finalClasses = List.unmodifiable(classDeclarations.where((declaration) => declaration.isFinal));

  /// Mixin declarations in this file.
  late final List<MixinDeclaration> mixinDeclarations = List.unmodifiable(declarations.whereType<MixinDeclaration>());

  /// Public mixin declarations in this file.
  late final List<MixinDeclaration> publicMixinDeclarations = List.unmodifiable(mixinDeclarations.where((declaration) => declaration.isPublic));

  /// Private mixin declarations in this file.
  late final List<MixinDeclaration> privateMixinDeclarations = List.unmodifiable(mixinDeclarations.where((declaration) => declaration.isPrivate));

  /// Enum declarations in this file.
  late final List<EnumDeclaration> enumDeclarations = List.unmodifiable(declarations.whereType<EnumDeclaration>());

  /// Public enum declarations in this file.
  late final List<EnumDeclaration> publicEnumDeclarations = List.unmodifiable(enumDeclarations.where((declaration) => declaration.isPublic));

  /// Private enum declarations in this file.
  late final List<EnumDeclaration> privateEnumDeclarations = List.unmodifiable(enumDeclarations.where((declaration) => declaration.isPrivate));

  /// Extension declarations in this file.
  late final List<ExtensionDeclaration> extensionDeclarations = List.unmodifiable(declarations.whereType<ExtensionDeclaration>());

  /// Public named extension declarations in this file.
  late final List<ExtensionDeclaration> publicExtensionDeclarations = List.unmodifiable(
    extensionDeclarations.where((declaration) => declaration.isPublic),
  );

  /// Private named extension declarations in this file.
  late final List<ExtensionDeclaration> privateExtensionDeclarations = List.unmodifiable(
    extensionDeclarations.where((declaration) => declaration.isPrivate),
  );

  /// Extension type declarations in this file.
  late final List<ExtensionTypeDeclaration> extensionTypeDeclarations = List.unmodifiable(declarations.whereType<ExtensionTypeDeclaration>());

  /// Public extension type declarations in this file.
  late final List<ExtensionTypeDeclaration> publicExtensionTypeDeclarations = List.unmodifiable(
    extensionTypeDeclarations.where((declaration) => declaration.isPublic),
  );

  /// Private extension type declarations in this file.
  late final List<ExtensionTypeDeclaration> privateExtensionTypeDeclarations = List.unmodifiable(
    extensionTypeDeclarations.where((declaration) => declaration.isPrivate),
  );

  /// Type aliases declared in this file.
  late final List<TypeAlias> typeAliases = List.unmodifiable(declarations.whereType<TypeAlias>());

  /// Public type aliases declared in this file.
  late final List<TypeAlias> publicTypeAliases = List.unmodifiable(typeAliases.where((declaration) => declaration.isPublic));

  /// Private type aliases declared in this file.
  late final List<TypeAlias> privateTypeAliases = List.unmodifiable(typeAliases.where((declaration) => declaration.isPrivate));

  /// Top-level functions declared in this file.
  late final List<FunctionDeclaration> topLevelFunctions = List.unmodifiable(declarations.whereType<FunctionDeclaration>());

  /// Public top-level functions declared in this file.
  late final List<FunctionDeclaration> publicTopLevelFunctions = List.unmodifiable(topLevelFunctions.where((declaration) => declaration.isPublic));

  /// Private top-level functions declared in this file.
  late final List<FunctionDeclaration> privateTopLevelFunctions = List.unmodifiable(topLevelFunctions.where((declaration) => declaration.isPrivate));

  /// Top-level variables declared in this file.
  late final List<TopLevelVariableDeclaration> topLevelVariables = List.unmodifiable(declarations.whereType<TopLevelVariableDeclaration>());

  /// Individual public top-level variables declared in this file.
  late final List<VariableDeclaration> publicTopLevelVariableDeclarations = List.unmodifiable([
    for (final declaration in topLevelVariables) ...declaration.variables.variables.where(_isPublicVariable),
  ]);

  /// Individual private top-level variables declared in this file.
  late final List<VariableDeclaration> privateTopLevelVariableDeclarations = List.unmodifiable([
    for (final declaration in topLevelVariables) ...declaration.variables.variables.where(_isPrivateVariable),
  ]);

  /// Top-level declarations that have annotations.
  late final List<CompilationUnitMember> annotatedDeclarations = List.unmodifiable(
    declarations.where((declaration) => declaration.metadata.isNotEmpty),
  );

  /// Type declarations that have annotations.
  late final List<CompilationUnitMember> annotatedTypeDeclarations = List.unmodifiable(
    typeDeclarations.where((declaration) => declaration.metadata.isNotEmpty),
  );

  /// Class members declared by every type in this file.
  late final List<ClassMember> classMembers = List.unmodifiable(
    _classMembers ??
        [
          for (final declaration in typeDeclarations) ...declaration.members,
        ],
  );

  /// Public class members declared by every type in this file.
  late final List<ClassMember> publicClassMembers = List.unmodifiable(
    classMembers.where((member) => member.isPublic),
  );

  /// Private class members declared by every type in this file.
  late final List<ClassMember> privateClassMembers = List.unmodifiable(classMembers.where((member) => member.isPrivate));

  /// Method declarations in this file.
  late final List<MethodDeclaration> methods = List.unmodifiable(classMembers.whereType<MethodDeclaration>());

  /// Public method declarations in this file.
  late final List<MethodDeclaration> publicMethods = List.unmodifiable(methods.where((method) => !method.name.lexeme.startsWith('_')));

  /// Private method declarations in this file.
  late final List<MethodDeclaration> privateMethods = List.unmodifiable(methods.where((method) => method.name.lexeme.startsWith('_')));

  /// Static method declarations in this file.
  late final List<MethodDeclaration> staticMethods = List.unmodifiable(methods.where((method) => method.isStatic));

  /// Instance method declarations in this file.
  late final List<MethodDeclaration> instanceMethods = List.unmodifiable(methods.where((method) => !method.isStatic));

  /// Field declarations in this file.
  late final List<FieldDeclaration> fields = List.unmodifiable(classMembers.whereType<FieldDeclaration>());

  /// Public field declarations in this file.
  ///
  /// For multi-variable declarations, prefer [publicFieldVariables] and
  /// [privateFieldVariables] when a rule needs per-field visibility.
  late final List<FieldDeclaration> publicFields = List.unmodifiable(fields.where((field) => field.fields.variables.any(_isPublicVariable)));

  /// Private field declarations in this file.
  ///
  /// A declaration with both public and private variables appears in both
  /// [publicFields] and [privateFields]. Use [publicFieldVariables] and
  /// [privateFieldVariables] for exact per-field checks.
  late final List<FieldDeclaration> privateFields = List.unmodifiable(fields.where((field) => field.fields.variables.any(_isPrivateVariable)));

  /// Individual public field variables in this file.
  late final List<VariableDeclaration> publicFieldVariables = List.unmodifiable([
    for (final field in fields) ...field.fields.variables.where(_isPublicVariable),
  ]);

  /// Individual private field variables in this file.
  late final List<VariableDeclaration> privateFieldVariables = List.unmodifiable([
    for (final field in fields) ...field.fields.variables.where(_isPrivateVariable),
  ]);

  /// Static field declarations in this file.
  late final List<FieldDeclaration> staticFields = List.unmodifiable(
    fields.where((field) => field.isStatic),
  );

  /// Instance field declarations in this file.
  late final List<FieldDeclaration> instanceFields = List.unmodifiable(fields.where((field) => !field.isStatic));

  /// Field declarations marked as `final`.
  late final List<FieldDeclaration> finalFields = List.unmodifiable(fields.where((field) => field.fields.isFinal));

  /// Field declarations that are mutable.
  late final List<FieldDeclaration> mutableFields = List.unmodifiable(fields.where((field) => !field.fields.isFinal && !field.fields.isConst));

  /// Field declarations marked as `const`.
  late final List<FieldDeclaration> constFields = List.unmodifiable(fields.where((field) => field.fields.isConst));

  /// Constructor declarations in this file.
  late final List<ConstructorDeclaration> constructors = List.unmodifiable(classMembers.whereType<ConstructorDeclaration>());

  /// Executable class members in this file.
  late final List<ClassMember> codeUnits = List.unmodifiable([
    ...methods,
    ...constructors,
  ]);

  /// Public constructor declarations in this file.
  late final List<ConstructorDeclaration> publicConstructors = List.unmodifiable(constructors.where(_isPublicConstructor));

  /// Private constructor declarations in this file.
  late final List<ConstructorDeclaration> privateConstructors = List.unmodifiable(constructors.where(_isPrivateConstructor));

  /// Const constructor declarations in this file.
  late final List<ConstructorDeclaration> constConstructors = List.unmodifiable(
    constructors.where((constructor) => constructor.constKeyword != null),
  );

  /// Factory constructor declarations in this file.
  late final List<ConstructorDeclaration> factoryConstructors = List.unmodifiable(
    constructors.where((constructor) => constructor.factoryKeyword != null),
  );

  /// Class members that have annotations.
  late final List<ClassMember> annotatedMembers = List.unmodifiable(classMembers.where((member) => member.metadata.isNotEmpty));

  /// Directives that represent relationships with other files or libraries.
  final List<Directive> dependencies;

  /// Dependency directives resolved to imported local files.
  late final List<Directive> resolvedDependencies = List.unmodifiable(
    dependencies.where((directive) => directive.targetFiles.isNotEmpty),
  );

  /// Parse errors, when the analyzer reported any.
  final List<HeimdallParseError> parseErrors;

  /// Non-syntactic diagnostics reported while resolving this file.
  final List<HeimdallAnalysisDiagnostic> analysisDiagnostics;

  /// `true` when the analyzer reported parse errors.
  bool get hasErrors => parseErrors.isNotEmpty;

  /// Returns the one-based line and column for [offset] inside this file.
  CharacterLocation sourceLocationAt(int offset) {
    return lineInfo.getLocation(offset.clamp(0, content.length));
  }
}

bool _hasDartUri(UriBasedDirective directive) => directive.targetUris.any((uri) => uri._uriKind == _DirectiveUriKind.dart);

bool _hasPackageUri(UriBasedDirective directive) => directive.targetUris.any((uri) => uri._uriKind == _DirectiveUriKind.package);

bool _hasRelativeUri(UriBasedDirective directive) => directive.targetUris.any((uri) => uri._uriKind == _DirectiveUriKind.relative);

bool _hasUpwardRelativeUri(UriBasedDirective directive) {
  return directive.targetUris.any(
    (uri) => uri == '..' || uri.startsWith('../') || uri.contains('/../'),
  );
}

bool _hasSameDirectoryRelativeUri(UriBasedDirective directive) {
  return directive.targetUris.any((uri) {
    if (uri.contains(':') || uri == '..' || uri.startsWith('../') || uri.contains('/../')) {
      return false;
    }
    if (!uri.contains('/')) return true;
    return uri.startsWith('./') && !uri.substring(2).contains('/');
  });
}

bool _isUnresolvedLocalDirective(UriBasedDirective directive) {
  return directive.targetFile == null && (_hasRelativeUri(directive) || _hasPackageUri(directive));
}

enum _DirectiveUriKind { dart, package, relative, other }

extension _StringUriKind on String {
  _DirectiveUriKind get _uriKind {
    if (startsWith('dart:')) return _DirectiveUriKind.dart;
    if (startsWith('package:')) return _DirectiveUriKind.package;
    if (!contains(':')) return _DirectiveUriKind.relative;
    return _DirectiveUriKind.other;
  }
}

bool _isPublicVariable(VariableDeclaration variable) => !variable.name.lexeme.startsWith('_');

bool _isPrivateVariable(VariableDeclaration variable) => variable.name.lexeme.startsWith('_');

bool _isPublicConstructor(ConstructorDeclaration constructor) => !_isPrivateConstructor(constructor);

bool _isPrivateConstructor(ConstructorDeclaration constructor) => constructor.name?.lexeme.startsWith('_') ?? false;

/// Parse diagnostic captured while importing a Dart file.
final class HeimdallParseError {
  /// Creates a parse error with a message and source location.
  const HeimdallParseError({
    required this.message,
    required this.line,
    required this.column,
  });

  /// Diagnostic message produced by the analyzer.
  final String message;

  /// One-based line number.
  final int line;

  /// One-based column number.
  final int column;

  @override
  String toString() => '$line:$column: $message';
}

/// Semantic diagnostic captured while resolving a Dart file.
final class HeimdallAnalysisDiagnostic {
  /// Creates a materialized analyzer diagnostic.
  const HeimdallAnalysisDiagnostic({
    required this.code,
    required this.message,
    required this.severity,
    required this.type,
    required this.line,
    required this.column,
  });

  /// Analyzer diagnostic code.
  final String code;

  /// Diagnostic message produced by the analyzer.
  final String message;

  /// Analyzer severity, such as `ERROR` or `WARNING`.
  final String severity;

  /// Analyzer diagnostic category.
  final String type;

  /// One-based line number.
  final int line;

  /// One-based column number.
  final int column;

  @override
  String toString() => '$line:$column [$severity/$code]: $message';
}
