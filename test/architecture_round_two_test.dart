import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

import 'architecture_fixtures/architecture_round_two/compile_all.dart' as fixtures;

const _root = 'test/architecture_fixtures/architecture_round_two';

void main() {
  // Static fixture imports enforce semantic Dart compilation on every test run.
  setUpAll(fixtures.main);
  for (final scenario in _layerCases) {
    test('layers round two: ${scenario.title}', () {
      final project = const HeimdallFileImporter(useCache: false).importPath('$_root/${scenario.fixture}/lib');
      expect(project.parseErrors, isEmpty);
      final source = project.fileByRelativePath('features/a/consumer.dart')!;
      final directive = source.importDirectives.last;
      expect(directive.resolvedTargets, hasLength(directive.targetUris.length));
      final report = Heimdall.layers()
          .layer('A')
          .definedBy(['features/a/**'])
          .layer('B')
          .definedBy(['features/b/**'])
          .layer('C')
          .definedBy(['features/c/**'])
          .whereLayer('A')
          .mayOnlyAccessLayers(['C'])
          .consideringOnlyDependenciesInLayers()
          .asRule()
          .check(project);
      expect(report.findings, hasLength(scenario.expected), reason: scenario.fixture);
      for (final finding in report.findings) {
        expect(finding.filePath, source.absolutePath);
        expect(finding.line, directive.line);
        expect(finding.message, contains('Consumer in layer A may not access B'));
        expect(finding.message, endsWith('via ${directive.targetUri}'));
      }
    });
  }

  for (final scenario in _sliceCases) {
    test('slices round two: ${scenario.title}', () {
      final project = const HeimdallFileImporter(useCache: false).importPath('$_root/${scenario.fixture}/lib');
      expect(project.parseErrors, isEmpty);
      final report = Heimdall.slices('features/(*)').shouldNotDependOnEachOther().check(project);
      expect(report.findings.map((finding) => finding.message), unorderedEquals(scenario.edges), reason: scenario.fixture);
    });
  }
}

class _LayerCase {
  const _LayerCase(this.fixture, this.title, this.expected);
  final String fixture;
  final String title;
  final int expected;
}

class _SliceCase {
  const _SliceCase(this.fixture, this.title, this.edges);
  final String fixture;
  final String title;
  final List<String> edges;
}

const _layerCases = <_LayerCase>[
  _LayerCase('promotion_write_control', 'invalidates a type promotion after a dynamic assignment', 0),
  _LayerCase('promotion_binding_control', 'does not transfer a guard to a shadowing local binding', 0),
  _LayerCase('negated_promotion_control', 'uses a negated is guard that exits before the receiver', 1),
  _LayerCase('conjunction_promotion_control', 'combines null and subtype guards in a true branch', 1),
  _LayerCase('extension_bound_control', 'rejects a generic extension whose inferred argument violates its bound', 0),
  _LayerCase('extension_parent_control', 'infers extension arguments through a generic superclass', 1),
  _LayerCase('extension_nominal_control', 'does not infer a generic extension for an unrelated nominal receiver', 0),
  _LayerCase('conditional_specificity_control', 'keeps specificity within each conditional extension branch', 0),
  _LayerCase('sdk_parent_control', 'prefers inherited SDK members over an extension', 0),
  _LayerCase('sdk_method', 'does not mistake int.abs for an imported extension method', 0),
  _LayerCase('sdk_getter', 'does not mistake int.isEven for an imported extension getter', 0),
  _LayerCase('generic_extension', 'infers an extension type argument from a generic receiver', 1),
  _LayerCase('bounded_extension', 'uses a generic extension receiver bound', 1),
  _LayerCase('binary_operator', 'finds an extension operator invocation', 1),
  _LayerCase('index_operator', 'finds an extension index operator', 1),
  _LayerCase('enum_constant', 'recovers the type of an enum constant receiver', 1),
  _LayerCase('null_promotion', 'uses the promoted receiver type after a null guard', 1),
  _LayerCase('is_promotion', 'uses the promoted receiver type after an is guard', 1),
  _LayerCase('imported_variable', 'recovers the type of an imported top-level variable', 1),
  _LayerCase('prefixed_variable', 'recovers the type of a prefixed imported variable', 1),
  _LayerCase('method_parameter_bound', 'uses the method type parameter bound for an extension receiver', 1),
  _LayerCase('shadowed_factory', 'does not infer a shadowed function return type for dynamic dispatch', 0),
  _LayerCase('mixin_override', 'uses a mixin getter override before its superclass getter', 0),
  _LayerCase('conditional_extensions', 'evaluates conditional extension branches independently', 1),
  _LayerCase('typed_local_control', 'recognizes an explicitly typed local copy of an imported value', 1),
  _LayerCase('explicit_index_control', 'recognizes explicit application of an extension index operator', 1),
  _LayerCase('assert_nonnull_control', 'recognizes an explicit non-null assertion on the receiver', 1),
  _LayerCase('dynamic_factory_control', 'does not assume a return type for a dynamic callback', 0),
  _LayerCase('concrete_generic_control', 'recognizes an extension with a concrete generic on type', 1),
  _LayerCase('enum_parameter_control', 'recognizes a declared enum receiver type', 1),
  _LayerCase('sdk_new_member_control', 'recognizes a new SDK receiver extension member', 1),
  _LayerCase('local_getter', 'a local getter shadows the reexported variable getter', 0),
  _LayerCase('local_setter', 'a local setter does not hide the reexported getter', 1),
  _LayerCase('local_accessors_control', 'keeps local getter and setter precedence over a reexported variable', 0),
];

const _sliceCases = <_SliceCase>[
  _SliceCase('local_getter', 'preserves the correct exported namespace for local_getter', []),
  _SliceCase('local_setter', 'preserves the correct exported namespace for local_setter', ['Slice a depends on b']),
  _SliceCase('local_accessors_control', 'preserves the correct exported namespace for local_accessors_control', []),
  _SliceCase('conditional_facade_control', 'retains both conditional value facade branches', ['Slice a depends on b', 'Slice a depends on c']),
  _SliceCase('direct_hidden_import_control', 'keeps a direct file dependency even when its names are hidden', ['Slice a depends on b']),
];
