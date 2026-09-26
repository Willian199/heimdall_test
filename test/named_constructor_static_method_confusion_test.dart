import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  final project = const HeimdallFileImporter(useCache: false).importPath(
    'test/executable_fixtures/static_method_constructor',
  );

  test('the fixture parses and a real static method is recognized', () {
    expect(project.parseErrors, isEmpty);

    final report = Heimdall.methods().that().haveName('onlyStatic').should().callStaticMethod('Product', 'staticCall').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('a named constructor is not a static method call', () {
    final report = Heimdall.methods().that().haveName('create').should().notCallStaticMethod('Product', 'named').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('file-level static method rules also ignore named constructors', () {
    final report = Heimdall.files().that().resideInPath('lib/calls.dart').should().notCallStaticMethod('Product', 'named').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('a factory constructor is not a static method call', () {
    final memberReport = Heimdall.methods().that().haveName('createFactory').should().notCallStaticMethod('FactoryProduct', 'named').check(project);
    final fileReport = Heimdall.files()
        .that()
        .resideInPath('lib/factory_calls.dart')
        .should()
        .notCallStaticMethod('FactoryProduct', 'named')
        .check(project);

    expect(memberReport.checkedCount, 1);
    expect(memberReport.findings, isEmpty);
    expect(fileReport.checkedCount, 1);
    expect(fileReport.findings, isEmpty);
  });
}
