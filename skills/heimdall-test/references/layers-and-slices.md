# Heimdall.layers() and Heimdall.slices(...)

## Layers method catalog

- `heimdallLayers`
- `layer`
- `definedBy`
- `consideringOnlyDependenciesInLayers`
- `consideringAllDependencies`
- `whereLayer`
- `mayOnlyAccessLayers`
- `mayNotAccessAnyLayer`
- `mayOnlyBeAccessedByLayers`
- `mayNotBeAccessedByAnyLayer`
- `asRule`

## Slices method catalog

- `shouldBeFreeOfCycles`
- `shouldNotDependOnEachOther`

## Usage

Use layers for named areas with explicit allowed access, and slices for repeated areas such as features. Paths below assume `importPath()`.

```dart
Heimdall.layers()
    .layer('Domain').definedBy(['src/domain/**'])
    .layer('Application').definedBy(['src/application/**'])
    .layer('Data').definedBy(['data/**'])
    .whereLayer('Domain').mayNotAccessAnyLayer()
    .whereLayer('Application').mayOnlyAccessLayers(['Domain'])
    .whereLayer('Data').mayOnlyAccessLayers(['Domain', 'Application'])
    .asRule()
    .check(project)
    .assertNoFindings();

Heimdall.slices('src/features/(*)')
    .shouldBeFreeOfCycles()
    .check(project)
    .assertNoFindings();
```

In this example, Domain cannot access other layers, Application can access Domain, and Data can access Domain and Application. The layer patterns assign files to those named areas.

Layer checks consider all dependencies by default. Use `consideringOnlyDependenciesInLayers()` to limit the check to dependencies whose targets belong to declared layers.

`(*)` captures one segment as the slice name. For example, `src/features/login/page.dart` belongs to the `login` slice. `shouldBeFreeOfCycles()` checks for dependency cycles between those slices. For feature isolation with explicit shared slices, see [Heimdall.dependencies()](dependencies.md).

Replace the layer names, allowed access, and paths with your project's architecture. Both ends of a local dependency need to be in the imported source tree for the target to resolve.
