import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  const fixture = 'test/importer_fixtures/nested_test_directory';

  test('the fixture contains both library and test files', () {
    final project = const HeimdallFileImporter(
      importOptions: [IncludeAllImportOption()],
      useCache: false,
    ).importPath(fixture);

    expect(
      project.files.map((file) => file.relativePath),
      orderedEquals(['lib/src/keep.dart', 'test/skip_test.dart']),
    );
  });

  test('excluding tests keeps library files when the package is nested under test', () {
    final project = const HeimdallFileImporter(
      importOptions: [ExcludeTestsImportOption()],
      useCache: false,
    ).importPath(fixture);

    expect(
      project.files.map((file) => file.relativePath),
      orderedEquals(['lib/src/keep.dart']),
    );
  });
}
