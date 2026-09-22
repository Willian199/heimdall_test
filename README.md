# Heimdall Test

> **Development status:** Heimdall Test is still under active development. The
> public API may change between minor versions while the package is being shaped.

See the [changelog](CHANGELOG.md) for release notes and breaking changes.

Heimdall Test is an AST-first architecture testing package for Dart, inspired by
ArchUnit. It imports Dart source files with `package:analyzer`, keeps the real
AST nodes, enriches them with file and dependency metadata, and lets tests
describe executable rules about files, type declarations, members, dependencies,
layers, and feature slices.

The usual flow is:

1. Import a project or source subtree with `HeimdallFileImporter`.
2. Choose a rule entry point with `Heimdall.classes()`, `files()`, `methods()`,
   `dependencies()`, `layers()`, or another scope.
3. Optionally select candidates with `.that()`.
4. Assert what the selected items should satisfy with `.should()`.
5. Run `.check(project)` and call `.assertNoFindings()` in a test.

## Features

- Import Dart projects or subtrees and keep analyzer AST nodes as the source of
  truth.
- Filter imported files with options such as `ExcludeTestsImportOption`,
  `IncludeLibraryImportOption`, and `ExcludeGeneratedDartImportOption`.
- Run fluent rules for files, type declarations, members, fields, methods,
  constructors, and executable code units.
- Check naming, paths, annotations, modifiers, parse errors, imports, exports,
  source snippets, public class/file conventions, and member usage.
- Resolve local dependencies across imports, exports, parts, barrel files,
  combinators, aliases, constructor calls, static calls, and visible types.
- Model layer rules with allowed access constraints.
- Model repeated path slices and detect cycles or cross-slice dependencies.
- Freeze existing findings so only new violations fail later test runs.
- Group reusable checks with plugins and execute them through `HeimdallRunner`.

## Quick Start

```dart
import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('repositories stay in data and use the Repository suffix', () {
    final project = const HeimdallFileImporter().importPath();

    Heimdall.classes()
        .that()
        .resideInPath('src/data')
        .should()
        .haveTypeNameEndingWith('Repository')
        .check(project)
        .assertNoFindings();
  });
}
```

## Importing Source

`HeimdallFileImporter` recursively reads `.dart` files under a root path, parses
them with the analyzer, and returns a `HeimdallProject`.

```dart
final project = const HeimdallFileImporter(
  importOptions: [
    IncludeLibraryImportOption(),
    ExcludeGeneratedDartImportOption(),
  ],
).importPath();
```

By default, `importPath()` reads `lib/` and skips common generated files such as
`.g.dart`, `.freezed.dart`, and `.gr.dart`.

The importer caches results by root path and import option key. When files may
change inside the same test process, call `HeimdallFileImporter.clearCache()` or
create the importer with `useCache: false`.

The imported project exposes:

- `HeimdallProject.files`
- `HeimdallProject.declarations`
- `HeimdallProject.typeDeclarations`
- `HeimdallProject.dependencies`
- `HeimdallSourceFile.parseErrors`
- analyzer nodes enriched by Heimdall extensions such as `name`, `line`,
  `relativePath`, `targetUri`, and `targetFile`

Conditional imports and exports expose every possible branch through
`targetUris`, `targetPaths`, and `targetFiles`. `resolvedTargets` preserves the
URI, path, and file association for each resolved branch. The singular
properties keep representing the directive's primary URI for compatibility.

## Rule Semantics

A fluent rule has three parts:

```dart
Heimdall.classes() // scope: all imported type declarations
    .that()        // optional predicates: select candidates
    .arePublic()
    .should()      // conditions: validate selected candidates
    .beFinal()
    .check(project);
```

Predicates select items. Conditions validate selected items. A finding is
reported when a selected item does not satisfy the condition.

Rules are strict by default: if the scope has no candidates, or `.that()` matches
no candidates, the report contains an empty-selection finding. This catches
misspelled path patterns and rules that silently stop checking anything.

Use `.allowEmpty()` when an empty selection is the intended result:

```dart
Heimdall.files()
    .that()
    .resideInPath('lib/src/legacy')
    .should()
    .allowEmpty()
    .exist()
    .check(project)
    .assertNoFindings();
```

You can also use `.failOnEmpty(false)` on a rule or condition builder. The global
switch `HeimdallConfiguration.failOnEmptySelection` can disable empty-selection
failures for a whole test process.

## Scopes

Use the narrowest entry point that matches the architecture rule:

```dart
Heimdall.files();        // imported Dart source files
Heimdall.classes();      // classes, enums, mixins, extensions, extension types
Heimdall.members();      // fields, methods, and constructors
Heimdall.fields();       // fields only
Heimdall.methods();      // methods only
Heimdall.constructors(); // constructors only
Heimdall.codeUnits();    // methods and constructors
Heimdall.code();         // built-in source hygiene rules
Heimdall.dependencies(); // built-in dependency policies
Heimdall.layers();       // layer architecture builder
Heimdall.slices(...);    // slice dependency builder
```

The `no...` entry points invert the final condition for every selected item:

```dart
Heimdall.noFiles()
    .that()
    .resideInPath('lib')
    .should()
    .importUri('dart:mirrors')
    .check(project)
    .assertNoFindings();
```

That rule reads as: no imported file under `lib` should import `dart:mirrors`.

## Composing Rules

Predicate builders use `.and()`, `.or()`, and `.not()`:

```dart
Heimdall.classes()
    .that()
    .resideInPath('lib/src/data')
    .and()
    .not()
    .haveTypeNameEndingWith('Dto')
    .should()
    .haveTypeNameEndingWith('Repository')
    .check(project);
```

Condition builders use `.andShould()`, `.orShould()`, and `.not()` before the
first condition is finalized. After a condition method returns a rule, continue
the condition chain with `.and()` or `.or()`:

```dart
Heimdall.files()
    .that()
    .resideInPath('lib/src')
    .should()
    .not()
    .importUri('dart:mirrors')
    .and()
    .haveNoParseErrors()
    .check(project);
```

Builder `.not()` affects only the next fluent DSL call. Reusable objects use
`HeimdallPredicate.not()` and `HeimdallCondition.not()` instead:

```dart
final notGenerated = HeimdallPredicate<HeimdallSourceFile>(
  'be generated',
  (file, _) => file.relativePath.endsWith('.g.dart'),
).not();

Heimdall.files().that().satisfy(notGenerated).should().haveNoParseErrors();
```

For reusable custom checks, create a `HeimdallPredicate<T>` for selection or a
`HeimdallCondition<T>` for validation and pass it to `.satisfy(...)`.

## Built-In Sights

`Heimdall.code()` provides source hygiene rules:

```dart
Heimdall.code().shouldParse().check(project).assertNoFindings();
Heimdall.code().shouldNotImportDartMirrors().check(project).assertNoFindings();
Heimdall.code().publicSignaturesShouldNotUseDynamic(
  ignoredTypes: {'Map<String, dynamic>', 'List<dynamic>'},
  externalGenericTypeNames: ['Bloc', 'Cubit', 'Response', 'ValueNotifier', 'ValueListenable'],
).check(project).assertNoFindings();
```

Both options are optional. `ignoredTypes` also covers nullable and nested uses;
bare names such as `Map` or `List` exempt all their parametrizations. Import
prefixes must still match. SDK generics such as `Future` and `Stream` are
recognized by default; `externalGenericTypeNames` adds types whose omitted
arguments should count as `dynamic`.

`Heimdall.dependencies()` provides dependency policies:

```dart
Heimdall.dependencies()
    .noFilesShouldDependOnUpperDirectories()
    .check(project)
    .assertNoFindings();

Heimdall.dependencies()
    .noFilesShouldImportPackageSrc('some_package')
    .check(project)
    .assertNoFindings();
```

## Layers

Use layers when package areas may only depend on specific other areas.

```dart
final rule = Heimdall.layers()
    .layer('Domain').definedBy(['lib/src/domain'])
    .layer('Application').definedBy(['lib/src/application'])
    .layer('Infrastructure').definedBy(['lib/src/data'])
    .whereLayer('Domain').mayNotAccessAnyLayer()
    .whereLayer('Application').mayOnlyAccessLayers(['Domain'])
    .whereLayer('Infrastructure').mayOnlyAccessLayers(['Application', 'Domain'])
    .asRule()
    .as('onion architecture');

rule.check(project).assertNoFindings();
```

By default, layer checks consider all dependencies. Call
`consideringOnlyDependenciesInLayers()` to ignore dependencies whose target is
not assigned to a declared layer.

## Slices

Use slices for repeated architecture areas, such as features.

```dart
Heimdall.slices('lib/src/features/(*)')
    .shouldBeFreeOfCycles()
    .check(project)
    .assertNoFindings();
```

`(*)` captures one path segment as the slice name. Heimdall can report dependency
cycles between slices or forbid any cross-slice dependency.

## Path Patterns

Path-based APIs use `pathMatches` semantics:

- A plain path like `lib/src/data` matches only that exact path.
- A path fragment like `data/repository` matches that sequence of segments
  anywhere, including files below that path.
- Use `lib/src/data/**` to match every item under `lib/src/data`.
- Use `**data/repository/**` or `**/data/repository/**` to match a nested path anywhere in the source tree.
- `..service..` matches a path segment named `service`; `..data/service..` matches that sequence of path segments anywhere.
- `..` is a path-fragment wildcard. It can cross `/` separators and is useful for "contains this path".
- `*` is a glob wildcard inside one path segment. It does not cross `/`.
- `**` matches across path segments.
- A glob pattern starting with `/`, such as `/data/**/*impl.dart`, matches that segment sequence at any depth.
- `(*)` captures one path segment for slice and layer helpers.

Examples:

```dart
pathMatches('lib/src/data', 'lib/src/data'); // true
pathMatches('lib/src/data/user_repository.dart', 'lib/src/data'); // false
pathMatches('lib/src/features/user/data/repository/user_repository.dart', 'data/repository'); // true
pathMatches('lib/src/data/user_repository.dart', 'lib/src/data/**'); // true
pathMatches('lib/src/features/user/data/repository/user_repository.dart', '**data/repository/**'); // true
pathMatches('lib/src/features/user/data/service/user_service.dart', '..data/service..'); // true
pathMatches('lib/src/features/user/data/service/user_impl.dart', '/data/**/*impl.dart'); // true
```

## Freezing Known Violations

Freezing records the initial findings in a JSON file and reports only new
findings on later runs. Resolved baseline findings are removed automatically;
new findings are not added to the baseline merely because the rule is rerun.

Baseline file paths are relative to the package root and use `/` separators,
so the same baseline can be shared between checkouts and operating systems.

```dart
Heimdall.classes()
    .should()
    .beFinal()
    .freeze(storePath: '.heimdall/final_classes.json')
    .check(project)
    .assertNoFindings();
```

## Plugins

Plugins group reusable rules.

```dart
final class ArchitecturePlugin implements HeimdallRulePlugin {
  @override
  String get name => 'architecture';

  @override
  Iterable<PluginRule> rules() => [
        PluginRule(
          'code parses',
          (project) => Heimdall.code().shouldParse().check(project),
        ),
      ];
}

final reports = HeimdallRunner([ArchitecturePlugin()]).run(project);
for (final report in reports) {
  report.assertNoFindings();
}
```

## Reports

Every executable rule returns a `HeimdallReport` with a description, checked item
count, and a list of `HeimdallValidationInfo` findings. In tests, call
`assertNoFindings()` to turn findings into a failing assertion.

Use `.as('description')` to replace a generated rule description and
`.because('reason')` to append intent to the generated description.
