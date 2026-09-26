import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  late HeimdallProject project;

  setUpAll(() {
    project = const HeimdallFileImporter(useCache: false).importPath(
      'test/member_fixtures/if_case_else_forwarding',
    );
    expect(project.parseErrors, isEmpty);
  });

  test('an if-case binding in the then branch does not shadow the parameter in else', () {
    final report = Heimdall.fields()
        .that()
        .areDeclaredInClassesThat(
          HeimdallPredicate('belong to CopyState', (item, _) => item.name == 'CopyState'),
        )
        .and()
        .haveName('count')
        .should()
        .passMatchingParameterToReturnedConstructorIn('copy')
        .check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('a switch expression forwarding the parameter in each constructor return is recognized', () {
    final report = Heimdall.fields()
        .that()
        .areDeclaredInClassesThat(
          HeimdallPredicate('belong to CopyState', (item, _) => item.name == 'CopyState'),
        )
        .and()
        .haveName('count')
        .should()
        .passMatchingParameterToReturnedConstructorIn('copyFromSwitch')
        .check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });
}
