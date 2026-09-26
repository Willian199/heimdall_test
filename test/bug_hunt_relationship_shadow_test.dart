import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('does not treat an if-case collection variable as a returned field', () {
    final project = const HeimdallFileImporter(useCache: false).importPath(
      'test/bug_hunt_fixtures',
    );
    final file = project.fileByRelativePath(
      'lib/shadowed_relationships.dart',
    )!;
    final owner = file.classDeclarations.singleWhere(
      (declaration) => declaration.name == 'IfElementShadow',
    );
    final valueField = owner.fields.single;
    final report = Heimdall.fields()
        .that()
        .haveName('value')
        .and()
        .areDeclaredInClassesThat(HeimdallPredicate('are IfElementShadow', (item, _) => item.name == 'IfElementShadow'))
        .should()
        .notBeIncludedInReturnedListOf('props')
        .check(project);

    expect(valueField.returnedListFieldNames, isNot(contains('value')));
    expect(report.findings, isEmpty);
  });

  test('does not treat a switch-case pattern variable as a forwarded field', () {
    final project = const HeimdallFileImporter(useCache: false).importPath(
      'test/bug_hunt_fixtures',
    );
    final file = project.fileByRelativePath(
      'lib/shadowed_relationships.dart',
    )!;
    final owner = file.classDeclarations.singleWhere(
      (declaration) => declaration.name == 'SwitchExpressionShadow',
    );
    final valueField = owner.fields.single;
    final report = Heimdall.fields()
        .that()
        .haveName('value')
        .and()
        .areDeclaredInClassesThat(HeimdallPredicate('are SwitchExpressionShadow', (item, _) => item.name == 'SwitchExpressionShadow'))
        .should()
        .notPassMatchingParameterToReturnedConstructorIn('copy')
        .check(project);

    expect(valueField.forwardedConstructorFieldNames, isEmpty);
    expect(report.findings, isEmpty);
  });

  for (final (name, includesField) in [
    ('IfElementElseField', true),
    ('IfElementExplicitField', true),
    ('SwitchExpressionListShadow', false),
  ]) {
    test('$name respects pattern scope when returning fields', () {
      final project = const HeimdallFileImporter(useCache: false).importPath('test/bug_hunt_fixtures');
      final report = Heimdall.fields()
          .that()
          .haveName('value')
          .and()
          .areDeclaredInClassesThat(HeimdallPredicate('are $name', (item, _) => item.name == name))
          .should()
          .beIncludedInReturnedListOf('props')
          .check(project);

      expect(report.checkedCount, 1);
      expect(report.findings, includesField ? isEmpty : hasLength(1));
    });
  }

  test('an unrelated switch binding preserves parameter forwarding', () {
    final project = const HeimdallFileImporter(useCache: false).importPath('test/bug_hunt_fixtures');
    final report = Heimdall.fields()
        .that()
        .haveName('value')
        .and()
        .areDeclaredInClassesThat(HeimdallPredicate('are forwarding control', (item, _) => item.name == 'SwitchExpressionForwardedParameter'))
        .should()
        .passMatchingParameterToReturnedConstructorIn('copy')
        .check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });
}
