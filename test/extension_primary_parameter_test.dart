import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('notReceiveParameter reports an extension type primary parameter', () {
    final project = const HeimdallFileImporter(useCache: false).importPath(
      'test/extension_primary_parameter_fixtures/lib',
    );
    expect(project.files.single.parseErrors, isEmpty);

    final report = Heimdall.classes().that().haveTypeName('UserId').should().notReceiveParameter('value').check(project);

    expect(report.findings, hasLength(1));
  });
}
