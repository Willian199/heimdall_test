import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

import 'code_fixtures/dynamic_signatures/mixin_inference/dynamic.dart' as dynamic_fixtures;
import 'code_fixtures/dynamic_signatures/mixin_inference/edges/additional/cases.dart' as additional_fixtures;
import 'code_fixtures/dynamic_signatures/mixin_inference/edges/cases.dart' as edge_fixtures;
import 'code_fixtures/dynamic_signatures/mixin_inference/edges/deep/cases.dart' as deep_fixtures;
import 'code_fixtures/dynamic_signatures/mixin_inference/edges/homonyms/cases.dart' as homonym_fixtures;
import 'code_fixtures/dynamic_signatures/mixin_inference/imports.dart' as imported_fixtures;
import 'code_fixtures/dynamic_signatures/mixin_inference/matrix/calls.dart' as calls;
import 'code_fixtures/dynamic_signatures/mixin_inference/matrix/contracts.dart' as contracts;
import 'code_fixtures/dynamic_signatures/mixin_inference/matrix/generics.dart' as generics;
import 'code_fixtures/dynamic_signatures/mixin_inference/matrix/interfaces.dart' as interfaces;
import 'code_fixtures/dynamic_signatures/mixin_inference/matrix/members.dart' as members;
import 'code_fixtures/dynamic_signatures/mixin_inference/matrix/relationships.dart' as relationships;
import 'code_fixtures/dynamic_signatures/mixin_inference/safe.dart' as fixtures;

void main() {
  const fixture = 'test/code_fixtures/dynamic_signatures/mixin_inference';
  final project = const HeimdallFileImporter(useCache: false).importPath(fixture);

  test('fixtures compile with Dart mixin inference intact', () {
    expect(fixtures.Counter().types, (int, String));
    expect(fixtures.Indirect().types, (int, String));
    expect(fixtures.Generic<bool>().types, (bool, String));
    expect(fixtures.Alias().types, (int, String));
    expect(fixtures.Prefixed().types, (int, String));
    expect(fixtures.AliasedBase().types, (int, String));
    expect(fixtures.AliasedMixin().types, (int, String));
    expect(fixtures.InterfaceCounter().types, (int, String));
    expect(dynamic_fixtures.ActualDynamic().types, (dynamic, String));
    expect(dynamic_fixtures.AliasedDynamic().types, (dynamic, String));
    expect(imported_fixtures.QueueCounter().elementType, int);
    expect(imported_fixtures.DynamicQueue().elementType, dynamic);
    expect(imported_fixtures.Shadowed().types, (dynamic, String));
  });

  test('infers mixin arguments from on constraints and the applied superclass', () {
    expect(project.parseErrors, isEmpty);
    final report = Heimdall.code().publicSignaturesShouldNotUseDynamic(pathPattern: 'safe.dart').check(project);
    expect(report.findings, isEmpty);
  });

  test('retains dynamic arguments, unconstrained parameters and inherited signatures', () {
    final report = Heimdall.code().publicSignaturesShouldNotUseDynamic(pathPattern: 'dynamic.dart').check(project);
    expect(
      report.findings.map((finding) => finding.message),
      unorderedEquals([
        'ActualDynamic has public dynamic supertype or extension target: Logging',
        'PartialCounter has public dynamic supertype or extension target: Partial',
        'ExplicitDynamic has public dynamic supertype or extension target: Base<dynamic, String>',
        'ExplicitDynamic has public dynamic supertype or extension target: Logging<dynamic, String>',
        'RawPlain has public dynamic supertype or extension target: Plain',
        'NestedDynamic has public dynamic supertype or extension target: Base<List<dynamic>, String>',
        'NestedDynamic has public dynamic supertype or extension target: Nested',
        'RecordDynamic has public dynamic supertype or extension target: Base<(int, {dynamic value}), String>',
        'RecordDynamic has public dynamic supertype or extension target: Recorded',
        'ChainDynamic has public dynamic supertype or extension target: Bridge',
        'ChainDynamic has public dynamic supertype or extension target: Following',
        'AliasedDynamic has public dynamic supertype or extension target: LoggingAlias',
        'CallbackDynamic has public dynamic supertype or extension target: Base<dynamic Function(), String>',
        'CallbackDynamic has public dynamic supertype or extension target: Callback',
        'AliasRecordDynamic has public dynamic supertype or extension target: Base<DynamicRecord, String>',
        'AliasRecordDynamic has public dynamic supertype or extension target: Recorded',
        'PatternRecordDynamic has public dynamic supertype or extension target: Base<DynamicRecord, String>',
        'PatternRecordDynamic has public dynamic supertype or extension target: AliasedRecord',
        'SharedAliasRecordDynamic has public dynamic supertype or extension target: Base<RecordPattern<dynamic>, String>',
        'SharedAliasRecordDynamic has public dynamic supertype or extension target: AliasedRecord',
        'DynamicOverrides has public dynamic supertype or extension target: Logging',
        'read has public dynamic return type',
        'inheritedDynamic has public dynamic type',
        'MixedBase has public dynamic supertype or extension target: Base<dynamic, String>',
        'MixedBase has public dynamic supertype or extension target: Iterable<dynamic>',
        'MixedDynamic has public dynamic supertype or extension target: MixedConstraints',
      ]),
    );
  });

  test('follows allowlisted package types and preserves declaration identity', () {
    final project = HeimdallFileImporter(
      useCache: false,
      referenceOptions: ReferenceImportOptions(packages: ['collection']),
    ).importPath(fixture);
    final declarations = project.declarations.toList();
    final report = Heimdall.code().publicSignaturesShouldNotUseDynamic(pathPattern: 'imports.dart').check(project);
    expect(
      report.findings.map((finding) => finding.message),
      unorderedEquals([
        'DynamicQueueBase has public dynamic supertype or extension target: HeapPriorityQueue<dynamic>',
        'DynamicQueue has public dynamic supertype or extension target: QueueLogging',
        'Shadowed has public dynamic supertype or extension target: Logging',
      ]),
    );
    expect(project.declarations, orderedEquals(declarations));
  });

  test('missing reference sources leave constrained arguments unknown', () {
    final project = const HeimdallFileImporter(
      useCache: false,
      referenceOptions: ReferenceImportOptions.none(),
    ).importPath(fixture);
    expect(Heimdall.code().publicSignaturesShouldNotUseDynamic(pathPattern: 'safe.dart').check(project).findings, isEmpty);
    expect(
      Heimdall.code().publicSignaturesShouldNotUseDynamic(pathPattern: 'dynamic.dart').check(project).findings.map((finding) => finding.message),
      contains('MixedDynamic has public dynamic supertype or extension target: MixedConstraints'),
    );
  });

  group('mixin inference edge cases', () {
    for (final edge in [...edge_fixtures.cases, ...additional_fixtures.cases, ...deep_fixtures.cases, ...homonym_fixtures.cases]) {
      test(edge.name, () {
        expect(edge.actual(), edge.expected, reason: 'Native Dart inference for ${edge.file}');
        final report = Heimdall.code().publicSignaturesShouldNotUseDynamic(pathPattern: 'edges/${edge.file}').check(project);
        expect(report.findings.map((finding) => finding.message), unorderedEquals(edge.findings), reason: edge.file);
      });
    }
  });

  test('one resolver keeps homonymous types separate across source files and import prefixes', () {
    final report = Heimdall.code().publicSignaturesShouldNotUseDynamic(pathPattern: 'edges/homonyms/homonyms_*.dart').check(project);
    expect(
      report.findings.map((finding) => (project.filesByPath[finding.filePath]!.relativePath, finding.message)),
      unorderedEquals([
        for (final edge in homonym_fixtures.cases)
          for (final message in edge.findings) ('edges/${edge.file}', message),
      ]),
    );
  });

  group('generic type discovery matrix', () {
    List<String> messagesFor(String file) => Heimdall.code()
        .publicSignaturesShouldNotUseDynamic(pathPattern: 'matrix/$file.dart')
        .check(project)
        .findings
        .map((finding) => finding.message)
        .toList();

    test('extends, implements, abstract classes, interfaces and mixin classes preserve arguments', () {
      expect(relationships.AbstractLeaf(1).argumentType, int);
      expect(relationships.AbstractLeaf(1).observedType, int);
      expect(relationships.AbstractLeaf(1).facadeType, int);
      expect(relationships.GenericLeaf<String>('value').argumentType, String);
      expect(relationships.MixinClassLeaf('value').argumentType, String);
      expect(relationships.ImplementsApplication(1).fetch(), 1);
      expect(relationships.NamedApplication('value').facadeType, String);
      expect(relationships.ImplementsAbstractAccess(1).current, 1);
      expect(relationships.DynamicAbstractLeaf(1).facadeType, dynamic);
      expect(
        messagesFor('relationships'),
        unorderedEquals([
          'DynamicInterfaceStore has public dynamic supertype or extension target: InterfaceStore<dynamic>',
          'DynamicInterfaceStore has public dynamic parameter value',
          'DynamicAbstractLeaf has public dynamic supertype or extension target: Access',
          'DynamicAbstractLeaf has public dynamic supertype or extension target: Observe',
          'DynamicAbstractLeaf has public dynamic supertype or extension target: FacadeAccess',
          'DynamicAbstractLeaf has public dynamic parameter value',
        ]),
      );
    });

    test('nested, reordered, nullable, bounded and dependent generic arguments match Dart', () {
      expect(generics.ReorderedSafe().pairTypes, (String, _typeOf<List<int?>>()));
      expect(generics.ReorderedDynamic().pairTypes, (String, _typeOf<List<dynamic>>()));
      expect(generics.DependentSafe(1).dependentTypes, (int, _typeOf<List<int>>()));
      expect(generics.DependentDynamic(1).dependentTypes, (dynamic, _typeOf<List<dynamic>>()));
      expect(generics.PayloadSafe({}).payloadType, _typeOf<int?>());
      expect(generics.PayloadDynamic({}).payloadType, dynamic);
      expect(generics.NullableSafe(null).nullableType, _typeOf<int?>());
      expect(generics.NullableDynamic(1).nullableType, dynamic);
      expect(generics.BoundedSafe(1).numberType, int);
      expect(generics.FactorySafe(() => 1).resultType, int);
      expect(generics.FactoryDynamic(() => 1).resultType, dynamic);
      expect(
        messagesFor('generics'),
        unorderedEquals([
          'ReorderedDynamic has public dynamic supertype or extension target: Reordered<dynamic, String>',
          'ReorderedDynamic has public dynamic supertype or extension target: PairAccess',
          'DependentDynamic has public dynamic supertype or extension target: Dependent',
          'DependentDynamic has public dynamic parameter value',
          'PayloadDynamic has public dynamic supertype or extension target: StoreBase<Payload<dynamic>>',
          'PayloadDynamic has public dynamic supertype or extension target: PayloadAccess',
          'PayloadDynamic has public dynamic parameter value',
          'NullableDynamic has public dynamic supertype or extension target: NullableAccess',
          'NullableDynamic has public dynamic parameter value',
          'FactoryDynamic has public dynamic supertype or extension target: StoreBase<dynamic Function()>',
          'FactoryDynamic has public dynamic supertype or extension target: FactoryAccess',
          'FactoryDynamic has public dynamic parameter value',
        ]),
      );
    });

    test('method, getter and setter overrides inherit instantiated mixin signatures', () {
      final typed = members.TypedOverrides(1)..current = 2;
      expect(typed.current, 2);
      typed.replace(3);
      expect(typed.fetch(), 3);
      final untyped = members.DynamicOverrides(1)..current = 'value';
      expect(untyped.current, 'value');
      untyped.replace(true);
      expect(untyped.fetch(), isTrue);
      expect(
        messagesFor('members'),
        unorderedEquals([
          'DynamicOverrides has public dynamic supertype or extension target: Access',
          'DynamicOverrides has public dynamic parameter value',
          'fetch has public dynamic return type',
          'current has public dynamic return type',
          'current has public dynamic parameter next',
          'replace has public dynamic parameter next',
        ]),
      );
    });

    test('unannotated abstract interface members inherit generic method and accessor types', () {
      final typed = interfaces.InterfaceOverrides(1)..value = 2;
      expect(typed.read(), 2);
      typed.write(3);
      expect(typed.value, 3);
      expect(
        messagesFor('interfaces'),
        unorderedEquals([
          'DynamicInterface has public dynamic supertype or extension target: Store<dynamic>',
          'read has public dynamic return type',
          'value has public dynamic return type',
          'value has public dynamic parameter next',
          'write has public dynamic parameter next',
        ]),
      );
    });

    test('method calls, getters, tear-offs, closures, cascades and generic calls retain result types', () {
      expect(calls.typedMethod, 1);
      expect(calls.typedGetter, 1);
      expect(calls.typedIdentity, 'value');
      expect(calls.explicitIdentity, [1]);
      expect(calls.typedTearOff(), 1);
      expect(calls.typedClosure(), 1);
      expect(calls.typedOverrideMethod, 1);
      expect(calls.typedOverrideGetter, 1);
      expect(calls.typedCascade, 2);
      expect(calls.typedAssignment, 2);
      expect(calls.typedInterfaceCall, 1);
      expect(calls.typedInterfaceGetter, 1);
      expect(calls.typedNamed, 'value');
      expect(calls.typedOptional, 2);
      expect(calls.typedSecond, 'value');
      expect(calls.typedWrap, ['value']);
      expect(calls.typedNestedIdentity, 'value');
      expect(calls.safeShadow, 2);
      expect(calls.dynamicTearOff(), 1);
      expect(calls.dynamicClosure(), 1);
      expect(calls.safeDynamicAssignment, 2);
      expect(contracts.TypedStore(1).inferredType(contracts.TypedStore(1).current), int);
      expect(contracts.TypedStore(1).inferredType(contracts.DynamicStore(1).current), dynamic);
      expect(contracts.TypedStore(1).inferredType(calls.typedWrap), _typeOf<List<String>>());
      expect(contracts.TypedStore(1).inferredType(calls.dynamicWrap), _typeOf<List<dynamic>>());
      expect(
        messagesFor('calls'),
        unorderedEquals([
          for (final name in [
            'dynamicMethod',
            'dynamicGetter',
            'dynamicTearOff',
            'dynamicClosure',
            'explicitDynamicIdentity',
            'inferredDynamicIdentity',
            'dynamicOverrideMethod',
            'dynamicOverrideGetter',
            'dynamicCascade',
            'dynamicInterface',
            'dynamicInterfaceCall',
            'dynamicInterfaceGetter',
            'dynamicNamed',
            'dynamicSecond',
            'dynamicWrap',
            'dynamicNestedIdentity',
            'dynamicShadow',
          ])
            '$name has public dynamic type',
        ]),
      );
    });

    test('generic contracts and on constraints expose dynamic only at concrete instantiations', () {
      final typed = contracts.TypedStore(1)
        ..current = 2
        ..replace(3);
      expect(typed.current, 3);
      expect(typed.identity<String>('value'), 'value');
      expect(
        messagesFor('contracts'),
        unorderedEquals([
          'DynamicStore has public dynamic supertype or extension target: StoreBase<dynamic>',
          'DynamicStore has public dynamic supertype or extension target: Access',
          'DynamicStore has public dynamic parameter value',
        ]),
      );
    });
  });
}

Type _typeOf<T>() => T;
