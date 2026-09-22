import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  final project = const HeimdallFileImporter(useCache: false).importPath('test/class_fixtures/class_rules_project');
  final limits =
      <
        ({
          String name,
          int actual,
          ClassPredicateBuilder Function(ClassPredicateBuilder, int) select,
          HeimdallRule<CompilationUnitMember> Function(ClassShouldBuilder, int) require,
        })
      >[
        (name: 'methods', actual: 1, select: (b, n) => b.haveAtMostMethods(n), require: (b, n) => b.haveAtMostMethods(n)),
        (name: 'fields', actual: 1, select: (b, n) => b.haveAtMostFields(n), require: (b, n) => b.haveAtMostFields(n)),
        (name: 'members', actual: 2, select: (b, n) => b.haveAtMostMembers(n), require: (b, n) => b.haveAtMostMembers(n)),
        (name: 'constructors', actual: 0, select: (b, n) => b.haveAtMostConstructors(n), require: (b, n) => b.haveAtMostConstructors(n)),
        (name: 'code units', actual: 1, select: (b, n) => b.haveAtMostCodeUnits(n), require: (b, n) => b.haveAtMostCodeUnits(n)),
        (name: 'method parameters', actual: 1, select: (b, n) => b.haveAtMostMethodParameters(n), require: (b, n) => b.haveAtMostMethodParameters(n)),
        (
          name: 'constructor parameters',
          actual: 0,
          select: (b, n) => b.haveAtMostConstructorParameters(n),
          require: (b, n) => b.haveAtMostConstructorParameters(n),
        ),
      ];
  for (final limit in limits) {
    test('at most ${limit.name} includes the boundary', () {
      for (final count in [limit.actual - 1, limit.actual, limit.actual + 1]) {
        final report = limit.require(Heimdall.classes().that().haveTypeName('SuperBase').should(), count).check(project);
        expect(report.checkedCount, 1);
        expect(report.hasFindings, limit.actual > count);
        final selected = limit
            .select(Heimdall.classes().that().haveTypeName('SuperBase').and(), count)
            .should()
            .haveTypeName('SuperBase')
            .allowEmpty()
            .check(project);
        expect(selected.checkedCount, limit.actual <= count ? 1 : 0);
      }
    });
  }

  test('count other than means unequal, not fewer than', () {
    final oneMethod = Heimdall.classes().that().haveTypeName('SuperBase');
    expect(oneMethod.should().haveMethodCountOtherThan(1).check(project).hasFindings, isTrue);
    oneMethod.should().haveMethodCountOtherThan(0).check(project).assertNoFindings();
    oneMethod.should().haveMethodCountOtherThan(2).check(project).assertNoFindings();
  });

  test('return type rules reject fields while declared-field rules accept them', () {
    final fields = Heimdall.members().that().haveName('id');
    expect(fields.should().haveReturnType('String').check(project).hasFindings, isTrue);
    fields.should().haveDeclaredFieldTypeName('String').check(project).assertNoFindings();
  });

  test('path complements form a complete disjoint partition', () {
    final inside = Heimdall.files().that().resideInPath('lib/src/domain/**').should().haveNoParseErrors().allowEmpty().check(project);
    final outside = Heimdall.files().that().resideOutsideOfPath('lib/src/domain/**').should().haveNoParseErrors().allowEmpty().check(project);
    expect(inside.checkedCount + outside.checkedCount, project.files.length);
    expect(inside.checkedCount, greaterThan(0));
    expect(outside.checkedCount, greaterThan(0));
  });

  test('the canonical constructor API supports unnamed and list-based checks', () {
    Heimdall.classes().that().haveTypeName('User').should().declareConstructor().check(project).assertNoFindings();
    Heimdall.classes().that().haveTypeName('User').should().declareAnyConstructor(['new', 'missing']).check(project).assertNoFindings();
    expect(Heimdall.classes().that().haveTypeName('User').should().notDeclareConstructor().check(project).hasFindings, isTrue);
  });
}
