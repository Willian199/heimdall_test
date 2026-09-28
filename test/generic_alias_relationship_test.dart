import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('extends follows the type arguments of a generic superclass alias', () {
    final project = const HeimdallFileImporter(useCache: false).importPath(
      'test/generic_alias_relationship_fixtures/lib',
    );

    final report = Heimdall.classes().that().haveTypeName('ChildThroughAlias').should().extend('GenericParent<int>').check(project);

    expect(report.findings, isEmpty);
  });
}
