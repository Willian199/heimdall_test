import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  final project = const HeimdallFileImporter(useCache: false).importPath(
    'test/executable_fixtures/static_receiver_shadowing',
  );

  test('a pattern variable does not shadow the class in the else branch', () {
    expect(project.parseErrors, isEmpty);

    final report = Heimdall.methods().that().haveName('callElse').should().callStaticMethod('Tools', 'run').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });
}
