import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('writing a field through a this-cascade counts as field access', () {
    final project = const HeimdallFileImporter(useCache: false).importPath(
      'test/cascade_field_access_fixtures/lib',
    );
    expect(project.parseErrors, isEmpty);

    final report = Heimdall.methods().that().haveName('writeThroughCascade').should().accessField('value').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });
}
