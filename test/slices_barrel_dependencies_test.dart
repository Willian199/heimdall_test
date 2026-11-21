import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

const _root = 'test/architecture_fixtures/slices_barrel_dependencies';

void main() {
  const slices = HeimdallSlices.matching('src/data/repository/(*)');

  for (final fixture in ['unused_exports', 'complete_module']) {
    test('$fixture: unused barrel exports do not create dependencies or cycles', () {
      final project = const HeimdallFileImporter().importPath('$_root/$fixture/lib');
      expect(project.parseErrors, isEmpty);

      expect(
        slices.shouldNotDependOnEachOther().check(project).findings.map((finding) => finding.message),
        ['Slice b depends on a'],
      );
      slices.shouldBeFreeOfCycles().check(project).assertNoFindings();
      slices.shouldNotDependOnEachOther(sharedSlices: ['a']).check(project).assertNoFindings();
    });
  }

  for (final fixture in ['referenced_implementation', 'referenced_interface', 'referenced_function', 'referenced_extension']) {
    test('$fixture: a reference through the package barrel creates a dependency and a cycle', () {
      final project = const HeimdallFileImporter().importPath('$_root/$fixture/lib');
      expect(project.parseErrors, isEmpty);

      expect(
        slices.shouldNotDependOnEachOther(sharedSlices: ['a']).check(project).findings.map((finding) => finding.message),
        ['Slice a depends on b'],
      );
      expect(slices.shouldBeFreeOfCycles().check(project).findings, hasLength(1));
    });
  }

  for (final fixture in ['exported_barrel', 'unused_direct_import']) {
    test('$fixture: explicit directive dependencies are preserved', () {
      final project = const HeimdallFileImporter().importPath('$_root/$fixture/lib');
      expect(project.parseErrors, isEmpty);

      expect(
        slices.shouldNotDependOnEachOther(sharedSlices: ['a']).check(project).findings.map((finding) => finding.message),
        ['Slice a depends on b'],
      );
    });
  }
}
