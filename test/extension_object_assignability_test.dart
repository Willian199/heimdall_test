import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('a non-null representation alone does not make an extension type an Object subtype', () {
    final project = const HeimdallFileImporter(useCache: false).importPath(
      'test/extension_object_assignability_fixtures/lib',
    );
    expect(project.files.single.parseErrors, isEmpty);

    final report = Heimdall.classes().that().haveTypeName('UserName').should().beAssignableTo('Object').check(project);

    expect(report.findings, hasLength(1));
    Heimdall.classes().that().haveTypeName('ObjectName').should().beAssignableTo('Object').check(project).assertNoFindings();
  });
}
