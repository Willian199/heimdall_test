# Heimdall.code()

## Method catalog

- `shouldParse`
- `shouldNotImportDartMirrors`
- `shouldNotImportPackage`
- `pathShouldBeEmpty`
- `pathShouldNotExist`
- `publicSignaturesShouldNotUseDynamic`
- `shouldHaveAtMostOnePublicClassPerFile`
- `preferRelativeImports`
- `preferPackageImports`
- `preferRelativeUris`
- `preferPackageUris`
- `publicClassNameShouldMatchFileName`
- `shouldNotUsePartOf`
- `barrelFilesShouldOnlyExport`

## Usage

The optional `pathPattern` defaults to `**` for `publicSignaturesShouldNotUseDynamic`, `shouldHaveAtMostOnePublicClassPerFile`, `preferRelativeImports`, `preferPackageImports`, `preferRelativeUris`, `preferPackageUris`, and `publicClassNameShouldMatchFileName`. With the default `importPath()`, this already covers the imported `lib/` tree. For a subtree, pass `pathPattern: 'src/domain/**'`, without a `lib/` prefix.

`publicSignaturesShouldNotUseDynamic` defaults all three ignore collections to empty. `barrelFilesShouldOnlyExport` defaults `barrelPattern` to `'index.dart'` and `allowedExportPatterns` to `const ['.dart']`; the latter patterns are checked against export URI text, not imported file paths. URI arguments such as `package:example/src/api.dart` retain their URI syntax.

Use ready-made source policies directly; this entry point returns policy methods rather than a `.that().should()` builder.

```dart
Heimdall.code().shouldParse().check(project).assertNoFindings();
Heimdall.code().shouldNotImportDartMirrors().check(project).assertNoFindings();
Heimdall.code()
    .publicSignaturesShouldNotUseDynamic()
    .check(project)
    .assertNoFindings();
```

| Policy | Existing method |
| --- | --- |
| Forbid a package import | `shouldNotImportPackage(...)` |
| Prefer relative/package imports | `preferRelativeImports(...)`, `preferPackageImports(...)` |
| Prefer relative/package URIs beyond imports | `preferRelativeUris(...)`, `preferPackageUris(...)` |
| Limit public classes per file | `shouldHaveAtMostOnePublicClassPerFile(...)` |
| Align public class and filename | `publicClassNameShouldMatchFileName(...)` |
| Forbid part-of directives | `shouldNotUsePartOf()` |
| Restrict barrel contents | `barrelFilesShouldOnlyExport(...)` |
| Require no files in a path | `pathShouldBeEmpty(...)`, `pathShouldNotExist(...)` |

Import policies apply to imports; the broader URI policies also cover other directive URIs, such as exports and parts. `shouldParse()` checks parsing, not full semantic analysis.

For a selected subtree with several conditions, use [Heimdall.files()](files.md). The built-in policies reuse the imported data, so no separate source scan is needed.
