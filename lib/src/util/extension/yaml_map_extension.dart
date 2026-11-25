import 'package:yaml/yaml.dart';

/// Shared queries for [YamlMap] nodes.
extension YamlMapExtension on YamlMap {
  /// The value node associated with [key], or `null` when absent.
  YamlNode? valueForKey(String key) {
    for (final entry in nodes.entries) {
      final keyNode = entry.key;
      if (keyNode is YamlScalar && keyNode.value == key) {
        return entry.value;
      }
    }
    return null;
  }
}
