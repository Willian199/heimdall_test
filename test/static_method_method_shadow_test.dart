import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  late HeimdallProject project;
  setUpAll(() {
    project = const HeimdallFileImporter(useCache: false).importPath(
      'test/executable_fixtures/static_method_method_shadow',
    );
    expect(project.parseErrors, isEmpty);
  });

  for (final methodName in [
    'callMethodTearoff',
    'callLocalFunctionTearoff',
    'callInheritedMethodTearoff',
    'callSwitchExpressionTearoff',
    'callCollectionIfTearoff',
    'callCollectionForTearoff',
  ]) {
    test('$methodName is not a static type receiver', () {
      final report = Heimdall.methods().that().haveName(methodName).should().notCallStaticMethod('Tools', 'run').check(project);

      expect(report.checkedCount, 1);
      expect(report.findings, isEmpty);
    });
  }

  test('file rules do not classify function tear-offs as static method calls', () {
    final report = Heimdall.files().that().resideInPath('lib/calls.dart').should().notCallStaticMethod('Tools', 'run').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });
}
