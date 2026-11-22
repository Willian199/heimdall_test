import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  group('HeimdallCondition', () {
    final project = const HeimdallFileImporter(useCache: false).importPath('test/importer_fixtures/basic_project');
    final sourceFile = project.fileByRelativePath('lib/src/domain/user.dart')!;

    test('uses findings from condition results directly', () {
      final condition = HeimdallCondition<int>('be even', (item, _) {
        return HeimdallFindings(
          subject: item,
          passed: false,
          findings: const [
            HeimdallValidationInfo(message: 'custom even failure'),
          ],
        );
      });

      final findings = condition.check(3, project);

      expect(findings, hasLength(1));
      expect(findings.single.message, 'custom even failure');
    });

    final groups = [
      (
        name: 'allOf',
        condition: HeimdallCondition<int>.allOf,
        passingCounts: [3],
        heading: 'Required conditions were not met.',
      ),
      (
        name: 'anyOf',
        condition: HeimdallCondition<int>.anyOf,
        passingCounts: [1, 2, 3],
        heading: 'None of the alternatives matched',
      ),
      (
        name: 'noneOf',
        condition: HeimdallCondition<int>.noneOf,
        passingCounts: [0],
        heading: 'Prohibited conditions matched.',
      ),
    ];

    for (final group in groups) {
      for (var passingCount = 0; passingCount <= 3; passingCount++) {
        test('${group.name} with $passingCount of 3 conditions met', () {
          final evaluated = <String>[];
          final conditions = ['A', 'B', 'C'].indexed.map((entry) {
            final (index, name) = entry;
            return HeimdallCondition<int>('be $name', (item, _) {
              evaluated.add(name);
              return HeimdallFindings(
                subject: item,
                passed: index >= 3 - passingCount,
                findings: [HeimdallValidationInfo(message: 'child $name', line: index + 1)],
              );
            });
          });

          final findings = group.condition(conditions).check(0, project);

          if (group.passingCounts.contains(passingCount)) {
            expect(findings, isEmpty);
          } else {
            expect(findings, hasLength(1));
            final prohibited = group.name == 'noneOf';
            final violations = ['A', 'B', 'C'].indexed.where((entry) => (entry.$1 >= 3 - passingCount) == prohibited).toList();
            final messages = violations.map((entry) => prohibited ? 'should not be ${entry.$2}' : 'child ${entry.$2}').toList();
            final message = findings.single.message;
            if (group.name == 'anyOf') {
              expect(message, '${group.heading} (child A [line 1] or child B [line 2] or child C [line 3]).');
            } else if (messages.length == 1) {
              expect(message, messages.single);
            } else {
              expect(
                message,
                [
                  group.heading,
                  for (final (index, violation) in violations.indexed) '  - line ${violation.$1 + 1} — ${messages[index]}',
                ].join('\n'),
              );
            }
            expect(findings.single.line, violations.first.$1 + 1);
          }
          const order = ['A', 'B', 'C'];
          expect(evaluated, group.name == 'anyOf' && passingCount > 0 ? order.take(4 - passingCount) : order);
        });
      }
    }

    test('anyOf keeps distinct details of each alternative on one line', () {
      final condition = HeimdallCondition.anyOf([
        HeimdallCondition<int>(
          'meet both requirements',
          (item, _) => HeimdallFindings(
            subject: item,
            passed: false,
            findings: const [
              HeimdallValidationInfo(message: 'first detail\n  with context', line: 5),
              HeimdallValidationInfo(message: 'second detail', line: 8),
            ],
          ),
        ),
        HeimdallCondition<int>(
          'meet the alternative requirement',
          (item, _) => HeimdallFindings(
            subject: item,
            passed: false,
            findings: const [HeimdallValidationInfo(message: 'alternative detail', line: 13)],
          ),
        ),
      ]);

      final finding = condition.check(0, project).single;
      expect(finding.line, 5);
      expect(
        finding.message,
        'None of the alternatives matched ((first detail with context [line 5] and second detail [line 8]) or alternative detail [line 13]).',
      );
    });

    test('anyOf keeps the same message at distinct locations', () {
      HeimdallCondition<int> requirementAt(int line) => HeimdallCondition(
        'meet the requirement at line $line',
        (item, _) => HeimdallFindings(
          subject: item,
          passed: false,
          findings: [HeimdallValidationInfo(message: 'requirement was not met', line: line)],
        ),
      );
      final finding = HeimdallCondition.anyOf([requirementAt(5), requirementAt(8)]).check(0, project).single;

      expect(finding.line, 5);
      expect(finding.message, 'None of the alternatives matched (requirement was not met [line 5] or requirement was not met [line 8]).');
    });

    test('single conditions use singular messages and keep the subject location', () {
      final child = HeimdallCondition<HeimdallSourceFile>(
        'contain code',
        (item, _) => HeimdallFindings(subject: item, passed: item == sourceFile),
      );
      final otherFile = project.files.firstWhere((file) => file != sourceFile);
      final all = HeimdallCondition.allOf([child]);
      final any = HeimdallCondition.anyOf([child]);
      final none = HeimdallCondition.noneOf([child]);

      for (final condition in [all, any]) {
        expect(condition.check(sourceFile, project), isEmpty);
        final finding = condition.check(otherFile, project).single;
        expect(finding.message, 'should contain code');
        expect(finding.filePath, otherFile.absolutePath);
      }
      expect(none.check(otherFile, project), isEmpty);
      final finding = none.check(sourceFile, project).single;
      expect(finding.message, 'should not contain code');
      expect(finding.filePath, sourceFile.absolutePath);
    });

    test('DSL noneOf lists only prohibited matches and their locations', () {
      final result = Heimdall.files()
          .that()
          .resideInPath(sourceFile.relativePath)
          .should()
          .containNoSource([
            'class User',
            'missing snippet',
            'User(',
          ])
          .check(project);

      expect(result.findings, hasLength(1));
      expect(
        result.findings.single.message,
        'Prohibited conditions matched.\n'
        '  - ${sourceFile.absolutePath}:1:1: should not contain source "class User"\n'
        '  - ${sourceFile.absolutePath}:2:9: should not contain source "User("',
      );
      expect(result.findings.single.filePath, sourceFile.absolutePath);
      expect(result.findings.single.line, 1);
      expect(result.findings.single.column, 1);
    });

    test('DSL not reports a violation when the wrapped condition passed', () {
      final result = Heimdall.files().that().resideInPath(sourceFile.relativePath).should().not().containSource('class User').check(project);

      expect(result.findings, hasLength(1));
      expect(
        result.findings.single.message,
        'should not contain source "class User"',
      );
      expect(result.findings.single.filePath, sourceFile.absolutePath);
    });

    test(
      'DSL class not reports a violation when the class condition passed',
      () {
        final classProject = const HeimdallFileImporter(
          useCache: false,
        ).importPath('test/importer_fixtures/basic_project');

        final result = Heimdall.classes().that().haveTypeName('User').should().not().bePublic().check(classProject);

        expect(result.checkedCount, 1);
        expect(result.findings, hasLength(1));
        expect(result.findings.single.message, 'should not be public');
        expect(
          result.findings.single.filePath?.replaceAll(r'\', '/'),
          endsWith('lib/src/domain/user.dart'),
        );
      },
    );
  });
}
