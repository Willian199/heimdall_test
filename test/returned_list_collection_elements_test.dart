import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  late HeimdallProject project;

  setUpAll(() {
    project = const HeimdallFileImporter(useCache: false).importPath(
      'test/member_fixtures/returned_list_elements',
    );
    expect(project.parseErrors, isEmpty);
  });

  for (final className in [
    'CollectionIfProps',
    'CollectionIfElseProps',
    'CollectionForProps',
    'SwitchExpressionProps',
  ]) {
    test('$className includes its field in the returned list', () {
      final report = Heimdall.fields()
          .that()
          .areDeclaredInClassesThat(
            HeimdallPredicate('belong to $className', (item, _) => item.name == className),
          )
          .and()
          .haveName('value')
          .should()
          .beIncludedInReturnedListOf('props')
          .check(project);

      expect(report.checkedCount, 1);
      expect(report.findings, isEmpty);
    });

    test('$className requires unconditional inclusion in every returned list', () {
      final report = Heimdall.fields()
          .that()
          .areDeclaredInClassesThat(
            HeimdallPredicate('belong to $className', (item, _) => item.name == className),
          )
          .and()
          .haveName('value')
          .should()
          .beIncludedInEveryReturnedListOf('props')
          .check(project);

      expect(report.checkedCount, 1);
      // A collection-if without else and a loop do not establish that an
      // element exists. This analysis does not execute conditions or loops.
      final guaranteed = className == 'CollectionIfElseProps' || className == 'SwitchExpressionProps';
      expect(report.findings, guaranteed ? isEmpty : hasLength(1));
    });
  }
}
