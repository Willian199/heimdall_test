import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('a named-argument label is not an identifier reference', () {
    final project = const HeimdallFileImporter(useCache: false).importPath(
      'test/named_argument_identifier_fixtures/lib',
    );

    final report = Heimdall.classes().that().haveTypeName('NamedArgumentOnly').should().notReferenceIdentifier('value').check(project);

    expect(report.findings, isEmpty);
  });
}
