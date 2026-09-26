import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  final project = const HeimdallFileImporter(useCache: false).importPath(
    'test/executable_fixtures/static_receiver_shadowing',
  );

  test('the fixture parses and a static call is recognized', () {
    expect(project.parseErrors, isEmpty);

    final report = Heimdall.methods().that().haveName('callStatic').should().callStaticMethod('Tools', 'run').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('an instance parameter named Tools is not the Tools class', () {
    final memberReport = Heimdall.methods().that().haveName('callInstance').should().notCallStaticMethod('Tools', 'run').check(project);
    final fileReport = Heimdall.files().that().resideInPath('lib/instance_calls.dart').should().notCallStaticMethod('Tools', 'run').check(project);

    expect(memberReport.checkedCount, 1);
    expect(memberReport.findings, isEmpty);
    expect(fileReport.checkedCount, 1);
    expect(fileReport.findings, isEmpty);
  });

  test('a local variable or field named Tools is not the Tools class', () {
    for (final methodName in ['callLocal', 'callField']) {
      final report = Heimdall.methods().that().haveName(methodName).should().notCallStaticMethod('Tools', 'run').check(project);

      expect(report.checkedCount, 1, reason: methodName);
      expect(report.findings, isEmpty, reason: methodName);
    }
  });
}
