import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('an extension type parameter is assignable to its declared bound', () {
    final project = const HeimdallFileImporter(useCache: false).importPath(
      'test/extension_type_parameter_bound_fixtures/lib',
    );
    expect(project.parseErrors, isEmpty);

    final report = Heimdall.methods().that().haveName('accepts').should().receiveParameterAssignableTo('num').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });
}
