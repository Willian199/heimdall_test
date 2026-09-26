import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  final project = const HeimdallFileImporter(useCache: false).importPath(
    'test/executable_fixtures/static_method_constructor',
  );

  test('fixture parses and detects a real named constructor call', () {
    expect(project.parseErrors, isEmpty);

    final report = Heimdall.methods()
        .that()
        .haveName('create')
        .should()
        .callConstructorWithArguments(
          'Product',
          constructorName: 'named',
          positionalArguments: ['1'],
        )
        .check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('a static method call is not a named constructor call', () {
    final report = Heimdall.methods()
        .that()
        .haveName('onlyStatic')
        .should()
        .notCallConstructorWithArguments(
          'Product',
          constructorName: 'staticCall',
          positionalArguments: ['1'],
        )
        .check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });
}
