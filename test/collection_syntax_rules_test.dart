import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  final project = const HeimdallFileImporter(useCache: false).importPath('test/code_fixtures/executable_syntax');
  final file = project.files.singleWhere((file) => file.relativePath.endsWith('sample.dart'));
  final logging = file.classMembers.whereType<MethodDeclaration>().firstWhere((member) => member.name.lexeme == 'logging');
  final widgets = file.classMembers.whereType<MethodDeclaration>().firstWhere((member) => member.name.lexeme == 'widgets');
  final state = file.classMembers.whereType<FieldDeclaration>().singleWhere((member) => member.ownerName == 'VariantState');
  FilePredicateBuilder files() => Heimdall.files().that().haveName('sample.dart');
  MemberPredicateBuilder members(String name) => Heimdall.methods().that().haveName(name);
  MemberPredicateBuilder stateFields() => Heimdall.fields().that().areDeclaredInClassesThat(
    HeimdallPredicate('belong to VariantState', (item, _) => item.name == 'VariantState'),
  );
  final cases = <_CollectionCase>[
    _CollectionCase(
      name: 'file containExpression',
      matches: ["'hello world'", "'helloworld'"],
      all: (values) => files().should().containAllExpressions(values).check(project),
      selectAll: (values) => files().containAllExpressions(values).should().predicate.test(file, project),
      any: (values) => files().should().containAnyExpression(values).check(project),
      selectAny: (values) => files().containAnyExpression(values).should().predicate.test(file, project),
      none: (values) => files().should().containNoExpressions(values).check(project),
      selectNone: (values) => files().containNoExpressions(values).should().predicate.test(file, project),
    ),
    _CollectionCase(
      name: 'file callMethodWithArguments',
      matches: ['print', 'configure'],
      all: (values) => files().should().callAllMethodsWithArguments(values).check(project),
      selectAll: (values) => files().callAllMethodsWithArguments(values).should().predicate.test(file, project),
      any: (values) => files().should().callAnyMethodWithArguments(values).check(project),
      selectAny: (values) => files().callAnyMethodWithArguments(values).should().predicate.test(file, project),
      none: (values) => files().should().callNoMethodsWithArguments(values).check(project),
      selectNone: (values) => files().callNoMethodsWithArguments(values).should().predicate.test(file, project),
    ),
    _CollectionCase(
      name: 'file callConstructorWithArguments',
      matches: ['Divider', 'Container'],
      all: (values) => files().should().callAllConstructorsWithArguments(values).check(project),
      selectAll: (values) => files().callAllConstructorsWithArguments(values).should().predicate.test(file, project),
      any: (values) => files().should().callAnyConstructorWithArguments(values).check(project),
      selectAny: (values) => files().callAnyConstructorWithArguments(values).should().predicate.test(file, project),
      none: (values) => files().should().callNoConstructorsWithArguments(values).check(project),
      selectNone: (values) => files().callNoConstructorsWithArguments(values).should().predicate.test(file, project),
    ),
    _CollectionCase(
      name: 'member containExpression',
      matches: ["'hello world'", "'helloworld'"],
      all: (values) => members('logging').should().containAllExpressions(values).check(project),
      selectAll: (values) => members('logging').containAllExpressions(values).should().predicate.test(logging, project),
      any: (values) => members('logging').should().containAnyExpression(values).check(project),
      selectAny: (values) => members('logging').containAnyExpression(values).should().predicate.test(logging, project),
      none: (values) => members('logging').should().containNoExpressions(values).check(project),
      selectNone: (values) => members('logging').containNoExpressions(values).should().predicate.test(logging, project),
    ),
    _CollectionCase(
      name: 'member callMethodWithArguments',
      matches: ['print', 'configure'],
      all: (values) => members('logging').should().callAllMethodsWithArguments(values).check(project),
      selectAll: (values) => members('logging').callAllMethodsWithArguments(values).should().predicate.test(logging, project),
      any: (values) => members('logging').should().callAnyMethodWithArguments(values).check(project),
      selectAny: (values) => members('logging').callAnyMethodWithArguments(values).should().predicate.test(logging, project),
      none: (values) => members('logging').should().callNoMethodsWithArguments(values).check(project),
      selectNone: (values) => members('logging').callNoMethodsWithArguments(values).should().predicate.test(logging, project),
    ),
    _CollectionCase(
      name: 'member callConstructorWithArguments',
      matches: ['Divider', 'Container'],
      all: (values) => members('widgets').should().callAllConstructorsWithArguments(values).check(project),
      selectAll: (values) => members('widgets').callAllConstructorsWithArguments(values).should().predicate.test(widgets, project),
      any: (values) => members('widgets').should().callAnyConstructorWithArguments(values).check(project),
      selectAny: (values) => members('widgets').callAnyConstructorWithArguments(values).should().predicate.test(widgets, project),
      none: (values) => members('widgets').should().callNoConstructorsWithArguments(values).check(project),
      selectNone: (values) => members('widgets').callNoConstructorsWithArguments(values).should().predicate.test(widgets, project),
    ),
    _CollectionCase(
      name: 'member haveMatchingParameterIn',
      matches: ['copyBoth', 'copyBothAgain'],
      all: (values) => stateFields().should().haveMatchingParameterInAllMethods(values).check(project),
      selectAll: (values) => stateFields().haveMatchingParameterInAllMethods(values).should().predicate.test(state, project),
      any: (values) => stateFields().should().haveMatchingParameterInAnyMethod(values).check(project),
      selectAny: (values) => stateFields().haveMatchingParameterInAnyMethod(values).should().predicate.test(state, project),
      none: (values) => stateFields().should().haveMatchingParameterInNoMethods(values).check(project),
      selectNone: (values) => stateFields().haveMatchingParameterInNoMethods(values).should().predicate.test(state, project),
    ),
    _CollectionCase(
      name: 'member beIncludedInReturnedListOf',
      matches: ['bothProps', 'alsoBothProps'],
      all: (values) => stateFields().should().beIncludedInReturnedListOfAllMethods(values).check(project),
      selectAll: (values) => stateFields().areIncludedInReturnedListOfAllMethods(values).should().predicate.test(state, project),
      any: (values) => stateFields().should().beIncludedInReturnedListOfAnyMethod(values).check(project),
      selectAny: (values) => stateFields().areIncludedInReturnedListOfAnyMethod(values).should().predicate.test(state, project),
      none: (values) => stateFields().should().beIncludedInReturnedListOfNoMethods(values).check(project),
      selectNone: (values) => stateFields().areIncludedInReturnedListOfNoMethods(values).should().predicate.test(state, project),
    ),
  ];

  for (final entry in cases) {
    test('${entry.name} composes all/any/none conditions and predicates', () {
      final mixed = [entry.matches.first, 'missing'];
      entry.all(entry.matches).assertNoFindings();
      expect(entry.all(mixed).findings, isNotEmpty);
      entry.any(mixed).assertNoFindings();
      expect(entry.any(['missing']).findings, isNotEmpty);
      entry.none(['missing']).assertNoFindings();
      final prohibited = entry.none(mixed);
      expect(prohibited.findings, isNotEmpty);
      expect(prohibited.findings.first.line, isNotNull);
      expect(prohibited.findings.first.column, isNotNull);
      expect(entry.selectAll(entry.matches), isTrue);
      expect(entry.selectAll(mixed), isFalse);
      expect(entry.selectAny(mixed), isTrue);
      expect(entry.selectAny(['missing']), isFalse);
      expect(entry.selectNone(['missing']), isTrue);
      expect(entry.selectNone(mixed), isFalse);
    });
    test('${entry.name} rejects empty collections on both sides', () {
      for (final build in [entry.all, entry.any, entry.none]) {
        expect(() => build([]), throwsArgumentError);
      }
      for (final select in [entry.selectAll, entry.selectAny, entry.selectNone]) {
        expect(() => select([]), throwsArgumentError);
      }
    });
  }

  test('relationship any does not merge partial coverage from different methods', () {
    expect(stateFields().should().haveMatchingParameterInAnyMethod(['copyFirst', 'copySecond']).check(project).findings, hasLength(2));
    stateFields().should().haveMatchingParameterInNoMethods(['copyFirst', 'copySecond']).check(project).assertNoFindings();
    expect(stateFields().should().beIncludedInReturnedListOfAnyMethod(['firstProps', 'secondProps']).check(project).findings, hasLength(2));
    stateFields().should().beIncludedInReturnedListOfNoMethods(['firstProps', 'secondProps']).check(project).assertNoFindings();
    expect(
      stateFields().should().haveMatchingParameterInAllMethods(['copyBoth', 'copyFirst']).check(project).findings.single.message,
      contains('second'),
    );
  });

  test('method variants forward argument and receiver filters in both scopes', () {
    final reports = [
      members('logging')
          .should()
          .callAnyMethodWithArguments(['missing', 'print'], receiver: '', positionalArguments: ["'hello world'"], exactArguments: true)
          .check(project),
      files()
          .should()
          .callAnyMethodWithArguments(['missing', 'print'], receiver: '', positionalArguments: ["'hello world'"], exactArguments: true)
          .check(project),
      members('logging').should().callAllMethodsWithArguments(['print'], receiver: 'logger', positionalArguments: ["'hello world'"]).check(project),
      files().should().callAllMethodsWithArguments(['configure'], namedArguments: {'enabled': 'true'}, positionalArguments: ['1']).check(project),
      members('logging').should().callNoMethodsWithArguments(['configure'], namedArguments: {'enabled': 'false'}).check(project),
      files().should().callNoMethodsWithArguments(['configure'], positionalArguments: [], exactArguments: true).check(project),
    ];
    for (final report in reports) {
      report.assertNoFindings();
    }
    expect(
      members('logging').should().callNoMethodsWithArguments(['print'], receiver: '', positionalArguments: ["'hello world'"]).check(project).findings,
      hasLength(1),
    );
    expect(
      files().should().callNoMethodsWithArguments(['print'], receiver: '', positionalArguments: ["'hello world'"]).check(project).findings,
      hasLength(1),
    );
    expect(
      members(
        'logging',
      ).callAnyMethodWithArguments(['missing', 'configure'], namedArguments: {'enabled': 'false'}).should().predicate.test(logging, project),
      isFalse,
    );
    expect(
      files().callAllMethodsWithArguments(['configure'], positionalArguments: [], exactArguments: true).should().predicate.test(file, project),
      isFalse,
    );
  });

  test('constructor variants forward named constructor and argument filters', () {
    final reports = [
      members('widgets')
          .should()
          .callAllConstructorsWithArguments(['Widget'], constructorName: 'named', namedArguments: {'label': "'hello world'"}, exactArguments: true)
          .check(project),
      files()
          .should()
          .callAllConstructorsWithArguments(['Widget'], constructorName: 'named', namedArguments: {'label': "'hello world'"}, exactArguments: true)
          .check(project),
      members('widgets').should().callAnyConstructorWithArguments(['missing', 'Divider'], namedArguments: {'height': '1 + 2'}).check(project),
      files().should().callAnyConstructorWithArguments(['missing', 'Container'], exactArguments: true).check(project),
      members('widgets').should().callNoConstructorsWithArguments(['Widget'], constructorName: 'other').check(project),
      files().should().callNoConstructorsWithArguments(['Divider'], namedArguments: {'height': '0'}).check(project),
    ];
    for (final report in reports) {
      report.assertNoFindings();
    }
    expect(members('widgets').should().callNoConstructorsWithArguments(['Container'], exactArguments: true).check(project).findings, hasLength(1));
    expect(files().should().callNoConstructorsWithArguments(['Divider'], namedArguments: {'height': '1+2'}).check(project).findings, hasLength(3));
    expect(
      members('widgets').callAnyConstructorWithArguments(['Widget'], constructorName: 'other').should().predicate.test(widgets, project),
      isFalse,
    );
    expect(files().callNoConstructorsWithArguments(['Container'], exactArguments: true).should().predicate.test(file, project), isFalse);
  });

  test('collection rules support inversion and condition chaining', () {
    final report = Heimdall.noMethods().that().haveName('logging').should().containAnyExpression(["'hello world'", 'missing']).check(project);
    expect(report.findings, isNotEmpty);
    expect(report.findings.first.column, isNotNull);
    members('logging')
        .should()
        .containAllExpressions(["'hello world'", "'helloworld'"])
        .and()
        .callAnyMethodWithArguments(['configure', 'missing'])
        .check(project)
        .assertNoFindings();
    files().should().containAnyExpression(['missing']).or().callAllMethodsWithArguments(['print', 'configure']).check(project).assertNoFindings();
  });
}

final class _CollectionCase {
  const _CollectionCase({
    required this.name,
    required this.matches,
    required this.all,
    required this.any,
    required this.none,
    required this.selectAll,
    required this.selectAny,
    required this.selectNone,
  });
  final String name;
  final List<String> matches;
  final HeimdallReport Function(List<String>) all;
  final HeimdallReport Function(List<String>) any;
  final HeimdallReport Function(List<String>) none;
  final bool Function(List<String>) selectAll;
  final bool Function(List<String>) selectAny;
  final bool Function(List<String>) selectNone;
}
