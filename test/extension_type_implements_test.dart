import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  late HeimdallProject project;
  setUpAll(() {
    project = const HeimdallFileImporter(useCache: false).importPath(
      'test/class_fixtures/extension_type_implements',
    );
  });

  test('implementation rules recognize extension type interfaces', () {
    expect(project.parseErrors, isEmpty);

    final implementation = Heimdall.classes().that().haveTypeName('UserId').should().implement('Identified').check(project);
    expect(implementation.checkedCount, 1);
    expect(implementation.findings, isEmpty);
  });

  test('assignability rules recognize extension type interfaces', () {
    final assignability = Heimdall.classes().that().haveTypeName('UserId').should().beAssignableTo('Identified').check(project);

    expect(assignability.checkedCount, 1);
    expect(assignability.findings, isEmpty);
  });

  test('constructor counts include the primary extension type constructor', () {
    final report = Heimdall.classes().that().haveTypeName('UserId').should().haveConstructorCount(1).check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('constructor parameter counts include primary extension type parameters', () {
    final report = Heimdall.classes().that().haveTypeName('UserId').should().haveConstructorParameterCount(1).check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });
}
