import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/util/extension/sdk/compilation_unit_member_extension.dart';
import 'package:test/test.dart';

import 'architecture_fixtures/configured_references/compile_all.dart' as fixtures;

const _root = 'test/architecture_fixtures/configured_references/lib';
const _queue = 'package:collection/src/priority_queue.dart';

void main() {
  setUpAll(fixtures.main);
  tearDown(HeimdallFileImporter.clearCache);

  final options = ReferenceImportOptions(sdkLibraries: ['dart:core', 'dart:async']);

  test('sdkLibraries reads actual core and async declarations without a type allowlist', () {
    final project = HeimdallFileImporter(referenceOptions: options, useCache: false).importPath(_root);
    final implicit = _declaration(project, 'ImplicitConsumer');
    final async = _declaration(project, 'AsyncConsumer');
    for (final name in ['DateTime', 'Stopwatch', 'StringBuffer', 'int']) {
      expect(implicit.sdkTypeName(name, project), name);
      expect(project.referenceTypes.visible(implicit, name).single.library!.uri, 'dart:core');
    }
    for (final name in ['Timer', 'Zone', 'AsyncError', 'Future', 'StreamController']) {
      expect(async.sdkTypeName(name, project), name);
      expect(project.referenceTypes.visible(async, name).single.library!.uri, 'dart:async');
    }
    expect(implicit.sdkTypeName('Never', project), 'Never');
    expect(implicit.sdkTypeName('DoesNotExist', project), isNull);
    expect(project.referenceLibraries.hasSdkInstanceMember('Timer', 'cancel'), isTrue);
    expect(project.referenceLibraries.library('dart:collection'), isNull);
  });

  test('sdkLibraries preserves prefixes, combinators, shadows, reexports and parts', () {
    final project = HeimdallFileImporter(referenceOptions: options, useCache: false).importPath(_root);
    final prefixed = _declaration(project, 'PrefixedConsumer');
    expect(prefixed.sdkTypeName('core.DateTime', project), 'DateTime');
    expect(prefixed.sdkTypeName('async.Timer', project), 'Timer');
    expect(prefixed.sdkTypeName('core.Never', project), 'Never');
    expect(prefixed.sdkTypeName('DateTime', project), isNull);
    expect(prefixed.sdkTypeName('Timer', project), isNull);
    expect(prefixed.sdkTypeName('Never', project), isNull);
    expect(prefixed.sdkTypeName('missing.Timer', project), isNull);
    final filtered = _declaration(project, 'FilteredConsumer');
    expect(filtered.sdkTypeName('Timer', project), 'Timer');
    for (final name in ['DateTime', 'StringBuffer', 'Future', 'Never']) {
      expect(filtered.sdkTypeName(name, project), isNull);
    }
    final shadowed = _declaration(project, 'ShadowedConsumer');
    for (final name in ['DateTime', 'Timer', 'Never']) {
      expect(shadowed.sdkTypeName(name, project), isNull);
    }
    final reexported = _declaration(project, 'ReexportedConsumer');
    expect(reexported.sdkTypeName('sdk.DateTime', project), 'DateTime');
    expect(reexported.sdkTypeName('sdk.Timer', project), 'Timer');
    expect(reexported.sdkTypeName('sdk.Never', project), 'Never');
    expect(reexported.sdkTypeName('sdk.Zone', project), isNull);
    expect(_declaration(project, 'PartConsumer').sdkTypeName('Timer', project), 'Timer');
  });

  test('sdkLibraries accepts other SDK libraries without assuming core or async', () {
    final project = HeimdallFileImporter(
      referenceOptions: ReferenceImportOptions(sdkLibraries: ['dart:convert']),
      useCache: false,
    ).importPath(_root);
    final source = _declaration(project, 'ImplicitConsumer');
    for (final name in ['JsonEncoder', 'Codec', 'StringConversionSink']) {
      expect(source.sdkTypeName(name, project), name);
      expect(project.referenceTypes.visible(source, name).single.library!.uri, 'dart:convert');
    }
    for (final name in ['DateTime', 'Timer', 'Never']) {
      expect(source.sdkTypeName(name, project), isNull);
    }
  });

  test('unconfigured SDK libraries are unavailable, including compiler-provided Never', () {
    final project = const HeimdallFileImporter(referenceOptions: ReferenceImportOptions.none(), useCache: false).importPath(_root);
    for (final (source, names) in [
      ('ImplicitConsumer', ['DateTime', 'Never']),
      ('AsyncConsumer', ['Timer', 'Zone']),
      ('PrefixedConsumer', ['core.int', 'core.Never', 'async.Timer']),
    ]) {
      final declaration = _declaration(project, source);
      for (final name in names) {
        expect(declaration.sdkTypeName(name, project), isNull);
      }
    }
  });

  for (final usePackages in [false, true]) {
    test('package consultation still works through ${usePackages ? 'packages' : 'packageLibraries'}', () {
      final project = HeimdallFileImporter(
        referenceOptions: ReferenceImportOptions(
          sdkLibraries: const [],
          packageLibraries: usePackages ? const [] : [_queue],
          packages: usePackages ? ['collection'] : const [],
        ),
        useCache: false,
      ).importPath(_root);
      final source = _declaration(project, 'PackageConsumer');
      final declarations = project.referenceTypes.visible(source, 'HeapPriorityQueue');
      expect(declarations.single.library!.uri, _queue);
      expect(source.sdkTypeName('HeapPriorityQueue', project), isNull);
      expect(project.referenceLibraries.library('dart:core'), isNull);
      expect(project.referenceLibraries.library('package:path/path.dart'), isNull);
    });
  }

  test('configured references share cached read-only source declarations', () {
    final first = HeimdallFileImporter(referenceOptions: options).importPath(_root);
    final second = HeimdallFileImporter(
      referenceOptions: ReferenceImportOptions(sdkLibraries: ['dart:async', 'dart:core', 'dart:core']),
    ).importPath(_root);
    expect(second, same(first));
    final source = _declaration(first, 'ImplicitConsumer');
    final declarations = first.referenceTypes.visible(source, 'DateTime');
    expect(first.referenceTypes.visible(source, 'DateTime'), same(declarations));
    expect(declarations.clear, throwsUnsupportedError);
    expect(first.referenceLibraries.library('dart:core'), same(declarations.single.library));
  });
}

CompilationUnitMember _declaration(HeimdallProject project, String name) =>
    project.declarations.singleWhere((declaration) => declaration.name == name);
