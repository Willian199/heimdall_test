import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  late HeimdallProject project;
  final importedFoo = HeimdallPredicate<CompilationUnitMember>(
    'are the imported Foo declaration',
    (item, _) => item.name == 'Foo' && item.relativePath.endsWith('foo.dart'),
  );

  setUpAll(() {
    project = const HeimdallFileImporter(useCache: false).importPath(
      'test/architecture_fixtures/shadowed_catch_pattern',
    );
  });

  test('fixture parses successfully', () {
    expect(project.parseErrors, isEmpty);
  });

  for (final consumer in [
    'CatchConsumer',
    'PatternConsumer',
    'GenericParameterConsumer',
    'GetterConsumer',
    'MethodReceiverConsumer',
    'TopLevelFunctionReceiverConsumer',
    'RepresentationShadowConsumer',
  ]) {
    test('a local $consumer variable does not depend on imported Foo', () {
      final report = Heimdall.classes().that().haveTypeName(consumer).should().notDependOnClassesThat(importedFoo).check(project);

      expect(report.checkedCount, 1);
      expect(report.findings, isEmpty);
    });
  }

  for (final consumer in [
    'ListPatternReceiverConsumer',
    'MapPatternReceiverConsumer',
    'GuardedSwitchPatternReceiverConsumer',
  ]) {
    test('$consumer pattern bindings do not create dependencies on imported Foo', () {
      final report = Heimdall.classes().that().haveTypeName(consumer).should().notDependOnClassesThat(importedFoo).check(project);

      expect(report.checkedCount, 1);
      expect(report.findings, isEmpty);
    });
  }

  test('a loop variable does not shadow an imported type after the loop', () {
    final report = Heimdall.classes().that().haveTypeName('LoopScopeConsumer').should().dependOnClassesThat(importedFoo).check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('a switch-expression pattern variable does not create an imported type dependency', () {
    expect(project.parseErrors, isEmpty);

    final report = Heimdall.classes()
        .that()
        .haveTypeName('SwitchExpressionPatternConsumer')
        .should()
        .notDependOnClassesThat(importedFoo)
        .check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('a collection-if pattern variable does not create an imported type dependency', () {
    final report = Heimdall.classes().that().haveTypeName('CollectionIfPatternConsumer').should().notDependOnClassesThat(importedFoo).check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('a collection-for variable does not create an imported type dependency', () {
    final report = Heimdall.classes()
        .that()
        .haveTypeName('CollectionForVariableConsumer')
        .should()
        .notDependOnClassesThat(importedFoo)
        .check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('a for-in variable does not create an imported type dependency', () {
    final report = Heimdall.classes().that().haveTypeName('ForInVariableConsumer').should().notDependOnClassesThat(importedFoo).check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('a top-level getter tear-off does not create an imported type dependency', () {
    final report = Heimdall.classes()
        .that()
        .haveTypeName('TopLevelGetterReceiverConsumer')
        .should()
        .notDependOnClassesThat(importedFoo)
        .check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('a switch-statement pattern variable does not create an imported type dependency', () {
    final report = Heimdall.classes()
        .that()
        .haveTypeName('SwitchStatementPatternConsumer')
        .should()
        .notDependOnClassesThat(importedFoo)
        .check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('a generic function type parameter does not create an imported type dependency', () {
    final report = Heimdall.classes()
        .that()
        .haveTypeName('GenericFunctionTypeShadowConsumer')
        .should()
        .notDependOnClassesThat(importedFoo)
        .check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('a generic function return type parameter does not create an imported type dependency', () {
    final report = Heimdall.classes()
        .that()
        .haveTypeName('GenericFunctionReturnShadowConsumer')
        .should()
        .notDependOnClassesThat(importedFoo)
        .check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('a for-in record-pattern variable does not create an imported type dependency', () {
    final report = Heimdall.classes().that().haveTypeName('ForInRecordPatternConsumer').should().notDependOnClassesThat(importedFoo).check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('a catch stack-trace parameter does not create an imported type dependency', () {
    final report = Heimdall.classes().that().haveTypeName('CatchStackTraceConsumer').should().notDependOnClassesThat(importedFoo).check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('a C-style loop variable does not hide a constructor dependency afterward', () {
    final report = Heimdall.classes().that().haveTypeName('CStyleForScopeConsumer').should().dependOnClassesThat(importedFoo).check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  for (final consumer in [
    'ConstructorInitializerDependencyConsumer',
    'ConstructorAssertDependencyConsumer',
    'RedirectingInitializerDependencyConsumer',
    'StaticInitializerDependencyConsumer',
  ]) {
    test('$consumer retains dependencies from conditional import branches', () {
      final alternateBranchFoo = HeimdallPredicate<CompilationUnitMember>(
        'are Foo from the alternate conditional branch',
        (item, _) => item.name == 'Foo' && item.relativePath.endsWith('foo_web.dart'),
      );
      final report = Heimdall.classes().that().haveTypeName(consumer).should().dependOnClassesThat(alternateBranchFoo).check(project);

      expect(report.checkedCount, 1);
      expect(report.findings, isEmpty);
    });
  }
}
