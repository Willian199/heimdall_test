import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  late HeimdallProject project;

  setUpAll(() {
    project = HeimdallFileImporter(
      useCache: false,
      importOptions: [
        PathPredicateImportOption(
          (path) => path.endsWith('parameter_assignability.dart'),
        ),
      ],
    ).importPath('test/bug_hunt_fixtures');
    expect(project.parseErrors, isEmpty);
  });
  test('class with implicit Object superclass is assignable to Object', () {
    final report = Heimdall.classes().that().haveTypeName('AssignabilityBase').should().beAssignableTo('Object').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('enum is assignable to its implicit Enum superclass', () {
    final report = Heimdall.classes().that().haveTypeName('AssignabilityResultKind').should().beAssignableTo('Enum').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('nullable parameter is not assignable to its non-nullable type', () {
    final report = Heimdall.methods().that().haveName('acceptsNullable').should().notReceiveParameterAssignableTo('AssignabilityBase').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('generic parameter retains its declared class hierarchy', () {
    final report = Heimdall.methods().that().haveName('acceptsGeneric').should().receiveParameterAssignableTo('AssignabilityBase').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('generic typedef parameter retains its aliased class hierarchy', () {
    final report = Heimdall.methods()
        .that()
        .haveName('acceptsGenericAlias')
        .should()
        .receiveParameterAssignableTo('AssignabilityBase')
        .check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('function parameter is not reported as having its callback return type', () {
    final report = Heimdall.methods().that().haveName('acceptsCallback').should().notReceiveParameterTypeName('void').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('super-formal parameter resolves the superclass generic argument', () {
    final report = Heimdall.constructors().that().haveName('copy').should().receiveParameterAssignableTo('String').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  for (final (method, target, assignable) in [
    ('acceptsNullable', 'AssignabilityBase?', true),
    ('acceptsNullable', 'Object?', true),
    ('acceptsNullable', 'Object', false),
    ('acceptsNullable', 'dynamic', true),
    ('acceptsGeneric', 'AssignabilityChild', true),
    ('acceptsGeneric', 'AssignabilityBase?', true),
    ('acceptsGenericAlias', 'AssignabilityChild', true),
    ('acceptsGenericAlias', 'UnrelatedType', false),
    ('acceptsCallback', 'Function', true),
    ('acceptsModernCallback', 'Function', true),
    ('acceptsModernCallback', 'void', false),
    ('acceptsNullableCallback', 'Function', false),
    ('acceptsNullableCallback', 'Function?', true),
  ]) {
    test('$method assignability to $target is $assignable', () {
      final report = Heimdall.methods().that().haveName(method).should().receiveParameterAssignableTo(target).check(project);

      expect(report.checkedCount, 1);
      expect(report.findings, assignable ? isEmpty : hasLength(1));
    });
  }

  for (final constructor in ['nested', 'nestedNullable']) {
    test('$constructor super-formal substitution preserves nested type arguments', () {
      final report = Heimdall.constructors().that().haveName(constructor).should().receiveParameterTypeName('List<String?>').check(project);

      expect(report.checkedCount, 1);
      expect(report.findings, isEmpty);
    });
  }
}
