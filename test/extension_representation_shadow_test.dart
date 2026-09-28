import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('extension type representation names shadow static type receivers', () {
    final project = const HeimdallFileImporter(useCache: false).importPath(
      'test/extension_representation_shadow_fixtures/lib',
    );
    expect(project.files.single.parseErrors, isEmpty);

    final report = Heimdall.methods().that().haveName('call').should().notCallStaticMethod('Tools', 'go').check(project);

    expect(report.findings, isEmpty);
  });
}
