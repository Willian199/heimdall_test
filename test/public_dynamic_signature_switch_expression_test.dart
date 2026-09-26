import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  test('infers dynamic through supported expression forms', () {
    final project = const HeimdallFileImporter(useCache: false).importPath(
      'test/code_fixtures/dynamic_signatures/switch_expression',
    );
    expect(project.parseErrors, isEmpty);

    final report = Heimdall.code().publicSignaturesShouldNotUseDynamic().check(project);

    expect(
      report.findings.map((finding) => finding.message),
      containsAll([
        'inferFromSwitch has public dynamic return type',
        'inferFromArithmetic has public dynamic return type',
        'inferFromCoalesce has public dynamic return type',
        'inferFromCascade has public dynamic return type',
        'inferFromUnary has public dynamic return type',
        'inferFromConstructorTearoff has public dynamic return type',
        'inferFromAssignment has public dynamic return type',
        'inferFromDynamicInvocation has public dynamic return type',
        'inferFromDynamicProperty has public dynamic return type',
        'inferFromPostfixIncrement has public dynamic return type',
        'inferFromPrefixIncrement has public dynamic return type',
        'inferFromForInBinding has public dynamic return type',
        'inferFromCStyleForBinding has public dynamic return type',
        'inferFromIfCaseBinding has public dynamic return type',
        'inferFromSwitchStatementBinding has public dynamic return type',
        'inferFromCollectionIfBinding has public dynamic return type',
        'inferFromCollectionForBinding has public dynamic return type',
        'inferFromSwitchExpressionBinding has public dynamic return type',
        'inferFromSwitchRecordBinding has public dynamic return type',
        'inferFromIfCaseRecordBinding has public dynamic return type',
        'inferFromMapPatternBinding has public dynamic return type',
        'inferFromListPatternBinding has public dynamic return type',
        'inferFromForInRecordBinding has public dynamic return type',
        'inferFromSwitchStatementRecordBinding has public dynamic return type',
        'inferFromCollectionIfRecordBinding has public dynamic return type',
        'inferFromRecordVariablePattern has public dynamic return type',
        'inferFromListVariablePattern has public dynamic return type',
        'inferFromMapVariablePattern has public dynamic return type',
        'inferFromAwaitForBinding has public dynamic return type',
        'inferFromAwaitForCollectionBinding has public dynamic return type',
        'inferFromListFirst has public dynamic return type',
        'inferFromIterableSingle has public dynamic return type',
        'inferFromSetLast has public dynamic return type',
        'inferFromMapValues has public dynamic return type',
        'inferFromMapKeys has public dynamic return type',
        'inferFromIteratorCurrent has public dynamic return type',
      ]),
    );
  });
}
