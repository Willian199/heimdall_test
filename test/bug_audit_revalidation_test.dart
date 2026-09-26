// Compile the fixtures to check the language's inferred types independently.
// ignore_for_file: avoid_relative_lib_imports

import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

import 'bug_audit_fixtures/lib/revalidation.dart' as examples;

void main() {
  final project = const HeimdallFileImporter(useCache: false).importPath('test/bug_audit_fixtures');
  final report = Heimdall.code().publicSignaturesShouldNotUseDynamic(pathPattern: 'lib/revalidation.dart').check(project);

  for (final name in [
    'nestedLength', 'inferredLength', 'mappedLength', 'callbackLength',
    'typedCallback', 'nestedCastLength', 'rawMappedLength',
  ]) {
    test('$name does not expose dynamic', () {
      expect(report.findings.where((finding) => finding.message.startsWith('$name ')), isEmpty);
    });
  }

  for (final name in ['explicitDynamicParameter', 'tearOffCallback']) {
    test('$name retains dynamic in the callback result', () {
      expect(report.findings.where((finding) => finding.message.startsWith('$name ')), hasLength(1));
    });
  }

  test('the Dart compiler independently confirms collection expression types', () {
    expect(examples.nestedLength, isA<int Function()>());
    expect(examples.inferredLength, isA<int Function()>());
    expect(examples.mappedLength, isA<int Function()>());
    expect(examples.callbackLength, isA<Iterable<int> Function()>());
    expect(examples.typedCallback, isA<Iterable<Object?> Function()>());
    expect(examples.nestedCastLength, isA<int Function()>());
    expect(examples.explicitDynamicParameter, isNot(isA<Iterable<int> Function()>()));
    expect(examples.tearOffCallback, isNot(isA<Iterable<int> Function()>()));
  });

  test('a method name does not hide a prefixed constructor', () {
    Heimdall.methods().that().haveName('prefixedConstruction').should()
        .callConstructorWithArguments('Product').check(project).assertNoFindings();
  });

  test('a local function is not a constructor', () {
    Heimdall.methods().that().haveName('localFunctionCall').should()
        .notCallConstructor('ProducedValue').check(project).assertNoFindings();
    Heimdall.methods().that().haveName('localFunctionCall').should()
        .notCallConstructorWithArguments('ProducedValue').check(project).assertNoFindings();
  });
}
