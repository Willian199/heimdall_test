import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  group('Plugins', () {
    const fixture = 'test/importer_fixtures/basic_project';

    test('runner executes plugin rules in plugin and rule order', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );
      final runner = HeimdallRunner([
        _StaticPlugin('first', [
          PluginRule('first-pass', (_) => _report('first-pass')),
          PluginRule('first-fail', (_) => _report('first-fail', findings: 1)),
        ]),
        _StaticPlugin('second', [
          PluginRule('second-pass', (_) => _report('second-pass')),
        ]),
      ]);

      final reports = runner.run(project);

      expect(
        reports,
        allOf(
          hasLength(3),
          orderedEquals([
            isA<HeimdallReport>().having(
              (report) => report.description,
              'description',
              'first-pass',
            ),
            isA<HeimdallReport>()
                .having(
                  (report) => report.description,
                  'description',
                  'first-fail',
                )
                .having((report) => report.findings, 'findings', hasLength(1)),
            isA<HeimdallReport>().having(
              (report) => report.description,
              'description',
              'second-pass',
            ),
          ]),
        ),
      );
    });

    test('composite plugins flatten child plugin rules', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );
      final composite = CompositeHeimdallPlugin('composite', [
        _StaticPlugin('a', [PluginRule('a', (_) => _report('a'))]),
        _StaticPlugin('b', [PluginRule('b', (_) => _report('b'))]),
      ]);

      final reports = const HeimdallRunner([]).run(project);
      final compositeReports = HeimdallRunner([composite]).run(project);

      expect(
        compositeReports,
        allOf(
          hasLength(2),
          orderedEquals([
            isA<HeimdallReport>().having(
              (report) => report.description,
              'description',
              'a',
            ),
            isA<HeimdallReport>().having(
              (report) => report.description,
              'description',
              'b',
            ),
          ]),
          isNot(equals(reports)),
        ),
      );
    });
  });
}

final class _StaticPlugin implements HeimdallRulePlugin {
  const _StaticPlugin(this.name, this._rules);

  @override
  final String name;

  final List<PluginRule> _rules;

  @override
  Iterable<PluginRule> rules() => _rules;
}

HeimdallReport _report(String description, {int findings = 0}) {
  return HeimdallReport(
    description: description,
    checkedCount: 1,
    findings: [
      for (var index = 0; index < findings; index++) HeimdallValidationInfo(message: '$description finding $index'),
    ],
  );
}
