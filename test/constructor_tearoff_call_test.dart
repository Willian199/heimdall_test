import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('invoking a stored constructor tear-off counts as a constructor call', () {
    final project = const HeimdallFileImporter(useCache: false).importPath(
      'test/constructor_tearoff_call_fixtures/lib',
    );
    expect(project.parseErrors, isEmpty);

    final report = Heimdall.methods().that().haveName('throughTearOff').should().callConstructor('Product').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);

    for (final name in ['unusedTearOff', 'ordinaryCallback', 'shadowedCallback']) {
      Heimdall.methods().that().haveName(name).should().notCallConstructor('Product').check(project).assertNoFindings();
    }
  });
}
