import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  final project = const HeimdallFileImporter(useCache: false).importPath(
    'test/executable_fixtures/static_method_constructor',
  );

  test('a primary extension type constructor is a constructor call', () {
    expect(project.parseErrors, isEmpty);

    final report = Heimdall.methods()
        .that()
        .haveName('createExtension')
        .should()
        .callConstructorWithArguments('ProductId', positionalArguments: ['1'])
        .check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });
}
