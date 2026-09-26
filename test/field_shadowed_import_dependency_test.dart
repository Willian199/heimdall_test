import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  final project = const HeimdallFileImporter(useCache: false).importPath(
    'test/architecture_fixtures/field_shadowed_import',
  );
  final importedUser = HeimdallPredicate<CompilationUnitMember>(
    'are the imported User',
    (item, _) => item.name == 'User' && item.relativePath.contains('/domain/'),
  );

  HeimdallReport reportFor(String className) =>
      Heimdall.classes().that().haveTypeName(className).should().notDependOnClassesThat(importedUser).check(project);

  test('the fixture parses and a type reference depends on imported User', () {
    expect(project.parseErrors, isEmpty);
    expect(reportFor('ActualConsumer').findings, hasLength(1));
  });

  test('a field declared before the method shadows the imported class', () {
    expect(reportFor('EarlierFieldConsumer').findings, isEmpty);
  });

  test('an instance field named User does not reference the imported class', () {
    final report = reportFor('FieldShadowedConsumer');

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('a field name does not hide an imported type annotation', () {
    final report = reportFor('TypeAndFieldConsumer');

    expect(report.checkedCount, 1);
    expect(report.findings, hasLength(1));
  });
}
