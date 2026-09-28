import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('a relative URI with a colon after the first path segment is classified as relative', () {
    final project = const HeimdallFileImporter(useCache: false).importPath('test/relative_colon_uri_fixtures');
    final file = project.fileByRelativePath('lib/consumer.dart')!;

    expect(file.sourceUris.single.isValid, isTrue);
    expect(file.relativeImports, contains(file.importDirectives.single));
  });

  test('preferPackageImports rejects a relative URI with a colon in a later segment', () {
    final project = const HeimdallFileImporter(useCache: false).importPath('test/relative_colon_uri_fixtures');
    final file = project.fileByRelativePath('lib/consumer.dart')!;
    final report = Heimdall.code().preferPackageImports(pathPattern: file.relativePath).check(project);

    expect(report.findings, hasLength(1));
  });
}
