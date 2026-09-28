import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('the inverse filename rule negates the vacuous match for an absent class', () {
    final project = const HeimdallFileImporter(useCache: false).importPath(
      'test/missing_named_class_fixtures/lib',
    );

    final report = Heimdall.files().that().haveName('helper.dart').should().notHavePublicClassNameMatchingFileNameFor('Missing').check(project);

    // The positive convention is documented to pass when the class is absent.
    // Its logical inverse must therefore fail; use an existence rule separately.
    expect(report.checkedCount, 1);
    expect(report.findings, hasLength(1));
    Heimdall.files().that().haveName('helper.dart').should().havePublicClassNameMatchingFileNameFor('Missing').check(project).assertNoFindings();
  });
}
