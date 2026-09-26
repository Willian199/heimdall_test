// Compile the exact fixture sources to verify Dart semantics as well as the
// package's parsed-source rules. These libraries intentionally live under test.
// ignore_for_file: avoid_relative_lib_imports

import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

import 'bug_audit_fixtures/lib/hierarchy_cases.dart' as hierarchy;
import 'bug_audit_fixtures/lib/relationship_cases.dart' as relationships;
import 'bug_audit_fixtures/lib/signature_cases.dart' as signatures;
import 'bug_audit_fixtures/lib/signature_closures.dart' as closures;

void main() {
  final project = const HeimdallFileImporter(useCache: false).importPath('test/bug_audit_fixtures');

  test('Dart accepts mixin interfaces, aliases and enum mixins', () {
    final implementations = <hierarchy.AuditContract>[
      hierarchy.DirectMixinWorker(),
      hierarchy.ChildMixinWorker(),
      const hierarchy.AliasMixinWorker(),
      hierarchy.EnumMixinWorker.one,
    ];
    expect(implementations, hasLength(4));
    Heimdall.classes().that().haveTypeName('AliasMixinWorker').should().implement('AuditContract').check(project).assertNoFindings();
    Heimdall.classes().that().haveTypeName('AliasMixinWorker').should().applyMixin('AuditContractMixin').check(project).assertNoFindings();
  });

  test('Dart infers closure returns but unannotated top-level functions return dynamic', () {
    expect(signatures.keyCount, isNot(isA<int Function()>()));
    expect(signatures.keyCount(), isA<int>());
    expect(closures.keyCount, isA<int Function()>());
    expect(closures.valueCount, isA<int Function()>());
    expect(closures.keyJoined, isA<String Function()>());
    expect(closures.valueAny, isA<bool Function()>());
    expect(closures.keyIteratorCanMove, isA<bool Function()>());
    expect(closures.entry, isA<MapEntry<dynamic, String> Function()>());
  });

  test('conditional and loop collection elements can be absent at runtime', () {
    expect(relationships.ConditionalListField().props(false), isEmpty);
    expect(relationships.LoopListField().props([]), isEmpty);
  });

  test('dynamic inference preserves concrete transforms and local members', () {
    final report = Heimdall.code().publicSignaturesShouldNotUseDynamic(pathPattern: 'lib/controls.dart').check(project);
    for (final name in ['knownMapped', 'knownExpanded', 'knownCast', 'knownMapCast', 'knownEntryValue', 'knownEntryKey', 'knownLocalFirst']) {
      expect(report.findings.where((finding) => finding.message.startsWith('$name ')), isEmpty, reason: name);
    }
    for (final name in ['dynamicEntryKey', 'dynamicEntryValue', 'dynamicLocalList']) {
      expect(report.findings.where((finding) => finding.message.startsWith('$name ')), isNotEmpty, reason: name);
    }
  });

  test('closure signatures preserve collection generics and concrete scalar results', () {
    final report = Heimdall.code().publicSignaturesShouldNotUseDynamic(pathPattern: 'lib/signature_closures.dart').check(project);
    for (final name in [
      'keyCount',
      'valueCount',
      'keyIsEmpty',
      'valueIsEmpty',
      'keyIsNotEmpty',
      'valueIsNotEmpty',
      'keyListLength',
      'valueListLength',
      'keyJoined',
      'valueJoined',
      'keyAny',
      'valueAny',
      'keyIteratorCanMove',
      'valueIteratorCanMove',
      'keyContains',
      'valueContains',
      'keyLengthPlus',
      'valueLengthPlus',
      'keyLengthComparison',
    ]) {
      expect(report.findings.where((finding) => finding.message.startsWith('$name ')), isEmpty, reason: name);
    }
    for (final name in [
      'entry',
      'itemsAsList',
      'itemsFiltered',
      'itemsMapped',
      'itemsAsSet',
      'itemsSkipped',
      'itemsTaken',
      'itemsFirstWhere',
      'itemsLastWhere',
      'itemsSingleWhere',
      'itemsElementAt',
      'itemsRemoveAt',
      'itemsRemoveLast',
      'itemsExpanded',
      'itemsFollowedBy',
      'itemsGetRange',
      'itemsSublist',
      'itemsReversed',
      'itemsSkipWhile',
      'itemsTakeWhile',
      'itemsCast',
      'mapRemove',
      'mapPutIfAbsent',
      'mapCast',
      'mapUpdate',
    ]) {
      expect(report.findings.where((finding) => finding.message.startsWith('$name ')), hasLength(1), reason: name);
    }
  });

  test('a pattern binding does not hide the field in the else branch', () {
    final report = Heimdall.methods().that().haveName('read').should().notAccessField('value').check(project);
    expect(report.findings, hasLength(1));
  });

  test('unconditional fields remain guaranteed alongside optional elements', () {
    for (final (field, method) in [('conditionalAlways', 'branchAndAlways'), ('loopAlways', 'loopAndAlways')]) {
      Heimdall.fields().that().haveName(field).should().beIncludedInEveryReturnedListOf(method).check(project).assertNoFindings();
    }
  });
}
