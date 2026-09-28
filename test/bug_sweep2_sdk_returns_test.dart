import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  const importer = HeimdallFileImporter(useCache: false);
  final project = importer.importPath('test/bug_sweep2_fixtures');
  setUpAll(() => expect(project.parseErrors, isEmpty, reason: project.parseErrors.join('\\n')));

  for (final file in ['shadowed_sdk.dart', 'prefixed_shadowed_sdk.dart']) {
    test('$file does not apply SDK inference to project declarations', () {
      expect(Heimdall.code().publicSignaturesShouldNotUseDynamic(pathPattern: file).check(project).findings, isEmpty);
    });
  }

  test('SDK callbacks and explicit arguments can produce concrete returns from dynamic receivers', () {
    final findings = Heimdall.code().publicSignaturesShouldNotUseDynamic(pathPattern: 'sdk_concrete_returns.dart').check(project).findings;
    expect(
      findings.map((finding) => finding.message),
      unorderedEquals([
        for (final name in ['rawListFromConcrete', 'rawListUnmodifiableConcrete', 'rawMapFromConcrete', 'rawMapUnmodifiableConcrete'])
          '$name has public dynamic type',
      ]),
    );
  });

  final messages = Heimdall.code()
      .publicSignaturesShouldNotUseDynamic(pathPattern: 'sdk_generic_returns.dart')
      .check(project)
      .findings
      .map((finding) => finding.message)
      .toSet();

  for (final name in [
    'streamMap',
    'streamAsyncMap',
    'streamAsyncExpand',
    'streamExpand',
    'streamWhere',
    'streamTake',
    'streamTakeWhile',
    'streamSkip',
    'streamSkipWhile',
    'streamDistinct',
    'streamHandleError',
    'streamTimeout',
    'streamBroadcast',
    'streamCast',
    'futureAsStream',
    'streamFirst',
    'streamLast',
    'streamSingle',
    'streamElementAt',
    'streamFirstWhere',
    'streamLastWhere',
    'streamSingleWhere',
    'streamToList',
    'streamToSet',
    'streamReduce',
    'streamFold',
    'streamListen',
    'streamDrain',
    'streamPipe',
    'streamMapFirst',
    'futureThenDynamic',
    'futureThenInferred',
    'futureThenValue',
    'futureThenMappedIndex',
    'futureThenMapLookup',
    'futureCatchError',
    'futureWhenComplete',
    'futureWhenCompleteDynamic',
    'futureTimeout',
    'futureTimeoutFallback',
    'futureAsStreamDirect',
    'futureSync',
    'futureMicrotask',
    'futureDelayed',
    'futureAny',
    'futureWait',
    'futureError',
    'futureSyncIndex',
    'futureDelayedLookup',
    'futureWaitEager',
    'futureThenThen',
    'futureThenAsStreamFirst',
    'futureThenCatchError',
    'futureThenTimeout',
    'futureThenWhenComplete',
    'whereTypeInferred',
    'whereTypeDynamic',
    'reduceDynamic',
    'foldDynamic',
    'iterableIndexed',
    'listAsMapValue',
    'listFrom',
    'listOf',
    'listUnmodifiable',
    'listGenerate',
    'listFilled',
    'listEmpty',
    'setFrom',
    'setOf',
    'setUnmodifiable',
    'setIdentity',
    'setLookup',
    'setUnion',
    'setIntersection',
    'setDifference',
    'iterableGenerate',
    'iterableEmpty',
    'listFromIterable',
    'setFromIterable',
    'listGenerateConditional',
    'mapMap',
    'mapMapExplicit',
    'mapMapKeyDynamic',
    'mapMapValueDynamic',
    'mapFrom',
    'mapOf',
    'mapUnmodifiable',
    'mapIdentity',
    'mapFromEntries',
    'mapFromIterable',
    'mapFromIterables',
    'mapStringKeyDynamicValue',
    'mapDynamicKeyIntValue',
    'dynamicMapEntry',
    'dynamicMapEntryKey',
    'dynamicMapEntryValue',
    'mappedEntriesDynamicKey',
    'mappedValuesDynamic',
    'mapMapCascade',
    'mapUnmodifiableFromEntries',
  ]) {
    test('$name exposes dynamic through an SDK generic return', () {
      expect(messages, contains('$name has public dynamic type'));
    });
  }
}
