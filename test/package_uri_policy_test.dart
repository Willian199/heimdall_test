import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  late HeimdallProject project;
  late HeimdallProject styles;

  setUpAll(() {
    project = const HeimdallFileImporter(useCache: false).importPath('test/file_member_fixtures/uri_policy/app/lib');
    styles = const HeimdallFileImporter(useCache: false).importPath('test/file_member_fixtures/import_styles/lib');
  });

  group('Heimdall.code().preferPackageImports()', () {
    test('accepts internal and external package imports and SDK imports', () {
      final report = Heimdall.code().preferPackageImports(pathPattern: 'package_valid.dart').check(styles);
      expect(report.checkedCount, 1);
      report.assertNoFindings();
    });

    test('rejects relative imports in every conditional branch', () {
      final report = Heimdall.code().preferPackageImports(pathPattern: 'external_conditional.dart').check(styles);
      expect(report.checkedCount, 1);
      expect(report.findings.map((finding) => finding.line), orderedEquals([1, 2]));
      expect(report.findings.map((finding) => finding.message), everyElement('Use package import instead of model.dart'));
    });

    for (final variation in ['show', 'hide', 'prefix', 'deferred']) {
      test('rejects relative $variation imports and accepts package imports', () {
        final path = 'variations/$variation.dart';
        final report = Heimdall.code().preferPackageImports(pathPattern: path).check(project);
        expect(report.checkedCount, 1);
        expect(report.findings.map((finding) => finding.line), orderedEquals([1]));
        expect(report.findings.single.filePath, project.fileByRelativePath(path)!.absolutePath);
      });
    }

    test('checks relative imports even outside the imported subtree', () {
      final subtree = const HeimdallFileImporter(useCache: false).importPath('test/file_member_fixtures/uri_policy/app/lib/sub');
      final report = Heimdall.code().preferPackageImports().check(subtree);
      expect(report.checkedCount, 1);
      expect(report.findings.single.message, 'Use package import instead of ../model.dart');
    });

    test('checks all files by default and preserves the rule description', () {
      final report = Heimdall.code().preferPackageImports().check(styles);
      expect(report.checkedCount, styles.files.length);
      expect(report.description, 'files should prefer package imports');
      expect(report.findings.map((finding) => finding.line), orderedEquals([1, 2]));
    });
  });

  group('Heimdall.code().preferPackageUris()', () {
    test('accepts package imports/exports, SDK URIs and relative parts', () {
      final report = Heimdall.code().preferPackageUris(pathPattern: 'package_valid.dart').check(styles);
      expect(report.checkedCount, 1);
      report.assertNoFindings();
    });

    for (final path in ['relative_part.dart', 'named_part.dart']) {
      test('accepts $path', () {
        final report = Heimdall.code().preferPackageUris(pathPattern: path).check(styles);
        expect(report.checkedCount, 1);
        report.assertNoFindings();
      });
    }

    test('rejects relative imports and exports including conditional alternatives', () {
      final report = Heimdall.code().preferPackageUris(pathPattern: 'invalid_conditional.dart').check(project);
      expect(report.checkedCount, 1);
      expect(report.findings.map((finding) => finding.line), orderedEquals([1, 1, 2, 2, 3, 4]));
      expect(report.findings.first.message, contains('URI model.dart'));
    });

    for (final variation in ['export_show', 'export_hide']) {
      test('rejects relative $variation exports', () {
        final report = Heimdall.code().preferPackageUris(pathPattern: 'variations/$variation.dart').check(project);
        expect(report.checkedCount, 1);
        expect(report.findings.map((finding) => finding.line), orderedEquals([1]));
      });
    }

    for (final path in [
      'invalid_part_of.dart',
      'external_part_of.dart',
      'package_external_part_of.dart',
      'invalid_uri_query.dart',
      'invalid_uri_fragment.dart',
      'invalid_uri_authority.dart',
      'invalid_uri_format.dart',
    ]) {
      test('rejects $path', () {
        final report = Heimdall.code().preferPackageUris(pathPattern: path).check(project);
        expect(report.checkedCount, 1);
        expect(report.findings.map((finding) => finding.line), orderedEquals([1]));
      });
    }

    test('rejects package parts and parts outside the package', () {
      final report = Heimdall.code().preferPackageUris(pathPattern: 'invalid_parts.dart').check(project);
      expect(report.checkedCount, 1);
      expect(report.findings.map((finding) => finding.line), orderedEquals([1, 2, 3]));
    });

    test('does not require package URI targets to be imported or exist', () {
      final report = Heimdall.code().preferPackageUris(pathPattern: 'missing_targets.dart').check(styles);
      expect(report.checkedCount, 1);
      report.assertNoFindings();
    });

    test('checks all files by default', () {
      final report = Heimdall.code().preferPackageUris().check(styles);
      expect(report.checkedCount, styles.files.length);
      expect(report.description, 'files should prefer package URIs');
      expect(report.findings.map((finding) => finding.line), orderedEquals([1, 2]));
    });
  });

  test('relative rules report missing internal targets and each offending conditional URI', () {
    final imports = Heimdall.code().preferRelativeImports(pathPattern: 'missing_targets.dart').check(styles);
    final uris = Heimdall.code().preferRelativeUris(pathPattern: 'missing_targets.dart').check(styles);
    expect(imports.checkedCount, 1);
    expect(uris.checkedCount, 1);
    expect(imports.findings.map((finding) => finding.line), orderedEquals([1, 2, 2]));
    expect(uris.findings.map((finding) => finding.line), orderedEquals([1, 2, 2, 3]));
    expect(
      imports.findings.map((finding) => finding.message),
      orderedEquals([
        'Use relative import instead of package:import_styles/missing.dart',
        'Use relative import instead of package:import_styles/missing_io.dart',
        'Use relative import instead of package:import_styles/missing_html.dart',
      ]),
    );
  });

  test('URI policies reuse immutable source-file metadata across evaluations', () {
    final file = styles.fileByRelativePath('external_conditional.dart')!;
    final cached = file.sourceUris;
    expect(
      cached.map((reference) => reference.target),
      orderedEquals([
        'model.dart',
        'package:external/model.dart',
        'package:external/model.dart',
        'model.dart',
      ]),
    );
    expect(cached.first.directive, same(file.relativeImports.first));
    expect(cached.first.relativeDestination, Uri.file(styles.fileByRelativePath('model.dart')!.absolutePath));

    Heimdall.code().preferRelativeUris().check(styles);
    Heimdall.code().preferPackageUris().check(styles);

    expect(file.sourceUris, same(cached));
    expect(file.sourceUris.first, same(cached.first));
    expect(cached.clear, throwsUnsupportedError);
  });
}
