import 'dart:io';

import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  late Directory root;

  setUp(() {
    root = Directory.systemTemp.createTempSync('heimdall_slice_barrel_');
  });

  tearDown(() => root.deleteSync(recursive: true));

  HeimdallProject importProject({
    String aBody = '',
    String aDirective = "import 'package:my_package/my_package.dart';",
    bool completeModuleBarrel = false,
  }) {
    final bDirective = completeModuleBarrel
        ? "import 'package:my_package/my_package.dart';"
        : "import 'package:my_package/src/data/repository/a/a_repository.dart';\n"
              "import 'package:my_package/src/data/repository/b/b_repository.dart';";
    final files = {
      'pubspec.yaml': 'name: my_package\nenvironment:\n  sdk: ^3.11.0\n',
      'lib/my_package.dart':
          "export 'src/data/repository/a/a_repository.dart';\n"
          "export 'src/data/repository/b/b_repository.dart';\n"
          '${completeModuleBarrel ? "export 'src/data/repository/a/a_repository_impl.dart';\nexport 'src/data/repository/b/b_repository_impl.dart';\n" : ''}',
      'lib/src/data/repository/a/a_repository.dart': 'abstract interface class ARepository {}',
      'lib/src/data/repository/a/a_repository_impl.dart':
          '''
$aDirective
final class ARepositoryImpl implements ARepository {
  $aBody
}
''',
      'lib/src/data/repository/b/b_repository.dart': '''
abstract interface class BRepository {}
int repositoryValue() => 1;
extension RepositoryExtension on String {
  int get repositoryExtensionValue => 1;
}
''',
      'lib/src/data/repository/b/b_repository_impl.dart':
          '''
$bDirective
final class BRepositoryImpl implements BRepository {
  final ARepository a = throw UnimplementedError();
}
''',
    };
    for (final entry in files.entries) {
      final file = File('${root.path}/${entry.key}');
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(entry.value);
    }
    final project = const HeimdallFileImporter().importPath('${root.path}/lib');
    expect(project.parseErrors, isEmpty);
    return project;
  }

  const slices = HeimdallSlices.matching('src/data/repository/(*)');

  test('a barrel exposing an unused slice does not create an edge or a cycle', () {
    final project = importProject();

    expect(
      slices.shouldNotDependOnEachOther().check(project).findings.map((finding) => finding.message),
      ['Slice b depends on a'],
    );
    slices.shouldBeFreeOfCycles().check(project).assertNoFindings();
    slices.shouldNotDependOnEachOther(sharedSlices: ['a']).check(project).assertNoFindings();
  });

  test('implementations can import the public package barrel exporting the complete module', () {
    final project = importProject(completeModuleBarrel: true);

    expect(
      slices.shouldNotDependOnEachOther().check(project).findings.map((finding) => finding.message),
      ['Slice b depends on a'],
    );
    slices.shouldBeFreeOfCycles().check(project).assertNoFindings();
    slices.shouldNotDependOnEachOther(sharedSlices: ['a']).check(project).assertNoFindings();
  });

  test('a referenced implementation in the public package barrel still creates a dependency', () {
    final project = importProject(completeModuleBarrel: true, aBody: 'final b = BRepositoryImpl();');

    expect(
      slices.shouldNotDependOnEachOther(sharedSlices: ['a']).check(project).findings.map((finding) => finding.message),
      ['Slice a depends on b'],
    );
    expect(slices.shouldBeFreeOfCycles().check(project).findings, hasLength(1));
  });

  for (final body in [
    'final BRepository b = throw UnimplementedError();',
    'final value = repositoryValue();',
    "final value = 'repository'.repositoryExtensionValue;",
  ]) {
    test('a reference through the barrel creates an edge and closes the cycle: $body', () {
      final project = importProject(aBody: body);

      expect(
        slices.shouldNotDependOnEachOther(sharedSlices: ['a']).check(project).findings.map((finding) => finding.message),
        ['Slice a depends on b'],
      );
      expect(slices.shouldBeFreeOfCycles().check(project).findings, hasLength(1));
    });
  }

  test('an export through a barrel retains dependencies without local references', () {
    final project = importProject(aDirective: "import 'a_repository.dart';\nexport 'package:my_package/my_package.dart';");

    expect(
      slices.shouldNotDependOnEachOther(sharedSlices: ['a']).check(project).findings.map((finding) => finding.message),
      ['Slice a depends on b'],
    );
  });

  test('an unused direct import retains its file dependency', () {
    final project = importProject(
      aDirective: "import 'a_repository.dart';\nimport '../b/b_repository.dart';",
    );

    expect(
      slices.shouldNotDependOnEachOther(sharedSlices: ['a']).check(project).findings.map((finding) => finding.message),
      ['Slice a depends on b'],
    );
  });
}
