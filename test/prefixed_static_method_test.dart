import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  late HeimdallProject project;

  setUpAll(() {
    project = const HeimdallFileImporter(useCache: false).importPath(
      'test/executable_fixtures/prefixed_static_method',
    );
    expect(project.parseErrors, isEmpty);
  });

  test('recognizes constructors through a prefixed import', () {
    final report = Heimdall.methods().that().haveName('createAndCall').should().callConstructor('Product').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('recognizes static methods through a prefixed import', () {
    final report = Heimdall.methods().that().haveName('createAndCall').should().callStaticMethod('Product', 'staticCall').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('file-level static method rules recognize prefixed imports', () {
    final report = Heimdall.files().that().resideInPath('lib/calls.dart').should().callStaticMethod('Product', 'staticCall').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });
}
