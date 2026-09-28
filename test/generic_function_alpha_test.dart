import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('generic function type parameters compare by binding, not spelling', () {
    final project = const HeimdallFileImporter(useCache: false).importPath(
      'test/generic_function_alpha_fixtures/lib',
    );
    expect(project.files.single.parseErrors, isEmpty);

    final report = Heimdall.fields().that().haveName('identity').should().haveDeclaredFieldTypeAssignableTo('U Function<U>(U)').check(project);

    expect(report.findings, isEmpty);

    for (final incompatible in ['U Function<U extends num>(U)', 'int Function(int)', 'int Function<U>(U)']) {
      Heimdall.fields().that().haveName('identity').should().notHaveDeclaredFieldTypeAssignableTo(incompatible).check(project).assertNoFindings();
    }
  });
}
