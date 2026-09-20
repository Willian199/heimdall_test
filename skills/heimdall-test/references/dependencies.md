# Heimdall.dependencies()

## Method catalog

- `noFilesShouldDependOnUpperDirectories`
- `noFilesShouldImportPackageSrc`
- `featuresShouldNotDependOnEachOther`
- `pubspecShouldNotDependOn`

## Usage

`Heimdall.dependencies()` provides ready-made checks for upward imports, private package APIs, feature isolation, and declared package dependencies.

```dart
Heimdall.dependencies()
    .noFilesShouldDependOnUpperDirectories()
    .check(project)
    .assertNoFindings();

Heimdall.dependencies()
    .noFilesShouldImportPackageSrc('some_dependency')
    .check(project)
    .assertNoFindings();

Heimdall.dependencies()
    .featuresShouldNotDependOnEachOther(
      featurePattern: 'src/features/(*)',
      sharedSlices: ['shared'],
    )
    .check(project)
    .assertNoFindings();
```

The first policy rejects upward relative imports. The second rejects imports of the named package's private `src` paths. Replace `some_dependency` with the dependency whose internals you want to protect.

For feature isolation, an explicit `featurePattern` is relative to the import root. With the default `importPath()`, pass `'src/features/(*)'` or `'features/(*)'`, without `lib/`.

When `featurePattern` is omitted, this policy internally uses package-relative paths and detects both conventional feature locations automatically. That internal default does not mean explicit patterns should include `lib/`. `sharedSlices` defaults to an empty collection; supplying names permits dependencies targeting those slices.

`pubspecShouldNotDependOn(packageName)` checks package metadata rather than source imports. Use it when the requirement is to prohibit a declared dependency, not just its usage.

Use [layers and slices](layers-and-slices.md) for named access policies and cycle checks. Import enough files to include local dependency targets. For custom diagnostics, consult [cached dependency metadata](cached-model-data.md): conditional branches, unresolved targets, and external dependencies require more care than reading only `targetUri`.
