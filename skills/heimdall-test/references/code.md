# Heimdall.code()

## Method catalog

- `shouldParse`
- `shouldNotImportDartMirrors`
- `shouldNotImportPackage`
- `pathShouldBeEmpty`
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
| Require no files in a path | `pathShouldBeEmpty(...)` |

Import policies apply to imports; the broader URI policies also cover other directive URIs, such as exports and parts. `shouldParse()` checks parsing, not full semantic analysis.

`preferPackageImports()` rejects relative import targets in every conditional
branch, using the same implementation as `files().should().notUseRelativeImports()`.
It does not filter by the project's package name and accepts other URI schemes.
To restrict imports to `package:` and `dart:`, use
`files().should().useOnlyPackageOrSdkImports()`.
`preferRelativeImports()` is the style rule that uses the project's package name:
it rejects imports beginning with `package:<current-package>/` while accepting
external packages and SDK imports. If the package name is unavailable, it cannot
identify same-package imports and reports no style findings.

For a selected subtree with several conditions, use [Heimdall.files()](files.md). The built-in policies reuse the imported data, so no separate source scan is needed.
