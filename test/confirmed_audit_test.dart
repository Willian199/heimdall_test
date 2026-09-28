import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

// All source models come from static fixtures through the public importer.
// Assertions describe correct behavior, so confirmed regressions fail.
void main() {
  late HeimdallProject project;
  setUpAll(() {
    project = const HeimdallFileImporter(useCache: false).importPath('test/confirmed_audit_fixtures/lib');
    for (final file in project.files) {
      expect(file.parseErrors, isEmpty, reason: file.relativePath);
    }
  });

  final assignability = <(String, String, String, bool)>[
    ('A01 List implements Iterable', 'list', 'Iterable<int>', true),
    ('A02 Set implements Iterable', 'set', 'Iterable<int>', true),
    ('A03 Queue implements Iterable', 'queue', 'Iterable<int>', true),
    ('A04 HashSet implements Set', 'hashSet', 'Set<int>', true),
    ('A05 HashMap implements Map', 'hashMap', 'Map<String, int>', true),
    ('A06 typed bytes implement List', 'bytes', 'List<int>', true),
    ('A07 int implements Comparable<num>', 'integer', 'Comparable<num>', true),
    ('A08 String implements Pattern', 'string', 'Pattern', true),
    ('A09 Future enters FutureOr union', 'future', 'FutureOr<int>', true),
    ('A10 value enters FutureOr union', 'integer', 'FutureOr<int>', true),
    ('A12 Null assignable to void', 'nil', 'void', true),
    ('A13 void assignable to dynamic', 'nothing', 'dynamic', true),
    ('A14 bounded class type parameter', 'bounded', 'num', true),
    ('A15 record implements Record', 'record', 'Record', true),
    ('A16 positional record covariance', 'record', '(num, Object)', true),
    ('A17 named record covariance', 'namedRecord', '({num a, Object b})', true),
    ('A18 named record order is irrelevant', 'namedRecord', '({String b, int a})', true),
    ('A19 function return covariance and parameter contravariance', 'function', 'num Function(int)', true),
    ('A20 raw SDK generic instantiates dynamic', 'listRaw', 'List<dynamic>', true),
    ('A21 nullable value assignable to void', 'nullableInt', 'void', true),
    ('A23 void type argument compatible with dynamic', 'voidList', 'List<dynamic>', true),
    ('A24 Null type argument compatible with void', 'nullList', 'List<void>', true),
  ];
  for (final (name, field, target, expected) in assignability) {
    test(name, () {
      final report = _member('TypeCases', field).haveDeclaredFieldTypeAssignableTo(target).check(project);
      _expectReport(report, expected);
    });
  }

  test('A25 super positional parameter may be renamed', () {
    _expectReport(_member('Renamed', 'new').receiveParameterTypeName('int').check(project), true);
  });
  test('A26 raw superclass uses bound for super parameter', () {
    _expectReport(_member('RawChild', 'new').receiveParameterTypeName('num').check(project), true);
  });
  test('A27 bounded method parameter is assignable to num', () {
    _expectReport(_member('BoundedMember', 'accept').receiveParameterAssignableTo('num').check(project), true);
  });
  test('A28 generic implements retains actual argument', () {
    _expectReport(_class('GenericImplementation').implement('Contract<int>').check(project), true);
  });
  test('A29 generic extends retains actual argument', () {
    _expectReport(_class('GenericExtended').extend('Parent<int>').check(project), true);
  });
  test('A30 generic mixin retains actual argument', () {
    _expectReport(_class('GenericMixed').applyMixin('GenericMixin<int>').check(project), true);
  });
  test('A31 mixin on constraint provides assignability', () {
    _expectReport(_class('Constrained').beAssignableTo('Parent<int>').check(project), true);
  });
  test('A32 nullable representation extension type is not Object', () {
    _expectReport(_class('NullableRepresentation').beAssignableTo('Object').check(project), false);
  });
  test('A34 function alias retains signature during assignability', () {
    _expectReport(_member('AliasCases', 'callback').haveDeclaredFieldTypeAssignableTo('num Function(int)').check(project), true);
  });

  test('B01 extension primary constructor is declared', () {
    _expectReport(_class('Primary').declareConstructor().check(project), true);
  });
  test('B02 extension primary const constructor is const', () {
    _expectReport(_class('Primary').declareConstConstructor().check(project), true);
  });
  test('B03 extension primary parameter is received', () {
    _expectReport(_class('Primary').receiveParameter('value').check(project), true);
  });
  test('B04 named primary constructor is declared', () {
    _expectReport(_class('NamedPrimary').declareConstructor(name: 'named').check(project), true);
  });
  test('B05 private primary constructor is private', () {
    _expectReport(_class('HiddenPrimary').haveOnlyPrivateConstructors().check(project), true);
  });

  final calls = <(String, String, String)>[
    ('C01 implicit unnamed constructor is not a method', 'constructorAsMethod', 'Product'),
    ('C02 implicit named constructor is not a method', 'namedConstructorAsMethod', 'named'),
  ];
  for (final (name, member, method) in calls) {
    test(name, () => _expectReport(_member('Calls', member).callMethod(method).check(project), false));
  }
  test('C03 prefixed SDK static call can match unqualified type', () {
    _expectReport(_member('Calls', 'sdkPrefixed').callStaticMethod('Future', 'wait').check(project), true);
  });
  test('C04 prefixed SDK constructor is detected', () {
    _expectReport(_member('Calls', 'sdkPrefixedConstructor').callConstructor('Completer').check(project), true);
  });
  test('C08 explicit new constructor invocation is detected', () {
    _expectReport(_member('Calls', 'explicitNew').callConstructor('Product').check(project), true);
  });
  test('C09 imported top-level function is not a constructor', () {
    _expectReport(_member('Calls', 'importedFunctionAsConstructor').callConstructor('importedFunction').check(project), false);
  });
  test('C11 invoked static callback field is not a static method', () {
    _expectReport(_member('Calls', 'fieldInvocation').callStaticMethod('Holder', 'callback').check(project), false);
  });
  test('C12 invoked static getter is not a static method', () {
    _expectReport(_member('Calls', 'getterInvocation').callStaticMethod('Holder', 'getter').check(project), false);
  });
  test('C13 explicit super constructor call is detected', () {
    _expectReport(_member('Initializers', 'new').callConstructor('Product').check(project), true);
  });
  test('C14 redirecting generative constructor call is detected', () {
    _expectReport(_member('Initializers', 'redirect').callConstructor('Initializers').check(project), true);
  });

  for (final (name, member, field) in <(String, String, String)>[
    ('D01 top-level variable is not an instance field', 'globalRead', 'topValue'),
    ('D02 type literal is not a field access', 'typeRead', 'Product'),
    ('D03 method tearoff is not a field access', 'methodTearoff', 'method'),
    ('D04 import prefix is not a field', 'importPrefixRead', 'dep'),
  ]) {
    test(name, () => _expectReport(_member('Access', member).accessField(field).check(project), false));
  }

  for (final (name, owner, expected) in <(String, String, bool)>[
    ('E01 named constructor forwards named argument', 'NamedCopy', true),
    ('E02 explicit new forwards named argument', 'NewCopy', true),
    ('E03 shadowed constructor name is a local function', 'ShadowCopy', false),
    ('E04 throw expression is not a constructor return', 'ThrowCopy', true),
    ('E05 finally overrides earlier constructor return', 'FinallyCopy', true),
  ]) {
    test(name, () => _expectReport(_member(owner, 'value').passMatchingParameterToReturnedConstructorIn('copyWith').check(project), expected));
  }
  test('E07 throw expression is not a returned list', () {
    _expectReport(_member('ThrowList', 'value').beIncludedInEveryReturnedListOf('props').check(project), true);
  });

  final signatures = <(String, String, bool)>[
    ('F01 assignment expression has RHS type', 'assignmentResult', false),
    ('F02 int arithmetic does not inherit dynamic argument type', 'integerSum', false),
    ('F03 int comparison returns bool', 'integerComparison', false),
    ('F04 int division returns double', 'integerDivision', false),
    ('F05 int shift returns int', 'integerShift', false),
    ('F06 bool xor returns bool', 'booleanXor', false),
    ('F07 overloaded unary minus returns dynamic', 'unaryMinus', true),
    ('F08 overloaded complement returns dynamic', 'unaryComplement', true),
    ('F09 overloaded addition returns dynamic', 'binaryOverload', true),
    ('F10 instance method tearoff exposes dynamic parameter', 'instanceTearoff', true),
    ('F11 static method tearoff exposes dynamic parameter', 'staticTearoff', true),
    ('F12 callback field invocation returns dynamic', 'callbackFieldResult', true),
    ('F15 record positional dynamic component escapes', 'recordPosition', true),
    ('F16 record named dynamic component escapes', 'recordName', true),
    ('F17 destructuring isolates concrete record component', 'destructuredRecord', false),
    ('F18 named destructuring isolates concrete component', 'destructuredNamed', false),
    ('F19 typed for-in variable is not dynamic iterable element', 'typedForLoop', false),
    ('F20 explicit pattern type is respected', 'typedPattern', false),
    ('F21 dynamic pattern annotation is respected', 'dynamicPattern', true),
    ('F22 null-aware list element exposes dynamic', 'nullAwareList', true),
    ('F23 null-aware set element exposes dynamic', 'nullAwareSet', true),
    ('F26 named generic constructor defaults to dynamic', 'rawNamedConstructor', true),
    ('F27 generic alias constructor defaults to dynamic', 'rawAliasConstructor', true),
    ('F28 invocation expands function typedef', 'functionAliasResult', true),
    ('F29 callable class invocation returns dynamic', 'callableResult', true),
    ('F30 untyped catch variable exposes dynamic', 'implicitCatch', true),
    ('F32 overridden setter uses setter signature', 'SetterOverride', true),
  ];
  for (final (name, declarationName, dynamicExpected) in signatures) {
    test(name, () {
      final declaration = project.declarations.singleWhere((item) => item.relativePath == 'signatures.dart' && item.name == declarationName);
      final result = Heimdall.code().publicSignaturesShouldNotUseDynamic().condition.evaluate(declaration, project);
      expect(result.passed, !dynamicExpected, reason: result.findings.join('\n'));
    });
  }

  for (final (name, field, target, expected) in <(String, String, String, bool)>[
    ('G01 local Object is not the SDK top type', 'text', 'Object', false),
    ('G02 local Never is not the SDK bottom type', 'userNever', 'String', false),
    ('G04 prefixed SDK int implements num', 'number', 'core.num', true),
    ('G05 prefixed SDK Object remains top type', 'text', 'core.Object', true),
    ('G06 prefixed SDK Null enters nullable type', 'nil', 'String?', true),
    ('G07 prefixed SDK Never remains bottom type', 'bottom', 'String', true),
    ('G08 prefixed Null generic covariance', 'nils', 'core.List<String?>', true),
  ]) {
    test(name, () => _expectReport(_member('ShadowTypes', field).haveDeclaredFieldTypeAssignableTo(target).check(project), expected));
  }
  test('G09 dependent instantiate-to-bound substitutes preceding parameter', () {
    _expectReport(_member('BoundCases', 'raw').haveDeclaredFieldTypeAssignableTo('DependentBounds<core.num, core.num>').check(project), true);
  });
  test('G11 super parameter prefix belongs to parent library', () {
    _expectReport(_member('ScopedChild', 'new').receiveParameterAssignableTo('child_scope.Holder').check(project), true);
  });
  test('G12 nested function argument retains concrete signature', () {
    _expectReport(
      _member('BoundCases', 'callbacks').haveDeclaredFieldTypeAssignableTo('core.List<core.num Function(core.int)>').check(project),
      true,
    );
  });
  test('G13 nested record arguments are covariant', () {
    _expectReport(_member('BoundCases', 'records').haveDeclaredFieldTypeAssignableTo('core.List<(core.num,)>').check(project), true);
  });
  test('G14 incompatible function typedef is rejected', () {
    _expectReport(_member('BoundCases', 'narrow').haveDeclaredFieldTypeAssignableTo('IncompatibleCallback').check(project), false);
  });
  test('G16 Null can inhabit FutureOr nullable value', () {
    _expectReport(_member('NullabilityCases', 'nil').haveDeclaredFieldTypeAssignableTo('FutureOr<int?>').check(project), true);
  });
  test('G17 concrete values are assignable to void', () {
    _expectReport(_member('NullabilityCases', 'integer').haveDeclaredFieldTypeAssignableTo('void').check(project), true);
  });
  test('H01 continuing signature rule preserves declaration selector', () {
    final rule = Heimdall.code().publicSignaturesShouldNotUseDynamic(pathPattern: 'signatures.dart');
    final before = rule.check(project);
    final after = rule.and().bePublic().check(project);
    expect(after.checkedCount, before.checkedCount);
  });
  test('H02 condition continuation preserves because explanation', () {
    final rule = _class('TypeCases').bePublic().because('audit explanation').and().haveTypeName('TypeCases');
    expect(rule.check(project).description, contains('audit explanation'));
  });
  test('H03 segment-sequence wildcard respects segment boundaries', () {
    final report = Heimdall.files().that().haveName('path_case.dart').should().resideInPath('..data/service..').check(project);
    _expectReport(report, false);
  });
}

MemberShouldBuilder _member(String owner, String name) => Heimdall.members()
    .that()
    .areDeclaredInClassesThat(HeimdallPredicate('owner $owner', (item, _) => item.name == owner))
    .and()
    .haveName(name)
    .should();

ClassShouldBuilder _class(String name) => Heimdall.classes().that().haveTypeName(name).should();

void _expectReport(HeimdallReport report, bool expected) {
  expect(report.checkedCount, 1, reason: 'The intended fixture subject must be selected.');
  expect(report.hasFindings, !expected, reason: '${report.description}\n${report.findings.join('\n')}');
}
