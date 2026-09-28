import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('a finally return replaces the earlier try return in every-return analysis', () {
    final project = const HeimdallFileImporter(useCache: false).importPath(
      'test/finally_returned_list_fixtures/lib',
    );
    expect(project.files.single.parseErrors, isEmpty);

    final report = Heimdall.fields().that().haveName('value').should().beIncludedInEveryReturnedListOf('props').check(project);

    expect(report.findings, isEmpty);
  });
}
