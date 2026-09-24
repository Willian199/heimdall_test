import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  final project = const HeimdallFileImporter(useCache: false).importPath(
    'test/architecture_fixtures/annotation_value_shadowing',
  );
  final importedUser = HeimdallPredicate<CompilationUnitMember>(
    'are the imported User',
    (item, _) => item.name == 'User' && item.relativePath.contains('/domain/'),
  );

  HeimdallReport reportFor(String className) =>
      Heimdall.classes().that().haveTypeName(className).should().notDependOnClassesThat(importedUser).check(project);

  test('the fixture parses and a prefixed annotation references imported User', () {
    expect(project.parseErrors, isEmpty);
    expect(reportFor('ImportedAnnotationConsumer').findings, hasLength(1));
  });

  test('a local annotation constant does not depend on imported User', () {
    final report = reportFor('LocalAnnotationConsumer');

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });
}
