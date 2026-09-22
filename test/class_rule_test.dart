import 'dart:io';

import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  group('Class rules', () {
    const fixture = 'test/class_fixtures/class_rules_project';
    const basicFixture = 'test/importer_fixtures/basic_project';

    test('assertNoFindings fails when an enabled rule selects no items', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        basicFixture,
      );

      final result = Heimdall.classes().that().resideInPath('missing').should().haveTypeNameEndingWith('Repository').check(project);

      expect(result.findings.single.message, contains('Rule .that() predicate matched no items'));
      expect(result.assertNoFindings, throwsStateError);
    });

    test('assertNoFindings fails when a rule selector returns no items', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        basicFixture,
      );
      final rule = HeimdallRule<Object>(
        customDescription: 'empty selector should pass',
        selector: (_) => const [],
        predicate: HeimdallPredicate('match everything', (_, _) => true),
        condition: HeimdallCondition(
          'pass',
          (item, _) => HeimdallFindings(
            subject: item,
            passed: true,
          ),
        ),
      );

      final result = rule.check(project);

      expect(result.findings.single.message, contains('Rule selector returned no items'));
      expect(result.assertNoFindings, throwsStateError);
    });

    test(
      'assertNoFindings allows empty selections when failOnEmptySelection is disabled',
      () {
        final project = const HeimdallFileImporter(useCache: false).importPath(
          basicFixture,
        );
        final previous = HeimdallConfiguration.failOnEmptySelection;

        try {
          HeimdallConfiguration.failOnEmptySelection = false;
          Heimdall.classes().that().resideInPath('missing').should().haveTypeNameEndingWith('Repository').check(project).assertNoFindings();
        } finally {
          HeimdallConfiguration.failOnEmptySelection = previous;
        }
      },
    );

    test('class rules ignore top-level declarations', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        basicFixture,
      );

      final result = Heimdall.classes().that().resideInPath('data').should().haveTypeNameEndingWith('Repository').check(project);

      expect(result.checkedCount, 1);
      expect(result.findings, isEmpty);
      result.assertNoFindings();
    });

    test('path rule findings keep assertNoFindings messages readable', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        basicFixture,
      );

      final result = Heimdall.classes().that().haveTypeName('User').should().resideInPath('lib/src/data/**').check(project);
      final matchingResult = Heimdall.classes().that().haveTypeName('User').should().resideInPathMatching(RegExp('data')).check(project);
      final outsideResult = Heimdall.classes().that().haveTypeName('User').should().resideOutsideOfPath('lib/src/domain/**').check(project);

      expect(
        result.findings.single.message,
        'User should reside in path lib/src/data/** (actual: lib/src/domain/user.dart)',
      );
      expect(
        matchingResult.findings.single.message,
        'User should reside in path matching data (actual: lib/src/domain/user.dart)',
      );
      expect(
        outsideResult.findings.single.message,
        'User should reside outside of path lib/src/domain/** (actual: lib/src/domain/user.dart)',
      );
      expect(
        result.assertNoFindings,
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            allOf(
              contains('Heimdall saw rule breaches:'),
              contains('User should reside in path lib/src/data/** (actual: lib/src/domain/user.dart)'),
              isNot(contains('resides in lib/src/domain/user.dart, expected')),
            ),
          ),
        ),
      );
    });

    test('negates the next class predicate', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        'test/class_fixtures/predicate_not_project',
      );

      final result = Heimdall.classes()
          .that()
          .resideInPath('repository')
          .and()
          .not()
          .haveTypeNameEndingWith('RepositoryImpl')
          .should()
          .haveTypeNameEndingWith('Repository')
          .check(project);

      expect(result.checkedCount, 1);
      expect(result.findings, isEmpty);
      expect(
        result.description,
        contains('not (have type name ending with RepositoryImpl)'),
      );
    });

    test('selects and checks classes by member counts', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );

      final superBase = Heimdall.classes()
          .that()
          .haveTypeName('SuperBase')
          .and()
          .haveMemberCount(2)
          .and()
          .haveFieldCount(1)
          .and()
          .haveMethodCount(1)
          .and()
          .haveConstructorCount(0)
          .and()
          .haveCodeUnitCount(1)
          .and()
          .haveConstructorParameterCount(0)
          .and()
          .haveMethodParameterCount(1)
          .and()
          .haveMoreThanMembers(1)
          .and()
          .haveMoreThanFields(0)
          .and()
          .haveMoreThanMethods(0)
          .and()
          .haveMoreThanCodeUnits(0)
          .and()
          .haveMoreThanMethodParameters(0)
          .should()
          .haveMemberCount(2)
          .and()
          .haveFieldCount(1)
          .and()
          .haveMethodCount(1)
          .and()
          .haveConstructorCount(0)
          .and()
          .haveCodeUnitCount(1)
          .and()
          .haveConstructorParameterCount(0)
          .and()
          .haveMethodParameterCount(1)
          .check(project);
      final smallClasses = Heimdall.classes()
          .that()
          .haveTypeName('SuperBase')
          .and()
          .haveAtMostFields(1)
          .and()
          .haveAtMostConstructors(0)
          .and()
          .haveAtMostConstructorParameters(0)
          .and()
          .haveAtMostMethodParameters(1)
          .should()
          .haveFieldCountOtherThan(2)
          .and()
          .haveMethodCountOtherThan(2)
          .and()
          .haveConstructorCountOtherThan(1)
          .and()
          .haveCodeUnitCountOtherThan(2)
          .and()
          .haveConstructorParameterCountOtherThan(1)
          .and()
          .haveMethodParameterCountOtherThan(2)
          .check(project);
      final userConstructorParameters = Heimdall.classes()
          .that()
          .haveTypeName('User')
          .and()
          .haveConstructorParameterCount(1)
          .and()
          .haveMoreThanConstructorParameters(0)
          .should()
          .haveConstructorParameterCount(1)
          .and()
          .haveMoreThanConstructorParameters(0)
          .check(project);

      expect(superBase.checkedCount, 1);
      expect(superBase.findings, isEmpty);
      expect(smallClasses.checkedCount, 1);
      expect(smallClasses.findings, isEmpty);
      expect(userConstructorParameters.checkedCount, 1);
      expect(userConstructorParameters.findings, isEmpty);
    });

    test('counts each instance field variable in multi-variable declarations', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );

      final result = Heimdall.classes().that().haveTypeName('FieldBag').and().haveFieldCount(2).should().haveFieldCount(2).check(project);

      expect(result.checkedCount, 1);
      expect(result.findings, isEmpty);
    });

    test('treats absent constructors as implicit public constructors', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );

      final onlyPrivate = Heimdall.classes().that().haveTypeName('PlainServiceImpl').should().haveOnlyPrivateConstructors().check(project);
      final notOnlyPrivate = Heimdall.classes()
          .that()
          .haveTypeName('PlainServiceImpl')
          .and()
          .notHaveOnlyPrivateConstructors()
          .should()
          .bePublic()
          .check(project);

      expect(onlyPrivate.findings, hasLength(1));
      expect(
        onlyPrivate.findings.single.message,
        contains('implicit public constructor'),
      );
      expect(notOnlyPrivate.checkedCount, 1);
      expect(notOnlyPrivate.findings, isEmpty);
    });

    test('have only rules fail when the class has no eligible members', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );

      final finalFields = Heimdall.classes().that().haveTypeName('PlainServiceImpl').should().haveOnlyFinalFields().check(project);
      final publicFields = Heimdall.classes().that().haveTypeName('PlainServiceImpl').should().haveOnlyPublicFields().check(project);
      final staticMembers = Heimdall.classes().that().haveTypeName('PlainServiceImpl').should().haveOnlyStaticMembers().check(project);

      expect(finalFields.findings.single.message, contains('declares no fields'));
      expect(publicFields.findings.single.message, contains('declares no fields'));
      expect(
        staticMembers.findings.single.message,
        contains('declares no fields or methods'),
      );
    });

    test('selects classes by raw type and identifier references', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );

      final autoCancelingServices = Heimdall.classes()
          .that()
          .haveTypeNameEndingWith('ServiceImpl')
          .and()
          .referenceType('DioClient')
          .and()
          .notReferenceIdentifier('CancelToken')
          .should()
          .applyMixin('DioAutoCancel')
          .check(project);
      final manualCancelingServices = Heimdall.classes()
          .that()
          .haveTypeNameEndingWith('ServiceImpl')
          .and()
          .referenceIdentifier('CancelToken')
          .should()
          .notReferenceType('MissingClient')
          .check(project);

      expect(autoCancelingServices.checkedCount, 1);
      expect(autoCancelingServices.findings, isEmpty);
      expect(manualCancelingServices.checkedCount, 1);
      expect(manualCancelingServices.findings, isEmpty);
    });

    test('raw identifier references ignore declaration names', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );

      final result = Heimdall.classes()
          .that()
          .haveTypeName('PlainServiceImpl')
          .and()
          .notReferenceIdentifier('PlainServiceImpl')
          .should()
          .bePublic()
          .check(project);

      expect(result.checkedCount, 1);
      expect(result.findings, isEmpty);
    });

    test('class dependency rules ignore imports unused by the declaration', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );

      final result = Heimdall.classes()
          .that()
          .haveTypeName('UnusedImport')
          .should()
          .notDependOnClassesThat(
            HeimdallPredicate(
              'reside in domain',
              (item, _) => item.relativePath.contains('domain'),
            ),
          )
          .check(project);

      expect(result.findings, isEmpty);
    });

    test('only dependency rules fail when a class has no dependencies', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );
      final target = HeimdallPredicate<CompilationUnitMember>(
        'reside in domain',
        (item, _) => item.relativePath.contains('domain'),
      );

      final predicateResult = Heimdall.classes().that().haveTypeName('User').and().onlyDependOnClassesThat(target).should().bePublic().check(project);
      final conditionResult = Heimdall.classes().that().haveTypeName('User').should().onlyDependOnClassesThat(target).check(project);

      expect(predicateResult.checkedCount, 0);
      expect(conditionResult.findings, hasLength(1));
      expect(conditionResult.findings.single.message, contains('does not depend on any class'));
    });

    test('only dependency any and none variants evaluate each target dependency', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );
      final domainTarget = HeimdallPredicate<CompilationUnitMember>(
        'are domain targets',
        (item, _) => item.name == 'DomainType',
      );
      final dataTarget = HeimdallPredicate<CompilationUnitMember>(
        'are data targets',
        (item, _) => item.name == 'DataType',
      );
      final forbiddenTarget = HeimdallPredicate<CompilationUnitMember>(
        'are forbidden targets',
        (item, _) => item.name == 'ForbiddenType',
      );

      final anyCondition = Heimdall.classes()
          .that()
          .haveTypeName('MixedConsumer')
          .should()
          .onlyDependOnClassesMatchingAnyOf([domainTarget, dataTarget])
          .check(project);
      final anyPredicate = Heimdall.classes()
          .that()
          .haveTypeName('MixedConsumer')
          .and()
          .onlyDependOnClassesMatchingAnyOf([domainTarget, dataTarget])
          .should()
          .bePublic()
          .check(project);
      final noneCondition = Heimdall.classes()
          .that()
          .haveTypeName('MixedConsumer')
          .should()
          .onlyDependOnClassesMatchingNoneOf([domainTarget, forbiddenTarget])
          .check(project);

      expect(anyCondition.findings, isEmpty);
      expect(anyPredicate.checkedCount, 1);
      expect(noneCondition.findings, hasLength(1));
      expect(noneCondition.findings.single.message, contains('DomainType'));
    });

    test('checks class annotations and private constructors', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );

      final annotated = Heimdall.classes().that().haveTypeName('AnnotatedAggregate').should().beAnnotatedWith('Entity').check(project);
      final constructors = Heimdall.classes().that().haveTypeName('AnnotatedAggregate').should().haveOnlyPrivateConstructors().check(project);

      expect(annotated.findings, isEmpty);
      expect(constructors.findings, isEmpty);
    });

    test('checks list-based class condition variants', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );

      final annotated = Heimdall.classes()
          .that()
          .haveTypeName('AnnotatedAggregate')
          .should()
          .beAnnotatedWithAnyOf(['Deprecated', 'Entity'])
          .and()
          .beAnnotatedWithNoneOf(['Deprecated'])
          .and()
          .haveTypeNameEndingWithAnyOf(['Aggregate', 'Repository'])
          .and()
          .declareAnyConstructor(['missing', '_'])
          .and()
          .declareNoMethods(['forbidden'])
          .check(project);
      final user = Heimdall.classes()
          .that()
          .haveTypeName('User')
          .should()
          .receiveAllParameters(['id'])
          .and()
          .receiveNoParameters(['token'])
          .and()
          .declareField('id')
          .and()
          .declareAllFields(['id'])
          .and()
          .declareAnyField(['missing', 'id'])
          .and()
          .declareNoFields(['token'])
          .check(project);
      final composite = Heimdall.classes()
          .that()
          .haveTypeName('CompositeRepository')
          .should()
          .implementAnyOf(['MissingGateway', 'Gateway'])
          .and()
          .extendAnyOf(['Cubit', 'BaseRepository'])
          .and()
          .beAssignableToAnyOf(['Cubit', 'BaseRepository'])
          .check(project);

      expect(annotated.findings, isEmpty);
      expect(user.findings, isEmpty);
      expect(composite.findings, isEmpty);
    });

    test('checks classes that use a mixin', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );

      final result = Heimdall.classes().that().applyMixin('Auditable').should().haveTypeNameEndingWith('Repository').check(project);

      expect(result.checkedCount, 1);
      expect(result.findings, isEmpty);
    });

    test('checks transitive class relationships and typedef aliases', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );

      final childExtendsGrandParent = Heimdall.classes()
          .that()
          .haveTypeName('Child')
          .should()
          .extend('GrandParent')
          .and()
          .extend('GrandParentAlias')
          .and()
          .beAssignableTo('GrandParentAlias')
          .check(project);
      final gatewayChildImplementsRoot = Heimdall.classes()
          .that()
          .haveTypeName('GatewayChild')
          .should()
          .implement('RootGateway')
          .and()
          .implement('RootGatewayAlias')
          .and()
          .beAssignableTo('RootGatewayAlias')
          .check(project);
      final transitiveExtendsPredicate = Heimdall.classes()
          .that()
          .extend('GrandParent')
          .should()
          .haveTypeNameEndingWithAnyOf(['Parent', 'Child'])
          .check(project);
      final transitiveImplementsPredicate = Heimdall.classes()
          .that()
          .implement('RootGateway')
          .should()
          .haveTypeNameEndingWithAnyOf(['Parent', 'Child'])
          .check(project);
      final transitiveMixinPredicate = Heimdall.classes()
          .that()
          .applyMixin('SharedBehaviorAlias')
          .should()
          .haveTypeNameEndingWithAnyOf(['Parent', 'Child'])
          .check(project);
      final mixinConditions = Heimdall.classes()
          .that()
          .haveTypeName('MixinChild')
          .should()
          .applyMixin('SharedBehavior')
          .and()
          .applyMixinAllOf(['SharedBehaviorAlias', 'ExtraBehavior'])
          .and()
          .applyMixinAnyOf(['MissingBehavior', 'ExtraBehavior'])
          .and()
          .applyMixinNoneOf(['MissingBehavior'])
          .and()
          .applyMixinTypeNameEndingWith('Behavior')
          .and()
          .applyMixinTypeNameEndingWithAllOf(['Behavior', 'ExtraBehavior'])
          .and()
          .applyMixinTypeNameEndingWithAnyOf(['MissingBehavior', 'ExtraBehavior'])
          .and()
          .applyMixinTypeNameEndingWithNoneOf(['MissingBehavior'])
          .check(project);
      final suffixConditions = Heimdall.classes()
          .that()
          .haveTypeName('GatewayChild')
          .should()
          .implementTypeNameEndingWith('Gateway')
          .and()
          .beAssignableToTypeNameEndingWith('Gateway')
          .check(project);
      final suffixPredicates = Heimdall.classes()
          .that()
          .extendTypeNameEndingWith('Parent')
          .or()
          .implementTypeNameEndingWith('Gateway')
          .or()
          .applyMixinTypeNameEndingWith('Behavior')
          .should()
          .bePublic()
          .check(project);
      final visibleAlias = Heimdall.classes()
          .that()
          .haveTypeName('AliasConsumer')
          .should()
          .implement('SecondaryContract')
          .and()
          .implement('SharedContractAlias')
          .check(project);
      final hiddenAlias = Heimdall.classes().that().haveTypeName('AliasConsumer').should().implement('PrimaryContract').check(project);
      final hiddenGlobalAlias = Heimdall.classes().that().haveTypeName('HiddenAliasConsumer').should().implement('HiddenContract').check(project);
      final hiddenGlobalAssignable = Heimdall.classes()
          .that()
          .haveTypeName('HiddenAssignableConsumer')
          .should()
          .beAssignableTo('HiddenContract')
          .check(project);

      expect(childExtendsGrandParent.findings, isEmpty);
      expect(gatewayChildImplementsRoot.findings, isEmpty);
      expect(transitiveExtendsPredicate.checkedCount, 2);
      expect(transitiveExtendsPredicate.findings, isEmpty);
      expect(transitiveImplementsPredicate.checkedCount, 2);
      expect(transitiveImplementsPredicate.findings, isEmpty);
      expect(transitiveMixinPredicate.checkedCount, 2);
      expect(transitiveMixinPredicate.findings, isEmpty);
      expect(mixinConditions.findings, isEmpty);
      expect(suffixConditions.findings, isEmpty);
      expect(suffixPredicates.checkedCount, 7);
      expect(suffixPredicates.findings, isEmpty);
      expect(visibleAlias.findings, isEmpty);
      expect(hiddenAlias.findings, hasLength(1));
      expect(hiddenGlobalAlias.findings, hasLength(1));
      expect(hiddenGlobalAssignable.findings, hasLength(1));
    });

    test('checks member rules for super method and field access', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );

      final superMethod = Heimdall.methods().that().haveName('callSuper').should().callMethod('normalize').check(project);
      final superField = Heimdall.methods().that().haveName('readSuper').should().accessField('inheritedName').check(project);
      final ownerExtends = Heimdall.methods()
          .that()
          .areDeclaredInClassesThatExtend('GrandParentAlias')
          .and()
          .haveName('loadChild')
          .should()
          .bePublic()
          .check(project);
      final ownerImplementsSuffix = Heimdall.methods()
          .that()
          .areDeclaredInClassesThatImplementTypeNameEndingWith('Gateway')
          .and()
          .haveName('fetchGateway')
          .should()
          .bePublic()
          .check(project);
      final ownerMixinSuffix = Heimdall.methods()
          .that()
          .areDeclaredInClassesThatApplyMixinTypeNameEndingWith('Behavior')
          .and()
          .haveName('auditChild')
          .should()
          .bePublic()
          .check(project);

      expect(superMethod.findings, isEmpty);
      expect(superField.findings, isEmpty);
      expect(ownerExtends.checkedCount, 1);
      expect(ownerExtends.findings, isEmpty);
      expect(ownerImplementsSuffix.checkedCount, 1);
      expect(ownerImplementsSuffix.findings, isEmpty);
      expect(ownerMixinSuffix.checkedCount, 1);
      expect(ownerMixinSuffix.findings, isEmpty);
    });

    test('checks list-based class predicates', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );

      final composite = Heimdall.classes()
          .that()
          .haveTypeNameEqualToAnyOf(['Missing', 'CompositeRepository'])
          .and()
          .haveTypeNameEqualToNoneOf(['LegacyRepository', 'InternalRepository'])
          .and()
          .haveTypeNameEndingWithAnyOf(['Repository'])
          .and()
          .haveTypeNameStartingWithNoneOf(['_'])
          .and()
          .haveTypeNameMatchingAnyOf([RegExp('Composite')])
          .and()
          .resideInAnyPath(['missing', '**domain/**'])
          .and()
          .extendAnyOf(['MissingBase', 'BaseRepository'])
          .and()
          .extendNoneOf(['LegacyBase', 'InternalBase'])
          .and()
          .applyMixinAllOf(['AdvancedAuditable'])
          .and()
          .implementAllOf(['Gateway'])
          .and()
          .areAssignableToAllOf(['BaseRepository', 'Gateway'])
          .and()
          .areAssignableToNoneOf(['MissingType'])
          .should()
          .haveTypeNameEqualToNoneOf(['LegacyRepository', 'InternalRepository'])
          .and()
          .extendNoneOf(['LegacyBase', 'InternalBase'])
          .and()
          .beInterfaces()
          .check(project);
      final annotated = Heimdall.classes()
          .that()
          .areAnnotatedWithAnyOf(['Deprecated', 'Entity'])
          .and()
          .areAnnotatedWithNoneOf(['Deprecated'])
          .should()
          .haveTypeNameEndingWith('Aggregate')
          .check(project);
      final user = Heimdall.classes()
          .that()
          .declareField('id')
          .and()
          .declareAllFields(['id'])
          .and()
          .declareAnyField(['missing', 'id'])
          .and()
          .declareNoFields(['token'])
          .should()
          .haveTypeName('User')
          .check(project);

      expect(composite.checkedCount, 1);
      expect(composite.findings, isEmpty);
      expect(annotated.checkedCount, 1);
      expect(annotated.findings, isEmpty);
      expect(user.checkedCount, 1);
      expect(user.findings, isEmpty);
    });

    test(
      'combines three or more class predicates and conditions in one rule',
      () {
        final project = const HeimdallFileImporter(useCache: false).importPath(
          fixture,
        );

        final builder =
            Heimdall.classes()
                .that()
                .areInterfaces()
                .and()
                .areAbstract()
                .and()
                .extend('BaseRepository')
                .and()
                .applyMixin('AdvancedAuditable')
                .and()
                .implement('Gateway')
                .should()
              ..beInterfaces();
        builder.andShould().beAbstract();
        final result = builder.andShould().beAssignableTo('BaseRepository').check(project);

        expect(
          result,
          isA<HeimdallReport>()
              .having((report) => report.checkedCount, 'checkedCount', 1)
              .having((report) => report.findings, 'findings', isEmpty)
              .having(
                (report) => report.description,
                'description',
                allOf(
                  contains('are interfaces'),
                  contains('extend BaseRepository'),
                  contains('mixin AdvancedAuditable'),
                ),
              ),
        );
      },
    );

    test('chains class conditions directly from built rules', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );

      final result = Heimdall.classes()
          .that()
          .haveTypeName('CompositeRepository')
          .should()
          .extend('Cubit')
          .or()
          .extend('BaseRepository')
          .check(project);

      expect(result.findings, isEmpty);
      expect(
        result.description,
        contains('(extend Cubit or extend BaseRepository)'),
      );
    });

    test('negates the next chained class condition', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );

      final result = Heimdall.classes().that().haveTypeName('CompositeRepository').should().extend('Cubit').or().not().extend('Bloc').check(project);

      expect(result.findings, isEmpty);
      expect(result.description, contains('(extend Cubit or not (extend Bloc))'));
    });

    test('freezes known findings and ignore patterns hide matches', () {
      const storePath = '$fixture/heimdall_freeze_test.json';
      final store = File(storePath);
      if (store.existsSync()) {
        store.deleteSync();
      }
      addTearDown(() {
        if (store.existsSync()) {
          store.deleteSync();
        }
      });
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );
      final rule = Heimdall.classes().that().haveTypeName('User').should().haveTypeNameEndingWith('Repository');

      final first = rule.freeze(storePath: storePath).check(project);
      final unchangedTimestamp = DateTime(2000);
      store.setLastModifiedSync(unchangedTimestamp);
      final second = rule.freeze(storePath: storePath).check(project);

      expect(first.findings, hasLength(1));
      expect(second.findings, isEmpty);
      expect(store.lastModifiedSync(), unchangedTimestamp);

      HeimdallConfiguration.addIgnoredViolationPattern('should end with');
      try {
        expect(rule.check(project).findings, isEmpty);
      } finally {
        HeimdallConfiguration.clearIgnoredViolationPatterns();
      }
    });

    test('reports findings missing from the freeze store', () {
      const storePath = '$fixture/heimdall_freeze_new_findings_test.json';
      final store = File(storePath);
      if (store.existsSync()) {
        store.deleteSync();
      }
      addTearDown(() {
        if (store.existsSync()) {
          store.deleteSync();
        }
      });
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );
      final userRule = Heimdall.classes().that().haveTypeName('User').should().haveTypeNameEndingWith('Repository');
      final allClassesRule = Heimdall.classes().should().haveTypeNameEndingWith('Repository');

      final first = userRule.freeze(storePath: storePath).check(project);
      final second = allClassesRule.freeze(storePath: storePath).check(project);
      final third = allClassesRule.freeze(storePath: storePath).check(project);

      expect(first.findings, hasLength(1));
      expect(second.findings, isNotEmpty);
      expect(second.findings.join('\n'), contains('Entity'));
      expect(second.findings.join('\n'), isNot(contains('User')));
      expect(third.findings.join('\n'), contains('Entity'));
      expect(third.findings.join('\n'), isNot(contains('User')));
    });

    test('freeze creates an empty baseline before later violations', () {
      const storePath = '$fixture/heimdall_freeze_empty_baseline_test.json';
      final store = File(storePath);
      if (store.existsSync()) {
        store.deleteSync();
      }
      addTearDown(() {
        if (store.existsSync()) {
          store.deleteSync();
        }
      });
      final project = const HeimdallFileImporter(useCache: false).importPath(
        fixture,
      );
      final cleanRule = Heimdall.classes().that().haveTypeName('User').should().haveTypeName('User');
      final violatingRule = Heimdall.classes().that().haveTypeName('User').should().haveTypeNameEndingWith('Repository');

      expect(cleanRule.freeze(storePath: storePath).check(project).findings, isEmpty);
      expect(store.existsSync(), isTrue);
      expect(violatingRule.freeze(storePath: storePath).check(project).findings, hasLength(1));
      expect(violatingRule.freeze(storePath: storePath).check(project).findings, hasLength(1));
    });
  });
}
