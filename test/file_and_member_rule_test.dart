import 'dart:async';

import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  group('File and member rules', () {
    const fixture = 'test/file_member_fixtures/file_member_project';

    test('detects forbidden imports', () {
      final project = const HeimdallFileImporter(
        useCache: false,
      ).importPath(fixture);

      final result = Heimdall.code().shouldNotImportDartMirrors().check(
        project,
      );

      expect(result.findings, hasLength(1));
    });

    test('checks file source and URI rules from imported content', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );

      final existing = Heimdall.files().that().resideInPath('lib/src/data/user_repository.dart').should().exist().check(project);
      final missing = Heimdall.files().that().resideInPath('lib/src/data/missing.dart').should().exist().check(project);
      final import = Heimdall.files()
          .that()
          .resideInPath('lib/src/data/user_repository.dart')
          .should()
          .importUri('../domain/user.dart')
          .check(project);
      final importByListPredicates = Heimdall.files()
          .that()
          .haveNameEqualToAnyOf(['missing.dart', 'user_repository.dart'])
          .and()
          .haveNameEndingWithAnyOf(['repository.dart', 'service.dart'])
          .and()
          .haveNameStartingWithNoneOf(['generated'])
          .and()
          .haveNameMatchingAnyOf([RegExp('repository')])
          .and()
          .resideInAnyPath(['missing', 'lib/src/data/**'])
          .and()
          .resideOutsideOfAtLeastOnePath(['lib/src/domain/**'])
          .should()
          .importUri('../domain/user.dart')
          .check(project);
      final allImports = Heimdall.files()
          .that()
          .resideInPath('lib/src/data/user_repository.dart')
          .should()
          .importAllUris(['../domain/user.dart'])
          .check(project);
      final anyImport = Heimdall.files()
          .that()
          .resideInPath('lib/src/data/user_repository.dart')
          .should()
          .importAnyUri(['missing.dart', '../domain/user.dart'])
          .check(project);
      final noExactImports = Heimdall.files()
          .that()
          .resideInPath('lib/src/data/user_repository.dart')
          .should()
          .importNoUris(['missing.dart', 'forbidden.dart'])
          .check(project);
      final noneImports = Heimdall.files()
          .that()
          .resideInPath('lib/src/data/user_repository.dart')
          .should()
          .not()
          .importAnyUri(['dart:mirrors', 'package:forbidden/'])
          .check(project);
      final noneMatchingImports = Heimdall.files()
          .that()
          .resideInPath('lib/src/data/user_repository.dart')
          .should()
          .not()
          .importAnyUriMatching([RegExp('dart:'), RegExp('forbidden')])
          .check(project);
      final invertedMatchingImport = Heimdall.noFiles()
          .that()
          .resideInPath('lib/src/data/user_repository.dart')
          .should()
          .importUriMatching(RegExp('domain/user'))
          .check(project);
      final noContent = Heimdall.files()
          .that()
          .resideInPath('lib/src/data/user_repository.dart')
          .should()
          .containNoSource(['debugPrint', 'dart:mirrors'])
          .check(project);
      final matchingContentCombinations = Heimdall.files()
          .that()
          .resideInPath('lib/src/data/user_repository.dart')
          .should()
          .containAllSourceMatching([
            RegExp(r'class\s+UserRepository'),
            RegExp('createRepository'),
          ])
          .and()
          .containAnySourceMatching([RegExp('missing'), RegExp(r'User\(')])
          .and()
          .containNoSourceMatching([RegExp('dart:mirrors')])
          .check(project);
      final content = Heimdall.files()
          .that()
          .resideInPath('lib/src/data/user_repository.dart')
          .should()
          .containAllSource([
            'UserRepository createRepository()',
            "const User('1')",
          ])
          .check(project);
      final matchingContent = Heimdall.files()
          .that()
          .resideInPath('lib/src/data/user_repository.dart')
          .should()
          .containSourceMatching(RegExp(r'const\s+User\('))
          .check(project);
      final forbiddenSource = Heimdall.files()
          .that()
          .resideInPath('lib/src/data/user_repository.dart')
          .should()
          .containNoSource(["const User('1')"])
          .check(project);
      final forbiddenMatchingSource = Heimdall.files()
          .that()
          .resideInPath('lib/src/data/user_repository.dart')
          .should()
          .containNoSourceMatching([RegExp(r'User\s+find\(\)')])
          .check(project);
      final invertedSource = Heimdall.noFiles()
          .that()
          .resideInPath('lib/src/data/user_repository.dart')
          .should()
          .containSource("const User('1')")
          .check(project);
      final invertedMatchingSource = Heimdall.noFiles()
          .that()
          .resideInPath('lib/src/data/user_repository.dart')
          .should()
          .containSourceMatching(RegExp(r'User\s+find\(\)'))
          .check(project);

      expect(existing.findings, isEmpty);
      expect(missing.findings, hasLength(1));
      expect(import.checkedCount, 1);
      expect(import.findings, isEmpty);
      expect(importByListPredicates.checkedCount, 1);
      expect(importByListPredicates.findings, isEmpty);
      expect(allImports.findings, isEmpty);
      expect(anyImport.findings, isEmpty);
      expect(noExactImports.findings, isEmpty);
      expect(noneImports.findings, isEmpty);
      expect(noneMatchingImports.findings, isEmpty);
      expect(invertedMatchingImport.findings.single.line, 1);
      expect(invertedMatchingImport.findings.single.column, isNotNull);
      expect(content.findings, isEmpty);
      expect(noContent.findings, isEmpty);
      expect(matchingContentCombinations.findings, isEmpty);
      expect(matchingContent.findings, isEmpty);
      expect(
        forbiddenSource.findings.single.message,
        contains('should not contain source "const User(\'1\')"'),
      );
      expect(forbiddenSource.findings.single.line, 6);
      expect(forbiddenSource.findings.single.column, 18);
      expect(
        forbiddenMatchingSource.findings.single.message,
        contains('should not contain source matching'),
      );
      expect(forbiddenMatchingSource.findings.single.line, 6);
      expect(forbiddenMatchingSource.findings.single.column, 3);
      expect(invertedSource.findings.single.line, 6);
      expect(invertedSource.findings.single.column, 18);
      expect(
        invertedSource.findings.single.message,
        contains('must not contain source "const User(\'1\')"'),
      );
      expect(invertedMatchingSource.findings.single.line, 6);
      expect(invertedMatchingSource.findings.single.column, 3);
      expect(
        invertedMatchingSource.findings.single.message,
        contains('must not contain source matching'),
      );
    });

    test('reports every matching file for empty path rules', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );

      final legacyFiles = Heimdall.files().that().resideInPath('lib/src/data/**').shouldNotExist().check(project);
      final legacyPath = Heimdall.code().pathShouldBeEmpty('lib/src/data').check(project);
      final emptyLegacyPath = Heimdall.code().pathShouldBeEmpty('lib/src/missing').allowEmpty().check(project);
      final parsedEmptySelection = Heimdall.files().that().resideInPath('lib/src/missing').should().allowEmpty().haveNoParseErrors().check(project);
      final parsedEmptySelectionAfterRule = Heimdall.files()
          .that()
          .resideInPath('lib/src/missing')
          .should()
          .haveNoParseErrors()
          .allowEmpty()
          .check(project);

      expect(legacyFiles.checkedCount, 2);
      expect(legacyFiles.findings, hasLength(2));
      expect(legacyPath.findings, hasLength(2));
      expect(
        legacyFiles.findings.map((finding) => finding.filePath?.replaceAll(r'\', '/')),
        contains(endsWith('lib/src/data/user_repository.dart')),
      );
      expect(emptyLegacyPath.checkedCount, 0);
      expect(emptyLegacyPath.findings, isEmpty);
      expect(parsedEmptySelection.findings, isEmpty);
      expect(parsedEmptySelectionAfterRule.findings, isEmpty);
    });

    test('path rule findings describe expected and actual paths clearly', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );

      final fileResult = Heimdall.files()
          .that()
          .resideInPath('lib/src/data/user_repository.dart')
          .should()
          .resideInPath('lib/src/domain/**')
          .check(project);
      final fileOutsideResult = Heimdall.files()
          .that()
          .resideInPath('lib/src/data/user_repository.dart')
          .should()
          .resideOutsideOfPath('lib/src/data/**')
          .check(project);
      final memberResult = Heimdall.methods().that().haveName('findName').should().resideInPath('lib/src/data/**').check(project);
      final memberOutsideResult = Heimdall.methods().that().haveName('findName').should().resideOutsideOfPath('lib/src/domain/**').check(project);

      expect(
        fileResult.findings.single.message,
        'should reside in path lib/src/domain/**',
      );
      expect(
        fileOutsideResult.findings.single.message,
        'should reside outside of path lib/src/data/**',
      );
      expect(
        memberResult.findings.single.message,
        'UserService.findName should reside in path lib/src/data/** (actual: lib/src/domain/service.dart)',
      );
      expect(
        memberOutsideResult.findings.single.message,
        'UserService.findName should reside outside of path lib/src/domain/** (actual: lib/src/domain/service.dart)',
      );
      expect(
        fileResult.assertNoFindings,
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('should reside in path lib/src/domain/**'),
          ),
        ),
      );
    });

    test('verbose report output uses the current zone printer', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );
      final printed = <String>[];

      runZoned(
        () {
          Heimdall.files()
              .that()
              .resideInPath('lib/src/data/user_repository.dart')
              .should()
              .containSource("const User('1')")
              .check(project)
              .assertNoFindings(verbose: true);
        },
        zoneSpecification: ZoneSpecification(
          print: (_, _, _, message) => printed.add(message),
        ),
      );

      expect(printed, hasLength(1));
      expect(printed.single, contains('1 items checked'));
    });

    test('checks export URI rules without treating exports as imports', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        'test/dsl_fixtures/combinations_project',
      );

      final export = Heimdall.files().that().resideInPath('lib/src/barrel.dart').should().exportUri('domain/user.dart').check(project);
      final exportCombinations = Heimdall.files()
          .that()
          .resideInPath('lib/src/barrel.dart')
          .should()
          .exportAllUris(['domain/user.dart'])
          .and()
          .exportUriMatching(RegExp(r'domain/.*\.dart$'))
          .and()
          .exportAnyUriMatching([RegExp('missing'), RegExp(r'domain/.*\.dart$')])
          .and()
          .exportNoUrisMatching([RegExp('forbidden')])
          .and()
          .exportAnyUri(['missing.dart', 'domain/user.dart'])
          .and()
          .exportNoUris(['forbidden.dart'])
          .check(project);
      final invertedMatchingExport = Heimdall.noFiles()
          .that()
          .resideInPath('lib/src/barrel.dart')
          .should()
          .exportUriMatching(RegExp(r'domain/.*\.dart$'))
          .check(project);
      final importDoesNotMatchExport = Heimdall.files()
          .that()
          .resideInPath('lib/src/barrel.dart')
          .should()
          .importUri('domain/user.dart')
          .check(project);

      expect(export.findings, isEmpty);
      expect(exportCombinations.findings, isEmpty);
      expect(invertedMatchingExport.findings.single.line, 1);
      expect(invertedMatchingExport.findings.single.column, isNotNull);
      expect(importDoesNotMatchExport.findings, hasLength(1));
    });

    test('checks extension declaration rules from analyzer nodes', () {
      final project = const HeimdallFileImporter(useCache: false).importPath();

      final extension = Heimdall.files()
          .that()
          .resideInPath('src/features/file_features/features/file_declare_extension_on_rules.dart')
          .should()
          .declareExtensionOn('FilePredicateBuilder')
          .and()
          .declareAllExtensionsOn(['FilePredicateBuilder', 'FileShouldBuilder'])
          .and()
          .declareAnyExtensionOn(['MissingBuilder', 'FileShouldBuilder'])
          .and()
          .declareNoExtensionsOn(['MissingBuilder'])
          .check(project);
      final extensionMethod = Heimdall.files()
          .that()
          .resideInPath('src/features/file_features/features/file_declare_extension_on_rules.dart')
          .should()
          .declareMethod('declareExtensionOn')
          .check(project);
      final staticProject = const HeimdallFileImporter(useCache: false).importPath(
        'test/executable_fixtures/static_method_constructor',
      );
      final staticCall = Heimdall.files()
          .that()
          .resideInPath('lib/calls.dart')
          .should()
          .callStaticMethod('Product', 'staticCall')
          .and()
          .callAllStaticMethods('Product', ['staticCall'])
          .and()
          .callAnyStaticMethod('Product', ['missing', 'staticCall'])
          .and()
          .callNoStaticMethods('Product', ['missing'])
          .check(staticProject);

      expect(extension.findings, isEmpty);
      expect(extensionMethod.findings, isEmpty);
      expect(staticCall.findings, isEmpty);
    });

    test('checks member rules', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );

      final fields = Heimdall.fields().should().beFinal().check(project);
      final methods = Heimdall.methods().that().haveName('findName').should().accessField('name').check(project);
      final constructors = Heimdall.constructors().that().arePrivate().should().bePrivate().check(project);
      final methodParameters = Heimdall.methods().that().haveName('findName').should().haveRequiredParameter('prefix').check(project);
      final methodCombinations = Heimdall.methods()
          .that()
          .haveName('findName')
          .should()
          .beAnnotatedWithAnyOf(['Deprecated', 'Tracked'])
          .and()
          .callAllMethods(['toUpperCase'])
          .and()
          .callNoMethods(['parse'])
          .and()
          .accessAnyField(['missing', 'name'])
          .and()
          .haveRequiredParameterAllOf(['prefix'])
          .and()
          .haveRequiredParameterAnyOf(['missing', 'prefix'])
          .check(project);
      final methodPredicateCombinations = Heimdall.methods()
          .that()
          .haveNameEqualToAnyOf(['missing', 'findName'])
          .and()
          .haveNameEndingWithAnyOf(['Name'])
          .and()
          .haveNameStartingWithNoneOf(['_'])
          .and()
          .haveNameMatchingAnyOf([RegExp('find')])
          .and()
          .areAnnotatedWithAnyOf(['Deprecated', 'Tracked'])
          .and()
          .haveReturnTypeEqualToAnyOf(['String'])
          .should()
          .accessField('name')
          .check(project);
      final constructorParameters = Heimdall.constructors().that().arePrivate().should().haveRequiredParameter('token').check(project);
      final invertedMatchingMethodCall = Heimdall.noMethods()
          .that()
          .haveName('findName')
          .should()
          .callMethodNameMatching(RegExp('toUpper'))
          .check(project);
      final invertedMatchingConstructorCall = Heimdall.noConstructors()
          .that()
          .arePrivate()
          .should()
          .callConstructorTypeNameMatching(RegExp('Helper'))
          .check(project);
      final invertedMatchingAnnotation = Heimdall.noMethods()
          .that()
          .haveName('findName')
          .should()
          .beAnnotatedWithTypeNameMatching(RegExp('Tracked'))
          .check(project);
      final constructorCombinations = Heimdall.constructors()
          .that()
          .arePrivate()
          .should()
          .callAnyConstructor(['Missing', 'Helper'])
          .and()
          .haveRequiredParameterNoneOf(['missing'])
          .check(project);
      final publicCubitMethods = Heimdall.methods()
          .that()
          .areDeclaredInClassesThat(
            HeimdallPredicate(
              'are cubit widgets',
              (item, _) => item.name == 'CubitWidget',
            ),
          )
          .and()
          .arePublic()
          .and()
          .receiveParameterTypeNameEndingWith('Cubit')
          .should()
          .haveName('publicAction')
          .check(project);
      final cubitConstructorParameters = Heimdall.constructors()
          .that()
          .areDeclaredInClassesThat(
            HeimdallPredicate(
              'are cubit widgets',
              (item, _) => item.name == 'CubitWidget',
            ),
          )
          .should()
          .receiveParameterTypeName('ChildCubit')
          .and()
          .receiveParameterTypeName('ViewCubit')
          .and()
          .receiveParameterTypeName('ParentCubit')
          .and()
          .receiveParameterTypeNameEndingWithAnyOf(['Missing', 'Cubit'])
          .and()
          .receiveParameterTypeNameEndingWithAllOf(['Cubit'])
          .and()
          .receiveParameterTypeNameStartingWithAnyOf(['Missing', 'Child'])
          .and()
          .receiveParameterTypeNameStartingWithAllOf(['Child', 'View', 'Parent'])
          .and()
          .receiveParameterTypeNameMatching(RegExp(r'Cubit$'))
          .and()
          .receiveParameterTypeNameMatchingAnyOf([RegExp('Missing'), RegExp(r'Cubit$')])
          .and()
          .receiveParameterTypeNameMatchingAllOf([RegExp('Child'), RegExp('Parent')])
          .and()
          .receiveParameterTypeNameStartingWithNoneOf(['Missing'])
          .check(project);
      final cubitAssignableConstructorParameters = Heimdall.constructors()
          .that()
          .areDeclaredInClassesThat(
            HeimdallPredicate(
              'are cubit widgets',
              (item, _) => item.name == 'CubitWidget',
            ),
          )
          .should()
          .receiveParameterAssignableTo('Cubit')
          .and()
          .receiveParameterAssignableToAnyOf(['Missing', 'Cubit'])
          .and()
          .receiveParameterAssignableToAllOf(['Cubit'])
          .and()
          .receiveParameterAssignableToNoneOf(['Missing'])
          .check(project);
      final publicCubitParameterMethods = Heimdall.methods()
          .that()
          .arePublic()
          .and()
          .receiveParameterAssignableTo('Cubit')
          .should()
          .haveName('publicAction')
          .check(project);
      final dynamicParameterMethods = Heimdall.methods()
          .that()
          .haveName('_dynamicAction')
          .should()
          .receiveParameterAssignableTo('Cubit')
          .check(project);
      final neverParameterMethods = Heimdall.methods().that().haveName('_neverAction').should().receiveParameterAssignableTo('Cubit').check(project);
      final nullableParameterMethods = Heimdall.methods()
          .that()
          .haveName('_nullableAction')
          .should()
          .receiveParameterAssignableTo('Cubit')
          .check(project);
      final externalParameterMethods = Heimdall.methods()
          .that()
          .haveName('_externalAction')
          .should()
          .receiveParameterAssignableTo('ExternalWidget')
          .check(project);
      final cubitFields = Heimdall.fields()
          .that()
          .areDeclaredInClassesThat(
            HeimdallPredicate(
              'are cubit widgets',
              (item, _) => item.name == 'CubitWidget',
            ),
          )
          .and()
          .haveDeclaredFieldTypeNameEqualToAnyOf(['ChildCubit', 'ViewCubit'])
          .and()
          .haveDeclaredFieldTypeNameEndingWith('Cubit')
          .and()
          .haveDeclaredFieldTypeNameStartingWithAnyOf(['Child', 'View'])
          .and()
          .haveDeclaredFieldTypeNameMatchingAnyOf([RegExp(r'Cubit$')])
          .should()
          .beFinal()
          .check(project);
      final assignableCubitFields = Heimdall.fields()
          .that()
          .haveDeclaredFieldTypeAssignableTo('Cubit')
          .and()
          .haveDeclaredFieldTypeAssignableToAnyOf(['Missing', 'Cubit'])
          .and()
          .haveDeclaredFieldTypeAssignableToAllOf(['Cubit'])
          .and()
          .haveDeclaredFieldTypeAssignableToNoneOf(['Missing'])
          .should()
          .beFinal()
          .check(project);
      final widgetCubitFields = Heimdall.fields()
          .that()
          .areDeclaredInClassesThat(
            HeimdallPredicate(
              'are cubit widgets',
              (item, _) => item.name == 'CubitWidget',
            ),
          )
          .should()
          .haveDeclaredFieldTypeAssignableTo('Cubit')
          .check(project);
      final multiCubitFields = Heimdall.fields()
          .that()
          .haveName('primaryCubit, secondaryCubit')
          .should()
          .haveDeclaredFieldTypeAssignableTo('Cubit')
          .check(project);
      final externalFields = Heimdall.fields()
          .that()
          .haveName('externalWidget')
          .should()
          .haveDeclaredFieldTypeAssignableTo('ExternalWidget')
          .check(project);
      final objectFields = Heimdall.fields().that().haveName('childCubit').should().haveDeclaredFieldTypeAssignableTo('Object').check(project);

      expect(fields.findings, isEmpty);
      expect(methods.findings, isEmpty);
      expect(constructors.findings, isEmpty);
      expect(methodParameters.findings, isEmpty);
      expect(methodCombinations.findings, isEmpty);
      expect(methodPredicateCombinations.findings, isEmpty);
      expect(constructorParameters.findings, isEmpty);
      expect(invertedMatchingMethodCall.findings.single.line, 15);
      expect(invertedMatchingMethodCall.findings.single.column, isNotNull);
      expect(invertedMatchingConstructorCall.findings.single.line, 27);
      expect(invertedMatchingConstructorCall.findings.single.column, isNotNull);
      expect(invertedMatchingAnnotation.findings.single.line, 14);
      expect(invertedMatchingAnnotation.findings.single.column, isNotNull);
      expect(constructorCombinations.findings, isEmpty);
      expect(publicCubitMethods.checkedCount, 1);
      expect(publicCubitMethods.findings, isEmpty);
      expect(cubitConstructorParameters.findings, isEmpty);
      expect(cubitAssignableConstructorParameters.findings, isEmpty);
      expect(publicCubitParameterMethods.checkedCount, 1);
      expect(publicCubitParameterMethods.findings, isEmpty);
      expect(dynamicParameterMethods.findings, isEmpty);
      expect(neverParameterMethods.findings, isEmpty);
      expect(nullableParameterMethods.findings, isEmpty);
      expect(externalParameterMethods.findings, isEmpty);
      expect(cubitFields.checkedCount, 3);
      expect(cubitFields.findings, isEmpty);
      expect(assignableCubitFields.checkedCount, 5);
      expect(assignableCubitFields.findings, isEmpty);
      expect(widgetCubitFields.checkedCount, 4);
      expect(widgetCubitFields.findings, isEmpty);
      expect(multiCubitFields.findings, isEmpty);
      expect(externalFields.findings, isEmpty);
      expect(objectFields.findings, isEmpty);
    });

    test('resolves field-formal and super-formal constructor parameter types', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );

      final fieldFormalParameters = Heimdall.constructors()
          .that()
          .areDeclaredInClassesThat(
            HeimdallPredicate(
              'are cubit widgets',
              (item, _) => item.name == 'CubitWidget',
            ),
          )
          .should()
          .receiveParameterTypeName('ChildCubit')
          .and()
          .receiveParameterTypeName('ViewCubit')
          .check(project);
      final superFormalParameters = Heimdall.constructors()
          .that()
          .areDeclaredInClassesThat(
            HeimdallPredicate(
              'are cubit widgets',
              (item, _) => item.name == 'CubitWidget',
            ),
          )
          .should()
          .receiveParameterTypeName('ParentCubit')
          .check(project);

      expect(fieldFormalParameters.checkedCount, 1);
      expect(fieldFormalParameters.findings, isEmpty);
      expect(superFormalParameters.checkedCount, 1);
      expect(superFormalParameters.findings, isEmpty);
    });

    test('checks class and file declaration shape rules', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );

      final classes = Heimdall.classes()
          .that()
          .haveTypeName('UserService')
          .should()
          .declareMethod('findName')
          .and()
          .declareConstructor(name: '_')
          .and()
          .receiveParameter('token')
          .check(project);
      final files = Heimdall.files()
          .that()
          .resideInPath('service.dart')
          .should()
          .declareClass('UserService')
          .and()
          .declareAllClasses(['Tracked', 'Helper', 'UserService'])
          .and()
          .declareAnyClass(['Missing', 'UserService'])
          .and()
          .declareNoClasses(['Forbidden'])
          .and()
          .declareMethod('findName')
          .and()
          .declareAllMethods(['findName'])
          .and()
          .declareAnyMethod(['missing', 'findName'])
          .and()
          .declareNoMethods(['forbidden'])
          .and()
          .declareConstructor(name: '_', className: 'UserService')
          .and()
          .declareAnyConstructor(['missing', '_'], className: 'UserService')
          .and()
          .declareNoConstructors(['forbidden'], className: 'UserService')
          .and()
          .receiveParameter('prefix')
          .and()
          .receiveAllParameters(['prefix', 'token'])
          .and()
          .receiveAnyParameter(['missing', 'prefix'])
          .and()
          .receiveNoParameters(['forbidden'])
          .check(project);

      expect(classes.findings, isEmpty);
      expect(files.findings, isEmpty);
    });

    test(
      'combines three or more member predicates and conditions in one rule',
      () {
        final project = const HeimdallFileImporter(useCache: false).importPath(
          fixture,
        );

        final builder =
            Heimdall.methods()
                .that()
                .areDeclaredInClassesThat(
                  HeimdallPredicate(
                    'are user services',
                    (item, _) => item.name == 'UserService',
                  ),
                )
                .and()
                .arePublic()
                .and()
                .areAnnotatedWith('Tracked')
                .and()
                .haveReturnType('String')
                .should()
              ..haveReturnType('String');
        builder.andShould().callMethod('toUpperCase');
        final methodResult = builder.andShould().accessField('name').check(project);
        final constructorResult = Heimdall.constructors().that().arePrivate().should().callConstructor('Helper').check(project);

        expect(
          methodResult,
          isA<HeimdallReport>()
              .having((report) => report.checkedCount, 'checkedCount', 1)
              .having((report) => report.findings, 'findings', isEmpty)
              .having(
                (report) => report.description,
                'description',
                allOf(
                  contains('are public'),
                  contains('are annotated with Tracked'),
                  contains('have raw return type String'),
                ),
              ),
        );
        expect(
          constructorResult,
          isA<HeimdallReport>()
              .having((report) => report.checkedCount, 'checkedCount', 1)
              .having((report) => report.findings, 'findings', isEmpty)
              .having(
                (report) => report.description,
                'description',
                contains('call constructor Helper'),
              ),
        );
      },
    );

    test('does not treat declarations as member calls or field access', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );

      final declaredMethodOnly = Heimdall.methods()
          .that()
          .areDeclaredInClassesThat(
            HeimdallPredicate(
              'are false positive fixtures',
              (item, _) => item.name == 'MemberFalsePositives',
            ),
          )
          .and()
          .haveName('save')
          .should()
          .callMethod('save')
          .check(project);
      final declaredFieldOnly = Heimdall.fields()
          .that()
          .areDeclaredInClassesThat(
            HeimdallPredicate(
              'are false positive fixtures',
              (item, _) => item.name == 'MemberFalsePositives',
            ),
          )
          .and()
          .haveName('name')
          .should()
          .accessField('name')
          .check(project);
      final declaredConstructorOnly = Heimdall.constructors()
          .that()
          .areDeclaredInClassesThat(
            HeimdallPredicate(
              'are false positive fixtures',
              (item, _) => item.name == 'MemberFalsePositives',
            ),
          )
          .and()
          .haveName('new')
          .should()
          .callConstructor('MemberFalsePositives')
          .check(project);
      final localVariableOnly = Heimdall.methods()
          .that()
          .areDeclaredInClassesThat(
            HeimdallPredicate(
              'are false positive fixtures',
              (item, _) => item.name == 'MemberFalsePositives',
            ),
          )
          .and()
          .haveName('readLocalName')
          .should()
          .accessField('name')
          .check(project);
      final nestedLocalVariableOnly = Heimdall.methods()
          .that()
          .areDeclaredInClassesThat(
            HeimdallPredicate(
              'are false positive fixtures',
              (item, _) => item.name == 'MemberFalsePositives',
            ),
          )
          .and()
          .haveName('readNestedLocalName')
          .should()
          .accessField('name')
          .check(project);

      expect(declaredMethodOnly.findings, hasLength(1));
      expect(
        declaredMethodOnly.findings.single.message,
        contains('does not call save'),
      );
      expect(declaredFieldOnly.findings, hasLength(1));
      expect(
        declaredFieldOnly.findings.single.message,
        contains('does not access field name'),
      );
      expect(declaredConstructorOnly.findings, hasLength(1));
      expect(
        declaredConstructorOnly.findings.single.message,
        contains('does not call constructor MemberFalsePositives'),
      );
      expect(localVariableOnly.findings, hasLength(1));
      expect(
        localVariableOnly.findings.single.message,
        contains('does not access field name'),
      );
      expect(nestedLocalVariableOnly.findings, hasLength(1));
      expect(
        nestedLocalVariableOnly.findings.single.message,
        contains('does not access field name'),
      );
    });
  });
}
