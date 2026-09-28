import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('the inverse private-constructor rule counts a private extension primary constructor', () {
    final project = const HeimdallFileImporter(useCache: false).importPath(
      'test/private_extension_constructor_fixtures/lib',
    );
    expect(project.files.single.parseErrors, isEmpty);

    final report = Heimdall.classes().that().haveTypeName('Hidden').should().notHaveOnlyPrivateConstructors().check(project);

    expect(report.findings, hasLength(1));
  });
}
