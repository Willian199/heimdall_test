import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

import 'architecture_fixtures/extension_access/compile_all.dart' as fixtures;

void main() {
  // The compiler checks the fixture libraries when this test is loaded.
  setUpAll(fixtures.main);
  for (final scenario in _cases) {
    test(scenario.title, () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        'test/architecture_fixtures/extension_access/${scenario.fixture}/lib',
      );
      expect(project.parseErrors, isEmpty);
      final source = project.fileByRelativePath('repositories/consumer.dart')!;
      final directive = source.importDirectives.singleWhere((directive) => directive.targetUri == scenario.uri);
      expect(directive.targetFiles, hasLength(1));
      final report = Heimdall.layers()
          .layer('Repository')
          .definedBy(['repositories/**'])
          .layer('Model')
          .definedBy(['models/**'])
          .layer('Extension')
          .definedBy(['extensions/**'])
          .layer('Allowed')
          .definedBy(['allowed_extensions/**'])
          .whereLayer('Repository')
          .mayOnlyAccessLayers(['Repository', 'Model', 'Allowed'])
          .consideringOnlyDependenciesInLayers()
          .asRule()
          .check(project);
      expect(report.findings, hasLength(scenario.expected), reason: scenario.fixture);
      for (final finding in report.findings) {
        expect(finding.filePath, source.absolutePath);
        expect(finding.line, directive.line);
        expect(finding.message, contains('Consumer in layer Repository may not access Extension'));
        expect(finding.message, endsWith('via ${scenario.uri}'));
      }
    });
  }
}

class _Case {
  const _Case(this.fixture, this.title, this.expected, this.uri);
  final String fixture;
  final String title;
  final int expected;
  final String uri;
}

const _cases = <_Case>[
  _Case('field_formal', 'infers a field formal receiver in a constructor initializer', 1, '../extensions/failure_text.dart'),
  _Case('inherited_field', 'uses the type of an inherited receiver field', 1, '../extensions/failure_text.dart'),
  _Case('getter_receiver', 'uses the return type of a receiver getter', 1, '../extensions/failure_text.dart'),
  _Case('getter', 'tracks an implicit extension getter', 1, '../extensions/failure_text.dart'),
  _Case('method', 'tracks an implicit extension method', 1, '../extensions/failure_text.dart'),
  _Case('setter', 'tracks an implicit extension setter', 1, '../extensions/failure_text.dart'),
  _Case('inferred', 'infers the receiver from a local constructor initializer', 1, '../extensions/failure_text.dart'),
  _Case('field', 'uses a declared field type for the receiver', 1, '../extensions/failure_text.dart'),
  _Case('field_chain', 'follows this and a typed field in a receiver chain', 1, '../extensions/failure_text.dart'),
  _Case('nullable', 'uses the non-null receiver type after null-aware access', 1, '../extensions/failure_text.dart'),
  _Case('cascade', 'tracks an extension call in a cascade', 1, '../extensions/failure_text.dart'),
  _Case('prefixed', 'keeps implicit extensions available through a prefixed import', 1, '../extensions/failure_text.dart'),
  _Case('reexport', 'finds the original extension behind a show reexport', 1, '../extensions/barrel.dart'),
  _Case('instance', 'prefers an existing instance member over an extension', 0, '../extensions/failure_text.dart'),
  _Case('inherited', 'prefers an inherited instance member over an extension', 0, '../extensions/failure_text.dart'),
  _Case('unrelated', 'does not match an extension by member name alone', 0, '../extensions/failure_text.dart'),
  _Case('dynamic', 'does not infer an extension for dynamic dispatch', 0, '../extensions/failure_text.dart'),
  _Case('local', 'prefers a more specific local extension', 0, '../extensions/failure_text.dart'),
  _Case('specific', 'prefers a more specific extension from another layer', 0, '../extensions/failure_text.dart'),
  _Case('hidden', 'honors hide on extension names', 0, '../extensions/failure_text.dart'),
  _Case('unused', 'does not report an unused imported extension', 0, '../extensions/failure_text.dart'),
  _Case('function_result', 'uses an explicit local function return type', 1, '../extensions/failure_text.dart'),
];
