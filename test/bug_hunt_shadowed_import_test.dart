import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('if-case guard variable does not create a dependency on a shadowed type', () {
    final project = const HeimdallFileImporter(useCache: false).importPath(
      'test/bug_hunt_fixtures',
    );

    final report = Heimdall.classes()
        .that()
        .haveTypeName('ShadowedPatternConsumer')
        .should()
        .notDependOnClassesWithTypeName('ShadowedPatternType')
        .check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  for (final (name, dependsOnType) in [
    ('CollectionGuardConsumer', false),
    ('PatternTypeConsumer', true),
    ('ElseTypeConsumer', true),
    ('CollectionElseTypeConsumer', true),
  ]) {
    test('$name respects the guard and branch scopes', () {
      final project = const HeimdallFileImporter(useCache: false).importPath('test/bug_hunt_fixtures');
      expect(project.parseErrors, isEmpty);
      final report = Heimdall.classes().that().haveTypeName(name).should().notDependOnClassesWithTypeName('ShadowedPatternType').check(project);

      expect(report.checkedCount, 1);
      expect(report.findings, dependsOnType ? hasLength(1) : isEmpty);
    });
  }
}
