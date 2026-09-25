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

  test('a named extension type constructor is not a static method call', () {
    final report = Heimdall.methods().that().haveName('parseExtension').should().notCallStaticMethod('ProductId', 'parse').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('file-level static rules ignore named extension type constructors', () {
    final report = Heimdall.files()
        .that()
        .resideInPath('lib/extension_type_calls.dart')
        .should()
        .notCallStaticMethod('ProductId', 'parse')
        .check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });
}
