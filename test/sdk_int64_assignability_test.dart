import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('64-bit typed data lists are assignable to List<int>', () {
    final project = const HeimdallFileImporter(useCache: false).importPath(
      'test/sdk_int64_assignability_fixtures/lib',
    );

    final report = Heimdall.fields()
        .that()
        .haveNameMatching(RegExp(r'Values$'))
        .should()
        .haveDeclaredFieldTypeAssignableTo('List<int>')
        .check(project);

    expect(report.checkedCount, 2);
    expect(report.findings, isEmpty);
  });
}
