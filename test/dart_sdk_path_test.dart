import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/mapper/importer/dart_sdk_path.dart';
import 'package:test/test.dart';

void main() {
  final root = const HeimdallFileImporter(useCache: false).importPath('test/importer_fixtures/sdk_paths').rootPath.replaceAll(r'\', '/');
  String resolve(String executable, {String? sdkPath}) => resolveDartSdkPath(executable, sdkPath: sdkPath).replaceAll(r'\', '/');

  test('locates a standalone Dart SDK from its executable', () {
    final expected = '$root/standalone';
    expect(resolve('$expected/bin/dart'), expected);
  });

  for (final platform in ['linux-x64', 'windows-x64', 'darwin-arm64']) {
    test('locates the bundled SDK from a Flutter $platform test executable', () {
      final cache = '$root/flutter/bin/cache';
      final expected = '$cache/dart-sdk';
      final engine = '$cache/artifacts/engine';
      // A lib/ directory alone must not make engine artifacts look like an SDK.
      final binary = platform == 'windows-x64' ? 'flutter_tester.exe' : 'flutter_tester';
      expect(resolve('$engine/$platform/$binary'), expected);
    });
  }

  test('accepts the legacy SDK library metadata location', () {
    final expected = '$root/legacy';
    expect(resolve('$expected/bin/dart'), expected);
  });

  test('an explicit SDK takes precedence over the runtime SDK', () {
    final explicit = '$root/explicit';
    expect(resolve('$root/standalone/bin/dart', sdkPath: explicit), explicit);
  });

  test('rejects an invalid explicit SDK without silently choosing another', () {
    expect(() => resolve('$root/standalone/bin/dart', sdkPath: '$root/invalid'), throwsArgumentError);
  });

  test('a missing SDK reports how to configure one', () {
    expect(
      () => resolve('$root/unknown/runner'),
      throwsA(isA<StateError>().having((error) => error.message, 'message', contains('ReferenceImportOptions(sdkPath: ...)'))),
    );
  });
}
