import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  final project = const HeimdallFileImporter(useCache: false).importPath(
    'test/architecture_fixtures/private_part_inheritance',
  );

  HeimdallReport rootAncestorReport(String className) =>
      Heimdall.classes().that().haveTypeName(className).and().areAssignableTo('Root').should().haveTypeName(className).check(project);

  test('fixture parses and a public base in a part resolves', () {
    expect(project.parseErrors, isEmpty);

    final report = rootAncestorReport('PublicChild');
    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('a private base in a part is visible to its owning library', () {
    final report = rootAncestorReport('PrivateChild');
    final owner = project.fileByRelativePath('lib/src/owner.dart')!;

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
    expect(project.exportedTypeDeclarationsOf(owner).map((declaration) => declaration.name), isNot(contains('_PrivateBase')));
  });
}
