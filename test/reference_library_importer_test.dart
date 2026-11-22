import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

import 'architecture_fixtures/reference_imports/compile_all.dart' as fixtures;

const _root = 'test/architecture_fixtures/reference_imports/lib';
const _queue = 'package:collection/src/priority_queue.dart';

void main() {
  setUpAll(fixtures.main);
  tearDown(HeimdallFileImporter.clearCache);

  test('default SDK member queries share the lazy consultation library', () {
    final project = const HeimdallFileImporter(useCache: false).importPath(_root);
    final references = project.referenceLibraries;
    final core = references.library('dart:core')!;
    expect(references, same(project.referenceLibraries));
    expect(core, same(references.library('dart:core')));
    expect(references.hasSdkInstanceMember('int', 'abs'), isTrue);
    expect(references.hasSdkInstanceMember('int', 'clamp'), isTrue);
    expect(references.hasSdkInstanceMember('int', 'notAnSdkMember'), isFalse);
    expect(core.types['int']!.instanceMembers, contains('isEven'));
    expect(references.library(_queue), isNull);
  });

  test('an SDK allowlist reads only selected libraries', () {
    final options = ReferenceImportOptions(sdkLibraries: ['dart:core']);
    final project = HeimdallFileImporter(referenceOptions: options, useCache: false).importPath(_root);
    expect(project.referenceLibraries.library('dart:core')!.types, contains('int'));
    expect(project.referenceLibraries.library('dart:collection'), isNull);
    expect(project.referenceLibraries.hasSdkInstanceMember('Queue', 'add'), isFalse);
  });

  test('none disables SDK and package reads', () {
    final project = const HeimdallFileImporter(referenceOptions: ReferenceImportOptions.none(), useCache: false).importPath(_root);
    expect(project.referenceLibraries.library('dart:core'), isNull);
    expect(project.referenceLibraries.library(_queue), isNull);
    expect(project.referenceLibraries.hasSdkInstanceMember('int', 'abs'), isFalse);
  });

  test('an exact package library does not permit sibling libraries or dependencies', () {
    final project = HeimdallFileImporter(
      referenceOptions: ReferenceImportOptions(packageLibraries: [_queue]),
      useCache: false,
    ).importPath(_root);
    final references = project.referenceLibraries;
    final library = references.library(_queue)!;
    expect(library.types, contains('HeapPriorityQueue'));
    expect(library.types['HeapPriorityQueue']!.instanceMembers, contains('removeFirst'));
    expect(references.library('package:collection/collection.dart'), isNull);
    expect(references.library('package:meta/meta.dart'), isNull);
  });

  test('a package allowlist permits its libraries without implicitly following exports', () {
    final project = HeimdallFileImporter(
      referenceOptions: ReferenceImportOptions(packages: ['collection']),
      useCache: false,
    ).importPath(_root);
    final references = project.referenceLibraries;
    expect(references.library(_queue)!.types, contains('HeapPriorityQueue'));
    final facade = references.library('package:collection/collection.dart')!;
    expect(facade.units.expand((unit) => unit.directives).whereType<ExportDirective>(), isNotEmpty);
    expect(facade.types, isNot(contains('HeapPriorityQueue')));
    expect(references.library('package:path/path.dart'), isNull);
  });

  test('library contents and derived indexes are cached and read-only', () {
    final project = const HeimdallFileImporter(useCache: false).importPath(_root);
    final library = project.referenceLibraries.library('dart:collection')!;
    final type = library.types['ListBase']!;
    expect(library.uri, 'dart:collection');
    expect(library.units, same(library.units));
    expect(library.types, same(library.types));
    expect(type.instanceMembers, same(type.instanceMembers));
    expect(type.parents, same(type.parents));
    expect(type.declaration.namePart.toSource(), contains('<E>'));
    expect(library.units.clear, throwsUnsupportedError);
    expect(library.types.clear, throwsUnsupportedError);
    expect(type.instanceMembers.clear, throwsUnsupportedError);
    expect(type.parents.clear, throwsUnsupportedError);
  });

  test('import and library handles do not read an SDK until contents are queried', () {
    final project = HeimdallFileImporter(
      referenceOptions: ReferenceImportOptions(sdkPath: 'test/architecture_fixtures/reference_imports/missing_sdk'),
      useCache: false,
    ).importPath(_root);
    final library = project.referenceLibraries.library('dart:core')!;
    expect(project.typeDeclarations, hasLength(2));
    expect(library.uri, 'dart:core');
    // An invalid explicit SDK must only fail at the first actual content read.
    expect(() => library.units, throwsArgumentError);
  });

  test('unknown allowed package libraries have a stable empty snapshot', () {
    const missing = 'package:heimdall_missing_package/missing.dart';
    final project = HeimdallFileImporter(
      referenceOptions: ReferenceImportOptions(packageLibraries: [missing]),
      useCache: false,
    ).importPath(_root);
    final library = project.referenceLibraries.library(missing)!;
    expect(library.units, isEmpty);
    expect(library.units, same(library.units));
    expect(library.types, isEmpty);
  });

  test('consultation cannot alter validation subjects, dependencies, layers or slices', () {
    final project = HeimdallFileImporter(
      referenceOptions: ReferenceImportOptions(packages: ['collection']),
      useCache: false,
    ).importPath(_root);
    final files = project.files;
    final declarations = project.declarations;
    final dependencies = project.dependencies;
    final members = project.classMembers;
    final layers = Heimdall.layers()
        .layer('A')
        .definedBy(['features/a/**'])
        .layer('B')
        .definedBy(['features/b/**'])
        .whereLayer('A')
        .mayNotAccessAnyLayer()
        .asRule();
    final slices = Heimdall.slices('features/(*)').shouldNotDependOnEachOther();
    final beforeLayers = layers.check(project).findings.map((item) => item.message).toList();
    final beforeSlices = slices.check(project).findings.map((item) => item.message).toList();
    expect(beforeLayers, hasLength(1));
    expect(beforeSlices, hasLength(1));
    final references = project.referenceLibraries;
    expect(references.library('dart:core')!.types, isNotEmpty);
    expect(references.library('dart:collection')!.types, isNotEmpty);
    expect(references.library(_queue)!.types, isNotEmpty);
    expect(project.files, same(files));
    expect(project.files, hasLength(2));
    expect(project.declarations, same(declarations));
    expect(project.typeDeclarations.map((item) => item.name), unorderedEquals(['Consumer', 'Model']));
    expect(project.dependencies, same(dependencies));
    expect(project.classMembers, same(members));
    expect(project.parseErrors, isEmpty);
    expect(project.analysisDiagnostics, isEmpty);
    expect(layers.check(project).findings.map((item) => item.message), beforeLayers);
    expect(slices.check(project).findings.map((item) => item.message), beforeSlices);
    expect(Heimdall.classes().should().haveTypeName('Consumer').check(project).findings, hasLength(1));
    expect(Heimdall.classes().should().haveTypeName('Consumer').check(project).checkedCount, 2);
  });

  test('equivalent allowlists share the importer snapshot', () {
    final first = HeimdallFileImporter(
      referenceOptions: ReferenceImportOptions(sdkLibraries: ['dart:core', 'dart:async'], packages: ['path', 'collection']),
    ).importPath(_root);
    final second = HeimdallFileImporter(
      referenceOptions: ReferenceImportOptions(sdkLibraries: ['dart:async', 'dart:core', 'dart:core'], packages: ['collection', 'path']),
    ).importPath(_root);
    expect(second, same(first));
  });

  test('different allowlists and SDK paths cannot reuse a cached snapshot', () {
    final first = const HeimdallFileImporter().importPath(_root);
    final none = const HeimdallFileImporter(referenceOptions: ReferenceImportOptions.none()).importPath(_root);
    final package = HeimdallFileImporter(referenceOptions: ReferenceImportOptions(packages: ['collection'])).importPath(_root);
    final sdk = HeimdallFileImporter(referenceOptions: ReferenceImportOptions(sdkPath: 'test/missing_sdk')).importPath(_root);
    expect(none, isNot(same(first)));
    expect(package, isNot(same(first)));
    expect(sdk, isNot(same(first)));
    expect(none.referenceLibraries.library('dart:core'), isNull);
    expect(first.referenceLibraries.library(_queue), isNull);
    expect(package.referenceLibraries.library(_queue), isNotNull);
  });

  test('uncached snapshots own separate consultation ASTs', () {
    final first = const HeimdallFileImporter(useCache: false).importPath(_root);
    final second = const HeimdallFileImporter(useCache: false).importPath(_root);
    expect(first.referenceLibraries, isNot(same(second.referenceLibraries)));
    expect(first.referenceLibraries.library('dart:core')!.units, isNot(same(second.referenceLibraries.library('dart:core')!.units)));
  });

  test('configuration snapshots mutable input and exposes immutable allowlists', () {
    final input = ['collection'];
    final options = ReferenceImportOptions(packages: input);
    input.add('meta');
    expect(options.packages, ['collection']);
    expect(options.packages.clear, throwsUnsupportedError);
    expect(options.sdkLibraries.clear, throwsUnsupportedError);
    expect(options.packageLibraries.clear, throwsUnsupportedError);
    expect(options.allows('package:meta/meta.dart'), isFalse);
    expect(options.cacheKey, isNot(const ReferenceImportOptions.defaults().cacheKey));
    expect(ReferenceImportOptions().cacheKey, const ReferenceImportOptions.defaults().cacheKey);
  });

  for (final uri in [
    'dart:core?x',
    'dart://core',
    'dart:core#x',
    'package:collection/../meta/meta.dart',
    'package:collection/%2e%2e/meta.dart',
    'package:collection/src%2fhidden.dart',
    'file:///tmp/a.dart',
    'package:/a.dart',
  ]) {
    test('malformed or traversal URI is denied: $uri', () {
      expect(ReferenceImportOptions(packages: ['collection']).allows(uri), isFalse);
      expect(() => ReferenceImportOptions(packageLibraries: [uri]), throwsArgumentError);
    });
  }
}
