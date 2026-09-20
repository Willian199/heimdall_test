# Heimdall.files()

## Method catalog

- `not`
- `exist`
- `shouldNotExist`
- `haveName`
- `haveNameAny`
- `haveNameAll`
- `haveNameNone`
- `haveNameStartingWith`
- `haveNameStartingWithAny`
- `haveNameStartingWithAll`
- `haveNameStartingWithNone`
- `haveNameEndingWith`
- `haveNameEndingWithAny`
- `haveNameEndingWithAll`
- `haveNameEndingWithNone`
- `haveNameMatching`
- `haveNameMatchingAny`
- `haveNameMatchingAll`
- `haveNameMatchingNone`
- `resideInPath`
- `resideInAnyPath`
- `resideInAllPaths`
- `resideInNoPaths`
- `resideOutsideOfPath`
- `resideOutsideOfAnyPath`
- `resideOutsideOfAllPaths`
- `resideOutsideOfNoPaths`
- `importUri`
- `importAllUris`
- `importAnyUri`
- `importNoneUris`
- `importUriMatching`
- `importAllUrisMatching`
- `importAnyUriMatching`
- `importNoUrisMatching`
- `exportUri`
- `exportAllUris`
- `exportAnyUri`
- `exportNoneUris`
- `exportUriMatching`
- `exportAllUrisMatching`
- `exportAnyUriMatching`
- `exportNoneUrisMatching`
- `useOnlyPackageImports`
- `notUseRelativeImports`
- `onlyImportFrom`
- `onlyImportFromAll`
- `onlyImportFromAny`
- `onlyImportFromNone`
- `containSource`
- `containAllSource`
- `containAnySource`
- `containNoSource`
- `containSourceMatching`
- `containAllSourceMatching`
- `containAnySourceMatching`
- `containNoSourceMatching`
- `haveNoParseErrors`
- `haveParseErrors`
- `haveNoParseErrorsMatching`
- `haveParseErrorsMatching`
- `haveNoParseErrorsMatchingAll`
- `haveNoParseErrorsMatchingAny`
- `haveNoParseErrorsMatchingNone`
- `beEmpty`
- `haveDocumentationComment`
- `haveDocumentationCommentMatching`
- `haveDocumentationCommentMatchingAll`
- `haveDocumentationCommentMatchingAny`
- `haveDocumentationCommentMatchingNone`
- `declareClass`
- `declareAllClasses`
- `declareAnyClass`
- `declareNoClasses`
- `declareMethod`
- `declareAllMethods`
- `declareAnyMethod`
- `declareNoMethods`
- `declareConstructor`
- `declareAllConstructors`
- `declareAnyConstructor`
- `declareNoConstructors`
- `declareConstConstructor`
- `declareAllConstConstructors`
- `declareAnyConstConstructor`
- `declareNoConstConstructors`
- `declareFactoryConstructor`
- `declareAllFactoryConstructors`
- `declareAnyFactoryConstructor`
- `declareNoFactoryConstructors`
- `declareExtensionOn`
- `declareAllExtensionsOn`
- `declareAnyExtensionOn`
- `declareNoExtensionsOn`
- `callStaticMethod`
- `callAllStaticMethods`
- `callAnyStaticMethod`
- `callNoStaticMethods`
- `haveAtMostOnePublicClass`
- `haveAtMostOnePublicClassNamed`
- `haveMoreThanOnePublicClassNamed`
- `haveAtMostOnePublicClassNamedAll`
- `haveAtMostOnePublicClassNamedAny`
- `haveAtMostOnePublicClassNamedNone`
- `havePublicClassNameMatchingFileName`
- `havePublicClassNameMatchingFileNameFor`
- `havePublicClassNameMatchingFileNameForAll`
- `havePublicClassNameMatchingFileNameForAny`
- `havePublicClassNameMatchingFileNameForNone`
- `haveMatchingSinglePublicClassFileName`
- `haveAtMostOneTopLevelClass`
- `haveMoreThanOneTopLevelClass`
- `haveAtMostTopLevelClasses`
- `haveMoreThanTopLevelClasses`
- `haveAtMostAllTopLevelClasses`
- `haveAtMostAnyTopLevelClasses`
- `haveAtMostNoTopLevelClasses`
- `haveNoTopLevelVariables`
- `haveNoTopLevelFunctions`
- `haveNoTopLevelExecutableMembers`
- `haveLibraryDirective`
- `haveLibraryDirectiveNamed`
- `haveAllLibraryDirectivesNamed`
- `haveAnyLibraryDirectiveNamed`
- `haveNoLibraryDirectivesNamed`
- `havePartOfDirective`
- `notUsePartOfDirective`
- `receiveParameter`
- `receiveAllParameters`
- `receiveAnyParameter`
- `receiveNoParameters`
- `noBeEmpty`
- `noCallStaticMethod`
- `noContainSource`
- `noContainSourceMatching`
- `noDeclareClass`
- `noDeclareConstConstructor`
- `noDeclareConstructor`
- `noDeclareExtensionOn`
- `noDeclareFactoryConstructor`
- `noDeclareMethod`
- `noExportUri`
- `noExportUriMatching`
- `noHaveDocumentationComment`
- `noHaveDocumentationCommentMatching`
- `noHaveLibraryDirective`
- `noHaveLibraryDirectiveNamed`
- `noHaveName`
- `noHaveNameEndingWith`
- `noHaveNameMatching`
- `noHaveNameStartingWith`
- `noHavePublicClassNameMatchingFileName`
- `noHavePublicClassNameMatchingFileNameFor`
- `noImportUri`
- `noImportUriMatching`
- `noOnlyImportFrom`
- `noReceiveParameter`
- `noResideInPath`
- `noResideOutsideOfPath`
- `noUseOnlyPackageImports`

## Usage

Use for source-file names and paths, imports/exports, parse errors, parts, public class/file conventions, and top-level structure. Subjects are `HeimdallSourceFile` instances.


```dart
Heimdall.files()
    .that()
    .resideInPath('src/domain/**')
    .should()
    .not()
    .importUri('dart:io')
    .and()
    .haveNoParseErrors()
    .check(project)
    .assertNoFindings();
```

Paths assume `importPath()`. Use the selected-file DSL when a policy applies only to a subtree. Ready-made project-wide conventions are described in [Heimdall.code()](code.md).

Use `Heimdall.noFiles().should().importUri(...)` to forbid an import across all imported files. URI matching is different from matching the resolved target file's path. For package internals or feature isolation, prefer [dependency policies](dependencies.md).

For custom checks, reuse `file.importDirectives`, `sourceUris`, declaration/member subsets, and source locations from the [cached model](cached-model-data.md). Use source-text matching only for intentionally textual requirements; structural policies should use the existing DSL or AST metadata.
