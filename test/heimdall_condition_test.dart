import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  group('HeimdallCondition', () {
    final project = const HeimdallFileImporter(useCache: false).importPath('test/importer_fixtures/basic_project');
    final sourceFile = project.fileByRelativePath('lib/src/domain/user.dart')!;

    test('uses findings from condition results directly', () {
      final condition = HeimdallCondition<int>('be even', (item, _) {
        return HeimdallFindings(
          subject: item,
          passed: false,
          findings: const [
            HeimdallValidationInfo(message: 'custom even failure'),
          ],
        );
      });

      final findings = condition.check(3, project);

      expect(findings, hasLength(1));
      expect(findings.single.message, 'custom even failure');
    });

    test('DSL noneOf reports each child condition that passed', () {
      final result = Heimdall.files()
          .that()
          .resideInPath(sourceFile.relativePath)
          .should()
          .containNoSource([
            'class User',
            'missing snippet',
          ])
          .check(project);

      expect(result.findings, hasLength(1));
      expect(
        result.findings.single.message,
        'should not contain source "class User"',
      );
      expect(result.findings.single.filePath, sourceFile.absolutePath);
    });

    test('DSL not reports a violation when the wrapped condition passed', () {
      final result = Heimdall.files().that().resideInPath(sourceFile.relativePath).should().not().containSource('class User').check(project);

      expect(result.findings, hasLength(1));
      expect(
        result.findings.single.message,
        'should not contain source "class User"',
      );
      expect(result.findings.single.filePath, sourceFile.absolutePath);
    });

    test(
      'DSL class not reports a violation when the class condition passed',
      () {
        final classProject = const HeimdallFileImporter(
          useCache: false,
        ).importPath('test/importer_fixtures/basic_project');

        final result = Heimdall.classes().that().haveTypeName('User').should().not().bePublic().check(classProject);

        expect(result.checkedCount, 1);
        expect(result.findings, hasLength(1));
        expect(result.findings.single.message, 'should not be public');
        expect(
          result.findings.single.filePath?.replaceAll(r'\', '/'),
          endsWith('lib/src/domain/user.dart'),
        );
      },
    );
  });
}
