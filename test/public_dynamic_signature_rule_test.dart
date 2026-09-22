import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  const importer = HeimdallFileImporter(useCache: false);
  const fixture = 'test/code_fixtures/dynamic_signatures';

  test('infers dynamic through calls, collections, members, constructors and generators', () {
    final imported = importer.importPath('$fixture/inference');
    final messages = Heimdall.code().publicSignaturesShouldNotUseDynamic().check(imported).findings.map((finding) => finding.message);
    expect(
      messages,
      unorderedEquals([
        for (final name in [
          'result',
          'forwarded',
          'awaited',
          'generated',
          'generatedAsync',
          'delegated',
          'localCall',
          'resultFromMethod',
          'inferredFromMethod',
          'resultFromReceiver',
        ])
          '$name has public dynamic return type',
        for (final name in [
          'called',
          'list',
          'map',
          'set',
          'spread',
          'conditionalList',
          'loopList',
          'indexed',
          'indexedVariable',
          'indexedMap',
          'inferredMapIndex',
          'future',
          'stream',
          'constructed',
          'explicitConstructor',
          'genericCall',
          'explicitGenericCall',
          'property',
          'getter',
          'method',
          'staticMethod',
          'genericProperty',
          'inheritedProperty',
          'callback',
          'callbackVariable',
          'tearOff',
        ])
          '$name has public dynamic type',
      ]),
    );
  });

  test('generic method calls bind explicit and inferred type arguments', () {
    final imported = importer.importPath('$fixture/inference');
    final messages = Heimdall.code().publicSignaturesShouldNotUseDynamic().check(imported).findings.map((finding) => finding.message).toList();
    for (final name in ['resultFromMethod', 'inferredFromMethod', 'resultFromReceiver']) {
      expect(messages, contains('$name has public dynamic return type'));
    }
    expect(messages.any((message) => message.startsWith('safeFromMethod ')), isFalse);
  });

  test('inferred collections and SDK factories respect ignored types', () {
    final imported = importer.importPath('$fixture/inference');
    final messages = Heimdall.code()
        .publicSignaturesShouldNotUseDynamic(
          ignoredTypes: {'List', 'Set', 'Map<String, dynamic>', 'Future<dynamic>', 'Stream<dynamic>'},
        )
        .check(imported)
        .findings
        .map((finding) => finding.message)
        .toList();
    for (final name in ['list', 'map', 'set', 'spread', 'conditionalList', 'loopList', 'future', 'stream']) {
      expect(messages.any((message) => message.startsWith('$name ')), isFalse, reason: name);
    }
    expect(messages, contains('called has public dynamic type'));
    expect(messages, contains('indexed has public dynamic type'));
  });

  test('ignores type signatures and outer nullability without exempting other dynamic uses', () {
    final imported = importer.importPath('$fixture/ignored_types');
    final strict = Heimdall.code().publicSignaturesShouldNotUseDynamic();
    final relaxed = Heimdall.code().publicSignaturesShouldNotUseDynamic(ignoredTypes: {' Map<String, dynamic> '});
    final expected = [
      'dynamicKey has public dynamic return type',
      'nestedDynamic has public dynamic return type',
      'prefixed has public dynamic return type',
      'mixed has public dynamic parameter other',
      'Callback has public dynamic return type',
      'callback has public dynamic return type',
    ];
    expect(strict.check(imported).findings, hasLength(13));
    expect(relaxed.check(imported).findings.map((finding) => finding.message), unorderedEquals(expected));
    expect(strict.check(imported).findings, hasLength(13));
    expect(relaxed.check(imported).findings.map((finding) => finding.message), unorderedEquals(expected));
    final callbackAllowed = Heimdall.code().publicSignaturesShouldNotUseDynamic(ignoredTypes: {'dynamic Function(int)'}).check(imported);
    expect(callbackAllowed.findings, hasLength(11));
  });

  test('type names ignore all arguments while preserving prefixes and unrelated dynamic', () {
    final imported = importer.importPath('$fixture/ignored_types');
    final result = Heimdall.code().publicSignaturesShouldNotUseDynamic(ignoredTypes: {'Map'}).check(imported);
    expect(
      result.findings.map((finding) => finding.message),
      unorderedEquals([
        'prefixed has public dynamic return type',
        'mixed has public dynamic parameter other',
        'Callback has public dynamic return type',
        'callback has public dynamic return type',
      ]),
    );
    final prefixed = Heimdall.code().publicSignaturesShouldNotUseDynamic(ignoredTypes: {'core.Map?'}).check(imported);
    expect(prefixed.findings, hasLength(12));
    expect(prefixed.findings.any((finding) => finding.message.startsWith('prefixed ')), isFalse);
  });

  test('ignores nullable signatures, inferred collections and nested parameters consistently', () {
    final imported = importer.importPath('$fixture/ignore_matching');
    final strict = Heimdall.code().publicSignaturesShouldNotUseDynamic().check(imported);
    expect(strict.findings, hasLength(16));
    final result = Heimdall.code()
        .publicSignaturesShouldNotUseDynamic(
          ignoredTypes: {' Map < String, dynamic > ? ', 'List<dynamic>?', 'Map<dynamic, dynamic>', 'void Function<T extends dynamic>()'},
        )
        .check(imported);
    expect(
      result.findings.map((finding) => finding.message),
      unorderedEquals([
        'differentArgument has public dynamic parameter value',
        'direct has public dynamic parameter value',
        'callback has public dynamic parameter value',
        'record has public dynamic parameter value',
      ]),
    );
    final names = Heimdall.code()
        .publicSignaturesShouldNotUseDynamic(
          ignoredTypes: {'Map', 'List', 'void Function<T extends dynamic>()'},
        )
        .check(imported);
    expect(
      names.findings.map((finding) => finding.message),
      unorderedEquals([
        'direct has public dynamic parameter value',
        'callback has public dynamic parameter value',
        'record has public dynamic parameter value',
      ]),
    );
  });

  test('ignored function types also exempt their generic bounds', () {
    final imported = importer.importPath('$fixture/ignore_matching');
    final result = Heimdall.code()
        .publicSignaturesShouldNotUseDynamic(
          ignoredTypes: {'void Function<T extends dynamic>()'},
        )
        .check(imported);
    expect(result.findings.any((finding) => finding.message.startsWith('boundedCallback ')), isFalse);
    expect(result.findings.any((finding) => finding.message.startsWith('BoundedCallback ')), isFalse);
  });

  test('covers implicit types, signature headers and inherited parameters without checking wildcards', () {
    final imported = importer.importPath('$fixture/coverage');
    final result = Heimdall.code().publicSignaturesShouldNotUseDynamic().check(imported);
    final messages = result.findings.map((finding) => finding.message).toList();
    expect(
      messages,
      containsAll([
        'missingType has public dynamic type',
        'explicitInitializer has public dynamic type',
        'emptyCollection has public dynamic type',
        'publicValue has public dynamic type',
        'callback has public dynamic parameter value',
        'legacyCallback has public dynamic parameter value',
        'bound has public dynamic type parameter bound: dynamic',
        'Api has public dynamic supertype or extension target: Box<dynamic>',
        'Wrapper has public dynamic parameter value',
        'Child has public dynamic parameter value',
        'InferredField has public dynamic parameter value',
        'InferredField.named has public dynamic parameter value',
        'AliasedChild has public dynamic parameter value',
        'value has public dynamic type',
        'accept has public dynamic parameter value',
        'Extra has public dynamic supertype or extension target: GenericExtension<dynamic>',
        'WithContract has public dynamic supertype or extension target: Contract<dynamic>',
        'ImplementsContract has public dynamic supertype or extension target: Contract<dynamic>',
        'recordInitializer has public dynamic type',
        'callbackInitializer has public dynamic type',
        'aliasInitializer has public dynamic type',
        'callbackAlias has public dynamic return type',
        'BareCallback has public dynamic return type',
        'own has public dynamic parameter value',
        'inferredDynamicReturn has public dynamic return type',
        'forwardBound has public dynamic return type',
      ]),
    );
    expect(messages.any((message) => message.startsWith('new ')), isFalse);
    expect(messages.where((message) => message == 'accept has public dynamic parameter value'), hasLength(1));
    for (final safe in [
      'wildcard',
      'nestedWildcard',
      'boundedRaw',
      'boundedAlias',
      'safeInitializer',
      'safeScalar',
      'inferredConstructor',
      'safeParameter',
      'safeLocal',
      'safeReturn',
      'cycle',
    ]) {
      expect(messages.any((message) => message.startsWith('$safe ')), isFalse, reason: safe);
    }
    expect(messages.any((message) => message.contains('parameter renamed')), isFalse);
  });

  test('reports dynamic throughout nested signatures and local aliases', () {
    final imported = importer.importPath('$fixture/nested');
    final result = Heimdall.code().publicSignaturesShouldNotUseDynamic(pathPattern: 'api.dart').check(imported);
    expect(
      result.findings.map((finding) => finding.message),
      unorderedEquals([
        for (final name in [
          'list',
          'mapKey',
          'mapValue',
          'set',
          'iterable',
          'nested',
          'rawNested',
          'callbackList',
          'positional',
          'named',
          'payload',
          'chain',
          'callback',
          'legacyCallback',
          'recordAlias',
          'hiddenDynamic',
        ])
          '$name has public dynamic return type',
        'recordParameter has public dynamic parameter value',
      ]),
    );
  });

  test('recognizes raw SDK generics without assuming unknown external types', () {
    final imported = importer.importPath('$fixture/external');
    final result = Heimdall.code().publicSignaturesShouldNotUseDynamic().check(imported);
    expect(imported.files, hasLength(1));
    expect(result.findings.map((finding) => finding.message), [
      'future has public dynamic return type',
      'stream has public dynamic return type',
      'explicit has public dynamic return type',
    ]);
  });

  test('external generic names extend SDK defaults and detect nested raw types', () {
    final imported = importer.importPath('$fixture/external');
    final rule = Heimdall.code().publicSignaturesShouldNotUseDynamic(
      externalGenericTypeNames: ['Bloc', 'Cubit', 'Response', 'ValueNotifier', 'ValueListenable'],
    );
    expect(rule.check(imported).findings.map((finding) => finding.message), [
      for (final name in ['future', 'stream', 'bloc', 'cubit', 'response', 'nested', 'explicit']) '$name has public dynamic return type',
    ]);
    expect(rule.check(importer.importPath('$fixture/local')).findings, isEmpty);
  });

  test('SDK and external name fallbacks handle prefixes, nullability and type parameter shadowing', () {
    final imported = importer.importPath('$fixture/raw_generics');
    final defaults = Heimdall.code().publicSignaturesShouldNotUseDynamic().check(imported);
    final sdkMessages = [
      for (final name in [
        'future',
        'stream',
        'futureOr',
        'completer',
        'subscription',
        'controller',
        'list',
        'map',
        'set',
        'iterable',
        'queue',
        'nested',
      ])
        '$name has public dynamic return type',
      'accept has public dynamic parameter value',
    ];
    expect(defaults.findings.map((finding) => finding.message), unorderedEquals(sdkMessages));
    expect(defaults.findings.any((finding) => finding.message.startsWith('externalList ')), isFalse);
    final explicitlyGeneric = Heimdall.code().publicSignaturesShouldNotUseDynamic(externalGenericTypeNames: ['other.List']).check(imported);
    expect(explicitlyGeneric.findings.map((finding) => finding.message), contains('externalList has public dynamic return type'));
    final external = Heimdall.code()
        .publicSignaturesShouldNotUseDynamic(
          externalGenericTypeNames: ['Response', 'ValueNotifier', 'ValueListenable'],
        )
        .check(imported);
    expect(
      external.findings.map((finding) => finding.message),
      unorderedEquals([
        ...sdkMessages,
        for (final name in ['response', 'otherResponse', 'notifier', 'listenable']) '$name has public dynamic return type',
      ]),
    );
    final prefixed = Heimdall.code()
        .publicSignaturesShouldNotUseDynamic(
          externalGenericTypeNames: ['http.Response'],
          ignoredTypes: {
            'Future',
            'Stream',
            'FutureOr',
            'Completer',
            'StreamSubscription',
            'StreamController',
            'core.List',
            'Map',
            'Set',
            'Iterable',
            'Queue',
          },
        )
        .check(imported);
    expect(prefixed.findings.map((finding) => finding.message), ['response has public dynamic return type']);
  });

  test('local non-generic names are accepted and a rule can check distinct projects', () {
    final rule = Heimdall.code().publicSignaturesShouldNotUseDynamic();
    final first = importer.importPath('$fixture/local');
    expect(rule.check(first).findings, isEmpty);
    final second = importer.importPath('$fixture/generic');
    expect(rule.check(second).findings, hasLength(1));
    expect(rule.check(first).findings, isEmpty);
  });

  test('resolves local barrels, aliases, prefixes and import/export combinators', () {
    final imported = importer.importPath('$fixture/visibility');
    final result = Heimdall.code().publicSignaturesShouldNotUseDynamic(pathPattern: 'api.dart').check(imported);
    expect(result.findings.map((finding) => finding.message), [
      'raw has public dynamic return type',
      'alias has public dynamic return type',
    ]);
  });
}
