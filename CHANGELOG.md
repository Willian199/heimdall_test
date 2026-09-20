## 0.9.1

- Added `preferRelativeImports()`, `preferPackageImports()`, `preferRelativeUris()` and `preferPackageUris()`.

## 0.9.0

- **Breaking change:** Frozen violation baselines now use package-relative paths with `/` separators. Recreate baselines previously stored with absolute paths; no legacy migration is performed.
- Fixed default feature dependency rules when importing `lib/` or another source subtree.
- Fixed incomplete exported type caches for circular exports while preserving `show` and `hide` combinators.
- Fixed dependency rules for declarations in `part` files by including imports from their owning library.
- Included constructor initializers when checking executable member references.
- Fixed named constructor detection for visible declarations, including prefixed imports and explicit `new` and `const` invocations.
- Fixed negated and composed project conditions throwing assertion errors when generating findings.
- Added regression coverage using static source fixtures.

## 0.8.0

- Fixed class dependency resolution for homonymous types imported through different prefixes.
- Added conditional import and export URI/target resolution across dependency, file, layer, and slice rules.
- Fixed frozen rules so new violations remain new on subsequent runs until explicitly baselined.
- Included top-level-only Dart files when building slice dependency graphs.
- Fixed null-assertion guards invalidated by assignments, calls, closures, or asynchronous suspension.
- Fixed prefixed annotations, inheritance relationships, and type aliases with homonymous imports.
- Preserved the originating URI for every resolved conditional dependency target and its diagnostics.

## 0.7.3

- Improved `publicSignaturesShouldNotUseDynamic` to report raw generic public signatures and dynamic generic arguments for types such as `Future` and `Cubit`.
- Kept collection signatures using `List`, `Set`, `Iterable`, and `Map` exempt from dynamic generic argument findings.
- Updated the built-in feature list to match the current dependency, file, class, and member rule APIs.

## 0.7.2

- Added ignore options to `publicSignaturesShouldNotUseDynamic` for selected paths and declaration names.
- Moved `pubspecShouldNotDependOn` to the dependency sight so pubspec dependency checks live under `Heimdall.dependencies()`.
- Improved feature dependency defaults to support both `lib/features/(*)` and `lib/src/features/(*)` layouts.

## 0.7.1

- Added member assignability rules for declared field types and executable parameters, including any/all/none predicate and condition variants.
- Improved type assignability resolution to respect import/export visibility and hidden aliases.
- Improved dependency sights to report file-level findings for upper-directory imports, package `src` imports, and feature dependencies.
- Improved slice capture matching so scoped patterns must match the full path before assigning a slice id.
- Improved public dynamic signature checks for type aliases, function-typed parameters, nested function signatures, and field-formal constructor parameters.
- Improved dependency detection to avoid treating type parameters as external type references.
- Updated dependency sight examples in the README to use the file-level APIs.

## 0.7.0

- **Breaking change:** Removed `conditionDescription` from `HeimdallFindings`; generic failure messages now use the owning `HeimdallCondition.description`.
- **Breaking change:** `HeimdallRule` now derives its description from `descriptionPrefix` and the condition by default; use `customDescription` for direct constructor overrides and `.as(...)` for fluent custom rule names.
- **Breaking change:** `HeimdallLayers.asRule()` no longer accepts a `description` parameter; call `.asRule().as('...')` to customize the generated rule description.
- Added negative class rule variants for multiple exact names.
- Improved `publicSignaturesShouldNotUseDynamic()` to scan all paths by default and to resolve field-formal and super-formal constructor parameters before reporting public dynamic usage.
- Reduced duplicate slice and feature-dependency findings by checking dependencies per source file instead of per declaration.
- Simplified generated rule and finding descriptions across file, class, member, layer, slice, dependency, and code-sight rules.

## 0.6.0

- Added preprocessed source, declaration, and member metadata in the importer models to reduce repeated AST traversal during rule checks.
- Improved class and member rule performance by reusing cached names, visibility, annotations, member lists, parameters, executable roots, and modifier flags.
- Optimized method, constructor, static method, annotation, and member lookup helpers to short-circuit when only a boolean match is needed.
- Simplified internal rule helpers by removing one-line wrappers and moving single-use public helpers closer to their feature implementation.
- Improved rule internals while preserving the public fluent DSL behavior.

## 0.5.3

- Added member name predicates and conditions, including starting-with, ending-with, and matching variants.
- Added member declared field type-name rules, including exact, starting-with, ending-with, and matching variants.
- Added parameter type-name matching variants and support for field-formal and super-formal constructor parameters.
- Added class member, field, method, constructor, code-unit, and parameter count rules.
- Added class reference rules for raw type and identifier references.

## 0.5.2

- Improved matching rules to report better messages and locations.

## 0.5.1

- Reviewed and improved generated rule descriptions and finding messages to avoid duplicated paths and confusing `assertNoFindings` output.

## 0.5.0

- **Breaking change:** Overhauled `.not()` and `.noneOf` handling. The internal logic was largely rewritten to fix incorrect behavior; 

## 0.4.1

- Added `no...` methods across feature rule extensions for file, class, and member predicates and conditions.

## 0.4.0

- Renamed the global empty-selection configuration from `failOnEmptyShould` to `failOnEmptySelection`.
- Empty-selection failures now distinguish between selectors that return no candidates and `.that()` predicates that match no items.
- Rules remain strict by default; tests that intentionally allow empty selections should opt in with `.allowEmpty()`.

## 0.3.1

- Added predicate builder `.not()` support for negating the next selection predicate in fluent rule chains.
- Documented the difference between builder `.not()` calls and reusable `HeimdallPredicate.not()` / `HeimdallCondition.not()` composition.

## 0.3.0

- Reworked the package around analyzer AST nodes as the primary source of rule information.
- Expanded the fluent API for files, classes, members, constructors, code units, dependencies, layers, slices, plugins, and freezing.
- Added broader built-in architecture checks for code hygiene, dependency policies, public class/file conventions, dynamic signatures, barrels, layers, and feature slices.
- Improved importer behavior, package URI resolution, parse diagnostics, path matching, and dependency graph traversal.
- Reduced source-text based checks in favor of AST-backed rule validation.
- Added more regression coverage and package self-architecture tests.
- This release contains breaking API and behavior changes from the 0.2.x line.

## 0.2.0

- Added typed all/any/none variants across file, class, and member selectors and conditions.
- Improved path matching for exact paths, path fragments, `..` patterns, and glob combinations.
- Expanded layer architecture coverage to report every problematic file.

## 0.1.0

- Added Dart source importer with package URI resolution, parse diagnostics, content hashes, and import options.
- Added fluent rules for classes, files, members, code units, dependencies, layers, and slices.
- Added built-in code, dependency, layer, slice, plugin, and freezing support.
- Added AST-aware dependency detection, including barrel exports, combinators, static calls, aliases, and local-scope handling.
- Added stricter path matching, duplicate export/import finding reduction, and public signature checks.
- Added regression fixtures and architecture tests for importer, DSL, dependency, layer, slice, and member behavior.
