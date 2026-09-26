import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  final project = const HeimdallFileImporter(useCache: false).importPath(
    'test/architecture_fixtures/import_export_same_type',
  );

  test('an import and reexport produce one dependency for the referencing class', () {
    expect(project.parseErrors, isEmpty);

    final report = Heimdall.classes()
        .that()
        .haveTypeName('Consumer')
        .should()
        .notDependOnClassesThat(
          HeimdallPredicate<CompilationUnitMember>(
            'are User',
            (item, _) => item.name == 'User',
          ),
        )
        .check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, hasLength(1));
    expect(report.findings.single.line, 1);
  });

  test('the export still exposes User to other libraries', () {
    final consumerFile = project.fileByRelativePath('lib/src/data/consumer.dart')!;

    expect(consumerFile.typeReferenceDirectives.whereType<ExportDirective>(), hasLength(1));
    expect(
      project.exportedTypeDeclarationsOf(consumerFile).map((item) => item.name),
      contains('User'),
    );
  });
}
