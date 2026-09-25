import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  late HeimdallProject project;

  setUpAll(() {
    project = const HeimdallFileImporter(useCache: false).importPath(
      'test/member_fixtures/prefixed_super_formal',
    );
    expect(project.parseErrors, isEmpty);
  });

  test('resolves a super formal through a prefixed superclass', () {
    final report = Heimdall.constructors()
        .that()
        .areDeclaredInClassesThat(HeimdallPredicate('are Child', (item, _) => item.name == 'Child'))
        .should()
        .receiveParameterTypeName('String')
        .check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, isEmpty);
  });

  test('does not resolve a prefixed super formal to an unrelated local class', () {
    final report = Heimdall.constructors()
        .that()
        .areDeclaredInClassesThat(HeimdallPredicate('are Child', (item, _) => item.name == 'Child'))
        .should()
        .receiveParameterTypeName('int')
        .check(project);

    expect(report.checkedCount, 1);
    expect(report.findings, hasLength(1));
  });
}
