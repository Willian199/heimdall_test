import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  late HeimdallProject project;
  setUpAll(() {
    project = const HeimdallFileImporter(useCache: false).importPath('test/code_fixtures/executable_syntax');
    Heimdall.code().shouldParse().check(project).assertNoFindings();
  });

  MemberPredicateBuilder method(String name) => Heimdall.methods().that().haveName(name);
  MemberPredicateBuilder field(String name, {String owner = 'Sample'}) =>
      Heimdall.fields().that().areDeclaredInClassesThat(HeimdallPredicate('named owner', (item, _) => item.name == owner)).and().haveName(name);

  test('final fields support filtered exceptions and mutable/const distinctions', () {
    Heimdall.fields()
        .that()
        .areDeclaredInClassesThat(HeimdallPredicate('named Sample', (item, _) => item.name == 'Sample'))
        .and()
        .areFinal()
        .should()
        .notBeMutable()
        .check(project)
        .assertNoFindings();
    field('constant').should().beConst().check(project).assertNoFindings();
    field('constant').should().notBeMutable().check(project).assertNoFindings();
    field('lazy').should().beFinal().check(project).assertNoFindings();
    field('mutable').should().beMutable().check(project).assertNoFindings();
    field('mutable').should().notBeFinal().check(project).assertNoFindings();
    expect(field('mutable').should().beFinal().check(project).findings, hasLength(1));
    expect(field('constant').should().beMutable().check(project).findings, hasLength(1));
    Heimdall.fields()
        .that()
        .areDeclaredInClassesThat(HeimdallPredicate('named Sample', (item, _) => item.name == 'Sample'))
        .and()
        .areNotMutable()
        .and()
        .areNotConst()
        .should()
        .beFinal()
        .check(project)
        .assertNoFindings();
  });

  test('nullable fields are selected from written annotations', () {
    final report =
        Heimdall.fields()
            .that()
            .areDeclaredInClassesThat(HeimdallPredicate('named Sample', (item, _) => item.name == 'Sample'))
            .and()
            .areNullable()
            .should()
            .beNullable()
            .check(project)
          ..assertNoFindings();
    expect(report.checkedCount, 2);
    field('stable').should().notBeNullable().check(project).assertNoFindings();
    expect(field('inferred').should().beNullable().check(project).findings, hasLength(1));
  });

  test('assertions include closures, skip comments, and report operator locations', () {
    final report = method('assertions').should().notContainNullAssertion().check(project);
    expect(report.findings, hasLength(2));
    final source = project.files.singleWhere((file) => file.relativePath.endsWith('sample.dart'));
    final lines = source.content.split('\n');
    for (final finding in report.findings) {
      expect(lines[finding.line! - 1][finding.column! - 1], '!');
    }
    method('assertions').should().containNullAssertion().check(project).assertNoFindings();
    expect(Heimdall.noMethods().that().haveName('assertions').should().containNullAssertion().check(project).findings, hasLength(2));
    expect(method('assertions').should().not().containNullAssertion().check(project).findings, hasLength(2));
  });

  test('file syntax ignores strings and comments but includes top-level functions', () {
    final clean = Heimdall.files()
        .that()
        .haveName('noise.dart')
        .should()
        .notContainNullAssertion()
        .and()
        .notCallMethodWithArguments('print')
        .and()
        .notCallConstructorWithArguments('Container');
    clean.check(project).assertNoFindings();
    Heimdall.files()
        .that()
        .haveName('sample.dart')
        .should()
        .callMethodWithArguments('print', positionalArguments: ["'top'"])
        .check(project)
        .assertNoFindings();
  });

  test('named arguments match regardless of order with subset and exact modes', () {
    final report = method('widgets')
        .should()
        .notCallConstructorWithArguments('Divider', namedArguments: {'height': '1+2', 'color': 'Colors.red'}, exactArguments: true)
        .check(project);
    expect(report.findings, hasLength(3));
    method('widgets').should().callConstructorWithArguments('Divider', namedArguments: {'height': '1 + 2'}).check(project).assertNoFindings();
    expect(
      method(
        'widgets',
      ).should().callConstructorWithArguments('Divider', namedArguments: {'height': '1 + 2'}, exactArguments: true).check(project).findings,
      hasLength(1),
    );
    expect(method('widgets').should().notCallConstructorWithArguments('Container', exactArguments: true).check(project).findings, hasLength(1));
    expect(
      method('widgets')
          .should()
          .notCallConstructorWithArguments('Widget', constructorName: 'named', namedArguments: {'label': "'hello world'"})
          .check(project)
          .findings,
      hasLength(2),
    );
  });

  test('method arguments distinguish receivers and literal contents', () {
    final unqualified = method(
      'logging',
    ).should().notCallMethodWithArguments('print', receiver: '', positionalArguments: ["'hello world'"]).check(project);
    expect(unqualified.findings, hasLength(1));
    expect(
      method('logging').should().notCallMethodWithArguments('print', positionalArguments: ["'hello world'"]).check(project).findings,
      hasLength(2),
    );
    method('logging')
        .should()
        .callMethodWithArguments('configure', positionalArguments: ['1'], namedArguments: {'enabled': 'true'})
        .check(project)
        .assertNoFindings();
    expect(
      method(
        'logging',
      ).should().callMethodWithArguments('configure', positionalArguments: [], namedArguments: {'enabled': 'true'}).check(project).findings,
      hasLength(1),
    );
    method('logging').should().notCallMethodWithArguments('configure', namedArguments: {'enabled': 'false'}).check(project).assertNoFindings();
  });

  test('expression rules use token boundaries and selected bodies', () {
    method('arithmetic').should().containExpression('first+second').check(project).assertNoFindings();
    method('other').should().notContainExpression('first + second').check(project).assertNoFindings();
    method('logging').should().containExpression("'hello world'").check(project).assertNoFindings();
    method('logging').should().notContainExpression("'hello  world'").check(project).assertNoFindings();
    expect(method('arithmetic').should().notContainExpression('first + second').check(project).findings, hasLength(1));
    expect(() => method('other').should().containExpression('x; void injected() {}'), throwsArgumentError);
    expect(() => method('other').should().containExpression(''), throwsArgumentError);
  });

  test('member syntax includes initializers but excludes parameter defaults', () {
    field('initialized').should().callConstructorWithArguments('Container', exactArguments: true).check(project).assertNoFindings();
    Heimdall.constructors()
        .that()
        .areDeclaredInClassesThat(HeimdallPredicate('named Sample', (item, _) => item.name == 'Sample'))
        .should()
        .containNullAssertion()
        .check(project)
        .assertNoFindings();
    method('defaults').should().notCallConstructorWithArguments('Container').check(project).assertNoFindings();
  });

  test('cascades preserve their receiver and are not constructor calls', () {
    method('cascades').should().callMethodWithArguments('print', receiver: 'logger').check(project).assertNoFindings();
    method('cascades').should().notCallMethodWithArguments('print', receiver: '').check(project).assertNoFindings();
    method('cascades').should().notCallConstructorWithArguments('Container').check(project).assertNoFindings();
  });

  test('method calls on values are not constructors with matching names', () {
    method('methodNamedLikeConstructor').should().notCallConstructorWithArguments('Container').check(project).assertNoFindings();
    method('methodNamedLikeConstructor').should().notCallConstructorWithArguments('builder.Container').check(project).assertNoFindings();
    method('methodNamedLikeConstructor').should().callMethodWithArguments('Container', receiver: 'builder').check(project).assertNoFindings();
    method('widgets').should().callConstructorWithArguments('Divider').check(project).assertNoFindings();
    method('widgets').should().callConstructorWithArguments('ui.Divider').check(project).assertNoFindings();
  });

  test('syntax predicates compose and preserve empty-selection contracts', () {
    Heimdall.methods().that().containNullAssertion().should().haveName('assertions').check(project).assertNoFindings();
    Heimdall.methods().that().containExpression('first + second').should().haveName('arithmetic').check(project).assertNoFindings();
    Heimdall.methods().that().callConstructorWithArguments('Divider').should().haveName('widgets').check(project).assertNoFindings();
    Heimdall.methods().that().callMethodWithArguments('configure').should().haveName('logging').check(project).assertNoFindings();
    expect(Heimdall.methods().that().containExpression('nonexistent').should().bePublic().check(project).findings, hasLength(1));
  });

  test('copyWith relation reports each missing variable of a nullable field', () {
    final report = Heimdall.fields()
        .that()
        .areDeclaredInClassesThat(HeimdallPredicate('named Sample', (item, _) => item.name == 'Sample'))
        .and()
        .areNullable()
        .should()
        .haveMatchingParameterIn('copyWith')
        .check(project);
    expect(report.findings, hasLength(1));
    expect(report.findings.single.message, contains('Sample.second'));
    field('label').should().haveMatchingParameterIn('copyWith').check(project).assertNoFindings();
    field('stable').should().notHaveMatchingParameterIn('copyWith').check(project).assertNoFindings();
    field('value', owner: 'Missing').should().notHaveMatchingParameterIn('copyWith').check(project).assertNoFindings();
  });

  test('props relation accepts direct fields, explicit this, and later local declarations', () {
    for (final owner in ['ExplicitThis', 'BlockReturn', 'LaterLocal', 'LaterPattern']) {
      field('value', owner: owner).should().beIncludedInReturnedListOf('props').check(project).assertNoFindings();
    }
    field('label').should().beIncludedInReturnedListOf('props').check(project).assertNoFindings();
    final report = field('first, second').should().beIncludedInReturnedListOf('props').check(project);
    expect(report.findings, hasLength(1));
    expect(report.findings.single.message, contains('Sample.second'));
  });

  test('props relation rejects other receivers, shadowing, nested returns and missing methods', () {
    for (final owner in ['Shadowed', 'OtherReceiver', 'Nested', 'PatternShadow', 'Missing']) {
      final report = field('value', owner: owner).should().beIncludedInReturnedListOf('props').check(project);
      expect(report.findings, hasLength(1), reason: owner);
      field('value', owner: owner).should().notBeIncludedInReturnedListOf('props').check(project).assertNoFindings();
    }
  });

  test('every-return props relation checks each branch without changing the existential rule', () {
    field('value', owner: 'BranchProps').should().beIncludedInReturnedListOf('props').check(project).assertNoFindings();
    expect(field('value', owner: 'BranchProps').should().beIncludedInEveryReturnedListOf('props').check(project).findings, hasLength(1));
    field('value', owner: 'BranchProps').should().notBeIncludedInEveryReturnedListOf('props').check(project).assertNoFindings();
    field('value', owner: 'CompleteBranchProps').should().beIncludedInEveryReturnedListOf('props').check(project).assertNoFindings();
    expect(field('value', owner: 'UnknownBranchProps').should().beIncludedInEveryReturnedListOf('props').check(project).findings, hasLength(1));
    expect(field('value', owner: 'LaterLocal').should().beIncludedInEveryReturnedListOf('props').check(project).findings, hasLength(1));
    expect(
      field('value', owner: 'CompleteBranchProps').areIncludedInEveryReturnedListOf('props').should().beFinal().check(project).findings,
      hasLength(1),
    );
  });

  test('copyWith forwarding checks named constructor arguments in every return', () {
    field('label', owner: 'CopyState').should().passMatchingParameterToReturnedConstructorIn('copyWith').check(project).assertNoFindings();
    field('count', owner: 'CopyState').should().haveMatchingParameterIn('copyWith').check(project).assertNoFindings();
    expect(
      field('count', owner: 'CopyState').should().passMatchingParameterToReturnedConstructorIn('copyWith').check(project).findings,
      hasLength(1),
    );
    for (final name in ['label', 'count']) {
      field(name, owner: 'CopyState').should().passMatchingParameterToReturnedConstructorIn('copyAll').check(project).assertNoFindings();
      field(name, owner: 'CopyState').should().passMatchingParameterToReturnedConstructorIn('copyDirect').check(project).assertNoFindings();
      expect(
        field(name, owner: 'CopyState').should().passMatchingParameterToReturnedConstructorIn('copyUnused').check(project).findings,
        hasLength(1),
      );
      expect(
        field(name, owner: 'CopyState').should().passMatchingParameterToReturnedConstructorIn('copyConditional').check(project).findings,
        hasLength(1),
      );
    }
    field('count', owner: 'CopyState').should().notPassMatchingParameterToReturnedConstructorIn('copyWith').check(project).assertNoFindings();
    expect(
      field('count', owner: 'CopyState').should().passMatchingParameterToReturnedConstructorIn('copyLoopShadow').check(project).findings,
      hasLength(1),
    );
    field('count', owner: 'CopyState').should().notPassMatchingParameterToReturnedConstructorIn('copyLoopShadow').check(project).assertNoFindings();
  });

  test('relationship predicates, inversion and repeated cache reads agree', () {
    Heimdall.fields()
        .that()
        .areDeclaredInClassesThat(HeimdallPredicate('named Sample', (item, _) => item.name == 'Sample'))
        .and()
        .haveMatchingParameterIn('copyWith')
        .should()
        .haveName('label')
        .check(project)
        .assertNoFindings();
    for (var run = 0; run < 2; run++) {
      final report = Heimdall.noFields()
          .that()
          .areDeclaredInClassesThat(HeimdallPredicate('named Sample', (item, _) => item.name == 'Sample'))
          .and()
          .haveName('label')
          .should()
          .beIncludedInReturnedListOf('props')
          .check(project);
      expect(report.findings, hasLength(1));
      expect(report.findings.single.column, isNotNull);
    }
  });

  test('models reuse immutable expression and relationship caches', () {
    final source = project.files.singleWhere((file) => file.relativePath.endsWith('sample.dart'));
    expect(identical(source.expressions, source.expressions), isTrue);
    expect(() => source.expressions.clear(), throwsUnsupportedError);
    final member = source.classMembers.whereType<MethodDeclaration>().firstWhere((member) => member.name.lexeme == 'props');
    expect(identical(member.executableExpressions, member.executableExpressions), isTrue);
    expect(identical(member.returnedListFieldNames, member.returnedListFieldNames), isTrue);
    expect(() => member.executableExpressions.clear(), throwsUnsupportedError);
    expect(() => member.returnedListFieldNames.clear(), throwsUnsupportedError);
    expect(() => member.parameterNames.clear(), throwsUnsupportedError);
  });

  test('imported compilation units are parsed but not semantically resolved', () {
    final source = project.files.singleWhere((file) => file.relativePath.endsWith('sample.dart'));
    expect(source.unit, isNotNull);
    expect(identical(source.unit!.declarations.first, source.declarations.first), isTrue);
    expect(source.isResolved, isFalse);
    expect(source.analysisDiagnostics, isEmpty);
    expect(project.analysisDiagnosticCount, 0);
  });
}
