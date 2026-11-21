import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

import 'architecture_fixtures/architecture_edges/compile_all.dart' as fixtures;

const _root = 'test/architecture_fixtures/architecture_edges';

// Assert the correct behavior, keeping discovered defects visible until fixed.
// All fixture entry points are included in architecture_edges/compile_all.dart.
void main() {
  // This static import makes the test runner compile all fixture libraries,
  // rather than relying exclusively on the importer's syntax-only parser.
  setUpAll(fixtures.main);

  for (final scenario in _layerCases) {
    test('layers: ${scenario.title}', () {
      final project = const HeimdallFileImporter(useCache: false).importPath('$_root/${scenario.fixture}/lib');
      expect(project.parseErrors, isEmpty);
      for (final file in project.files) {
        for (final directive in file.dependencies) {
          expect(directive.resolvedTargets, hasLength(directive.targetUris.length), reason: file.relativePath);
        }
      }
      final source = project.fileByRelativePath(scenario.source)!;
      final directive = source.importDirectives.single;
      final report = Heimdall.layers()
          .layer('A')
          .definedBy(['features/a/**'])
          .layer('B')
          .definedBy(['features/b/**'])
          .layer('C')
          .definedBy(['features/c/**'])
          .whereLayer('A')
          .mayOnlyAccessLayers(scenario.allowed)
          .consideringOnlyDependenciesInLayers()
          .asRule()
          .check(project);

      expect(report.checkedCount, greaterThan(0));
      expect(
        report.findings,
        unorderedMatches([
          for (final name in scenario.expected)
            isA<HeimdallValidationInfo>()
                .having((finding) => finding.filePath, 'source path', source.absolutePath)
                .having((finding) => finding.line, 'import line', directive.line)
                .having((finding) => finding.message, 'source declaration', contains('$name in layer A'))
                .having((finding) => finding.message, 'target layer', contains('may not access B'))
                .having((finding) => finding.message, 'directive URI', endsWith('via ${directive.targetUri}')),
        ]),
        reason: scenario.fixture,
      );
    });
  }

  for (final scenario in _sliceCases) {
    test('slices: ${scenario.title}', () {
      final project = const HeimdallFileImporter(useCache: false).importPath('$_root/${scenario.fixture}/lib');
      expect(project.parseErrors, isEmpty);
      for (final file in project.files) {
        for (final directive in file.dependencies) {
          expect(directive.resolvedTargets, hasLength(directive.targetUris.length), reason: file.relativePath);
        }
      }
      final slices = Heimdall.slices('features/(*)');
      final report = scenario.cycles == null ? slices.shouldNotDependOnEachOther().check(project) : slices.shouldBeFreeOfCycles().check(project);
      if (scenario.cycles == null) {
        expect(report.findings.map((finding) => finding.message), unorderedEquals(scenario.edges), reason: scenario.fixture);
      } else {
        expect(report.findings, hasLength(scenario.cycles), reason: scenario.fixture);
        for (final finding in report.findings) {
          expect(finding.message, startsWith('Cycle detected: '));
          expect(finding.message, contains('a'));
          expect(finding.message, contains('b'));
        }
      }
    });
  }
}

class _LayerCase {
  const _LayerCase(this.fixture, this.title, this.source, this.expected, {this.allowed = const []});
  final String fixture;
  final String title;
  final String source;
  final List<String> expected;
  final List<String> allowed;
}

class _SliceCase {
  const _SliceCase(this.fixture, this.title, {this.edges = const [], this.cycles});
  final String fixture;
  final String title;
  final List<String> edges;
  final int? cycles;
}

const _layerCases = <_LayerCase>[
  _LayerCase('method_bound', 'finds a dependency used only in a method generic bound', 'features/a/consumer.dart', ['Consumer']),
  _LayerCase('method_annotation', 'finds an imported annotation on a method', 'features/a/consumer.dart', ['Consumer']),
  _LayerCase('constructor_annotation', 'finds an imported annotation on a constructor', 'features/a/consumer.dart', ['Consumer']),
  _LayerCase('closure_bound', 'finds a dependency used only in a generic closure bound', 'features/a/consumer.dart', ['callback']),
  _LayerCase('constant_pattern', 'finds imported constants in constant patterns', 'features/a/consumer.dart', ['Consumer']),
  _LayerCase('relational_pattern', 'finds imported constants in relational patterns', 'features/a/consumer.dart', ['Consumer']),
  _LayerCase('loop_nested_binding', 'does not extend a closure local binding into the surrounding loop', 'features/a/consumer.dart', ['Consumer']),
  _LayerCase('implicit_extension', 'finds an imported extension used through an instance receiver', 'features/a/consumer.dart', ['Consumer']),
  _LayerCase('explicit_extension_control', 'recognizes an explicitly applied imported extension', 'features/a/consumer.dart', ['Consumer']),
  _LayerCase('class_bound_control', 'recognizes an imported class generic bound', 'features/a/consumer.dart', ['Consumer']),
  _LayerCase('loop_shadow_control', 'respects a binding declared in the loop body', 'features/a/consumer.dart', []),
  _LayerCase('pattern_guard_control', 'recognizes an imported constant in a pattern guard', 'features/a/consumer.dart', ['Consumer']),
  _LayerCase('local_type_export_shadow', 'a barrel local type shadows its reexported homonym', 'features/a/consumer.dart', [], allowed: ['B']),
  _LayerCase('local_value_export_shadow', 'a barrel local function shadows its reexported homonym', 'features/a/consumer.dart', [], allowed: ['B']),
  _LayerCase('barrel_function', 'layers also follows functions reexported through a facade outside the slice pattern', 'features/a/consumer.dart', [
    'Consumer',
  ]),
  _LayerCase('barrel_variable', 'layers also follows variables reexported through a facade outside the slice pattern', 'features/a/consumer.dart', [
    'Consumer',
  ]),
  _LayerCase('barrel_getter', 'layers also follows getters reexported through a facade outside the slice pattern', 'features/a/consumer.dart', [
    'Consumer',
  ]),
  _LayerCase('barrel_show', 'layers respect the facade import show combinator', 'features/a/consumer.dart', [], allowed: ['C']),
];

const _sliceCases = <_SliceCase>[
  _SliceCase('barrel_function', 'follows functions reexported through a facade outside the slice pattern', edges: ['Slice a depends on b']),
  _SliceCase('barrel_variable', 'follows variables reexported through a facade outside the slice pattern', edges: ['Slice a depends on b']),
  _SliceCase('barrel_getter', 'follows getters reexported through a facade outside the slice pattern', edges: ['Slice a depends on b']),
  _SliceCase('barrel_show', 'respects import show when expanding a facade', edges: ['Slice a depends on c']),
  _SliceCase('barrel_hide', 'respects import hide when expanding a facade', edges: ['Slice a depends on c']),
  _SliceCase('barrel_export_show', 'respects export show when expanding a facade', edges: ['Slice a depends on c']),
  _SliceCase(
    'barrel_types_control',
    'follows all visible types reexported outside the slice pattern',
    edges: ['Slice a depends on b', 'Slice a depends on c'],
  ),
  _SliceCase('barrel_alias_control', 'follows type aliases reexported outside the slice pattern', edges: ['Slice a depends on b']),
  _SliceCase('function_cycle', 'detects a cycle closed through a function facade', cycles: 1),
  _SliceCase('filtered_cycle', 'does not invent a cycle through a hidden facade export', cycles: 0),
  _SliceCase('direct_type_cycle_control', 'detects a direct cycle between type declarations', cycles: 1),
];
