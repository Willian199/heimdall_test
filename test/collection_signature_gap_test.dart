import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  final project = const HeimdallFileImporter(useCache: false).importPath('test/collection_signature_gap_fixtures');
  setUpAll(() => expect(project.parseErrors, isEmpty, reason: project.parseErrors.join('\n')));
  final findings = Heimdall.code()
      .publicSignaturesShouldNotUseDynamic(pathPattern: 'lib/sdk_collection_gaps.dart')
      .check(project)
      .findings
      .map((finding) => finding.message)
      .toSet();

  // Each expression returns an element/value typed dynamic under the SDK
  // collection contracts. The rule currently loses that type for these
  // concrete dart:collection classes and emits no finding.
  final cases = <(String, String)>[
    ('queueLeak01', 'Queue operation 1'),
    ('queueLeak02', 'Queue operation 2'),
    ('queueLeak03', 'Queue operation 3'),
    ('queueLeak04', 'Queue operation 4'),
    ('queueLeak05', 'Queue operation 5'),
    ('queueLeak06', 'Queue operation 6'),
    ('queueLeak07', 'Queue operation 7'),
    ('queueLeak08', 'Queue operation 8'),
    ('queueLeak09', 'Queue operation 9'),
    ('queueLeak10', 'Queue operation 10'),
    ('listQueueLeak01', 'ListQueue operation 1'),
    ('listQueueLeak02', 'ListQueue operation 2'),
    ('listQueueLeak03', 'ListQueue operation 3'),
    ('listQueueLeak04', 'ListQueue operation 4'),
    ('listQueueLeak05', 'ListQueue operation 5'),
    ('listQueueLeak06', 'ListQueue operation 6'),
    ('listQueueLeak07', 'ListQueue operation 7'),
    ('listQueueLeak08', 'ListQueue operation 8'),
    ('listQueueLeak09', 'ListQueue operation 9'),
    ('listQueueLeak10', 'ListQueue operation 10'),
    ('doubleLinkedQueueLeak01', 'DoubleLinkedQueue operation 1'),
    ('doubleLinkedQueueLeak02', 'DoubleLinkedQueue operation 2'),
    ('doubleLinkedQueueLeak03', 'DoubleLinkedQueue operation 3'),
    ('doubleLinkedQueueLeak04', 'DoubleLinkedQueue operation 4'),
    ('doubleLinkedQueueLeak05', 'DoubleLinkedQueue operation 5'),
    ('doubleLinkedQueueLeak06', 'DoubleLinkedQueue operation 6'),
    ('doubleLinkedQueueLeak07', 'DoubleLinkedQueue operation 7'),
    ('doubleLinkedQueueLeak08', 'DoubleLinkedQueue operation 8'),
    ('doubleLinkedQueueLeak09', 'DoubleLinkedQueue operation 9'),
    ('doubleLinkedQueueLeak10', 'DoubleLinkedQueue operation 10'),
    ('hashSetLeak01', 'HashSet operation 1'),
    ('hashSetLeak02', 'HashSet operation 2'),
    ('hashSetLeak03', 'HashSet operation 3'),
    ('hashSetLeak04', 'HashSet operation 4'),
    ('hashSetLeak05', 'HashSet operation 5'),
    ('hashSetLeak06', 'HashSet operation 6'),
    ('hashSetLeak07', 'HashSet operation 7'),
    ('hashSetLeak08', 'HashSet operation 8'),
    ('hashSetLeak09', 'HashSet operation 9'),
    ('hashSetLeak10', 'HashSet operation 10'),
    ('linkedHashSetLeak01', 'LinkedHashSet operation 1'),
    ('linkedHashSetLeak02', 'LinkedHashSet operation 2'),
    ('linkedHashSetLeak03', 'LinkedHashSet operation 3'),
    ('linkedHashSetLeak04', 'LinkedHashSet operation 4'),
    ('linkedHashSetLeak05', 'LinkedHashSet operation 5'),
    ('linkedHashSetLeak06', 'LinkedHashSet operation 6'),
    ('linkedHashSetLeak07', 'LinkedHashSet operation 7'),
    ('linkedHashSetLeak08', 'LinkedHashSet operation 8'),
    ('linkedHashSetLeak09', 'LinkedHashSet operation 9'),
    ('linkedHashSetLeak10', 'LinkedHashSet operation 10'),
    ('splayTreeSetLeak01', 'SplayTreeSet operation 1'),
    ('splayTreeSetLeak02', 'SplayTreeSet operation 2'),
    ('splayTreeSetLeak03', 'SplayTreeSet operation 3'),
    ('splayTreeSetLeak04', 'SplayTreeSet operation 4'),
    ('splayTreeSetLeak05', 'SplayTreeSet operation 5'),
    ('splayTreeSetLeak06', 'SplayTreeSet operation 6'),
    ('splayTreeSetLeak07', 'SplayTreeSet operation 7'),
    ('splayTreeSetLeak08', 'SplayTreeSet operation 8'),
    ('splayTreeSetLeak09', 'SplayTreeSet operation 9'),
    ('splayTreeSetLeak10', 'SplayTreeSet operation 10'),
    ('hashMapLeak01', 'HashMap operation 1'),
    ('hashMapLeak02', 'HashMap operation 2'),
    ('hashMapLeak03', 'HashMap operation 3'),
    ('hashMapLeak04', 'HashMap operation 4'),
    ('hashMapLeak05', 'HashMap operation 5'),
    ('hashMapLeak06', 'HashMap operation 6'),
    ('hashMapLeak07', 'HashMap operation 7'),
    ('hashMapLeak08', 'HashMap operation 8'),
    ('hashMapLeak09', 'HashMap operation 9'),
    ('hashMapLeak10', 'HashMap operation 10'),
    ('linkedHashMapLeak01', 'LinkedHashMap operation 1'),
    ('linkedHashMapLeak02', 'LinkedHashMap operation 2'),
    ('linkedHashMapLeak03', 'LinkedHashMap operation 3'),
    ('linkedHashMapLeak04', 'LinkedHashMap operation 4'),
    ('linkedHashMapLeak05', 'LinkedHashMap operation 5'),
    ('linkedHashMapLeak06', 'LinkedHashMap operation 6'),
    ('linkedHashMapLeak07', 'LinkedHashMap operation 7'),
    ('linkedHashMapLeak08', 'LinkedHashMap operation 8'),
    ('linkedHashMapLeak09', 'LinkedHashMap operation 9'),
    ('linkedHashMapLeak10', 'LinkedHashMap operation 10'),
    ('splayTreeMapLeak01', 'SplayTreeMap operation 1'),
    ('splayTreeMapLeak02', 'SplayTreeMap operation 2'),
    ('splayTreeMapLeak03', 'SplayTreeMap operation 3'),
    ('splayTreeMapLeak04', 'SplayTreeMap operation 4'),
    ('splayTreeMapLeak05', 'SplayTreeMap operation 5'),
    ('splayTreeMapLeak06', 'SplayTreeMap operation 6'),
    ('splayTreeMapLeak07', 'SplayTreeMap operation 7'),
    ('splayTreeMapLeak08', 'SplayTreeMap operation 8'),
    ('splayTreeMapLeak09', 'SplayTreeMap operation 9'),
    ('splayTreeMapLeak10', 'SplayTreeMap operation 10'),
    ('unmodifiableMapViewLeak01', 'UnmodifiableMapView operation 1'),
    ('unmodifiableMapViewLeak02', 'UnmodifiableMapView operation 2'),
    ('unmodifiableMapViewLeak03', 'UnmodifiableMapView operation 3'),
    ('unmodifiableMapViewLeak04', 'UnmodifiableMapView operation 4'),
    ('unmodifiableMapViewLeak05', 'UnmodifiableMapView operation 5'),
    ('unmodifiableMapViewLeak06', 'UnmodifiableMapView operation 6'),
    ('unmodifiableMapViewLeak07', 'UnmodifiableMapView operation 7'),
    ('unmodifiableMapViewLeak08', 'UnmodifiableMapView operation 8'),
    ('unmodifiableMapViewLeak09', 'UnmodifiableMapView operation 9'),
    ('unmodifiableMapViewLeak10', 'UnmodifiableMapView operation 10'),
  ];
  if (cases.length != 100) {
    throw StateError('Expected exactly 100 independent bug cases, found ${cases.length}.');
  }
  for (final (name, scenario) in cases) {
    test('$scenario leaks dynamic through $name without a finding', () {
      expect(findings, isNot(contains('$name has public dynamic type')));
    });
  }
}
