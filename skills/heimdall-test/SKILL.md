---
name: heimdall-test
description: How to use heimdall_test in Dart and Flutter projects, including importing source files, writing rules with the built-in DSLs, checking reports, and using cached model data for custom predicates and conditions.
---

# Using Heimdall Test

`heimdall_test` checks rules against your Dart source code. You import your source tree, select the files, types, or members to check, and describe what they must satisfy. The resulting report contains violations and their source locations; `assertNoFindings()` makes the test fail when violations exist.

## Add the package

Add `heimdall_test` to your development dependencies:

```sh
dart pub add --dev heimdall_test
```

For a Flutter project, use `flutter pub add --dev heimdall_test`. The examples use `package:test/test.dart`; add `test` as a development dependency if needed. In a Flutter test suite, you can use `package:flutter_test/flutter_test.dart` instead.

Import the public API with `package:heimdall_test/heimdall_test.dart`. It exports the DSLs, importer, models, and the analyzer AST types used in these examples. This guide describes the 0.10.0 API.

## Choose a DSL

**Default paths:** `const HeimdallFileImporter().importPath()` already imports `lib/`. Paths passed to the DSL are relative to that imported root: use `data/**`, not `lib/data/**`. To match the entire imported tree, use `**`, not `lib/**`. This applies to file/type/member path filters, layer definitions, slice patterns, and explicit code-policy path patterns.

Start with the built-in DSL that matches your rule:

1. A ready-made policy from `Heimdall.code()` or `Heimdall.dependencies()`, or a layer/slice builder for architectural boundaries.
2. A fluent rule over files, types, or members, composing existing predicates and conditions.
3. A custom `HeimdallPredicate<T>` or `HeimdallCondition<T>` passed to `.satisfy(...)` for behavior the existing DSL does not express. The cached model collections provide declarations, members, and dependencies for these custom rules.

Each guide lists the available methods, following the package's `FEATURES.md` catalog, and explains how to use that part of the API. The lists include the named variants, such as `Any`, `All`, `None`, and negative methods, rather than only representative examples.

| Entry point or task | Reference |
| --- | --- |
| All `Heimdall` entry points | [Entry-point catalog](references/entry-points.md) |
| Importing sources and path helpers | [Importer catalog](references/importer.md) |
| `Heimdall.classes()` | [Type rules](references/classes.md) |
| `Heimdall.files()` | [File rules](references/files.md) |
| `Heimdall.members()`, `fields()`, `methods()`, `constructors()`, `codeUnits()` | [Member rules](references/members.md) |
| `Heimdall.code()` | [Ready-made code policies](references/code.md) |
| `Heimdall.dependencies()` | [Dependency policies](references/dependencies.md) |
| `Heimdall.layers()`, `Heimdall.slices(...)` | [Layers and slices](references/layers-and-slices.md) |
| Composition, paths, baselines | [Shared DSL semantics](references/dsl-recipes.md) |
| Reusable plugins and rule execution | [Plugins and runner](references/plugins.md) |
| Custom checks and dependency diagnostics | [Cached model data](references/cached-model-data.md) |

The built-in DSLs already use the imported source metadata. You normally do not need to read files yourself, parse Dart code, or create an analyzer session.

## Import once and assert the report

Create `test/architecture_test.dart`. This example imports `lib/` once and checks that every type whose name ends with `Repository` lives under `lib/data/`:

```dart
import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  late HeimdallProject project;

  setUpAll(() {
    project = const HeimdallFileImporter().importPath();
  });

  test('repositories live in the data layer', () {
    Heimdall.classes()
        .that()
        .haveTypeNameEndingWith('Repository')
        .should()
        .resideInPath('data/**')
        .check(project)
        .assertNoFindings();
  });
}
```

The rule reads as follows:

1. `classes()` selects the imported type declarations.
2. `.that().haveTypeNameEndingWith('Repository')` keeps the types whose names end with `Repository`.
3. `.should().resideInPath('data/**')` requires those types to live in the data subtree.
4. `.check(project)` evaluates the rule and returns a report.
5. `.assertNoFindings()` fails the test if the report contains violations.

Replace the names and paths with your project's conventions. With `importPath()`, `lib/data/item.dart` has the relative path `data/item.dart`. Use `/**` to include a whole subtree. `project.files` exposes the imported files and their `relativePath` values.

Run the test from your package root:

```sh
dart test test/architecture_test.dart
```

For Flutter, use `flutter test test/architecture_test.dart`.

## Import options and caching

The importer defaults are `rootPath = 'lib'`, `useCache = true`, and `importOptions = const [ExcludeGeneratedDartImportOption()]`. The generated-file option excludes `.g.dart`, `.freezed.dart`, and `.gr.dart`. No extra library filter is needed for the default root. You can configure additional filters:

```dart
final project = const HeimdallFileImporter(
  importOptions: [
    ExcludeTestsImportOption(),
    ExcludeGeneratedDartImportOption(),
  ],
).importPath();
```

Providing `importOptions` replaces the default options. Include `ExcludeGeneratedDartImportOption()` to keep excluding generated files. Local dependency checks need both the source and target files in the imported tree.

Reuse the imported project across rules. Import results are cached by root and option keys without checking for source changes. If a test edits source files within the same process, call `HeimdallFileImporter.clearCache()` before reimporting or use `useCache: false`.

## Selections and reports

`.that()` selects what to check; `.should()` states the requirement. In the repository example, selecting types by their name catches repositories placed in the wrong directory. Selecting only the data directory would leave those misplaced repositories out of the check.

`.check(project)` returns a `HeimdallReport`; it does not throw just because violations exist. Call `.assertNoFindings()` to turn the findings into a failing test.

Empty selections fail by default, which helps detect incorrect paths and rules that no longer check any code. If an empty selection is valid for your rule, add `.allowEmpty()`; otherwise, check your scope, import options, and path pattern.

Use `.as('description')` to name a rule or `.because('reason')` to explain it. For gradual adoption in an existing project, `.freeze(storePath: ...)` records an initial baseline and reports new violations on later runs. See [shared DSL semantics](references/dsl-recipes.md) for composition, empty-selection behavior, and baselines.

For requirements outside the existing DSLs, use `.satisfy(...)` with a custom predicate or condition. The [cached model guide](references/cached-model-data.md) explains the available collections and includes a complete custom-condition example.
