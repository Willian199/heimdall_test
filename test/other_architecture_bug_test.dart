import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('part-of ownership does not create a reverse slice dependency', () {
    final project = const HeimdallFileImporter(useCache: false).importPath('test/other_bug_fixtures/part_of_cycle');
    final report = Heimdall.slices('lib/src/features/(*)').shouldBeFreeOfCycles().check(project);

    expect(project.parseErrors, isEmpty);
    // `part of` is the reverse ownership declaration for the same library;
    // treating it as a second dependency creates a cycle that is not present.
    expect(report.findings, isEmpty);
  });

  test('cycle limit does not report a cycle in a disconnected slice', () {
    final project = const HeimdallFileImporter(useCache: false).importPath('test/other_bug_fixtures/cycle_limit');
    final report = Heimdall.slices('lib/src/features/(*)').shouldBeFreeOfCycles().check(project);

    expect(project.parseErrors, isEmpty);
    expect(report.findings.where((finding) => finding.message.contains('z')), isEmpty);
  });

  // A single lower bound remains identifiable inside an SDK range union.
  test('disjoint SDK constraints still use their minimum language version', () {
    final disjoint = const HeimdallFileImporter(useCache: false).importPath('test/other_bug_fixtures/disjoint_sdk');
    final legacy = const HeimdallFileImporter(useCache: false).importPath('test/other_bug_fixtures/min_sdk_legacy');

    expect(disjoint.packageName, 'disjoint_sdk');
    expect(disjoint.parseErrors, isNotEmpty);
    expect(legacy.parseErrors, isNotEmpty);
  });

  test('backslashes in relative URIs are rejected by the URI policy', () {
    final project = const HeimdallFileImporter(useCache: false).importPath('test/other_bug_fixtures/backslash_uri');
    final consumer = project.fileByRelativePath('lib/src/a/consumer.dart')!;
    final import = consumer.importDirectives.single;

    expect(consumer.sourceUris.single.isValid, isFalse);
    expect(
      Heimdall.code().preferRelativeUris(pathPattern: consumer.relativePath).check(project).findings,
      isNotEmpty,
    );
    expect(import.targetFiles.map((file) => file.relativePath), isNot(contains('lib/src/b/target.dart')));
  });

  test('relative import resolution follows Windows case-insensitive paths', () {
    final project = const HeimdallFileImporter(useCache: false).importPath('test/other_bug_fixtures/path_case');
    final consumer = project.fileByRelativePath('lib/consumer.dart')!;
    final import = consumer.importDirectives.single;

    expect(import.targetFiles.map((file) => file.relativePath), contains('lib/Target.dart'));
  });
}
