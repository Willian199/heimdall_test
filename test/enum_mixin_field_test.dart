import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('property access includes getters supplied by an enum mixin', () {
    final project = const HeimdallFileImporter(useCache: false).importPath(
      'test/enum_mixin_field_fixtures/lib',
    );
    expect(project.files.single.parseErrors, isEmpty);

    final report = Heimdall.methods().that().haveName('readShared').should().accessField('shared').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });
}
