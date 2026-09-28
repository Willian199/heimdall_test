import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('Never? is assignable to nullable types because it represents Null', () {
    final project = const HeimdallFileImporter(useCache: false).importPath(
      'test/never_nullable_assignability_fixtures/lib',
    );
    expect(project.parseErrors, isEmpty);

    final report = Heimdall.fields().that().haveName('value').should().haveDeclaredFieldTypeAssignableTo('String?').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });
}
