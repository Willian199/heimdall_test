import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  group('Relative local and package external URI policy', () {
    late HeimdallProject project;
    late HeimdallProject nestedProject;
    late HeimdallRule<HeimdallSourceFile> policy;

    setUpAll(() {
      project =
          HeimdallFileImporter(
            useCache: false,
            importOptions: [PathPredicateImportOption((path) => !pathMatches(path, 'nested'))],
          ).importPath(
            'test/file_member_fixtures/uri_policy/app/lib',
          );
      nestedProject = const HeimdallFileImporter(useCache: false).importPath(
        'test/file_member_fixtures/uri_policy/app/lib/nested/lib',
      );
      policy = Heimdall.code().preferRelativeUris();
    });

    test('fixtures parse and package identity comes from pubspec', () {
      expect(project.packageName, 'uri_policy_app');
      expect(project.parseErrors, isEmpty);
    });

    test('accepts relative imports, external packages, SDK URIs and conditional alternatives', () {
      _expectFindings(project, policy, 'valid.dart', []);
    });

    test('accepts relative part-of URIs', () {
      _expectFindings(project, policy, 'relative_part.dart', []);
    });

    test('accepts named part-of directives', () {
      _expectFindings(project, policy, 'named_part.dart', []);
    });

    test('accepts relative references to parent directories in the same package', () {
      _expectFindings(project, policy, 'sub/valid.dart', []);
    });

    test('accepts files without directives', () {
      _expectFindings(project, policy, 'model.dart', []);
    });

    test('rejects internal package imports and relative external imports', () {
      _expectFindings(project, policy, 'invalid_imports.dart', [1, 2, 3, 4, 5, 6]);
    });

    test('rejects internal package exports and relative external exports', () {
      _expectFindings(project, policy, 'invalid_exports.dart', [1, 2, 3, 4]);
    });

    test('checks default and inactive conditional import and export branches', () {
      _expectFindings(project, policy, 'invalid_conditional.dart', [1, 1, 2, 2, 3, 4]);
    });

    test('requires part directives to stay local and relative', () {
      _expectFindings(project, policy, 'invalid_parts.dart', [1, 2, 3]);
    });

    test('rejects package URIs in part-of directives', () {
      _expectFindings(project, policy, 'invalid_part_of.dart', [1]);
    });

    test('rejects relative external part-of directives', () {
      _expectFindings(project, policy, 'external_part_of.dart', [1]);
    });

    test('rejects external package part-of directives', () {
      _expectFindings(project, policy, 'package_external_part_of.dart', [1]);
    });

    test('checks show imports', () {
      _expectFindings(project, policy, 'variations/show.dart', [3]);
    });

    test('checks hide imports', () {
      _expectFindings(project, policy, 'variations/hide.dart', [3]);
    });

    test('checks prefixed imports', () {
      _expectFindings(project, policy, 'variations/prefix.dart', [3]);
    });

    test('checks deferred imports', () {
      _expectFindings(project, policy, 'variations/deferred.dart', [3]);
    });

    test('checks show exports', () {
      _expectFindings(project, policy, 'variations/export_show.dart', [3]);
    });

    test('checks hide exports', () {
      _expectFindings(project, policy, 'variations/export_hide.dart', [3]);
    });

    test('uses the originating package for files in a nested package', () {
      _expectFindings(nestedProject, policy, 'valid.dart', []);
    });

    test('rejects own-package URIs and relative cross-package references in a nested package', () {
      _expectFindings(nestedProject, policy, 'invalid.dart', [1, 2, 3]);
    });

    test('reports query-bearing URIs instead of throwing', () {
      _expectFindings(project, policy, 'invalid_uri_query.dart', [1]);
    });

    test('reports fragment-bearing URIs instead of throwing', () {
      _expectFindings(project, policy, 'invalid_uri_fragment.dart', [1]);
    });

    test('rejects package URIs with an authority', () {
      _expectFindings(project, policy, 'invalid_uri_authority.dart', [1]);
    });

    test('reports malformed URIs instead of throwing', () {
      _expectFindings(project, policy, 'invalid_uri_format.dart', [1]);
    });

    test('checks the whole source tree without hiding violations by selection', () {
      final report = policy.check(project);

      expect(report.findings, hasLength(32));
    });
  });
}

void _expectFindings(
  HeimdallProject project,
  HeimdallRule<HeimdallSourceFile> policy,
  String file,
  List<int> lines,
) {
  expect(project.fileByRelativePath(file), isNotNull);
  final report = Heimdall.files()
      .that()
      .satisfy(HeimdallPredicate<HeimdallSourceFile>('have exact path $file', (item, _) => item.relativePath == file))
      .should()
      .satisfy(policy.condition)
      .check(project);
  expect(report.findings.map((finding) => finding.line), orderedEquals(lines));
  expect(report.findings.map((finding) => finding.filePath), everyElement(project.fileByRelativePath(file)!.absolutePath));
  expect(report.findings.every((finding) => finding.message.contains('URI policy:')), isTrue);
}
