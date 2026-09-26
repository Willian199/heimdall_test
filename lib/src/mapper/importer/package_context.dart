import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

/// Package metadata needed while importing a Dart source tree.
final class ImportPackageContext {
  /// Creates package context from already resolved metadata.
  const ImportPackageContext({
    required this.rootPath,
    required this.packageRootPath,
    required this.packageName,
    required this.featureSet,
  });

  /// Resolves package metadata for the normalized import [rootPath].
  factory ImportPackageContext.resolve(String rootPath) {
    final packageRootPath = _findPackageRoot(rootPath) ?? rootPath;
    final pubspec = _readPubspecYaml(packageRootPath);
    return ImportPackageContext(
      rootPath: rootPath,
      packageRootPath: packageRootPath,
      packageName: _readPackageName(pubspec),
      featureSet: _readFeatureSet(pubspec),
    );
  }

  /// Normalized root path passed to the importer.
  final String rootPath;

  /// Package root path containing `pubspec.yaml`, or [rootPath] when absent.
  final String packageRootPath;

  /// Package name from `pubspec.yaml`, when available.
  final String? packageName;

  /// Analyzer language feature set selected from the package SDK constraint.
  final FeatureSet featureSet;
}

String? _readPackageName(YamlMap? pubspec) {
  final name = pubspec == null ? null : _yamlMapValue(pubspec, 'name');
  return name is YamlScalar && name.value is String ? name.value as String : null;
}

FeatureSet _readFeatureSet(YamlMap? pubspec) {
  final environment = pubspec == null ? null : _yamlMapValue(pubspec, 'environment');
  final sdkNode = environment is YamlMap ? _yamlMapValue(environment, 'sdk') : null;
  final sdkConstraint = sdkNode is YamlScalar && sdkNode.value is String ? sdkNode.value as String : null;
  if (sdkConstraint == null) {
    return FeatureSet.latestLanguageVersion();
  }

  try {
    final constraint = VersionConstraint.parse(sdkConstraint);
    if (constraint is VersionRange && constraint.min != null) {
      return FeatureSet.fromEnableFlags2(
        sdkLanguageVersion: constraint.min!,
        flags: const [],
      );
    }
  } on FormatException {
    return FeatureSet.latestLanguageVersion();
  }
  return FeatureSet.latestLanguageVersion();
}

YamlMap? _readPubspecYaml(String root) {
  final pubspec = File(p.join(root, 'pubspec.yaml'));
  if (!pubspec.existsSync()) {
    return null;
  }
  final yaml = loadYamlNode(pubspec.readAsStringSync());
  return yaml is YamlMap ? yaml : null;
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

String? _findPackageRoot(String path) {
  var current = Directory(path);
  if (FileSystemEntity.isFileSync(current.path)) {
    current = current.parent;
  }
  while (current.parent.path != current.path) {
    if (File(p.join(current.path, 'pubspec.yaml')).existsSync()) {
      return p.normalize(current.path);
    }
    current = current.parent;
  }
  if (File(p.join(current.path, 'pubspec.yaml')).existsSync()) {
    return p.normalize(current.path);
  }
  return null;
}
