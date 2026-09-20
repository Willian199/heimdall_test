# Shared DSL semantics

## Method catalog

- `that`
- `should`
- `and`
- `or`
- `not` (predicate/condition builder)
- `andShould`
- `orShould`
- `satisfy`
- `allowEmpty`
- `failOnEmpty`
- `check`
- `assertNoFindings`
- `because`
- `as`
- `freeze`

## Usage

All snippets use `package:heimdall_test/heimdall_test.dart` and an imported `project`. Paths below assume `importPath()`.

`importPath()` defaults to `lib/`, so use `src/domain/**` for `lib/src/domain/` and `**` for all imported files. Repeating `lib/` in a DSL path pattern prevents it from matching the default imported paths. The examples use import-relative paths throughout.

## Selection and composition

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

Predicate builders compose with `.and()`, `.or()`, and `.not()`. After a condition returns a rule, continue with `.and()` or `.or()`. Condition builders also expose `.andShould()` and `.orShould()`. Builder `.not()` applies to the next DSL call. For explicitly grouped reusable logic, use `HeimdallPredicate.allOf/anyOf/noneOf` or `HeimdallCondition.allOf/anyOf/noneOf` with nonempty inputs.

The `noFiles()`, `noClasses()`, and other `no...` entry points invert the final condition per selected item. For example, `Heimdall.noFiles().should().importUri('dart:mirrors')` forbids that import. Avoid combining inversion and already negative methods unless the resulting logic is intended.

## Paths and incremental adoption

Use `/` in patterns. `*` stays inside one path segment; `**` crosses segments; `..service..` matches a segment named `service`. A plain multi-segment pattern beginning at the checked path's first segment is an exact match; use `data/**` for descendants. `pathMatches(...)` can verify a pattern against an actual `relativePath`.

To adopt a rule gradually while keeping a baseline of existing violations:

```dart
Heimdall.classes()
    .should()
    .beFinal()
    .freeze(storePath: '.heimdall/final_classes.json')
    .check(project)
    .assertNoFindings();
```

The first run records existing findings. Later runs fail on new findings and remove resolved entries. Keep the baseline under version control when sharing it with the team; do not regenerate it merely to make a test pass.
