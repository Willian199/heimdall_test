import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  final project = const HeimdallFileImporter(useCache: false).importPath(
    'test/architecture_fixtures/shadowed_import',
  );
  final domainUser = HeimdallPredicate<CompilationUnitMember>(
    'are the domain User',
    (item, _) => item.name == 'User' && item.relativePath.contains('/domain/'),
  );

  test('fixture parses and a prefixed reference depends on the imported User', () {
    expect(project.parseErrors, isEmpty);

    final report = Heimdall.classes().that().haveTypeName('ImportedUserConsumer').should().notDependOnClassesThat(domainUser).check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, hasLength(1));
  });

  test('a local User shadows the unused imported User', () {
    final report = Heimdall.classes().that().haveTypeName('LocalUserConsumer').should().notDependOnClassesThat(domainUser).check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });
}
