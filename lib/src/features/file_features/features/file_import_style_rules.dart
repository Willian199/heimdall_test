import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/file_features/helpers/import_style_conditions.dart';

/// Predicate-side DSL for import URI style, independent of package ownership.
///
/// Every conditional branch is checked. Exports and parts are not checked.
/// These rules inspect URI text; they do not validate syntax or resolve targets.
extension FileImportStylePredicateRules on FilePredicateBuilder {
  /// Selects files whose import targets all start with `package:` or `dart:`.
  ///
  /// Accepts both the project's package and external packages. Files without
  /// imports also match. Equivalent to `onlyImportFrom(['package:', 'dart:'])`.
  FilePredicateBuilder useOnlyPackageOrSdkImports() {
    return onlyImportFrom(const ['package:', 'dart:']);
  }

  /// Selects files with an import outside the `package:` and `dart:` prefixes.
  ///
  /// This is the inverse of [useOnlyPackageOrSdkImports]. Files without imports
  /// do not match. SDK imports alone do not satisfy this rule.
  FilePredicateBuilder notUseOnlyPackageOrSdkImports() {
    return importFromOutside(const ['package:', 'dart:']);
  }

  /// Selects files without relative import targets, including conditional ones.
  ///
  /// A relative target contains no colon. Other URI schemes are accepted;
  /// use [useOnlyPackageOrSdkImports] to allow only `package:` and `dart:`.
  /// Files without imports match. No project package-name filter is applied.
  FilePredicateBuilder notUseRelativeImports() {
    return satisfy(
      HeimdallPredicate(
        'not use relative imports',
        (item, _) => item.relativeImports.isEmpty,
      ),
    );
  }
}

/// Condition-side DSL for import URI style, independent of package ownership.
///
/// Every conditional branch is checked. Exports and parts are not checked.
/// These rules inspect URI text; they do not validate syntax or resolve targets.
extension FileImportStyleShouldRules on FileShouldBuilder {
  /// Requires every import target to start with `package:` or `dart:`.
  ///
  /// Accepts both the project's package and external packages, and files without
  /// imports. Equivalent to `onlyImportFrom(['package:', 'dart:'])`.
  HeimdallRule<HeimdallSourceFile> useOnlyPackageOrSdkImports() {
    return onlyImportFrom(const ['package:', 'dart:']);
  }

  /// Requires an import outside the `package:` and `dart:` prefixes.
  ///
  /// This is the inverse of [useOnlyPackageOrSdkImports]. Files without imports
  /// fail. SDK imports alone do not satisfy this rule.
  HeimdallRule<HeimdallSourceFile> notUseOnlyPackageOrSdkImports() {
    return importFromOutside(const ['package:', 'dart:']);
  }

  /// Rejects every relative import target, including conditional alternatives.
  ///
  /// A relative target contains no colon. Other URI schemes and files without
  /// imports are accepted. No project package-name filter is applied.
  /// [HeimdallCodeSight.preferPackageImports] uses this same check.
  HeimdallRule<HeimdallSourceFile> notUseRelativeImports() {
    return satisfy(fileShouldNotUseRelativeImports());
  }
}
