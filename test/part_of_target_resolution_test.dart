import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('a URI-based part-of resolves to its imported library file', () {
    final project = const HeimdallFileImporter(useCache: false).importPath(
      'test/importer_fixtures/review_project/lib/parts',
    );
    final owner = project.fileByRelativePath('uri_owner.dart')!;
    final piece = project.fileByRelativePath('uri_piece.dart')!;
    final part = owner.partDirectives.single;
    final partOf = piece.partOfDirectives.single;

    expect(project.parseErrors, isEmpty);
    expect(part.targetFile, same(piece));
    expect(partOf.targetUri, 'uri_owner.dart');
    expect(partOf.targetFile, same(owner));
    expect(partOf.targetFiles, contains(owner));
  });
}
