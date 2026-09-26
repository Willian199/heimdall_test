import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('unnamed extensions are not public declarations', () {
    final project = const HeimdallFileImporter(useCache: false).importPath(
      'test/class_fixtures/anonymous_extension_visibility',
    );

    expect(project.parseErrors, isEmpty);
    expect(project.extensionDeclarations, hasLength(2));
    expect(
      project.publicExtensionDeclarations.map((extension) => extension.name?.lexeme),
      orderedEquals(['PublicStringExtension']),
    );
  });
}
