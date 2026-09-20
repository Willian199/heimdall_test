# Importer and path helpers

- `importPath`
- `clearCache`
- `includes`
- `pathMatches`
- `normalizePath`

`HeimdallFileImporter.importPath` imports a source directory and returns a `HeimdallProject`. The default root is `lib`. `HeimdallFileImporter.clearCache` clears cached imports. Import options use `includes` to determine whether a file belongs in the imported set. `pathMatches` checks a path against a pattern; `normalizePath` normalizes path separators.

## Defaults

| Setting | Default | Effect |
| --- | --- | --- |
| `importPath([rootPath])` | `'lib'` | Only the `lib/` source tree is traversed |
| `useCache` | `true` | Reuses imports for the same root and option keys |
| `importOptions` | `const [ExcludeGeneratedDartImportOption()]` | Skips `.g.dart`, `.freezed.dart`, and `.gr.dart` |

`IncludeLibraryImportOption()` is unnecessary when importing the default root. `ExcludeTestsImportOption()` is not a default option; the root-level `test/` directory is already outside `lib/`. Providing an options list replaces the default list.

## Paths are relative to the import root

```dart
final project = const HeimdallFileImporter().importPath();
```

For that default import:

| Path in your package | Imported relative path | DSL subtree pattern |
| --- | --- | --- |
| `lib/data/item.dart` | `data/item.dart` | `data/**` |
| `lib/features/login/page.dart` | `features/login/page.dart` | `features/login/**` |
| `lib/main.dart` | `main.dart` | `**` for the whole imported tree |

Passing `lib/data/**` to a path filter does not match `data/item.dart`. With strict empty selections enabled by default, such a filter causes an empty-selection finding; as a condition, it rejects selected items whose paths do not match.

`project.fileByRelativePath('data/item.dart')` uses the same relative base. Layer `definedBy(...)`, slice patterns, and explicit `pathPattern` arguments also use paths relative to the import root.

An explicit root changes that base: `importPath('lib/')` gives `data/item.dart`, while `importPath('.')` gives `lib/data/item.dart` when run from the package root. Import options filter the discovered files; they do not change the relative base.
