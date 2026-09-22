# Reuse cached model data

Use this reference when a requirement needs a custom predicate/condition or a diagnostic query. Prefer the built-in DSL for requirements it already expresses.

The models are exported through `package:heimdall_test/heimdall_test.dart`. Their implementation lives in `lib/src/mapper/model/` in the package source. The collections below are available in the 0.10.0 API.

## Two different caches

The importer caches entire projects by import root and option keys. It does not watch the filesystem. A project and its source models also materialize derived collections with `late final` and unmodifiable lists/maps. Reuse those collections and treat imported data as a snapshot; do not mutate AST nodes or attempt to update cached lists. Reimport after source changes with cache invalidation or `useCache: false`.

## Project and file collections

`HeimdallProject` aggregates many of the per-file collections below. Prefer a project collection for project-wide queries and a `HeimdallSourceFile` collection for per-file rules.

| Need | Existing data |
| --- | --- |
| File lookup | `project.filesByPath` indexed by absolute path; `project.fileByRelativePath(...)` relative to the import root |
| Source and locations | `file.content`, `file.lineInfo`, `file.sourceLocationAt(offset)`, `absolutePath`, `relativePath` |
| Syntax diagnostics | `file.parseErrors`, `file.hasErrors`; `project.filesWithParseErrors`, `parseErrors`, `parseErrorCount` |
| Semantic diagnostic storage | `analysisDiagnostics`; project `filesWithAnalysisDiagnostics`, `analysisDiagnosticCount` |
| Top-level declarations | `declarations`, `publicDeclarations`, `privateDeclarations` |
| All supported type declarations | `typeDeclarations`, `publicTypeDeclarations`, `privateTypeDeclarations` |
| Actual Dart classes only | `classDeclarations`, `publicClassDeclarations`, `privateClassDeclarations` |
| Class modifiers | `abstractClasses`, `sealedClasses`, `baseClasses`, `interfaceClasses`, `finalClasses` |
| Other declaration kinds | `mixinDeclarations`, `enumDeclarations`, `extensionDeclarations`, `extensionTypeDeclarations`, `typeAliases` |
| Top-level functions/variables | `topLevelFunctions`, `topLevelVariables`, `publicTopLevelVariableDeclarations`, `privateTopLevelVariableDeclarations` |
| Members | `classMembers`, `methods`, `fields`, `constructors`, `codeUnits`, `annotatedMembers` |
| Method subsets | `publicMethods`, `privateMethods`, `staticMethods`, `instanceMethods` |
| Field subsets | `publicFields`, `privateFields`, `staticFields`, `instanceFields`, `finalFields`, `mutableFields`, `constFields` |
| Individual field variables | `publicFieldVariables`, `privateFieldVariables` |
| Constructor subsets | `publicConstructors`, `privateConstructors`, `constConstructors`, `factoryConstructors` |
| Annotations | `annotatedDeclarations`, `annotatedTypeDeclarations` |
| Directives | `importDirectives`, `exportDirectives`, `partDirectives`, `partOfDirectives`, `dependencies` |
| Import categories | `dartImports`, `packageImports`, `relativeImports`, `relativeUpwardImports`, `relativeSameDirectoryImports`, `resolvedImports`, `unresolvedLocalImports` |

File-specific helpers also include `libraryDirective`, `typeReferenceDirectives`, `externalImports`, `deferredImports`, `prefixedImports`, `combinatorImports`, `sourceUris`, and `resolvedDependencies`. Files provide corresponding export categories such as `dartExports`, `packageExports`, `relativeExports`, `resolvedExports`, `unresolvedLocalExports`, `externalExports`, and `combinatorExports`. Project-specific helpers include `packageName`, `packageRootPath`, `packageRootUri`, `internalPackageImports`, `externalPackageImports`, and `packageSrcImports`.

Do not interpret a `FieldDeclaration` as one variable: `int exposed = 0, _hidden = 1;` is one declaration with two variables. It appears in both `publicFields` and `privateFields`. Use the individual variable collections for per-variable visibility. `topLevelVariables` likewise contains declaration groups; use the individual top-level variable collections when needed.

## Enriched AST nodes

Declarations, members, and directives are analyzer nodes enriched with Heimdall metadata. `HeimdallFileImporter` attaches this metadata automatically, including source paths, locations, and ownership. Independently parsed nodes do not have that context, so accessing context-dependent extensions on them can throw.

- `HeimdallDeclaration` on `CompilationUnitMember`: `name`, `sourcePath`, `relativePath`, `line`, `location`, `sourceLocationAt`, `annotations`, `annotationNodes`, `members`, `constructors`, `methods`, `fields`, `fieldVariables`, visibility and modifier helpers.
- `HeimdallMember` on `ClassMember`: `owner`, `ownerName`, `name`, source locations, `type`, `parameters`, `executableRoots`, annotations, kind and modifier helpers. `type` is textual, not a fully resolved semantic type. For a multi-variable field, `name` is a comma-separated representation.
- `HeimdallDependency` on `Directive`: `originPath`, `line`, `targetUri`, `targetUris`, `conditionalTargetUris`, `targetPath`, `targetPaths`, `targetFile`, `targetFiles`, `resolvedTargets`.

Do not infer full analyzer semantic resolution from model names or available properties. In this repository version, the importer uses `parseString` and does not populate `file.unit` or semantic diagnostics. An empty `analysisDiagnostics` list does not prove semantic correctness. Use the project's analyzer command for that validation.

## Dependencies and conditional branches

Singular `targetUri`, `targetPath`, and `targetFile` describe the primary branch. `targetUris`/`targetFiles` include the alternatives, including inactive conditional imports and exports. `resolvedTargets` preserves the association between each URI, absolute path, and imported file. Separate lists cannot reliably be zipped together because unresolved entries and deduplication can differ.

A null `targetFile` or an empty `targetFiles` list does not prove a broken import. SDK libraries, external packages, excluded files, and files outside the imported subtree may have no imported target. `unresolvedLocalImports` can include package imports; it is not a compiler diagnostic. Conditional directives may belong to several URI categories at once.

`file.sourceUris` caches parsed URI branches, including conditional alternatives and URI-based part-of directives. Each `HeimdallSourceUri` exposes `directive`, `target`, nullable `uri`, `isValid`, `relativeDestination`, and `isPart`. `relativeDestination` is a lexical resolution and does not prove that a file exists. Named part-of directives have no URI entry.

For local type visibility, use `project.exportedTypeDeclarationsOf(file)` for cached exports, including public type aliases, parts, transitive barrels, and combinators. Use `visibleTypeDeclarationsThrough(directive)` or `visibleTypeDeclarationsThroughTarget(directive, targetFile)` when visibility through a particular directive matters. Do not treat every declaration in a target file as visible through its imports or exports.

## Custom condition using cached collections

When your rule is not covered by a built-in DSL, `.satisfy(...)` accepts a custom predicate or condition. This example limits the combined number of public top-level functions and variables in each API file, using two cached collections:

```dart
final limitedEntryPoints = HeimdallCondition<HeimdallSourceFile>(
  'declare at most three public top-level entry points',
  (file, _) => HeimdallFindings(
    subject: file,
    passed: file.publicTopLevelFunctions.length +
            file.publicTopLevelVariableDeclarations.length <=
        3,
  ),
);

Heimdall.files()
    .that()
    .resideInPath('src/api/**')
    .should()
    .satisfy(limitedEntryPoints)
    .check(project)
    .assertNoFindings();
```

A predicate returns a boolean for selection. A condition returns `HeimdallFindings` with the evaluated `subject` and explicit `passed` value, including successful evaluations. Keep the subject so default and inverted findings retain source locations. Do not return a bare boolean or list from a condition callback.
