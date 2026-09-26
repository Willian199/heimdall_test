import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  late HeimdallProject project;
  setUpAll(() {
    project = const HeimdallFileImporter(useCache: false).importPath(
      'test/member_fixtures/access_field_receiver',
    );
  });

  group('accessField tracks the owning member scope', () {
    test('fixture parses successfully', () {
      expect(project.parseErrors, isEmpty);
    });

    test('ignores same-named properties on other receivers', () {
      final report = Heimdall.methods().that().haveName('readOtherName').should().accessField('name').check(project);

      expect(report.checkedCount, 1);
      expect(report.findings, hasLength(1));
      expect(report.findings.single.message, contains('does not access field name'));
    });

    test('recognizes an owning field read in a for-in iterable', () {
      final report = Heimdall.methods().that().haveName('countEntries').should().accessField('entries').check(project);

      expect(report.checkedCount, 1);
      expect(report.findings, isEmpty);
    });

    test('recognizes an owning field read after a for-in scope ends', () {
      final report = Heimdall.methods().that().haveName('readNameAfterLoop').should().accessField('name').check(project);

      expect(report.checkedCount, 1);
      expect(report.findings, isEmpty);
    });

    test('does not count a pattern variable as an owning field read', () {
      final report = Heimdall.methods().that().haveName('readPattern').should().accessField('name').check(project);

      expect(report.checkedCount, 1);
      expect(report.findings, hasLength(1));
      expect(report.findings.single.message, contains('does not access field name'));
    });

    test('does not count a catch parameter as an owning field read', () {
      final report = Heimdall.methods().that().haveName('catchName').should().accessField('name').check(project);

      expect(report.checkedCount, 1);
      expect(report.findings, hasLength(1));
      expect(report.findings.single.message, contains('does not access field name'));
    });
  });
}
