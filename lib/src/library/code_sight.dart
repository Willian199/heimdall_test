import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/file_features/helpers/import_style_conditions.dart';
export 'public_dynamic_signature_rule.dart';

/// Built-in rules for source-code hygiene checks.
final class HeimdallCodeSight {
  /// Creates the built-in code sight rule provider.
  const HeimdallCodeSight();

  /// Ensures imported files do not import `dart:mirrors`.
  HeimdallRule<HeimdallSourceFile> shouldNotImportDartMirrors() {
    return Heimdall.files().should().notImportUri('dart:mirrors').as('code should not import dart:mirrors');
  }

  /// Ensures imported files do not import [packageName].
  HeimdallRule<HeimdallSourceFile> shouldNotImportPackage(
    String packageName,
  ) {
    final escapedPackageName = RegExp.escape(packageName);
    return Heimdall.files().should().notImportUriMatching(RegExp('^package:$escapedPackageName/')).as('code should not import package:$packageName');
  }

  /// Ensures all imported files parse without analyzer errors.
  HeimdallRule<HeimdallSourceFile> shouldParse() {
    return Heimdall.files().should().haveNoParseErrors().as('code should parse');
  }

  /// Ensures [pathPattern] is empty among imported files.
  ///
  /// This accepts existing directories in the filesystem; it only fails when
  /// imported files are found under the path.
  HeimdallRule<HeimdallSourceFile> pathShouldBeEmpty(String pathPattern) =>
      _emptyPathRule(pathPattern, description: 'path $pathPattern should be empty');

  /// Ensures files in [pathPattern] declare at most one public class.
  HeimdallRule<HeimdallSourceFile> shouldHaveAtMostOnePublicClassPerFile({
    String pathPattern = '**',
  }) {
    return Heimdall.files().that().resideInPath(pathPattern).should().haveAtMostOnePublicClass().as('files should have at most one public class');
  }

  /// Requires same-package imports to use relative URIs, including every
  /// conditional branch and targets excluded from the imported source set.
  ///
  /// Other package imports and SDK imports are accepted. This is a style check;
  /// use [preferRelativeUris] to also validate URI syntax and package boundaries.
  HeimdallRule<HeimdallSourceFile> preferRelativeImports({
    String pathPattern = '**',
  }) => Heimdall.files().that().resideInPath(pathPattern).should().satisfy(_preferRelativeImports()).as('files should prefer relative imports');

  /// Rejects relative import targets, regardless of package ownership.
  ///
  /// Checks every conditional branch without requiring imported targets.
  /// Uses the same check as [FileImportStyleShouldRules.notUseRelativeImports].
  /// Other URI schemes are accepted; this does not restrict imports to
  /// `package:` and `dart:`. Use [preferPackageUris] for the complete URI policy.
  HeimdallRule<HeimdallSourceFile> preferPackageImports({
    String pathPattern = '**',
  }) => Heimdall.files()
      .that()
      .resideInPath(pathPattern)
      .should()
      .satisfy(fileShouldNotUseRelativeImports(description: 'prefer package imports', message: (uri) => 'Use package import instead of $uri'))
      .as('files should prefer package imports');

  /// Requires relative same-package imports/exports and `package:` external ones.
  ///
  /// SDK URIs are accepted for imports/exports. Parts and URI-based part-ofs
  /// must be relative and stay in the same package; named part-ofs are accepted.
  /// Checks URI syntax and every conditional branch without reading files.
  /// Uses the checked project's package metadata. Import each package separately.
  HeimdallRule<HeimdallSourceFile> preferRelativeUris({
    String pathPattern = '**',
  }) => Heimdall.files().that().resideInPath(pathPattern).should().satisfy(_preferRelativeUris()).as('files should prefer relative URIs');

  /// Requires imports/exports to use `package:` or SDK URIs.
  ///
  /// Parts and URI-based part-ofs must remain relative within the same package;
  /// named part-ofs are accepted. Checks syntax and every conditional branch.
  /// Uses the checked project's package metadata. Import each package separately.
  /// Rules use imported metadata only and do not read or create files.
  HeimdallRule<HeimdallSourceFile> preferPackageUris({
    String pathPattern = '**',
  }) => Heimdall.files().that().resideInPath(pathPattern).should().satisfy(_preferPackageUris()).as('files should prefer package URIs');

  HeimdallCondition<HeimdallSourceFile> _preferRelativeImports() {
    return HeimdallCondition('prefer relative imports', (file, project) {
      final ownPackagePrefix = project.packageName == null ? null : 'package:${project.packageName}/';
      final findings = [
        if (ownPackagePrefix != null)
          for (final directive in file.packageImports)
            for (final target in directive.targetUris)
              if (target.startsWith(ownPackagePrefix))
                HeimdallValidationInfo(
                  filePath: file.absolutePath,
                  line: directive.line,
                  message: 'Use relative import instead of $target',
                ),
      ];
      return HeimdallFindings(subject: file, passed: findings.isEmpty, findings: findings);
    });
  }

  /// Requires relative internal URIs using cached source-file metadata.
  HeimdallCondition<HeimdallSourceFile> _preferRelativeUris() {
    return HeimdallCondition('prefer relative URIs', (file, project) {
      final findings = <HeimdallValidationInfo>[];
      for (final reference in file.sourceUris) {
        final uri = reference.uri;
        final allowed =
            reference.isValid &&
            switch (uri!.scheme) {
              'dart' => !reference.isPart,
              'package' => !reference.isPart && project.packageName != null && uri.pathSegments.first != project.packageName,
              '' => reference.relativeDestination!.toString().startsWith(project.packageRootUri.toString()),
              _ => false,
            };
        if (!allowed) {
          findings.add(
            HeimdallValidationInfo(
              filePath: file.absolutePath,
              line: reference.directive.line,
              message: 'URI policy: invalid ${reference.directive.runtimeType} URI ${reference.target}',
            ),
          );
        }
      }
      return HeimdallFindings(subject: file, passed: findings.isEmpty, findings: findings);
    });
  }

  /// Requires package URIs for imports/exports while keeping parts relative.
  HeimdallCondition<HeimdallSourceFile> _preferPackageUris() {
    return HeimdallCondition('prefer package URIs', (file, project) {
      final findings = <HeimdallValidationInfo>[];
      for (final reference in file.sourceUris) {
        final uri = reference.uri;
        final allowed =
            reference.isValid &&
            switch (uri!.scheme) {
              'dart' => !reference.isPart,
              'package' => !reference.isPart && project.packageName != null,
              '' => reference.isPart && reference.relativeDestination!.toString().startsWith(project.packageRootUri.toString()),
              _ => false,
            };
        if (!allowed) {
          findings.add(
            HeimdallValidationInfo(
              filePath: file.absolutePath,
              line: reference.directive.line,
              message: 'URI policy: invalid ${reference.directive.runtimeType} URI ${reference.target}',
            ),
          );
        }
      }
      return HeimdallFindings(subject: file, passed: findings.isEmpty, findings: findings);
    });
  }

  /// Ensures a single public class has a file name matching its class name.
  HeimdallRule<HeimdallSourceFile> publicClassNameShouldMatchFileName({
    String pathPattern = '**',
  }) {
    return Heimdall.files()
        .that()
        .resideInPath(pathPattern)
        .should()
        .havePublicClassNameMatchingFileName()
        .as('public class name should match file name');
  }

  /// Ensures imported files do not use `part of`.
  HeimdallRule<HeimdallSourceFile> shouldNotUsePartOf() {
    return HeimdallRule(
      descriptionPrefix: 'code',
      selector: (project) => project.files,
      predicate: const HeimdallPredicate('all files', _allFiles),
      condition: HeimdallCondition('not use part of', (item, _) {
        final findings = item.partOfDirectives
            .map(
              (directive) => HeimdallValidationInfo(
                filePath: item.absolutePath,
                line: directive.line,
                message: 'uses part of',
              ),
            )
            .toList();
        return HeimdallFindings(
          subject: item,
          passed: findings.isEmpty,
          findings: findings,
        );
      }),
    );
  }

  /// Ensures barrel files export only targets matching allowed patterns.
  HeimdallRule<HeimdallSourceFile> barrelFilesShouldOnlyExport({
    String barrelPattern = 'index.dart',
    List<String> allowedExportPatterns = const ['**/*.dart'],
  }) {
    return HeimdallRule(
      descriptionPrefix: 'barrel files',
      selector: (project) => project.files,
      predicate: HeimdallPredicate(
        'barrel files matching $barrelPattern',
        (item, _) => pathMatches(item.relativePath, barrelPattern),
      ),
      condition: HeimdallCondition('only export allowed targets', (item, _) {
        final findings = [
          for (final directive in item.exportDirectives)
            for (final target in directive.targetUris)
              if (!allowedExportPatterns.any(
                (pattern) => pathMatches(target, pattern),
              ))
                HeimdallValidationInfo(
                  filePath: item.absolutePath,
                  line: directive.line,
                  message: 'exports forbidden $target',
                ),
        ];
        return HeimdallFindings(
          subject: item,
          passed: findings.isEmpty,
          findings: findings,
        );
      }),
    );
  }
}

HeimdallRule<HeimdallSourceFile> _emptyPathRule(
  String pathPattern, {
  required String description,
}) {
  final normalizedPattern = normalizePath(pathPattern);
  final childPattern = normalizedPattern.endsWith('/') ? '$normalizedPattern**' : '$normalizedPattern/**';
  return HeimdallRule(
    customDescription: description,
    failOnEmptySelection: false,
    selector: (project) => project.files,
    predicate: HeimdallPredicate(
      'reside in path $pathPattern',
      (item, _) => pathMatches(item.relativePath, normalizedPattern) || pathMatches(item.relativePath, childPattern),
    ),
    condition: HeimdallCondition('not exist', (item, _) {
      final findings = [
        HeimdallValidationInfo(
          filePath: item.absolutePath,
          message: 'should not exist',
        ),
      ];
      return HeimdallFindings(
        subject: item,
        passed: false,
        findings: findings,
      );
    }),
  );
}

bool _allFiles(HeimdallSourceFile _, HeimdallProject project) => true;
