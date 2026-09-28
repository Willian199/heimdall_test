import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('members available through a mixin on constraint shadow static type receivers', () {
    final project = const HeimdallFileImporter(useCache: false).importPath(
      'test/mixin_on_receiver_shadow_fixtures/lib',
    );
    expect(project.files.single.parseErrors, isEmpty);

    final report = Heimdall.methods().that().haveName('call').should().notCallStaticMethod('Tools', 'run').check(project);

    expect(report.findings, isEmpty);
  });
}
