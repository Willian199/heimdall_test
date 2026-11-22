import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

// Permanent regression coverage for the corrections to issues #8, #9 and #10.
void main() {
  test('issue8: reports one violation when several access constraints reject the same edge', () {
    final project = const HeimdallFileImporter(useCache: false).importPath(
      'test/architecture_fixtures/layer_issues/repeated_type/lib',
    );
    final report = Heimdall.layers()
        .layer('UI')
        .definedBy(['ui/**'])
        .layer('Domain')
        .definedBy(['domain/**'])
        .whereLayer('UI')
        .mayNotAccessAnyLayer()
        .whereLayer('UI')
        .mayOnlyAccessLayers([])
        .whereLayer('Domain')
        .mayNotBeAccessedByAnyLayer()
        .asRule()
        .check(project);
    expect(project.parseErrors, isEmpty);
    expect(report.findings, hasLength(1));
    expect(report.findings.single.message, contains('Profile in layer UI may not access Domain'));
    expect(report.findings.single.filePath, project.fileByRelativePath('ui/profile.dart')!.absolutePath);
    expect(report.findings.single.line, 1);
  });

  for (final scenario in _scenarios) {
    test('${scenario.group}: ${scenario.description}', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        'test/architecture_fixtures/layer_issues/${scenario.fixture}/lib',
      );
      expect(project.parseErrors, isEmpty, reason: 'The fixture must parse successfully.');
      expect(project.files, isNotEmpty);
      for (final file in project.files) {
        for (final directive in file.importDirectives) {
          expect(
            directive.resolvedTargets,
            hasLength(directive.targetUris.length),
            reason: 'Every fixture import branch must resolve: ${file.relativePath}',
          );
        }
      }
      // Validate fixture locations independently of the returned diagnostics.
      for (final expected in scenario.expected) {
        final file = project.fileByRelativePath(expected.path)!;
        expect(
          file.dependencies.where((directive) => directive.line == expected.line && directive.targetUris.contains(expected.uri)),
          hasLength(1),
          reason: 'Expected location must identify the directive introducing the dependency.',
        );
      }

      final builder = Heimdall.layers().layer('UI').definedBy(['ui/**']);
      if (!scenario.undeclared) {
        builder.layer('Domain').definedBy(['domain/**']);
      }
      if (scenario.data) {
        builder.layer('Data').definedBy(['data/**']);
      }
      if (scenario.incoming) {
        builder.whereLayer('Domain').mayNotBeAccessedByAnyLayer();
      } else if (scenario.allowed) {
        builder.whereLayer('UI').mayOnlyAccessLayers(['Domain']);
      } else {
        builder.whereLayer('UI').mayNotAccessAnyLayer();
      }
      if (scenario.onlyDeclared) {
        builder.consideringOnlyDependenciesInLayers();
      }
      final report = builder.asRule().check(project);

      // Compare complete diagnostics without requiring a traversal order.
      expect(
        report.findings,
        unorderedMatches([
          for (final expected in scenario.expected)
            isA<HeimdallValidationInfo>()
                .having((finding) => finding.filePath, 'filePath', project.fileByRelativePath(expected.path)!.absolutePath)
                .having((finding) => finding.line, 'line', expected.line)
                .having((finding) => finding.message, 'source declaration', contains(expected.name))
                .having((finding) => finding.message, 'source layer', contains('in layer UI'))
                .having(
                  (finding) => finding.message,
                  'target layer',
                  contains(scenario.undeclared ? 'accesses undeclared layer' : 'may not access ${expected.layer}'),
                )
                .having((finding) => finding.message, 'import URI', endsWith('via ${expected.uri}')),
        ]),
        reason: '${scenario.group}: ${scenario.fixture}',
      );
    });
  }
}

class _Scenario {
  const _Scenario(
    this.fixture,
    this.group,
    this.description,
    this.expected, {
    this.incoming = false,
    this.undeclared = false,
    this.onlyDeclared = false,
    this.allowed = false,
    this.data = false,
  });

  final String fixture;
  final String group;
  final String description;
  final List<_Expected> expected;
  final bool incoming;
  final bool undeclared;
  final bool onlyDeclared;
  final bool allowed;
  final bool data;
}

class _Expected {
  const _Expected(this.name, {required this.uri, required this.path, required this.line, required this.layer});

  final String name;
  final String uri;
  final String path;
  final int line;
  final String layer;
}

const _scenarios = <_Scenario>[
  _Scenario(
    'review_cascade',
    'review',
    'ignores cascaded instance calls with imported function names',
    [],
  ),
  _Scenario(
    'review_inherited_call',
    'review',
    'respects inherited members shadowing imported functions',
    [],
  ),
  _Scenario(
    'review_inherited_prefix',
    'review',
    'respects inherited members shadowing import prefixes',
    [],
  ),
  _Scenario(
    'review_nested_function',
    'review',
    'checks nested function bodies without requiring top-level metadata',
    [
      _Expected('Profile', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'review_getter',
    'review',
    'distinguishes getter access across separately exported accessors',
    [
      _Expected('Profile', uri: '../domain/barrel.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
    data: true,
  ),
  _Scenario(
    'review_setter',
    'review',
    'distinguishes setter access across separately exported accessors',
    [
      _Expected('Profile', uri: '../domain/barrel.dart', path: 'ui/profile.dart', line: 1, layer: 'Data'),
    ],
    data: true,
  ),
  _Scenario(
    'review_compound',
    'review',
    'distinguishes compound access across separately exported accessors',
    [
      _Expected('Profile', uri: '../domain/barrel.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
      _Expected('Profile', uri: '../domain/barrel.dart', path: 'ui/profile.dart', line: 1, layer: 'Data'),
    ],
    data: true,
  ),
  _Scenario(
    'review_exported_part',
    'review',
    'resolves public functions exported from library parts',
    [
      _Expected('Profile', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'review_private_part',
    'review',
    'resolves private functions introduced by a part directive',
    [
      _Expected('Profile', uri: '../domain/values.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'target_variable_show',
    'issue10',
    'respects show for individual variables sharing a declaration',
    [
      _Expected('Profile', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'target_private_sibling',
    'issue10',
    'exports a public variable following a private variable',
    [
      _Expected('Profile', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'target_variable_hide',
    'issue10',
    'hides one variable without hiding its sibling',
    [
      _Expected('Profile', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'value_export_cycle',
    'issue10',
    'follows cyclic exports without losing a function dependency',
    [
      _Expected('Profile', uri: '../domain/barrel.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'value_export_diamond',
    'issue10',
    'deduplicates a function exposed through multiple export paths',
    [
      _Expected('Profile', uri: '../domain/barrel.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'private_value_control',
    'controls',
    'does not export private functions',
    [],
  ),
  _Scenario(
    'named_label_control',
    'controls',
    'does not mistake a named argument label for an imported value',
    [],
  ),
  _Scenario(
    'property_selector_control',
    'controls',
    'does not mistake an instance property selector for an imported value',
    [],
  ),
  _Scenario(
    'extension_member_control',
    'controls',
    'respects extension members shadowing imported values',
    [],
  ),
  _Scenario(
    'local_type_control',
    'controls',
    'respects local type names shadowing imported functions',
    [],
  ),
  _Scenario(
    'function_annotation',
    'issue10',
    'checks imported types used in top-level function annotations',
    [
      _Expected('initialize', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'function_type_bound',
    'issue10',
    'checks imported types in top-level function type parameter bounds',
    [
      _Expected('consume', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'multiple_types',
    'issue8',
    'reports one boundary crossing for multiple types from one import',
    [
      _Expected('Profile', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'prefixed_types',
    'issue8',
    'deduplicates multiple types imported with a prefix',
    [
      _Expected('Profile', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'show_types',
    'issue8',
    'deduplicates visible types with a show combinator',
    [
      _Expected('Profile', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'repeated_type',
    'controls',
    'does not count every occurrence of the same type',
    [
      _Expected('Profile', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'independent_sources',
    'controls',
    'preserves separate declarations using the same directive',
    [
      _Expected('Profile', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
      _Expected('Header', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'independent_directives',
    'controls',
    'preserves violations from separate directives',
    [
      _Expected('Profile', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
      _Expected('Profile', uri: '../domain/address.dart', path: 'ui/profile.dart', line: 2, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'undeclared_types',
    'issue8',
    'deduplicates types in an undeclared target layer',
    [
      _Expected('Profile', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
    undeclared: true,
  ),
  _Scenario(
    'incoming_types',
    'issue8',
    'deduplicates violations of incoming access constraints',
    [
      _Expected('Profile', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
    incoming: true,
  ),
  _Scenario(
    'barrel_types',
    'issue8',
    'deduplicates multiple types exposed by a barrel',
    [
      _Expected('Profile', uri: '../domain/barrel.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'barrel_distinct_layers',
    'controls',
    'preserves distinct forbidden target layers behind one barrel',
    [
      _Expected('Profile', uri: '../domain/barrel.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
      _Expected('Profile', uri: '../domain/barrel.dart', path: 'ui/profile.dart', line: 1, layer: 'Data'),
    ],
    data: true,
  ),
  _Scenario(
    'conditional_types',
    'issue8',
    'deduplicates each conditional URI while preserving both branches',
    [
      _Expected('Profile', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
      _Expected('Profile', uri: '../domain/web.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'package_types',
    'issue8',
    'deduplicates multiple types through a package URI',
    [
      _Expected('Profile', uri: 'package:layer_issue_fixture/domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'uri_part',
    'issue9',
    'uses the library import location for a URI part',
    [
      _Expected('Header', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'shifted_part',
    'issue9',
    'pairs the library path with an import several lines down',
    [
      _Expected('Header', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 7, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'named_part',
    'issue9',
    'uses the owner of a named part',
    [
      _Expected('Header', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 3, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'prefixed_part',
    'issue9',
    'locates a prefixed import used inside a part',
    [
      _Expected('Header', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 3, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'package_part',
    'issue9',
    'locates a package import used inside a part',
    [
      _Expected('Header', uri: 'package:layer_issue_fixture/domain/model.dart', path: 'ui/profile.dart', line: 2, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'incoming_part',
    'issue9',
    'locates incoming access violations from parts',
    [
      _Expected('Header', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 5, layer: 'Domain'),
    ],
    incoming: true,
  ),
  _Scenario(
    'undeclared_part',
    'issue9',
    'locates undeclared layer violations from parts',
    [
      _Expected('Header', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 3, layer: 'Domain'),
    ],
    undeclared: true,
  ),
  _Scenario(
    'multiple_parts',
    'issue9',
    'preserves findings for separate declarations sharing an owner',
    [
      _Expected('Header', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 6, layer: 'Domain'),
      _Expected('Footer', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 6, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'top_level_part',
    'issue9',
    'checks top-level references inside a part at the library import',
    [
      _Expected('createUser', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 4, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'function_return',
    'issue10',
    'checks a top-level function return type',
    [
      _Expected('createUser', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'function_parameter',
    'issue10',
    'checks a top-level function parameter type',
    [
      _Expected('consume', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'function_body',
    'issue10',
    'checks type references in a top-level function body',
    [
      _Expected('createUser', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'variable_initializer',
    'issue10',
    'checks an inferred top-level variable initializer',
    [
      _Expected('defaultUser', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'variable_annotation',
    'issue10',
    'checks an explicit top-level variable type',
    [
      _Expected('defaultUser', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'top_getter',
    'issue10',
    'checks a top-level getter using a forbidden function',
    [
      _Expected('value', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'top_setter',
    'issue10',
    'checks a top-level setter parameter type',
    [
      _Expected('user', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'top_closure',
    'issue10',
    'checks a closure stored in a top-level variable',
    [
      _Expected('factory', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'function_target',
    'issue10',
    'checks a class calling an imported top-level function',
    [
      _Expected('Profile', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'variable_target',
    'issue10',
    'checks a class reading an imported top-level variable',
    [
      _Expected('Profile', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'constant_target',
    'issue10',
    'checks a class reading an imported top-level constant',
    [
      _Expected('Profile', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'getter_target',
    'issue10',
    'checks a class reading an imported top-level getter',
    [
      _Expected('Profile', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'setter_target',
    'issue10',
    'checks a class writing an imported top-level setter',
    [
      _Expected('Profile', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'function_tearoff',
    'issue10',
    'checks an imported function tear-off',
    [
      _Expected('Profile', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'prefixed_function',
    'issue10',
    'checks a prefixed imported function call',
    [
      _Expected('Profile', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'prefixed_variable',
    'issue10',
    'checks a prefixed imported variable read',
    [
      _Expected('Profile', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'top_to_top',
    'issue10',
    'checks a top-level function calling another layer function',
    [
      _Expected('value', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'multiple_variables',
    'issue10',
    'checks all variables in a top-level declaration',
    [
      _Expected('defaultUser', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'barrel_function',
    'issue10',
    'checks function references exposed through a re-export',
    [
      _Expected('Profile', uri: '../domain/barrel.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'conditional_function',
    'issue10',
    'checks both conditional branches of a top-level function dependency',
    [
      _Expected('Profile', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
      _Expected('Profile', uri: '../domain/web.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'mixed_crossings',
    'issue10',
    'reports all three crossings from the issue example',
    [
      _Expected('currentUser', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
      _Expected('defaultUser', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
      _Expected('Profile', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 1, layer: 'Domain'),
    ],
  ),
  _Scenario(
    'unused_import',
    'controls',
    'ignores an unused forbidden import',
    [],
  ),
  _Scenario(
    'unused_top_import',
    'controls',
    'ignores an unused import in a top-level-only file',
    [],
  ),
  _Scenario(
    'allowed_access',
    'controls',
    'allows referenced types and values when access is permitted',
    [],
    allowed: true,
  ),
  _Scenario(
    'ignored_undeclared',
    'controls',
    'ignores unassigned targets only when explicitly configured',
    [],
    undeclared: true,
    onlyDeclared: true,
  ),
  _Scenario(
    'local_function_shadow',
    'controls',
    'does not mistake a local function for an imported function',
    [],
  ),
  _Scenario(
    'parameter_shadow',
    'controls',
    'does not mistake a parameter for an imported variable',
    [],
  ),
  _Scenario(
    'prefix_shadow',
    'controls',
    'does not mistake a parameter for an import prefix',
    [],
  ),
  _Scenario(
    'local_top_shadow',
    'controls',
    'does not mistake a local top-level function for an imported one',
    [],
  ),
  _Scenario(
    'hidden_function',
    'controls',
    'does not expose a hidden imported function with the same member name',
    [],
  ),
  _Scenario(
    'show_excludes_variable',
    'controls',
    'does not expose variables excluded by show',
    [],
  ),
  _Scenario(
    'two_owners',
    'issue9',
    'does not mix import locations between separate libraries',
    [
      _Expected('Header', uri: '../domain/model.dart', path: 'ui/profile.dart', line: 2, layer: 'Domain'),
      _Expected('Footer', uri: '../domain/model.dart', path: 'ui/other.dart', line: 4, layer: 'Domain'),
    ],
  ),
];
