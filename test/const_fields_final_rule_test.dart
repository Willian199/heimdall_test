import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  late HeimdallProject project;

  setUpAll(() {
    project = const HeimdallFileImporter(useCache: false).importPath(
      'test/class_fixtures/const_fields_are_final',
    );
    expect(project.parseErrors, isEmpty);
  });

  test('a const field does not satisfy the final-only rule', () {
    final report = Heimdall.classes().that().haveTypeName('Constants').should().haveOnlyFinalFields().check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, hasLength(1));
  });

  test('a const field does not satisfy a named final-fields rule', () {
    final report = Heimdall.classes().that().haveTypeName('Constants').should().haveFinalFieldsNamedAllOf(['answer']).check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, hasLength(1));
  });

  test('a const field does not match any named final-field rule', () {
    final report = Heimdall.classes().that().haveTypeName('Constants').should().haveFinalFieldNamedAnyOf(['answer']).check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, hasLength(1));
  });

  test('a const field satisfies the no-named-final-fields rule', () {
    final report = Heimdall.classes().that().haveTypeName('Constants').should().haveNoFinalFieldsNamed(['answer']).check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('class selection excludes const from named final fields', () {
    final report = Heimdall.classes().that().haveTypeName('Constants').and().haveFinalFieldNamedAnyOf(['answer']).should().bePublic().check(project);

    expect(report.checkedCount, 0);
    expect(report.findings, hasLength(1));
    expect(report.findings.single.message, contains('matched no items'));
  });

  test('const and final field indexes remain distinct', () {
    expect(project.constFields, hasLength(1));
    expect(project.finalFields, isEmpty);
    expect(project.constFields.single.isConst, isTrue);
    expect(project.constFields.single.isFinal, isFalse);
  });
}
