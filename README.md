# Heimdall Test

> **Development status:** The package is under active development. Public APIs may change between minor versions. See the [changelog](CHANGELOG.md) for release notes.

Heimdall Test is an AST-first architecture testing package for Dart, inspired by ArchUnit. It imports Dart source files with `package:analyzer`, keeps the real AST nodes, enriches them with file and dependency metadata, and lets tests describe executable rules about files, type declarations, members, dependencies, layers, and feature slices.

## Features

- Import Dart projects or subtrees and keep analyzer AST nodes as the source of truth.
- Filter imported files with options such as `ExcludeTestsImportOption`, `IncludeLibraryImportOption`, and `ExcludeGeneratedDartImportOption`.
- Run fluent rules for files, type declarations, members, fields, methods, constructors, and executable code units.
- Check naming, paths, annotations, modifiers, parse errors, imports, exports, source snippets, public class/file conventions, and member usage.
- Resolve local dependencies across imports, exports, parts, barrel files, combinators, aliases, constructor calls, static calls, and visible types.
- Model layer rules with allowed access constraints.
- Model repeated path slices and detect cycles or cross-slice dependencies.
- Freeze existing findings so only new violations fail later test runs.
- Group reusable checks with plugins and execute them through `HeimdallRunner`.

## Quick Start

Add the development dependencies:

```sh
dart pub add --dev heimdall_test
```

For a Flutter app, use `flutter pub add --dev heimdall_test` instead.

Save this example as `test/architecture/architecture_test.dart`:

```dart
import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('repositories stay in data', () {
    final project = const HeimdallFileImporter().importPath();

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

Run `dart test test/architecture/architecture_test.dart` or `flutter test test/architecture/architecture_test.dart` from the package root. The rule selects types whose names end in `Repository` and requires them to live under `lib/data/`. Adjust paths and naming conventions to your app.

## Importing Source

`HeimdallFileImporter` recursively discovers `.dart` files under the supplied root, applies import options, and parses the remaining files with the analyzer. It returns a `HeimdallProject` containing the files, declarations, members, and dependency directives used by the rules. Importing parses source without requiring a build or full semantic resolution.

```dart
final project = const HeimdallFileImporter().importPath();

expect(project.files, isNotEmpty);
expect(project.parseErrors, isEmpty);
```

The default root is `lib/`. Pass another directory to `importPath(...)` to change the source tree being checked. All rule paths are relative to that root, as explained in [Paths](#paths).

### Filtering files before parsing

By default, the importer skips `.g.dart`, `.freezed.dart`, `.gr.dart`, `.gen.dart`, and `.mocks.dart`. Add custom exclusions with literal, non-empty, case-sensitive suffixes:

```dart
final project = HeimdallFileImporter(
  importOptions: [
    ExcludeGeneratedDartImportOption(
      additionalSuffixes: ['.generated.dart', '.custom.dart'],
    ),
  ],
).importPath();

expect(project.parseErrors, isEmpty);
```

| Import option | Effect |
| --- | --- |
| `IncludeLibraryImportOption()` | Includes only files under a `lib/` path segment |
| `ExcludeTestsImportOption()` | Excludes files under `test/` and files ending in `_test.dart` |
| `ExcludeGeneratedDartImportOption.defaults()` | Excludes the built-in generated suffixes |
| `ExcludeGeneratedDartImportOption(additionalSuffixes: [...])` | Excludes the built-in suffixes plus custom ones |

A file must pass every configured import option. Supplying `importOptions` replaces the default list, so include `const ExcludeGeneratedDartImportOption.defaults()` when you want to retain that exclusion alongside other filters. Excluded files are not parsed or available to any rule; predicate filters, introduced below, select from files that have already been imported.

### Reusing an imported project

Import once and pass the same project to multiple rules. The importer also caches snapshots by root path and configuration. If source files change within the same process, call `HeimdallFileImporter.clearCache()` or use `HeimdallFileImporter(useCache: false)` to obtain a fresh snapshot.

## Paths

`importPath()` reads `lib/` by default. All rule paths are relative to that imported root:

| Source file | Imported root | Path seen by rules |
| --- | --- | --- |
| `lib/data/user_repository.dart` | `lib/` (default) | `data/user_repository.dart` |
| `lib/data/user_repository.dart` | `.` | `lib/data/user_repository.dart` |
| `lib/features/login/login.dart` | `lib/features/` | `login/login.dart` |

Use `data/**` for all files below `lib/data/` with the default import. Layers use the same path matching. Slices use `(*)` to capture a path segment as a slice name.

### Common patterns

| Pattern | Meaning |
| --- | --- |
| `data/**` | Everything below the root's `data/` folder |
| `**/data/**` | A `data/` folder at any depth and its descendants |
| `*` | Characters within one path segment |
| `**` | Characters across path segments |
| `..service..` | A segment named `service` anywhere in the path |
| `..data/service..` | The sequence `data/service` anywhere in the path |
| `/data/**/*impl.dart` | A `data/` folder at any depth, followed by a file ending in `impl.dart` |
| `features/(*)` | Feature names captured by slice rules |

Plain paths have two additional behaviors: a single segment such as `data` matches that segment anywhere; a multi-segment path starting with the checked path's first segment requires an exact match. A fragment starting with a different first segment can match inside the path. Prefer explicit globs when selecting directories and their descendants.

```dart
expect(pathMatches('data/user_repository.dart', 'data/**'), isTrue);
expect(pathMatches('features/login/data/repository.dart', '**/data/**'), isTrue);
expect(pathMatches('data/repositories/user_repository.dart', 'data/repositories'), isFalse);
expect(pathMatches('features/login/data/repository/user_repository.dart', 'data/repository'), isTrue);
```

## Rule Semantics

The usual flow is:

1. Import a project or source subtree with `HeimdallFileImporter`.
2. Choose a rule entry point with `Heimdall.classes()`, `files()`, `methods()`, `dependencies()`, `layers()`, or another scope.
3. Optionally select candidates with `.that()`.
4. Assert what the selected items should satisfy with `.should()`.
5. Run `.check(project)` and call `.assertNoFindings()` in a test.

A fluent rule has three parts: its entry point chooses the **scope**, a **predicate** selects which items are checked, and a **condition** states what those items must satisfy. `.that()` starts predicate selection; `.should()` starts condition validation. Without `.that()`, the rule checks every item in its scope.

```dart
final project = const HeimdallFileImporter().importPath();

Heimdall.classes() // scope: all imported type declarations
    .that() // optional predicates: select candidates
    .arePublic()
    .should() // conditions: validate selected candidates
    .beFinal()
    .check(project)
    .assertNoFindings();
```

This rule requires public type declarations to be final. `.check(project)` evaluates the rule and returns a report; `.assertNoFindings()` fails the test if the report contains violations.

## Scopes

The scope determines which imported items are available to a rule. For example, `Heimdall.files()` makes imported source files available to the check:

```dart
final project = const HeimdallFileImporter().importPath();

Heimdall.files()
    .should()
    .haveNoParseErrors()
    .check(project)
    .assertNoFindings();
```

Choose the entry point for the kind of item you want to check:

| Entry point | Items checked |
| --- | --- |
| `Heimdall.files()` | Imported Dart source files |
| `Heimdall.classes()` | Classes, enums, mixins, extensions, and extension types |
| `Heimdall.members()` | Fields, methods, and constructors |
| `Heimdall.fields()` | Fields |
| `Heimdall.methods()` | Methods |
| `Heimdall.constructors()` | Constructors |
| `Heimdall.codeUnits()` | Methods and constructors |
| `Heimdall.code()` | Built-in source hygiene rules |
| `Heimdall.dependencies()` | Built-in dependency policies |
| `Heimdall.layers()` | Layer architecture rules |
| `Heimdall.slices('features/(*)')` | Feature slice dependency rules |

## Predicates

Predicates filter the chosen scope through `.that()`. Only matching items reach the conditions.

```dart
final project = const HeimdallFileImporter().importPath();

Heimdall.classes()
    .that()
    .areInterfaces()
    .should()
    .beAbstract()
    .check(project)
    .assertNoFindings();
```

Here, `.areInterfaces()` selects interface declarations. `.beAbstract()` checks that the selected interfaces are abstract; other declarations are not selected.

### Custom predicates

Use the built-in predicates for individual modifiers, such as `.areInterfaces()`. A custom predicate can name a reusable combination, such as an abstract interface:

```dart
final isContract = HeimdallPredicate<CompilationUnitMember>(
  'be an abstract interface',
  (declaration, _) => declaration.isAbstract && declaration.isInterface,
);
```

Use `.that().satisfy(isContract)` to select matching declarations.

### File matchers

File matchers operate on paths and properties of already imported files. This rule selects files in either `domain/` or `application/` and checks that they parse:

```dart
final project = const HeimdallFileImporter().importPath();

Heimdall.files()
    .that()
    .resideInAnyPath(['domain/**', 'application/**'])
    .should()
    .haveNoParseErrors()
    .check(project)
    .assertNoFindings();
```

| Matcher | Selection |
| --- | --- |
| `.resideInPath('data/**')` | Files matching one pattern |
| `.resideInAnyPath(['domain/**', 'application/**'])` | Files matching at least one pattern |
| `.resideInAllPaths(['features/**', '**/data/**'])` | Files matching every pattern, such as `features/login/data/model.dart` |

These methods are also available as conditions after `.should()`. Before `.should()`, a non-matching file is excluded from the selection; after `.should()`, a selected file that does not match produces a violation.

## Conditions

Conditions validate the items selected by the predicates. Start validation with `.should()`, then evaluate the rule with `.check(project)` and enforce its result with `.assertNoFindings()`.

```dart
final project = const HeimdallFileImporter().importPath();

Heimdall.files()
    .should()
    .haveAtMostOnePublicClass()
    .check(project)
    .assertNoFindings();
```

Here, `.haveAtMostOnePublicClass()` is the condition. There is no predicate, so every imported file is checked. A file declaring more than one public class produces a violation.

### Custom conditions

`HeimdallCondition<T>` returns a `HeimdallFindings` with the evaluated `subject` and a `passed` result. This condition accepts either `final` or `sealed` declarations:

```dart
final isFinalOrSealed = HeimdallCondition<CompilationUnitMember>(
  'be final or sealed',
  (declaration, _) => HeimdallFindings(
    subject: declaration,
    passed: declaration.isFinal || declaration.isSealed,
  ),
);
```

Use `.should().satisfy(isFinalOrSealed)` to validate selected declarations.

A failed condition produces a finding using its description and subject location. Supply `findings` when you need more specific diagnostics. Reusable predicates and conditions support `.not()`, `.and(...)`, and `.or(...)` outside the fluent builders.

## Combining Predicates and Conditions

Use `.and()` to require both criteria or `.or()` to accept either. Before `.should()`, these operators combine selection predicates; after `.should()`, they combine validation conditions.

```dart
final project = const HeimdallFileImporter().importPath();

Heimdall.classes()
    .that() // Select DTOs under data/.
    .resideInPath('data/**')
    .and()
    .haveTypeNameEndingWith('Dto')
    .should() // Require them to be final and public.
    .beFinal()
    .and()
    .bePublic()
    .check(project)
    .assertNoFindings();
```

Only declarations matching both predicates are checked. Each selected declaration must satisfy both conditions. Replacing either `.and()` with `.or()` changes that pair to accept either criterion.

Builder `.not()` negates the next predicate or condition; prefer a directly negated method when available. The `no...` entry points invert the condition for every selected item.

## Layers

Define layers by path and declare which other layers they may access. This example keeps Domain independent, lets Application use Domain, and lets Infrastructure use both:

```dart
final project = const HeimdallFileImporter().importPath();

Heimdall.layers()
    .layer('Domain').definedBy(['domain/**'])
    .layer('Application').definedBy(['application/**'])
    .layer('Infrastructure').definedBy(['data/**'])
    .whereLayer('Domain').mayNotAccessAnyLayer()
    .whereLayer('Application').mayOnlyAccessLayers(['Domain'])
    .whereLayer('Infrastructure').mayOnlyAccessLayers(['Application', 'Domain'])
    .asRule()
    .check(project)
    .assertNoFindings();
```

By default, references to imported declarations outside the declared layers also produce findings. Add `.consideringOnlyDependenciesInLayers()` before `.asRule()` to restrict the check to declared layers. Use `.mayOnlyBeAccessedByLayers(...)` or `.mayNotBeAccessedByAnyLayer()` to constrain incoming access instead.

Layer checks follow used types, top-level functions, getters, setters, variables, and implicit extension accesses. Unused imports do not produce layer violations. Findings identify the relevant import's file and line, including when the reference is in a `part` file. Repeated references from the same declaration through the same import to the same destination layer produce one finding per conditional URI branch.

## Feature Slices

Slices group files by a captured path segment. With the default import, `features/(*)` maps `lib/features/login/...` to the `login` slice.

To prevent dependency cycles:

```dart
final project = const HeimdallFileImporter().importPath();

Heimdall.slices('features/(*)')
    .shouldBeFreeOfCycles()
    .check(project)
    .assertNoFindings();
```

To forbid dependencies between features while allowing them to depend on a shared slice:

```dart
final project = const HeimdallFileImporter().importPath();

Heimdall.slices('features/(*)')
    .shouldNotDependOnEachOther(sharedSlices: ['shared'])
    .check(project)
    .assertNoFindings();
```

Slice graphs include direct imports, exports, and parts. For imports through a facade, references also create edges to the slices declaring the used types or top-level values, even when the facade is outside the matching pattern. Merely exposing an unused declaration through an imported facade does not add that edge. Exported declarations are followed according to `show` and `hide` visibility.

## Built-In Checks

### Source hygiene

`Heimdall.code()` provides ready-made checks for parse errors, public-class organization, and public signatures using `dynamic`:

```dart
final project = const HeimdallFileImporter().importPath();

Heimdall.code().shouldParse().check(project).assertNoFindings();
Heimdall.code().shouldHaveAtMostOnePublicClassPerFile().check(project).assertNoFindings();

Heimdall.code()
    .publicSignaturesShouldNotUseDynamic(
      ignoredTypes: {'Map<String, dynamic>', 'List<dynamic>'},
      externalGenericTypeNames: ['Bloc', 'Cubit', 'Response'],
    )
    .check(project)
    .assertNoFindings();
```

Both arguments are optional. `ignoredTypes` exempts matching signatures, including nullable and nested uses; a bare name such as `Map` exempts all its parametrizations. Import prefixes must match. Raw generic types are resolved from visible declarations and their bounds, respecting import/export prefixes, `show`/`hide`, and reexports. SDK sources are consulted lazily using the importer's `referenceOptions`; package sources require explicit permission there. Consulted sources never become validation subjects. `externalGenericTypeNames` provides a fallback for unresolved external generic types whose omitted arguments should count as `dynamic`.

### Dependency policies

These checks prevent upward relative dependencies and imports of another package's private `src/` libraries:

```dart
final project = const HeimdallFileImporter().importPath();

Heimdall.dependencies()
    .noFilesShouldDependOnUpperDirectories()
    .check(project)
    .assertNoFindings();

Heimdall.dependencies()
    .noFilesShouldImportPackageSrc('collection')
    .check(project)
    .assertNoFindings();
```

## Rule Behavior

### Empty selections

Rules fail when there are no candidates or the predicate matches no items. This catches misspelled paths and missing declarations: the Quick Start test also fails if the project has no `Repository` types.

Use `.allowEmpty()` when a rule should apply only if matching items exist. For example, DTOs must be final, but the project does not need to declare any DTOs:

```dart
final project = const HeimdallFileImporter().importPath();

Heimdall.classes()
    .that()
    .haveTypeNameEndingWith('Dto')
    .should()
    .beFinal()
    .allowEmpty()
    .check(project)
    .assertNoFindings();
```

This passes when there are no DTOs. If DTOs exist, each one must satisfy the condition; `.allowEmpty()` does not suppress their violations.

`.failOnEmpty(false)` provides the same setting on a rule or condition builder. `HeimdallConfiguration.failOnEmptySelection` controls this behavior globally.

### Reports and descriptions

A `HeimdallReport` contains `checkedCount`, `findings`, and `description`. Use `.as('description')` to name a rule or `.because('reason')` to explain its purpose. Neither `.check(project)` nor reading a report throws for violations; call `.assertNoFindings()` to enforce the result.

## Freezing Known Violations

Freezing lets you adopt a rule without immediately fixing all existing violations. The first run saves the findings as a JSON baseline; later runs fail only for new violations. Fixed findings are removed, and new findings are not automatically accepted into the baseline.

```dart
final project = const HeimdallFileImporter().importPath();

Heimdall.classes()
    .should()
    .beFinal()
    .freeze(storePath: '.heimdall/final_classes.json')
    .check(project)
    .assertNoFindings();
```

Commit the baseline to share it with the team. Stored file paths are relative to the package root and use `/`, so the baseline can be shared between checkouts and operating systems.

## Plugins

Plugins group reusable, named checks. Define the plugin class at library scope:

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
```

Run its checks inside the test:

```dart
final project = const HeimdallFileImporter().importPath();
final reports = HeimdallRunner([ArchitecturePlugin()]).run(project);

for (final report in reports) {
  report.assertNoFindings();
}
```
