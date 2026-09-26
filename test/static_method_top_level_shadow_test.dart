import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  late HeimdallProject project;

  setUpAll(() {
    project = const HeimdallFileImporter(useCache: false).importPath(
      'test/executable_fixtures/static_method_top_level_shadow',
    );
    expect(project.parseErrors, isEmpty);
  });

  test('a top-level function tear-off is not a static type receiver', () {
    final report = Heimdall.methods().that().haveName('callFunctionTearoff').should().notCallStaticMethod('Tools', 'run').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('a top-level getter tear-off is not a static type receiver', () {
    final report = Heimdall.methods().that().haveName('callGetterTearoff').should().notCallStaticMethod('Tools', 'run').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('file rules do not treat a top-level function tear-off as a static receiver', () {
    final report = Heimdall.files().that().resideInPath('lib/calls.dart').should().notCallStaticMethod('Tools', 'run').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('file rules do not treat a top-level getter tear-off as a static receiver', () {
    final report = Heimdall.files().that().resideInPath('lib/getter_calls.dart').should().notCallStaticMethod('Tools', 'run').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });
}
