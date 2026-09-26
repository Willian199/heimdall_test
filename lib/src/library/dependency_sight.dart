import 'dart:io';

import 'package:heimdall_test/heimdall_test.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Built-in rules for dependency and import constraints.
final class HeimdallDependencySight {
  /// Creates the built-in dependency sight rule provider.
  const HeimdallDependencySight();

  /// Ensures files do not import paths through `../`.
  HeimdallRule<HeimdallSourceFile> noFilesShouldDependOnUpperDirectories() {
    return Heimdall.files()
        .should()
        .satisfy(
          HeimdallCondition('not depend on upper directories', (item, project) {
            final findings = item.relativeUpwardImports
                .map(
                  (dependency) => HeimdallValidationInfo(
                    filePath: item.absolutePath,
                    line: dependency.line,
                    message: '${item.relativePath} imports ${dependency.targetUri}',
                  ),
                )
                .toList();
            return HeimdallFindings(
              subject: item,
              passed: findings.isEmpty,
              findings: findings,
            );
          }),
        )
        .as('no files should depend on upper directories');
  }

  /// Ensures files do not import another package's private `src` API.
  HeimdallRule<HeimdallSourceFile> noFilesShouldImportPackageSrc(
    String packageName,
  ) {
    return Heimdall.files()
        .should()
        .satisfy(
          HeimdallCondition('not import package:$packageName/src', (
            item,
            project,
          ) {
            final findings = [
              for (final dependency in item.packageImports)
                for (final uri in dependency.targetUris)
                  if (uri.startsWith('package:$packageName/src/'))
                    HeimdallValidationInfo(
                      filePath: item.absolutePath,
                      line: dependency.line,
                      message: '${item.relativePath} imports internal package source $uri',
                    ),
            ];
            return HeimdallFindings(
              subject: item,
              passed: findings.isEmpty,
              findings: findings,
            );
          }),
        )
        .as('no files should import package:$packageName/src');
  }

  /// Ensures feature slices do not import other feature slices.
  ///
  /// Default patterns use package-relative paths, regardless of the import
  /// root. An explicit [featurePattern] uses paths relative to the import root.
  HeimdallRule<HeimdallSourceFile> featuresShouldNotDependOnEachOther({
    String? featurePattern,
    Iterable<String> sharedSlices = const [],
  }) {
    final featurePatterns = featurePattern == null ? const ['lib/features/(*)', 'lib/src/features/(*)'] : [featurePattern];
    final sharedSliceSet = sharedSlices.map(normalizePath).toSet();
    return HeimdallRule(
      descriptionPrefix: 'features',
      selector: (project) => project.files,
      predicate: const HeimdallPredicate('all files', _allFiles),
      condition: HeimdallCondition('not depend on each other', (
        item,
        project,
      ) {
        final findings = <HeimdallValidationInfo>[];
        String featurePath(HeimdallSourceFile file) =>
            featurePattern == null ? p.relative(file.absolutePath, from: project.packageRootPath) : file.relativePath;
        final ownFeature = _captureFeature(featurePath(item), featurePatterns);
        if (ownFeature != null) {
          for (final dependency in item.resolvedDependencies) {
            for (final targetFile in dependency.targetFiles) {
              final targetFeature = _captureFeature(
                featurePath(targetFile),
                featurePatterns,
              );
              if (targetFeature == null || targetFeature == ownFeature || sharedSliceSet.contains(normalizePath(targetFeature))) {
                continue;
              }
              findings.add(
                HeimdallValidationInfo(
                  filePath: item.absolutePath,
                  line: dependency.line,
                  message: '${item.relativePath} in feature $ownFeature imports feature $targetFeature',
                ),
              );
            }
          }
        }
        return HeimdallFindings(
          subject: item,
          passed: findings.isEmpty,
          findings: findings,
        );
      }),
    );
  }

  /// Ensures `pubspec.yaml` does not depend on [packageName].
  HeimdallRule<HeimdallProject> pubspecShouldNotDependOn(String packageName) {
    return HeimdallRule(
      descriptionPrefix: 'pubspec',
      selector: (project) => [project],
      predicate: const HeimdallPredicate('imported project', _allProjects),
      condition: HeimdallCondition('not depend on $packageName', (item, _) {
        final findings = <HeimdallValidationInfo>[];
        final pubspec = File('${item.packageRootPath}/pubspec.yaml');
        if (pubspec.existsSync()) {
          final yaml = loadYamlNode(pubspec.readAsStringSync());
          if (yaml is YamlMap) {
            const sections = [
              'dependencies',
              'dev_dependencies',
              'dependency_overrides',
            ];
            for (final section in sections) {
              final dependencies = _yamlMapValue(yaml, section);
              if (dependencies is! YamlMap) {
                continue;
              }
              final dependencyNode = _yamlMapValue(dependencies, packageName);
              if (dependencyNode == null) {
                continue;
              }
              final span = dependencyNode.span;
              findings.add(
                HeimdallValidationInfo(
                  filePath: pubspec.path,
                  line: span.start.line + 1,
                  column: span.start.column + 1,
                  message: 'pubspec $section depends on forbidden $packageName',
                ),
              );
              break;
            }
          }
        }
        return HeimdallFindings(
          subject: item,
          passed: findings.isEmpty,
          findings: findings,
        );
      }),
    );
  }
}

bool _allFiles(HeimdallSourceFile _, HeimdallProject project) => true;

bool _allProjects(HeimdallProject _, HeimdallProject project) => true;

String? _captureFeature(String path, Iterable<String> featurePatterns) {
  for (final pattern in featurePatterns) {
    final feature = captureSlicePathSegment(path, pattern);
    if (feature != null) {
      return feature;
    }
  }
  return null;
}

YamlNode? _yamlMapValue(YamlMap map, String key) {
  for (final entry in map.nodes.entries) {
    final keyNode = entry.key;
    if (keyNode is YamlScalar && keyNode.value == key) {
      return entry.value;
    }
  }
  return null;
}
