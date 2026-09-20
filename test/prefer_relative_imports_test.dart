import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  group('Heimdall.code().preferRelativeImports()', () {
    late HeimdallProject project;

    setUpAll(() {
      project = const HeimdallFileImporter(useCache: false).importPath(
        'test/file_member_fixtures/uri_policy/app/lib',
      );
    });

    test('checks all files by default and describes the rule', () {
      final report = Heimdall.code().preferRelativeImports().check(project);

      expect(report.description, 'files should prefer relative imports');
      expect(report.checkedCount, project.files.length);
      expect(report.hasFindings, isTrue);
      expect(report.assertNoFindings, throwsStateError);
    });

    test('accepts relative, external package, SDK and conditional imports', () {
      // Anchor the glob to the root, excluding nested files with the same name.
      final report = Heimdall.code().preferRelativeImports(pathPattern: 'v*.dart').check(project);

      expect(report.checkedCount, 1);
      expect(report.findings, isEmpty);
      report.assertNoFindings();
    });

    test('accepts relative imports from a parent directory', () {
      final report = Heimdall.code().preferRelativeImports(pathPattern: 'sub/valid.dart').check(project);

      expect(report.checkedCount, 1);
      report.assertNoFindings();
    });

    test('reports each internal package import with its location and message', () {
      final report = Heimdall.code().preferRelativeImports(pathPattern: 'invalid_imports.dart').check(project);

      expect(report.checkedCount, 1);
      expect(report.findings.map((finding) => finding.line), orderedEquals([1, 2, 3, 4, 5]));
      expect(
        report.findings.map((finding) => finding.filePath),
        everyElement(project.fileByRelativePath('invalid_imports.dart')!.absolutePath),
      );
      expect(
        report.findings.map((finding) => finding.message),
        everyElement('Use relative import instead of package:uri_policy_app/model.dart'),
      );
    });

    for (final variation in ['show', 'hide', 'prefix', 'deferred']) {
      test('checks $variation imports within the selected path', () {
        final path = 'variations/$variation.dart';
        final report = Heimdall.code().preferRelativeImports(pathPattern: path).check(project);

        expect(report.checkedCount, 1);
        expect(report.findings.map((finding) => finding.line), orderedEquals([3]));
        expect(report.findings.single.filePath, project.fileByRelativePath(path)!.absolutePath);
      });
    }

    test('checks internal package imports in conditional branches', () {
      final report = Heimdall.code().preferRelativeImports(pathPattern: 'invalid_conditional.dart').check(project);

      expect(report.checkedCount, 1);
      expect(report.findings.map((finding) => finding.line), orderedEquals([1, 3]));
      expect(
        report.findings.map((finding) => finding.message),
        everyElement('Use relative import instead of package:uri_policy_app/model.dart'),
      );
    });

    test('reports internal imports when targets are outside the imported subtree', () {
      final subtree = const HeimdallFileImporter(useCache: false).importPath(
        'test/file_member_fixtures/uri_policy/app/lib/variations',
      );
      expect(subtree.fileByRelativePath('../model.dart'), isNull);

      final report = Heimdall.code().preferRelativeImports(pathPattern: 'show.dart').check(subtree);

      expect(report.checkedCount, 1);
      expect(report.findings.map((finding) => finding.line), orderedEquals([3]));
    });

    test('reports internal imports when targets are excluded by import options', () {
      final filtered = HeimdallFileImporter(
        useCache: false,
        importOptions: [PathPredicateImportOption((path) => !path.endsWith('model.dart'))],
      ).importPath('test/file_member_fixtures/uri_policy/app/lib');
      expect(filtered.fileByRelativePath('model.dart'), isNull);

      final report = Heimdall.code().preferRelativeImports(pathPattern: 'invalid_imports.dart').check(filtered);

      expect(report.checkedCount, 1);
      expect(report.findings.map((finding) => finding.line), orderedEquals([1, 2, 3, 4, 5]));
    });

    test('does not mistake an external conditional branch for an internal one', () {
      final fixture = const HeimdallFileImporter(useCache: false).importPath(
        'test/file_member_fixtures/import_styles/lib',
      );
      final report = Heimdall.code().preferRelativeImports(pathPattern: 'external_conditional.dart').check(fixture);

      expect(report.checkedCount, 1);
      report.assertNoFindings();
    });

    for (final path in ['model.dart', 'invalid_exports.dart', 'invalid_parts.dart']) {
      test('does not report non-import directives in $path', () {
        final report = Heimdall.code().preferRelativeImports(pathPattern: path).check(project);

        expect(report.checkedCount, greaterThan(0));
        report.assertNoFindings();
      });
    }
  });
}
