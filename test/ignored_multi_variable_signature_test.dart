import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('ignoring one public variable does not ignore or report it with its siblings', () {
    final project = const HeimdallFileImporter(useCache: false).importPath(
      'test/ignored_multi_variable_signature_fixtures/lib',
    );
    expect(project.parseErrors, isEmpty);

    final report = Heimdall.code().publicSignaturesShouldNotUseDynamic(ignoredDeclarationNames: {'first'}).check(project);

    expect(report.findings, hasLength(1));
    expect(report.findings.single.message, contains('second'));
  });
}
