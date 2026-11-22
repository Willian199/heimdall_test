import 'dart:io';

import 'package:path/path.dart' as p;

/// Finds the source SDK for Dart and Flutter test executables.
///
/// The analyzer assumes the executable is `<sdk>/bin/dart`. Flutter tests run
/// inside `<flutter>/bin/cache/artifacts/engine/<platform>/flutter_tester`,
/// whose SDK is instead `<flutter>/bin/cache/dart-sdk`.
String resolveDartSdkPath(String executable, {String? sdkPath}) {
  if (sdkPath != null) {
    if (!_isDartSdk(sdkPath)) {
      throw ArgumentError.value(sdkPath, 'sdkPath', 'Expected a Dart SDK directory containing library metadata');
    }
    return p.normalize(p.absolute(sdkPath));
  }

  var directory = p.dirname(p.absolute(executable));
  while (true) {
    for (final candidate in [directory, p.join(directory, 'dart-sdk')]) {
      if (_isDartSdk(candidate)) {
        return p.normalize(candidate);
      }
    }
    final parent = p.dirname(directory);
    if (parent == directory) {
      break;
    }
    directory = parent;
  }
  throw StateError('Unable to locate the Dart SDK from $executable. Set ReferenceImportOptions(sdkPath: ...) to its source SDK directory.');
}

bool _isDartSdk(String directory) {
  final internal = p.join(directory, 'lib', '_internal');
  return File(p.join(internal, 'allowed_experiments.json')).existsSync() &&
      (File(p.join(internal, 'sdk_library_metadata', 'lib', 'libraries.dart')).existsSync() || File(p.join(internal, 'libraries.dart')).existsSync());
}
