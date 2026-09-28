import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('a named extension declaration is not an assignable runtime type', () {
    final project = const HeimdallFileImporter(useCache: false).importPath(
      'test/extension_assignability_fixtures/lib',
    );
    expect(project.parseErrors, isEmpty);

    final report = Heimdall.classes().that().haveTypeName('Display').should().notBeAssignableTo('Object').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });
}
