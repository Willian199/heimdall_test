import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  const importer = HeimdallFileImporter(useCache: false);
  const fixture = 'test/importer_fixtures/review_project/lib';

  for (final variant in ['Uri', 'Named']) {
    test('$variant part inherits library imports and combinators', () {
      final project = importer.importPath('$fixture/parts');
      expect(project.parseErrors, isEmpty);
      final positive = Heimdall.classes().that().haveTypeName('${variant}Consumer').should().dependOnClassesWithTypeName('Forbidden').check(project);
      final negative = Heimdall.classes()
          .that()
          .haveTypeName('${variant}Consumer')
          .should()
          .noDependOnClassesWithTypeName('Forbidden')
          .check(project);
      expect(positive.checkedCount, 1);
      expect(positive.findings, isEmpty);
      expect(negative.findings, hasLength(1));
      expect(negative.findings.single.filePath, endsWith('${variant.toLowerCase()}_piece.dart'));
      expect(
        Heimdall.classes().that().haveTypeName('${variant}HiddenConsumer').should().noDependOnClassesWithTypeName('Hidden').check(project).findings,
        isEmpty,
      );
    });
  }

  test('constructor initializers expose constructor and method calls', () {
    final project = importer.importPath('$fixture/initializers');
    expect(project.parseErrors, isEmpty);
    for (final name in ['direct', 'body']) {
      expect(Heimdall.constructors().that().haveName(name).should().callConstructor('Product').check(project).findings, isEmpty);
      expect(Heimdall.constructors().that().haveName(name).should().noCallConstructor('Product').check(project).findings, hasLength(1));
    }
    expect(Heimdall.constructors().that().haveName('method').should().callMethod('createProduct').check(project).findings, isEmpty);
    expect(Heimdall.constructors().that().haveName('method').should().noCallMethod('createProduct').check(project).findings, hasLength(1));
  });

  for (final name in ['plain', 'named', 'explicitNew', 'constant', 'prefixed', 'prefixedNamed', 'prefixedNew']) {
    test('constructor rules recognize $name invocation', () {
      final project = importer.importPath('$fixture/calls');
      expect(project.parseErrors, isEmpty);
      expect(Heimdall.methods().that().haveName(name).should().callConstructor('Product').check(project).findings, isEmpty);
      expect(Heimdall.methods().that().haveName(name).should().noCallConstructor('Product').check(project).findings, hasLength(1));
      final selected = Heimdall.methods().that().haveName(name).and().callConstructor('Product').should().haveName(name).check(project);
      expect(selected.checkedCount, 1);
      expect(selected.findings, isEmpty);
      expect(
        Heimdall.methods().that().haveName(name).should().callConstructorTypeNameMatching(RegExp(r'^Product$')).check(project).findings,
        isEmpty,
      );
      expect(Heimdall.methods().that().haveName(name).should().callConstructorTypeNameStartingWith('Prod').check(project).findings, isEmpty);
      expect(Heimdall.methods().that().haveName(name).should().callConstructorTypeNameEndingWith('duct').check(project).findings, isEmpty);
    });
  }

  test('static and instance methods are not treated as named constructors', () {
    final project = importer.importPath('$fixture/calls');
    expect(Heimdall.methods().that().haveName('methodsOnly').should().noCallConstructor('Product').check(project).findings, isEmpty);
  });

  test('project conditions can be negated and composed with assertions enabled', () {
    final project = importer.importPath('$fixture/clean');
    final condition = Heimdall.dependencies().pubspecShouldNotDependOn('forbidden').condition;
    expect(condition.check(project, project), isEmpty);
    final findings = condition.not().check(project, project);
    expect(findings, hasLength(1));
    expect(findings.single.filePath, project.packageRootPath);
    expect(condition.not().not().check(project, project), isEmpty);
    expect(HeimdallCondition.noneOf([condition]).check(project, project), hasLength(1));
    final cycles = Heimdall.slices('(*)').shouldBeFreeOfCycles().condition;
    expect(cycles.not().check(project, project), hasLength(1));
  });
}
