# Heimdall.files()

## Method catalog

- `not`
- `exist`
- `shouldNotExist`
- `haveName`
- `haveNameEqualToAnyOf`
- `haveNameEqualToAllOf`
- `haveNameEqualToNoneOf`
- `haveNameStartingWith`
- `haveNameStartingWithAnyOf`
- `haveNameStartingWithAllOf`
- `haveNameStartingWithNoneOf`
- `haveNameEndingWith`
- `haveNameEndingWithAnyOf`
- `haveNameEndingWithAllOf`
- `haveNameEndingWithNoneOf`
- `haveNameMatching`
- `haveNameMatchingAnyOf`
- `haveNameMatchingAllOf`
- `haveNameMatchingNoneOf`
- `resideInPath`
- `resideInAnyPath`
- `resideInAllPaths`
- `resideOutsideOfAllPaths`
- `resideOutsideOfPath`
- `resideOutsideOfAtLeastOnePath`
- `importUri`
- `importAllUris`
- `importAnyUri`
- `importNoUris`
- `importUriMatching`
- `importAllUrisMatching`
- `importAnyUriMatching`
- `importNoUrisMatching`
- `exportUri`
- `exportAllUris`
- `exportAnyUri`
- `exportNoUris`
- `exportUriMatching`
- `exportAllUrisMatching`
- `exportAnyUriMatching`
- `exportNoUrisMatching`
- `useOnlyPackageOrSdkImports`
- `notUseRelativeImports`
- `onlyImportFrom`
- `haveEveryImportMatchAllPrefixes`
- `haveAllImportsShareAnyPrefix`
- `haveNoPrefixSharedByAllImports`
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
- `haveParseErrorsMatchingNoneOf`
- `notHaveParseErrorsMatchingAllOf`
- `haveParseErrorsMatchingAllOf`
- `beEmpty`
- `haveDocumentationComment`
- `haveDocumentationCommentMatching`
- `haveDocumentationCommentMatchingAllOf`
- `haveDocumentationCommentMatchingAnyOf`
- `haveDocumentationCommentMatchingNoneOf`
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
- `haveAtMostOnePublicClassForEachName`
- `haveAtMostOnePublicClassForAtLeastOneName`
- `haveMultiplePublicClassesForEachName`
- `havePublicClassNameMatchingFileName`
- `havePublicClassNameMatchingFileNameFor`
- `havePublicClassNameMatchingFileNameForAllOf`
- `havePublicClassNameMatchingFileNameForAnyOf`
- `havePublicClassNameMatchingFileNameForNoneOf`
- `haveAtMostOnePublicClassWithMatchingFileName`
- `haveAtMostTopLevelClasses`
- `haveMoreThanTopLevelClasses`
- `haveTopLevelClassCountAtMostAllOf`
- `haveTopLevelClassCountAtMostAnyOf`
- `haveTopLevelClassCountExceedingAllOf`
- `haveNoTopLevelVariables`
- `haveNoTopLevelFunctions`
- `haveNoTopLevelExecutableMembers`
- `haveLibraryDirective`
- `haveLibraryDirectiveNamed`
- `haveAllLibraryDirectivesNamed`
- `haveAnyLibraryDirectiveNamed`
- `haveNoLibraryDirectivesNamed`
- `havePartOfDirective`
- `haveNoPartOfDirective`
- `receiveParameter`
- `receiveAllParameters`
- `receiveAnyParameter`
- `receiveNoParameters`
- `notBeEmpty`
- `notCallStaticMethod`
- `notContainSource`
- `notContainSourceMatching`
- `notDeclareClass`
- `notDeclareConstConstructor`
- `notDeclareConstructor`
- `notDeclareExtensionOn`
- `notDeclareFactoryConstructor`
- `notDeclareMethod`
- `notExportUri`
- `notExportUriMatching`
- `haveNoDocumentationComment`
- `haveNoDocumentationCommentMatching`
- `haveNoLibraryDirective`
- `haveNoLibraryDirectiveNamed`
- `haveNameDifferentFrom`
- `notHaveNameEndingWith`
- `notHaveNameMatching`
- `notHaveNameStartingWith`
- `notHavePublicClassNameMatchingFileName`
- `notHavePublicClassNameMatchingFileNameFor`
- `notImportUri`
- `notImportUriMatching`
- `importFromOutside`
- `notReceiveParameter`
- `notUseOnlyPackageOrSdkImports`

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
