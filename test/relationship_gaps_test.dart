import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  final project = const HeimdallFileImporter(useCache: false).importPath('test/relationship_gap_fixtures');
  setUpAll(() => expect(project.parseErrors, isEmpty, reason: project.parseErrors.join('\n')));

  test('extend follows generic substitutions through intermediate superclasses', () {
    final report = Heimdall.classes().that().haveTypeName('Leaf').should().extend('Root<int>').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('implement follows generic substitutions inherited through a superclass', () {
    final report = Heimdall.classes().that().haveTypeName('Leaf').should().implement('Contract<int>').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });
}
