import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  group('DSL filter and condition combinations', () {
    const fixture = 'test/dsl_fixtures/combinations_project';

    HeimdallProject importProject() {
      return const HeimdallFileImporter(useCache: false).importPath(fixture);
    }

    test(
      'combines class filters with and, or, custom predicates, and negation',
      () {
        final project = importProject();

        final domainServices = Heimdall.classes()
            .that()
            .resideInPath('domain')
            .and()
            .haveTypeNameEndingWith('Service')
            .should()
            .haveTypeNameEndingWith('Service')
            .check(project);
        final domainOrPresentation = Heimdall.classes()
            .that()
            .resideInPath('domain')
            .or()
            .resideInPath('presentation')
            .should()
            .bePublic()
            .check(project);
        final outsideData = Heimdall.classes()
            .that()
            .resideOutsideOfPath('data')
            .and()
            .satisfy(
              HeimdallPredicate(
                'are concrete user classes',
                (item, _) => item.name.contains('User'),
              ),
            )
            .should()
            .resideOutsideOfPath('data')
            .check(project);
        final noRepositoriesInData = Heimdall.noClasses().that().haveTypeNameEndingWith('Repository').should().resideInPath('data').check(project);

        expect(domainServices.checkedCount, 1);
        expect(domainServices.findings, isEmpty);
        expect(domainOrPresentation.checkedCount, 17);
        expect(domainOrPresentation.findings, hasLength(1));
        expect(
          domainOrPresentation.findings.single.message,
          contains('_HiddenPresenter should be public'),
        );
        expect(outsideData.checkedCount, 2);
        expect(outsideData.findings, isEmpty);
        expect(noRepositoriesInData.findings, hasLength(10));
        expect(
          noRepositoriesInData.findings.map((finding) => finding.message),
          everyElement(contains('must not reside in path data')),
        );
        expect(
          noRepositoriesInData.description,
          'no classes that have type name ending with Repository should reside in path data',
        );
      },
    );

    test('combines class conditions with andShould and orShould', () {
      final project = importProject();

      final strictBuilder = Heimdall.classes().that().haveTypeName('UserRepository').should()..haveTypeNameEndingWith('Repository');
      final strict = strictBuilder.andShould().haveOnlyFinalFields().check(
        project,
      );

      final relaxedBuilder = Heimdall.classes().that().haveTypeName('UserRepository').should()..haveTypeNameEndingWith('Service');
      final relaxed = relaxedBuilder.orShould().haveTypeNameEndingWith('Repository').check(project);

      expect(strict.findings, isEmpty);
      expect(relaxed.findings, isEmpty);
    });

    test('keeps condition-chain descriptions stable when predicates contain should', () {
      final project = importProject();

      final result = Heimdall.classes()
          .that()
          .satisfy(
            HeimdallPredicate(
              'items should stay public',
              (item, _) => item.name == 'UserRepository',
            ),
          )
          .should()
          .bePublic()
          .and()
          .beFinal()
          .check(project);

      expect(result.description, startsWith('classes that items should stay public should'));
      expect(result.description, contains('(be public and be final)'));
    });

    test('keeps inverted rule descriptions and findings readable', () {
      final project = importProject();

      final noUsecaseFiles = Heimdall.noFiles().should().haveNameEndingWith('usecase.dart').check(project);
      final noRepositoryFiles = Heimdall.noFiles().should().haveNameEndingWith('repository.dart').check(project);
      final publicUseCases = Heimdall.classes()
          .that()
          .resideInPath('use_case')
          .and()
          .arePublic()
          .should()
          .haveTypeNameEndingWith('UseCase')
          .check(project);

      expect(
        noUsecaseFiles.description,
        'no files should have name ending with usecase.dart',
      );
      expect(
        publicUseCases.description,
        'classes that (reside in path use_case and are public) should have type name ending with UseCase',
      );
      expect(
        noRepositoryFiles.findings,
        isNotEmpty,
      );
      expect(
        noRepositoryFiles.findings.map((finding) => finding.message),
        everyElement('must not have name ending with repository.dart'),
      );
    });

    test('guards accidental double not calls in predicate and condition builders', () {
      expect(
        () => Heimdall.classes().that().not().not().arePublic(),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => Heimdall.classes().should().not().not().bePublic(),
        throwsA(isA<AssertionError>()),
      );
    });

    test(
      'combines file filters, source checks, import checks, and parse checks',
      () {
        final project = importProject();

        final sourceCombination = Heimdall.files()
            .that()
            .resideInPath('user_repository.dart')
            .or()
            .resideInPath('user_controller.dart')
            .should()
            .containAnySource(['repository.find()', 'service.normalize'])
            .check(project);
        final chainedFileConditions = Heimdall.files()
            .that()
            .resideInPath('user_repository.dart')
            .should()
            .containSource('service.normalize')
            .or()
            .containSource('missing snippet')
            .check(project);
        final negatedFileCondition = Heimdall.files()
            .that()
            .resideInPath('user_repository.dart')
            .should()
            .containSource('missing snippet')
            .or()
            .not()
            .containSource('forbidden snippet')
            .check(project);
        final externalExport = Heimdall.files()
            .that()
            .resideInPath('barrel.dart')
            .should()
            .exportUri('package:external/external.dart')
            .check(project);
        final forbiddenImport = Heimdall.files()
            .that()
            .resideInPath('barrel.dart')
            .should()
            .not()
            .importUriMatching(RegExp('package:external/'))
            .check(project);
        final missingFile = Heimdall.noFiles().that().resideInPath('missing.dart').should().allowEmpty().exist().check(project);
        final absentLegacyFolder = Heimdall.files().that().resideInPath('..usecase..').shouldNotExist().allowEmpty().check(project);
        final existingFileShouldNotExist = Heimdall.files().that().resideInPath('barrel.dart').shouldNotExist().check(project);
        final parse = Heimdall.code().shouldParse().check(project);

        expect(sourceCombination.checkedCount, 2);
        expect(sourceCombination.findings, isEmpty);
        expect(chainedFileConditions.findings, isEmpty);
        expect(negatedFileCondition.findings, isEmpty);
        expect(externalExport.findings, isEmpty);
        expect(forbiddenImport.findings, isEmpty);
        expect(missingFile.findings, isEmpty);
        expect(absentLegacyFolder.findings, isEmpty);
        expect(existingFileShouldNotExist.findings, hasLength(1));
        expect(parse.findings, isNotEmpty);
        expect(parse.findings.first.line, isNotNull);
        expect(parse.findings.first.column, isNotNull);
        expect(
          parse.findings.map((finding) => finding.filePath),
          everyElement(endsWith('syntax.dart')),
        );
      },
    );

    test(
      'expresses project content policies with generic inverted file rules',
      () {
        final project = importProject();
        final reports = [
          Heimdall.noFiles().that().resideInPath('lib').should().callMethodWithArguments('print', receiver: '').check(project),
          Heimdall.noFiles().that().resideInPath('lib').should().callConstructorWithArguments('Container', exactArguments: true).check(project),
          Heimdall.noFiles().that().resideInPath('lib').should().containSourceMatching(RegExp(r'\}\s*on\s+Object\b')).check(project),
          Heimdall.noFiles().that().resideInPath('lib').should().containSourceMatching(RegExp(r'\bWidget\s+_\w+\s*\(')).check(project),
          Heimdall.noFiles()
              .that()
              .resideInPath('lib')
              .should()
              .containSourceMatching(
                RegExp(r'''==\s*['"][SN]['"]|['"][SN]['"]\s*==\s*'''),
              )
              .check(project),
          Heimdall.noFiles()
              .that()
              .resideInPath('lib')
              .should()
              .containSourceMatching(
                RegExp(
                  r'\bPlatform\.is(?:Android|IOS|Fuchsia|Linux|MacOS|Windows)\b',
                ),
              )
              .check(project),
        ];

        expect(reports.map((report) => report.findings), everyElement(isEmpty));
      },
    );

    test('combines member filters and code-unit conditions', () {
      final project = importProject();

      final trackedMethods = Heimdall.methods()
          .that()
          .areDeclaredInClassesThat(
            HeimdallPredicate(
              'are domain services',
              (item, _) => item.name == 'DomainService',
            ),
          )
          .and()
          .areAnnotatedWith('Tracked')
          .should()
          .haveReturnType('String')
          .check(project);
      final staticFields = Heimdall.fields().that().areStatic().should().beFinal().check(project);
      final codeUnits = Heimdall.codeUnits().that().haveName('show').should().callMethod('toUpperCase').check(project);
      final chainedMemberConditions = Heimdall.methods()
          .that()
          .haveName('show')
          .should()
          .callMethod('toUpperCase')
          .or()
          .haveReturnType('String')
          .check(project);
      final negatedMemberCondition = Heimdall.methods()
          .that()
          .haveName('show')
          .should()
          .callMethod('toUpperCase')
          .or()
          .not()
          .callMethod('parse')
          .check(project);

      expect(trackedMethods.checkedCount, 1);
      expect(trackedMethods.findings, isEmpty);
      expect(staticFields.checkedCount, 1);
      expect(staticFields.findings, isEmpty);
      expect(chainedMemberConditions.findings, isEmpty);
      expect(negatedMemberCondition.findings, isEmpty);
      expect(codeUnits.checkedCount, 2);
      expect(codeUnits.findings, hasLength(1));
      expect(
        codeUnits.findings.single.message,
        contains('_HiddenPresenter.show does not call toUpperCase'),
      );
    });

    test('covers dependency, module, barrel, and pubspec sights', () {
      final project = importProject();

      final upperDirectories = Heimdall.dependencies().noFilesShouldDependOnUpperDirectories().check(project);
      final featureDependencies = Heimdall.dependencies().featuresShouldNotDependOnEachOther().check(project);
      final featureDependenciesWithSharedTarget = Heimdall.dependencies()
          .featuresShouldNotDependOnEachOther(
            sharedSlices: ['account'],
          )
          .check(project);
      final packageSrc = Heimdall.dependencies().noFilesShouldImportPackageSrc('external').check(project);
      final modules = Heimdall.slices(
        'lib/src/features/(*)',
      ).shouldNotDependOnEachOther().check(project);
      final modulesWithSharedTarget = Heimdall.slices(
        'lib/src/features/(*)',
      ).shouldNotDependOnEachOther(sharedSlices: ['account']).check(project);
      final scopedFeatureDependencies = Heimdall.dependencies()
          .featuresShouldNotDependOnEachOther(
            featurePattern: 'lib/src/features/(*)/domain/**',
          )
          .check(project);
      final scopedModules = Heimdall.slices(
        'lib/src/features/(*)/domain/**',
      ).shouldNotDependOnEachOther().check(project);
      final barrel = Heimdall.code()
          .barrelFilesShouldOnlyExport(
            barrelPattern: 'lib/src/barrel.dart',
            allowedExportPatterns: ['domain/*.dart'],
          )
          .check(project);
      final pubspec = Heimdall.dependencies().pubspecShouldNotDependOn('forbidden_dep').check(project);
      final devPubspec = Heimdall.dependencies().pubspecShouldNotDependOn('forbidden_dev_dep').check(project);

      expect(upperDirectories.findings, isNotEmpty);
      expect(featureDependencies.findings, hasLength(1));
      expect(featureDependenciesWithSharedTarget.findings, isEmpty);
      expect(packageSrc.findings, isEmpty);
      expect(modules.findings, hasLength(1));
      expect(modulesWithSharedTarget.findings, isEmpty);
      expect(scopedFeatureDependencies.findings, isEmpty);
      expect(scopedModules.findings, isEmpty);
      expect(barrel.findings, hasLength(1));
      expect(pubspec.findings, hasLength(1));
      expect(pubspec.findings.single.message, contains('dependencies'));
      expect(devPubspec.findings, hasLength(1));
      expect(devPubspec.findings.single.message, contains('dev_dependencies'));
    });

    test(
      'resolves barrel exports, aliased imports, AST references, and transitive assignability',
      () {
        final project = importProject();

        final dataMustNotDependOnDomain = Heimdall.classes()
            .that()
            .resideInPath('data')
            .should()
            .notDependOnClassesThat(
              HeimdallPredicate(
                'reside in domain',
                (item, _) => item.relativePath.contains('/domain/'),
              ),
            )
            .check(project);
        final commentOnly = Heimdall.classes()
            .that()
            .haveTypeName('CommentRepository')
            .should()
            .notDependOnClassesThat(
              HeimdallPredicate(
                'are DomainService',
                (item, _) => item.name == 'DomainService',
              ),
            )
            .check(project);
        final homePageWidget = Heimdall.classes()
            .that()
            .haveTypeName('HomePage')
            .and()
            .areAssignableTo('Widget')
            .should()
            .haveTypeNameEndingWith('Widget')
            .check(project);
        final hiddenByExportShow = Heimdall.classes()
            .that()
            .haveTypeName('CombinatorRepository')
            .should()
            .notDependOnClassesThat(
              HeimdallPredicate(
                'are HiddenByCombinator',
                (item, _) => item.name == 'HiddenByCombinator',
              ),
            )
            .check(project);
        final hiddenByImportShow = Heimdall.classes()
            .that()
            .haveTypeName('ImportShowRepository')
            .should()
            .notDependOnClassesThat(
              HeimdallPredicate(
                'are HiddenByCombinator',
                (item, _) => item.name == 'HiddenByCombinator',
              ),
            )
            .check(project);
        final simpleIdentifierOnly = Heimdall.classes()
            .that()
            .haveTypeName('SimpleIdentifierRepository')
            .should()
            .notDependOnClassesThat(
              HeimdallPredicate('are User', (item, _) => item.name == 'User'),
            )
            .check(project);
        final staticMethodCall = Heimdall.classes()
            .that()
            .haveTypeName('StaticRepository')
            .should()
            .notDependOnClassesThat(
              HeimdallPredicate('are User', (item, _) => item.name == 'User'),
            )
            .check(project);
        final repeatedExportShows = Heimdall.classes()
            .that()
            .haveTypeName('DualCombinatorRepository')
            .should()
            .notDependOnClassesThat(
              HeimdallPredicate(
                'are HiddenByCombinator',
                (item, _) => item.name == 'HiddenByCombinator',
              ),
            )
            .check(project);
        final duplicateExports = Heimdall.classes()
            .that()
            .haveTypeName('DuplicateVisibleRepository')
            .should()
            .notDependOnClassesThat(
              HeimdallPredicate(
                'are VisibleThroughCombinator',
                (item, _) => item.name == 'VisibleThroughCombinator',
              ),
            )
            .check(project);
        final typeParameterShadow = Heimdall.classes()
            .that()
            .haveTypeName('TypeParameterHolder')
            .should()
            .notDependOnClassesThat(
              HeimdallPredicate('are User', (item, _) => item.name == 'User'),
            )
            .check(project);

        expect(
          dataMustNotDependOnDomain.findings.map((finding) => finding.message),
          containsAll([
            contains('UserRepository depends on forbidden User'),
            contains('AliasRepository depends on forbidden User'),
            contains('BarrelRepository depends on forbidden User'),
            contains('StaticRepository depends on forbidden User'),
          ]),
        );
        expect(
          dataMustNotDependOnDomain.findings.map((finding) => finding.message),
          isNot(contains(contains('CommentRepository'))),
        );
        expect(commentOnly.findings, isEmpty);
        expect(hiddenByExportShow.findings, isEmpty);
        expect(hiddenByImportShow.findings, isEmpty);
        expect(simpleIdentifierOnly.findings, isEmpty);
        expect(typeParameterShadow.findings, isEmpty);
        expect(staticMethodCall.findings, hasLength(1));
        expect(
          staticMethodCall.findings.single.message,
          contains('StaticRepository depends on forbidden User'),
        );
        expect(repeatedExportShows.findings, hasLength(1));
        expect(
          repeatedExportShows.findings.single.message,
          contains('HiddenByCombinator'),
        );
        expect(duplicateExports.findings, hasLength(1));
        expect(
          duplicateExports.findings.single.message,
          contains('VisibleThroughCombinator'),
        );
        expect(homePageWidget.checkedCount, 1);
        expect(
          homePageWidget.findings.single.message,
          contains('HomePage should end with Widget'),
        );
      },
    );

    test(
      'reports explicit and locally inferred dynamic without flagging safe inferred values',
      () {
        final project = importProject();

        final result = Heimdall.code()
            .publicSignaturesShouldNotUseDynamic(
              pathPattern: 'dynamic_signature.dart',
            )
            .check(project);

        expect(result.findings, hasLength(41));
        expect(
          result.findings.map((finding) => finding.message),
          containsAll([
            contains('publicTopLevelDynamic has public dynamic type'),
            contains('RawFutureAlias has public dynamic type'),
            contains('publicRawFuture has public dynamic type'),
            contains('rawFutureReturn has public dynamic return type'),
            contains('rawFutureReturn has public dynamic parameter rawFutureParameter'),
            contains('publicTopLevelImplicit has public dynamic type'),
            contains('publicFieldImplicit has public dynamic type'),
            contains('implicitReturn has public dynamic return type'),
            contains('DynamicFutureAlias has public dynamic type'),
            contains('DynamicAlias has public dynamic type'),
            contains('DynamicCallback has public dynamic return type'),
            contains(
              'DynamicCallback has public dynamic parameter value',
            ),
            contains('LegacyDynamicCallback has public dynamic return type'),
            contains(
              'LegacyDynamicCallback has public dynamic parameter value',
            ),
            contains(
              'callbackParameter has public dynamic parameter callback',
            ),
            contains('publicFieldDynamic has public dynamic type'),
            contains('publicDynamicFuture has public dynamic type'),
            contains('publicRawCubit has public dynamic type'),
            contains('publicDynamicCubit has public dynamic type'),
            contains('publicRawPrefixedGeneric has public dynamic type'),
            contains('explicitReturn has public dynamic return type'),
            contains(
              'explicitReturn has public dynamic parameter explicitParameter',
            ),
            contains('dynamicFutureReturn has public dynamic return type'),
            contains(
              'dynamicFutureReturn has public dynamic parameter dynamicFutureParameter',
            ),
            contains('rawCubitReturn has public dynamic return type'),
            contains(
              'rawCubitReturn has public dynamic parameter rawCubitParameter',
            ),
            contains('dynamicCubitReturn has public dynamic return type'),
            contains(
              'dynamicCubitReturn has public dynamic parameter dynamicCubitParameter',
            ),
            contains(
              'implicitReturn has public dynamic parameter implicitParameter',
            ),
          ]),
        );
        expect(
          result.findings.map((finding) => finding.message),
          allOf(
            [
              isNot(
                contains(
                  contains('publicTopLevelInferred has public dynamic type'),
                ),
              ),
              isNot(
                contains(
                  contains('publicFieldInferred has public dynamic type'),
                ),
              ),
              isNot(
                contains(
                  contains('wildcardParameter has public dynamic parameter _'),
                ),
              ),
              isNot(
                contains(contains('has public dynamic parameter codigo')),
              ),
              isNot(
                contains(contains('has public dynamic parameter parametro')),
              ),
            ],
          ),
        );
      },
    );

    test('ignores selected public dynamic signatures by path and declaration', () {
      final project = importProject();

      final ignoredByPath = Heimdall.code()
          .publicSignaturesShouldNotUseDynamic(
            pathPattern: 'dynamic_signature.dart',
            ignoredPathPatterns: [r'domain\dynamic_signature'],
          )
          .allowEmpty()
          .check(project);
      final ignoredByDeclaration = Heimdall.code()
          .publicSignaturesShouldNotUseDynamic(
            pathPattern: 'dynamic_signature.dart',
            ignoredDeclarationNames: {'DynamicAlias'},
            ignoredDeclarationNamePatterns: [RegExp('^Legacy')],
          )
          .check(project);

      expect(ignoredByPath.findings, isEmpty);
      expect(ignoredByPath.checkedCount, 0);
      expect(ignoredByDeclaration.findings, hasLength(38));
      expect(
        ignoredByDeclaration.findings.map((finding) => finding.message),
        allOf([
          isNot(contains(contains('DynamicAlias'))),
          isNot(contains(contains('LegacyDynamicCallback'))),
        ]),
      );
    });
  });
}
