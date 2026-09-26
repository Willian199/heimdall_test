import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  late HeimdallProject project;

  setUpAll(() {
    project = const HeimdallFileImporter(useCache: false).importPath(
      'test/member_fixtures/if_case_else_field',
    );
    expect(project.parseErrors, isEmpty);
  });

  test('a pattern variable in the then branch does not shadow the field in else', () {
    final report = Heimdall.fields()
        .that()
        .areDeclaredInClassesThat(
          HeimdallPredicate('belong to IfCaseElseReader', (item, _) => item.name == 'IfCaseElseReader'),
        )
        .and()
        .haveName('value')
        .should()
        .beIncludedInReturnedListOf('props')
        .check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });
}
