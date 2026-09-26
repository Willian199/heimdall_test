import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  final project = const HeimdallFileImporter(useCache: false).importPath(
    'test/architecture_fixtures/shadowed_import_prefix',
  );
  final importedFoo = HeimdallPredicate<CompilationUnitMember>(
    'are Foo declarations from the domain library',
    (item, _) => item.name == 'Foo' && item.relativePath.endsWith('/domain/foo.dart'),
  );

  test('a local variable can shadow an import prefix in member access', () {
    expect(project.parseErrors, isEmpty);

    final report = Heimdall.classes().that().haveTypeName('Consumer').should().notDependOnClassesThat(importedFoo).check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  for (final (name, dependsOnFoo) in [
    ('ParameterConsumer', false),
    ('FieldConsumer', false),
    ('MethodConsumer', false),
    ('Carrier', true),
    ('DirectConsumer', true),
    ('ScopeConsumer', true),
  ]) {
    test('$name respects the scope of the import prefix', () {
      final report = Heimdall.classes().that().haveTypeName(name).should().notDependOnClassesThat(importedFoo).check(project);

      expect(report.checkedCount, 1);
      expect(report.findings, dependsOnFoo ? hasLength(1) : isEmpty);
    });
  }
}
