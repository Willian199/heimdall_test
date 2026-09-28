import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('assignability by type-name suffix includes a mixin on constraint', () {
    final project = const HeimdallFileImporter(useCache: false).importPath(
      'test/mixin_constraint_name_fixtures/lib',
    );
    expect(project.files.single.parseErrors, isEmpty);

    final report = Heimdall.classes().that().haveTypeName('Adapter').should().beAssignableToTypeNameEndingWith('Host').check(project);

    expect(report.findings, isEmpty);
  });
}
