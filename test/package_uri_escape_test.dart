import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('percent-encoded package traversal is not resolved outside package lib', () {
    final project = const HeimdallFileImporter(useCache: false).importPath('test/package_uri_escape_fixtures');
    final consumer = project.fileByRelativePath('lib/consumer.dart')!;
    final dependency = consumer.importDirectives.single;

    expect(project.parseErrors, isEmpty);
    expect(project.packageName, 'package_uri_escape_fixture');
    expect(consumer.sourceUris.single.isValid, isFalse);
    expect(dependency.targetFiles, isEmpty);
    expect(consumer.externalImports, contains(dependency));
  });
}
