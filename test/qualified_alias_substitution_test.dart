import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('substituting an unused alias type parameter preserves a prefixed type', () {
    final project = const HeimdallFileImporter(useCache: false).importPath(
      'test/qualified_alias_substitution_fixtures/lib',
    );
    expect(project.parseErrors, isEmpty);

    final report = Heimdall.fields().that().haveName('value').should().haveDeclaredFieldTypeAssignableTo('types.Value').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });
}
