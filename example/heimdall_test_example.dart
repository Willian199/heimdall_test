import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  group('Package architecture', () {
    late HeimdallProject project;

    setUpAll(() {
      project = const HeimdallFileImporter().importPath();
    });

    test('keeps source files parseable', () {
      Heimdall.code().shouldParse().check(project).assertNoFindings();
    });

    test('does not import dart:mirrors', () {
      Heimdall.code().shouldNotImportDartMirrors().check(project).assertNoFindings();
    });

    test('uses PascalCase for public types under src', () {
      Heimdall.classes()
          .that()
          .resideInPath('src')
          .and()
          .arePublic()
          .should()
          .satisfy(_havePascalCaseName())
          .as('public types should use PascalCase')
          .check(project)
          .assertNoFindings();
    });

    test('keeps source layers depending in the expected direction', () {
      Heimdall.layers()
          .layer('Public')
          .definedBy(['heimdall_test.dart'])
          .layer('Core')
          .definedBy(['src/core.dart', 'src/core/(**)', 'src/mapper/(**)'])
          .layer('Library')
          .definedBy(['src/library_rules.dart', 'src/library/(**)'])
          .layer('Plugins')
          .definedBy(['src/plugins.dart'])
          .whereLayer('Public')
          .mayOnlyAccessLayers(['Core', 'Library', 'Plugins'])
          .whereLayer('Core')
          .mayOnlyAccessLayers(['Core'])
          .whereLayer('Library')
          .mayOnlyAccessLayers(['Core', 'Library'])
          .whereLayer('Plugins')
          .mayOnlyAccessLayers(['Core'])
          .consideringOnlyDependenciesInLayers()
          .asRule()
          .as('package source layers')
          .check(project)
          .assertNoFindings();
    });
  });
}

HeimdallCondition<CompilationUnitMember> _havePascalCaseName() {
  final pascalCase = RegExp(r'^[A-Z][A-Za-z0-9]*$');
  return HeimdallCondition('have PascalCase names', (item, _) {
    if (pascalCase.hasMatch(item.name)) {
      return HeimdallFindings(
        subject: item,
        passed: true,
      );
    }

    final location = item.location;

    return HeimdallFindings(
      subject: item,
      passed: false,
      findings: [
        HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: location.lineNumber,
          column: location.columnNumber,
          message: '${item.name} should use PascalCase',
        ),
      ],
    );
  });
}
