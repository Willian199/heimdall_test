import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  final project = const HeimdallFileImporter(useCache: false).importPath(
    'test/executable_fixtures/static_receiver_shadowing',
  );

  test('a for-in variable does not shadow the class in the iterable', () {
    expect(project.parseErrors, isEmpty);

    final report = Heimdall.methods().that().haveName('callInIterable').should().callStaticMethod('Tools', 'actions').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('a for-in variable shadows the class in the body', () {
    final report = Heimdall.methods().that().haveName('callInIterable').should().notCallStaticMethod('Tools', 'run').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });
}
