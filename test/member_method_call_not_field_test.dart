import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  late HeimdallProject project;

  setUpAll(() {
    project = const HeimdallFileImporter(useCache: false).importPath(
      'test/member_fixtures/method_call_not_field',
    );
    expect(project.parseErrors, isEmpty);
  });

  test('a same-named method invocation is not field access', () {
    final report = Heimdall.methods().that().haveName('callValue').should().notAccessField('value').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('a for-in record pattern variable is not field access', () {
    final report = Heimdall.methods().that().haveName('callPattern').should().notAccessField('name').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  for (final methodName in ['callIfCollectionPattern', 'callForCollectionPattern']) {
    test('$methodName pattern variables are not field access', () {
      final report = Heimdall.methods().that().haveName(methodName).should().notAccessField('name').check(project);

      expect(report.checkedCount, 1);
      expect(report.findings, isEmpty);
    });
  }

  test('a collection for variable does not hide the field after its element', () {
    final report = Heimdall.methods().that().haveName('readFieldAfterCollectionLoop').should().accessField('value').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('a for-in binding does not shadow the field in the iterable expression', () {
    final report = Heimdall.methods().that().haveName('iterateFieldBeforeLoopBinding').should().accessField('values').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('a C-style for variable does not hide the field after its loop', () {
    final report = Heimdall.methods().that().haveName('readFieldAfterLoop').should().accessField('index').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  for (final methodName in [
    'readStatementPattern',
    'readExpressionPattern',
    'readBoundNameInGuard',
    'readListPattern',
    'readMapPattern',
  ]) {
    test('$methodName pattern variables are not field access', () {
      final report = Heimdall.methods().that().haveName(methodName).should().notAccessField('name').check(project);

      expect(report.checkedCount, 1);
      expect(report.findings, isEmpty);
    });
  }

  test('a local record-pattern variable does not count as field access', () {
    final report = Heimdall.methods().that().haveName('readLocalPattern').should().notAccessField('name').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('a named argument label is not field access', () {
    final report = Heimdall.methods().that().haveName('callWithoutReadingField').should().notAccessField('value').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('a named record field label is not field access', () {
    final report = Heimdall.methods().that().haveName('callWithoutReadingFieldInRecord').should().notAccessField('value').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  for (final methodName in ['readCatchStackTrace', 'readCatchException', 'readForPattern']) {
    test('$methodName local bindings are not field access', () {
      final report = Heimdall.methods()
          .that()
          .haveName(methodName)
          .should()
          .notAccessField(switch (methodName) {
            'readForPattern' => 'name',
            'readCatchException' => 'failure',
            _ => 'stack',
          })
          .check(project);

      expect(report.checkedCount, 1);
      expect(report.findings, isEmpty);
    });
  }

  test('writing a same-named field on another object is not access to this field', () {
    final report = Heimdall.methods().that().haveName('writeOther').should().notAccessField('value').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('writing a same-named field through another object cascade is not access to this field', () {
    final report = Heimdall.methods().that().haveName('writeOtherThroughCascade').should().notAccessField('value').check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });
}
