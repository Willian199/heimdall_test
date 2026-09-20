import 'dart:io';

import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  const importer = HeimdallFileImporter(useCache: false);
  const fixture = 'test/importer_fixtures/review_project';

  for (final layout in ['features', 'src/features']) {
    test('default feature rules work across import roots for $layout', () {
      final fixtureRoot = '$fixture/feature_${layout.startsWith('src') ? 'src' : 'plain'}';
      for (final root in ['', '/lib', '/lib/$layout']) {
        final project = importer.importPath('$fixtureRoot$root');
        expect(Heimdall.dependencies().featuresShouldNotDependOnEachOther().check(project).findings, hasLength(1));
        expect(Heimdall.dependencies().featuresShouldNotDependOnEachOther(sharedSlices: ['b']).check(project).findings, isEmpty);
      }
      final project = importer.importPath('$fixtureRoot/lib');
      expect(Heimdall.dependencies().featuresShouldNotDependOnEachOther(featurePattern: '$layout/(*)').check(project).findings, hasLength(1));
    });
  }

  test('cyclic exports remain complete in either query order and respect combinators', () {
    for (final order in [
      ['a.dart', 'b.dart'],
      ['b.dart', 'a.dart'],
    ]) {
      final project = importer.importPath('$fixture/lib/cycles');
      for (final name in order) {
        final file = project.fileByRelativePath(name)!;
        expect(project.exportedTypeDeclarationsOf(file).map((type) => type.name), unorderedEquals(['A', 'B']));
      }
      final barrel = project.fileByRelativePath('barrel.dart')!;
      expect(project.exportedTypeDeclarationsOf(barrel).map((type) => type.name), unorderedEquals(['A', 'B']));
    }
  });

  test('freeze survives relocation and import-root changes while reporting new findings', () {
    final storeDirectory = Directory.systemTemp.createTempSync('heimdall_baseline_');
    addTearDown(() => storeDirectory.deleteSync(recursive: true));
    final rule = Heimdall.classes().should().beFinal().freeze(storePath: '${storeDirectory.path}/baseline.json');
    final original = importer.importPath('$fixture/freeze/original/lib');
    expect(rule.check(original).findings, hasLength(1));
    expect(rule.check(importer.importPath('$fixture/freeze/copy')).findings, isEmpty);
    final changed = importer.importPath('$fixture/freeze/changed/lib');
    expect(rule.check(changed).findings, hasLength(1));
    expect(rule.check(changed).findings, hasLength(1));
    expect(rule.check(importer.importPath('$fixture/freeze/resolved/lib')).findings, hasLength(1));
    // A resolved baseline entry must be reported again if it reappears.
    expect(rule.check(original).findings, hasLength(1));
  });
}
