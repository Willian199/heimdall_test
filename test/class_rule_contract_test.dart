import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  group('Class rule DSL contract', () {
    test('keeps predicate and should builder class methods in sync', () {
      final project = const HeimdallFileImporter(useCache: false).importPath();
      final predicateMethods = _publicBuilderMethodNames(
        project,
        relativePath: 'src/core/class_rules/class_predicate_builder.dart',
        className: 'ClassPredicateBuilder',
      );
      final shouldMethods = _publicBuilderMethodNames(
        project,
        relativePath: 'src/core/class_rules/class_should_builder.dart',
        className: 'ClassShouldBuilder',
      );

      final predicateContractNames = predicateMethods.map(_classRuleMethodKey).whereType<String>().toSet();
      final shouldContractNames = shouldMethods.map(_classRuleMethodKey).whereType<String>().toSet();

      expect(
        predicateContractNames.difference(shouldContractNames),
        isEmpty,
        reason: 'Every public ClassPredicateBuilder class rule method must have a matching ClassShouldBuilder method.',
      );
      expect(
        shouldContractNames.difference(predicateContractNames),
        isEmpty,
        reason: 'Every public ClassShouldBuilder class rule method must have a matching ClassPredicateBuilder method.',
      );
    });

    test('exposes extend variants on predicate and should builders', () {
      ClassPredicateBuilder(inverted: false).extend('Base');
      ClassPredicateBuilder(inverted: false).extendAny(['Base', 'Entity']);
      ClassPredicateBuilder(inverted: false).extendAll(['Base', 'Entity']);
      ClassPredicateBuilder(inverted: false).extendNone(['Base', 'Entity']);

      Heimdall.classes().should().extend('Base');
      Heimdall.classes().should().extendAny(['Base', 'Entity']);
      Heimdall.classes().should().extendAll(['Base', 'Entity']);
      Heimdall.classes().should().extendNone(['Base', 'Entity']);
    });

    test(
      'exposes extend type name ending with variants on predicate and should builders',
      () {
        ClassPredicateBuilder(inverted: false).extendTypeNameEndingWith('Base');
        ClassPredicateBuilder(
          inverted: false,
        ).extendTypeNameEndingWithAny(['Base', 'Entity']);
        ClassPredicateBuilder(
          inverted: false,
        ).extendTypeNameEndingWithAll(['Base', 'Entity']);
        ClassPredicateBuilder(
          inverted: false,
        ).extendTypeNameEndingWithNone(['Base', 'Entity']);

        Heimdall.classes().should().extendTypeNameEndingWith('Base');
        Heimdall.classes().should().extendTypeNameEndingWithAny(['Base', 'Entity']);
        Heimdall.classes().should().extendTypeNameEndingWithAll(['Base', 'Entity']);
        Heimdall.classes().should().extendTypeNameEndingWithNone(['Base', 'Entity']);
      },
    );

    test(
      'exposes extend type name starting with variants on predicate and should builders',
      () {
        ClassPredicateBuilder(inverted: false).extendTypeNameStartingWith('Base');
        ClassPredicateBuilder(
          inverted: false,
        ).extendTypeNameStartingWithAny(['Base', 'Entity']);
        ClassPredicateBuilder(
          inverted: false,
        ).extendTypeNameStartingWithAll(['Base', 'Entity']);
        ClassPredicateBuilder(
          inverted: false,
        ).extendTypeNameStartingWithNone(['Base', 'Entity']);

        Heimdall.classes().should().extendTypeNameStartingWith('Base');
        Heimdall.classes().should().extendTypeNameStartingWithAny([
          'Base',
          'Entity',
        ]);
        Heimdall.classes().should().extendTypeNameStartingWithAll([
          'Base',
          'Entity',
        ]);
        Heimdall.classes().should().extendTypeNameStartingWithNone([
          'Base',
          'Entity',
        ]);
      },
    );

    test(
      'exposes extend type name matching variants on predicate and should builders',
      () {
        ClassPredicateBuilder(
          inverted: false,
        ).extendTypeNameMatching(RegExp('Base'));
        ClassPredicateBuilder(
          inverted: false,
        ).extendTypeNameMatchingAny([RegExp('Base'), RegExp('Entity')]);
        ClassPredicateBuilder(
          inverted: false,
        ).extendTypeNameMatchingAll([RegExp('Base')]);
        ClassPredicateBuilder(
          inverted: false,
        ).extendTypeNameMatchingNone([RegExp('Legacy')]);

        Heimdall.classes().should().extendTypeNameMatching(RegExp('Base'));
        Heimdall.classes().should().extendTypeNameMatchingAny([
          RegExp('Base'),
          RegExp('Entity'),
        ]);
        Heimdall.classes().should().extendTypeNameMatchingAll([RegExp('Base')]);
        Heimdall.classes().should().extendTypeNameMatchingNone([RegExp('Legacy')]);
      },
    );

    test('exposes class type name variants on predicate and should builders', () {
      ClassPredicateBuilder(inverted: false).haveTypeName('User');
      ClassPredicateBuilder(inverted: false).haveTypeNameAny(['User', 'Account']);
      ClassPredicateBuilder(inverted: false).haveTypeNameAll(['User']);
      ClassPredicateBuilder(inverted: false).haveTypeNameNone(['Legacy']);

      Heimdall.classes().should().haveTypeName('User');
      Heimdall.classes().should().haveTypeNameAny(['User', 'Account']);
      Heimdall.classes().should().haveTypeNameAll(['User']);
      Heimdall.classes().should().haveTypeNameNone(['Legacy']);
    });

    test(
      'exposes class type name ending with variants on predicate and should builders',
      () {
        ClassPredicateBuilder(inverted: false).haveTypeNameEndingWith('Repository');
        ClassPredicateBuilder(
          inverted: false,
        ).haveTypeNameEndingWithAny(['Repository', 'Gateway']);
        ClassPredicateBuilder(
          inverted: false,
        ).haveTypeNameEndingWithAll(['Repository']);
        ClassPredicateBuilder(
          inverted: false,
        ).haveTypeNameEndingWithNone(['Legacy']);

        Heimdall.classes().should().haveTypeNameEndingWith('Repository');
        Heimdall.classes().should().haveTypeNameEndingWithAny([
          'Repository',
          'Gateway',
        ]);
        Heimdall.classes().should().haveTypeNameEndingWithAll(['Repository']);
        Heimdall.classes().should().haveTypeNameEndingWithNone(['Legacy']);
      },
    );

    test(
      'exposes class type name starting with variants on predicate and should builders',
      () {
        ClassPredicateBuilder(inverted: false).haveTypeNameStartingWith('User');
        ClassPredicateBuilder(
          inverted: false,
        ).haveTypeNameStartingWithAny(['User', 'Account']);
        ClassPredicateBuilder(
          inverted: false,
        ).haveTypeNameStartingWithAll(['User']);
        ClassPredicateBuilder(
          inverted: false,
        ).haveTypeNameStartingWithNone(['Legacy']);

        Heimdall.classes().should().haveTypeNameStartingWith('User');
        Heimdall.classes().should().haveTypeNameStartingWithAny([
          'User',
          'Account',
        ]);
        Heimdall.classes().should().haveTypeNameStartingWithAll(['User']);
        Heimdall.classes().should().haveTypeNameStartingWithNone(['Legacy']);
      },
    );

    test(
      'exposes class type name matching variants on predicate and should builders',
      () {
        ClassPredicateBuilder(inverted: false).haveTypeNameMatching(RegExp('User'));
        ClassPredicateBuilder(
          inverted: false,
        ).haveTypeNameMatchingAny([RegExp('User'), RegExp('Account')]);
        ClassPredicateBuilder(
          inverted: false,
        ).haveTypeNameMatchingAll([RegExp('User')]);
        ClassPredicateBuilder(
          inverted: false,
        ).haveTypeNameMatchingNone([RegExp('Legacy')]);

        Heimdall.classes().should().haveTypeNameMatching(RegExp('User'));
        Heimdall.classes().should().haveTypeNameMatchingAny([
          RegExp('User'),
          RegExp('Account'),
        ]);
        Heimdall.classes().should().haveTypeNameMatchingAll([RegExp('User')]);
        Heimdall.classes().should().haveTypeNameMatchingNone([RegExp('Legacy')]);
      },
    );

    test('exposes mixin variants on predicate and should builders', () {
      ClassPredicateBuilder(inverted: false).mixin('Auditable');
      ClassPredicateBuilder(inverted: false).mixinAny(['Auditable', 'Tracked']);
      ClassPredicateBuilder(inverted: false).mixinAll(['Auditable']);
      ClassPredicateBuilder(inverted: false).mixinNone(['Legacy']);

      Heimdall.classes().should().mixin('Auditable');
      Heimdall.classes().should().mixinAny(['Auditable', 'Tracked']);
      Heimdall.classes().should().mixinAll(['Auditable']);
      Heimdall.classes().should().mixinNone(['Legacy']);
    });

    test(
      'exposes mixin ending and starting variants on predicate and should builders',
      () {
        ClassPredicateBuilder(inverted: false).mixinTypeNameEndingWith('Behavior');
        ClassPredicateBuilder(
          inverted: false,
        ).mixinTypeNameEndingWithAny(['Behavior', 'Tracking']);
        ClassPredicateBuilder(inverted: false).mixinTypeNameEndingWithAll(['Behavior']);
        ClassPredicateBuilder(inverted: false).mixinTypeNameEndingWithNone(['Legacy']);

        ClassPredicateBuilder(inverted: false).mixinTypeNameStartingWith('Audit');
        ClassPredicateBuilder(
          inverted: false,
        ).mixinTypeNameStartingWithAny(['Audit', 'Track']);
        ClassPredicateBuilder(inverted: false).mixinTypeNameStartingWithAll(['Audit']);
        ClassPredicateBuilder(inverted: false).mixinTypeNameStartingWithNone(['Legacy']);

        Heimdall.classes().should().mixinTypeNameEndingWith('Behavior');
        Heimdall.classes().should().mixinTypeNameEndingWithAny([
          'Behavior',
          'Tracking',
        ]);
        Heimdall.classes().should().mixinTypeNameEndingWithAll(['Behavior']);
        Heimdall.classes().should().mixinTypeNameEndingWithNone(['Legacy']);

        Heimdall.classes().should().mixinTypeNameStartingWith('Audit');
        Heimdall.classes().should().mixinTypeNameStartingWithAny(['Audit', 'Track']);
        Heimdall.classes().should().mixinTypeNameStartingWithAll(['Audit']);
        Heimdall.classes().should().mixinTypeNameStartingWithNone(['Legacy']);
      },
    );

    test('exposes mixin matching variants on predicate and should builders', () {
      ClassPredicateBuilder(inverted: false).mixinTypeNameMatching(RegExp('Behavior'));
      ClassPredicateBuilder(
        inverted: false,
      ).mixinTypeNameMatchingAny([RegExp('Behavior'), RegExp('Tracking')]);
      ClassPredicateBuilder(
        inverted: false,
      ).mixinTypeNameMatchingAll([RegExp('Behavior')]);
      ClassPredicateBuilder(
        inverted: false,
      ).mixinTypeNameMatchingNone([RegExp('Legacy')]);

      Heimdall.classes().should().mixinTypeNameMatching(RegExp('Behavior'));
      Heimdall.classes().should().mixinTypeNameMatchingAny([
        RegExp('Behavior'),
        RegExp('Tracking'),
      ]);
      Heimdall.classes().should().mixinTypeNameMatchingAll([RegExp('Behavior')]);
      Heimdall.classes().should().mixinTypeNameMatchingNone([RegExp('Legacy')]);
    });

    test('exposes annotation variants on predicate and should builders', () {
      ClassPredicateBuilder(inverted: false).areAnnotatedWith('Entity');
      ClassPredicateBuilder(
        inverted: false,
      ).areAnnotatedWithAny(['Entity', 'Aggregate']);
      ClassPredicateBuilder(inverted: false).areAnnotatedWithAll(['Entity']);
      ClassPredicateBuilder(inverted: false).areAnnotatedWithNone(['Legacy']);

      Heimdall.classes().should().beAnnotatedWith('Entity');
      Heimdall.classes().should().beAnnotatedWithAny(['Entity', 'Aggregate']);
      Heimdall.classes().should().beAnnotatedWithAll(['Entity']);
      Heimdall.classes().should().beAnnotatedWithNone(['Legacy']);
    });

    test(
      'exposes annotation type name ending and starting variants on predicate and should builders',
      () {
        ClassPredicateBuilder(
          inverted: false,
        ).areAnnotatedWithTypeNameEnding('Entity');
        ClassPredicateBuilder(
          inverted: false,
        ).areAnnotatedWithTypeNameEndingAny(['Entity', 'Aggregate']);
        ClassPredicateBuilder(
          inverted: false,
        ).areAnnotatedWithTypeNameEndingAll(['Entity']);
        ClassPredicateBuilder(
          inverted: false,
        ).areAnnotatedWithTypeNameEndingNone(['Legacy']);

        ClassPredicateBuilder(
          inverted: false,
        ).areAnnotatedWithTypeNameStarting('Domain');
        ClassPredicateBuilder(
          inverted: false,
        ).areAnnotatedWithTypeNameStartingAny(['Domain', 'Infra']);
        ClassPredicateBuilder(
          inverted: false,
        ).areAnnotatedWithTypeNameStartingAll(['Domain']);
        ClassPredicateBuilder(
          inverted: false,
        ).areAnnotatedWithTypeNameStartingNone(['Legacy']);

        Heimdall.classes().should().beAnnotatedWithTypeNameEnding('Entity');
        Heimdall.classes().should().beAnnotatedWithTypeNameEndingAny([
          'Entity',
          'Aggregate',
        ]);
        Heimdall.classes().should().beAnnotatedWithTypeNameEndingAll(['Entity']);
        Heimdall.classes().should().beAnnotatedWithTypeNameEndingNone(['Legacy']);

        Heimdall.classes().should().beAnnotatedWithTypeNameStarting('Domain');
        Heimdall.classes().should().beAnnotatedWithTypeNameStartingAny([
          'Domain',
          'Infra',
        ]);

        Heimdall.classes().should().beAnnotatedWithTypeNameStartingAll(['Domain']);
        Heimdall.classes().should().beAnnotatedWithTypeNameStartingNone(['Legacy']);
      },
    );

    test(
      'exposes annotation matching variants on predicate and should builders',
      () {
        ClassPredicateBuilder(
          inverted: false,
        ).areAnnotatedWithTypeNameMatching(RegExp('Entity'));

        ClassPredicateBuilder(
          inverted: false,
        ).areAnnotatedWithTypeNameMatchingAny([
          RegExp('Entity'),
          RegExp('Aggregate'),
        ]);
        ClassPredicateBuilder(
          inverted: false,
        ).areAnnotatedWithTypeNameMatchingAll([RegExp('Entity')]);
        ClassPredicateBuilder(
          inverted: false,
        ).areAnnotatedWithTypeNameMatchingNone([RegExp('Legacy')]);

        Heimdall.classes().should().beAnnotatedWithTypeNameMatching(
          RegExp('Entity'),
        );

        Heimdall.classes().should().beAnnotatedWithTypeNameMatchingAny([
          RegExp('Entity'),
          RegExp('Aggregate'),
        ]);
        Heimdall.classes().should().beAnnotatedWithTypeNameMatchingAll([
          RegExp('Entity'),
        ]);
        Heimdall.classes().should().beAnnotatedWithTypeNameMatchingNone([
          RegExp('Legacy'),
        ]);
      },
    );

    test('exposes implement variants on predicate and should builders', () {
      ClassPredicateBuilder(inverted: false).implement('Gateway');
      ClassPredicateBuilder(inverted: false).implementAny(['Gateway', 'Port']);
      ClassPredicateBuilder(inverted: false).implementAll(['Gateway']);
      ClassPredicateBuilder(inverted: false).implementNone(['Legacy']);

      Heimdall.classes().should().implement('Gateway');
      Heimdall.classes().should().implementAny(['Gateway', 'Port']);
      Heimdall.classes().should().implementAll(['Gateway']);
      Heimdall.classes().should().implementNone(['Legacy']);
    });

    test(
      'exposes implement type name ending and starting variants on predicate and should builders',
      () {
        ClassPredicateBuilder(inverted: false).implementTypeNameEndingWith('Gateway');
        ClassPredicateBuilder(
          inverted: false,
        ).implementTypeNameEndingWithAny(['Gateway', 'Port']);
        ClassPredicateBuilder(
          inverted: false,
        ).implementTypeNameEndingWithAll(['Gateway']);
        ClassPredicateBuilder(
          inverted: false,
        ).implementTypeNameEndingWithNone(['Legacy']);

        ClassPredicateBuilder(inverted: false).implementTypeNameStartingWith('Gate');
        ClassPredicateBuilder(
          inverted: false,
        ).implementTypeNameStartingWithAny(['Gate', 'Port']);
        ClassPredicateBuilder(inverted: false).implementTypeNameStartingWithAll(['Gate']);
        ClassPredicateBuilder(
          inverted: false,
        ).implementTypeNameStartingWithNone(['Legacy']);

        Heimdall.classes().should().implementTypeNameEndingWith('Gateway');
        Heimdall.classes().should().implementTypeNameEndingWithAny([
          'Gateway',
          'Port',
        ]);
        Heimdall.classes().should().implementTypeNameEndingWithAll(['Gateway']);
        Heimdall.classes().should().implementTypeNameEndingWithNone(['Legacy']);

        Heimdall.classes().should().implementTypeNameStartingWith('Gate');
        Heimdall.classes().should().implementTypeNameStartingWithAny(['Gate', 'Port']);
        Heimdall.classes().should().implementTypeNameStartingWithAll(['Gate']);
        Heimdall.classes().should().implementTypeNameStartingWithNone(['Legacy']);
      },
    );

    test(
      'exposes implement type name matching variants on predicate and should builders',
      () {
        ClassPredicateBuilder(
          inverted: false,
        ).implementTypeNameMatching(RegExp('Gateway'));

        ClassPredicateBuilder(
          inverted: false,
        ).implementTypeNameMatchingAny([RegExp('Gateway'), RegExp('Port')]);
        ClassPredicateBuilder(
          inverted: false,
        ).implementTypeNameMatchingAll([RegExp('Gateway')]);
        ClassPredicateBuilder(
          inverted: false,
        ).implementTypeNameMatchingNone([RegExp('Legacy')]);

        Heimdall.classes().should().implementTypeNameMatching(RegExp('Gateway'));

        Heimdall.classes().should().implementTypeNameMatchingAny([
          RegExp('Gateway'),
          RegExp('Port'),
        ]);
        Heimdall.classes().should().implementTypeNameMatchingAll([
          RegExp('Gateway'),
        ]);
        Heimdall.classes().should().implementTypeNameMatchingNone([
          RegExp('Legacy'),
        ]);
      },
    );

    test('exposes assignable variants on predicate and should builders', () {
      ClassPredicateBuilder(inverted: false).areAssignableTo('Entity');
      ClassPredicateBuilder(
        inverted: false,
      ).areAssignableToAny(['Entity', 'Aggregate']);
      ClassPredicateBuilder(inverted: false).areAssignableToAll(['Entity']);
      ClassPredicateBuilder(inverted: false).areAssignableToNone(['Legacy']);

      Heimdall.classes().should().beAssignableTo('Entity');
      Heimdall.classes().should().beAssignableToAny(['Entity', 'Aggregate']);
      Heimdall.classes().should().beAssignableToAll(['Entity']);
      Heimdall.classes().should().beAssignableToNone(['Legacy']);
    });

    test(
      'exposes assignable type name ending and starting variants on predicate and should builders',
      () {
        ClassPredicateBuilder(
          inverted: false,
        ).areAssignableToTypeNameEndingWith('Entity');
        ClassPredicateBuilder(
          inverted: false,
        ).areAssignableToTypeNameEndingWithAny(['Entity', 'Aggregate']);
        ClassPredicateBuilder(
          inverted: false,
        ).areAssignableToTypeNameEndingWithAll(['Entity']);
        ClassPredicateBuilder(
          inverted: false,
        ).areAssignableToTypeNameEndingWithNone(['Legacy']);

        ClassPredicateBuilder(
          inverted: false,
        ).areAssignableToTypeNameStartingWith('Domain');
        ClassPredicateBuilder(
          inverted: false,
        ).areAssignableToTypeNameStartingWithAny(['Domain', 'Core']);
        ClassPredicateBuilder(
          inverted: false,
        ).areAssignableToTypeNameStartingWithAll(['Domain']);
        ClassPredicateBuilder(
          inverted: false,
        ).areAssignableToTypeNameStartingWithNone(['Legacy']);

        Heimdall.classes().should().beAssignableToTypeNameEndingWith('Entity');
        Heimdall.classes().should().beAssignableToTypeNameEndingWithAny([
          'Entity',
          'Aggregate',
        ]);
        Heimdall.classes().should().beAssignableToTypeNameEndingWithAll(['Entity']);
        Heimdall.classes().should().beAssignableToTypeNameEndingWithNone(['Legacy']);

        Heimdall.classes().should().beAssignableToTypeNameStartingWith('Domain');
        Heimdall.classes().should().beAssignableToTypeNameStartingWithAny([
          'Domain',
          'Core',
        ]);
        Heimdall.classes().should().beAssignableToTypeNameStartingWithAll([
          'Domain',
        ]);
        Heimdall.classes().should().beAssignableToTypeNameStartingWithNone([
          'Legacy',
        ]);
      },
    );

    test(
      'exposes assignable type name matching variants on predicate and should builders',
      () {
        ClassPredicateBuilder(
          inverted: false,
        ).areAssignableToTypeNameMatching(RegExp('Entity'));
        ClassPredicateBuilder(
          inverted: false,
        ).areAssignableToTypeNameMatchingAny([RegExp('Entity'), RegExp('Aggregate')]);
        ClassPredicateBuilder(
          inverted: false,
        ).areAssignableToTypeNameMatchingAll([RegExp('Entity')]);
        ClassPredicateBuilder(
          inverted: false,
        ).areAssignableToTypeNameMatchingNone([RegExp('Legacy')]);

        Heimdall.classes().should().beAssignableToTypeNameMatching(
          RegExp('Entity'),
        );
        Heimdall.classes().should().beAssignableToTypeNameMatchingAny([
          RegExp('Entity'),
          RegExp('Aggregate'),
        ]);
        Heimdall.classes().should().beAssignableToTypeNameMatchingAll([
          RegExp('Entity'),
        ]);
        Heimdall.classes().should().beAssignableToTypeNameMatchingNone([
          RegExp('Legacy'),
        ]);
      },
    );

    test('exposes dependency variants on predicate and should builders', () {
      final target = HeimdallPredicate<CompilationUnitMember>(
        'have type name Entity',
        (item, _) => item.name == 'Entity',
      );

      ClassPredicateBuilder(inverted: false).dependOnClassesThat(target);
      ClassPredicateBuilder(inverted: false).noDependOnClassesThat(target);
      ClassPredicateBuilder(inverted: false).onlyDependOnClassesThat(target);

      Heimdall.classes().should().dependOnClassesThat(target);
      Heimdall.classes().should().noDependOnClassesThat(target);
      Heimdall.classes().should().onlyDependOnClassesThat(target);
    });

    test(
      'exposes dependency target type name variants on predicate and should builders',
      () {
        ClassPredicateBuilder(inverted: false).dependOnClassesWithTypeName('Entity');
        ClassPredicateBuilder(
          inverted: false,
        ).dependOnAllClassesWithTypeName(['Entity']);
        ClassPredicateBuilder(
          inverted: false,
        ).dependOnAnyClassesWithTypeName(['Entity', 'Aggregate']);
        ClassPredicateBuilder(
          inverted: false,
        ).dependOnNoClassesWithTypeName(['Legacy']);

        ClassPredicateBuilder(
          inverted: false,
        ).dependOnClassesWithTypeNameEndingWith('Repository');
        ClassPredicateBuilder(
          inverted: false,
        ).dependOnAllClassesWithTypeNameEndingWith(['Repository']);
        ClassPredicateBuilder(
          inverted: false,
        ).dependOnAnyClassesWithTypeNameEndingWith(['Repository', 'Gateway']);
        ClassPredicateBuilder(
          inverted: false,
        ).dependOnNoClassesWithTypeNameEndingWith(['Legacy']);

        ClassPredicateBuilder(
          inverted: false,
        ).dependOnClassesWithTypeNameStartingWith('Domain');
        ClassPredicateBuilder(
          inverted: false,
        ).dependOnAllClassesWithTypeNameStartingWith(['Domain']);
        ClassPredicateBuilder(
          inverted: false,
        ).dependOnAnyClassesWithTypeNameStartingWith(['Domain', 'Core']);
        ClassPredicateBuilder(
          inverted: false,
        ).dependOnNoClassesWithTypeNameStartingWith(['Legacy']);

        ClassPredicateBuilder(
          inverted: false,
        ).dependOnClassesWithTypeNameMatching(RegExp('Entity'));
        ClassPredicateBuilder(
          inverted: false,
        ).dependOnAllClassesWithTypeNameMatching([RegExp('Entity')]);
        ClassPredicateBuilder(
          inverted: false,
        ).dependOnAnyClassesWithTypeNameMatching([RegExp('Entity')]);
        ClassPredicateBuilder(
          inverted: false,
        ).dependOnNoClassesWithTypeNameMatching([RegExp('Legacy')]);

        Heimdall.classes().should().dependOnClassesWithTypeName('Entity');
        Heimdall.classes().should().dependOnAllClassesWithTypeName(['Entity']);
        Heimdall.classes().should().dependOnAnyClassesWithTypeName([
          'Entity',
          'Aggregate',
        ]);
        Heimdall.classes().should().dependOnNoClassesWithTypeName(['Legacy']);
        Heimdall.classes().should().dependOnClassesWithTypeNameEndingWith(
          'Repository',
        );
        Heimdall.classes().should().dependOnAllClassesWithTypeNameEndingWith([
          'Repository',
        ]);
        Heimdall.classes().should().dependOnAnyClassesWithTypeNameEndingWith([
          'Repository',
          'Gateway',
        ]);
        Heimdall.classes().should().dependOnNoClassesWithTypeNameEndingWith([
          'Legacy',
        ]);
        Heimdall.classes().should().dependOnClassesWithTypeNameStartingWith(
          'Domain',
        );
        Heimdall.classes().should().dependOnAllClassesWithTypeNameStartingWith([
          'Domain',
        ]);
        Heimdall.classes().should().dependOnAnyClassesWithTypeNameStartingWith([
          'Domain',
          'Core',
        ]);
        Heimdall.classes().should().dependOnNoClassesWithTypeNameStartingWith([
          'Legacy',
        ]);
        Heimdall.classes().should().dependOnClassesWithTypeNameMatching(
          RegExp('Entity'),
        );
        Heimdall.classes().should().dependOnAllClassesWithTypeNameMatching([
          RegExp('Entity'),
        ]);
        Heimdall.classes().should().dependOnAnyClassesWithTypeNameMatching([
          RegExp('Entity'),
        ]);
        Heimdall.classes().should().dependOnNoClassesWithTypeNameMatching([
          RegExp('Legacy'),
        ]);
      },
    );

    test('exposes class path variants on predicate and should builders', () {
      ClassPredicateBuilder(inverted: false).resideInPath('lib/src');
      ClassPredicateBuilder(
        inverted: false,
      ).resideInAnyPath(['lib/src', 'test']);
      ClassPredicateBuilder(
        inverted: false,
      ).resideInAllPaths(['lib/src', '**/*.dart']);
      ClassPredicateBuilder(
        inverted: false,
      ).resideInNoPaths(['test', 'example']);
      ClassPredicateBuilder(inverted: false).resideOutsideOfPath('test');
      ClassPredicateBuilder(
        inverted: false,
      ).resideOutsideOfAnyPath(['test', 'example']);
      ClassPredicateBuilder(
        inverted: false,
      ).resideOutsideOfAllPaths(['test', 'example']);
      ClassPredicateBuilder(
        inverted: false,
      ).resideOutsideOfNoPaths(['lib/src', '**/*.dart']);

      Heimdall.classes().should().resideInPath('lib/src');
      Heimdall.classes().should().resideInAnyPath(['lib/src', 'test']);
      Heimdall.classes().should().resideInAllPaths(['lib/src', '**/*.dart']);
      Heimdall.classes().should().resideInNoPaths(['test', 'example']);
      Heimdall.classes().should().resideOutsideOfPath('test');
      Heimdall.classes().should().resideOutsideOfAnyPath(['test', 'example']);
      Heimdall.classes().should().resideOutsideOfAllPaths(['test', 'example']);
      Heimdall.classes().should().resideOutsideOfNoPaths([
        'lib/src',
        '**/*.dart',
      ]);

      ClassPredicateBuilder(inverted: false).resideInPathMatching(RegExp('src'));
      ClassPredicateBuilder(
        inverted: false,
      ).resideInAnyPathMatching([RegExp('src'), RegExp('test')]);
      ClassPredicateBuilder(
        inverted: false,
      ).resideInAllPathsMatching([RegExp(r'\.dart$')]);
      ClassPredicateBuilder(
        inverted: false,
      ).resideInNoPathsMatching([RegExp('example')]);

      Heimdall.classes().should().resideInPathMatching(RegExp('src'));
      Heimdall.classes().should().resideInAnyPathMatching([
        RegExp('src'),
        RegExp('test'),
      ]);
      Heimdall.classes().should().resideInAllPathsMatching([RegExp(r'\.dart$')]);
      Heimdall.classes().should().resideInNoPathsMatching([RegExp('example')]);
    });

    test('exposes class member declaration variants on both builders', () {
      ClassPredicateBuilder(inverted: false).declareMethod('call');
      ClassPredicateBuilder(
        inverted: false,
      ).declareAllMethods(['call', 'close']);
      ClassPredicateBuilder(
        inverted: false,
      ).declareAnyMethod(['call', 'close']);
      ClassPredicateBuilder(inverted: false).declareNoMethods(['dispose']);

      Heimdall.classes().should().declareMethod('call');
      Heimdall.classes().should().declareAllMethods(['call', 'close']);
      Heimdall.classes().should().declareAnyMethod(['call', 'close']);
      Heimdall.classes().should().declareNoMethods(['dispose']);

      ClassPredicateBuilder(inverted: false).declareConstructor();
      ClassPredicateBuilder(inverted: false).declareConstructor(name: '_');
      ClassPredicateBuilder(
        inverted: false,
      ).declareAllConstructors(['new', '_']);
      ClassPredicateBuilder(
        inverted: false,
      ).declareAnyConstructor(['new', '_']);
      ClassPredicateBuilder(
        inverted: false,
      ).declareNoConstructors(['legacy']);

      Heimdall.classes().should().declareConstructor();
      Heimdall.classes().should().declareConstructor(name: '_');
      Heimdall.classes().should().declareAllConstructors(['new', '_']);
      Heimdall.classes().should().declareAnyConstructor(['new', '_']);
      Heimdall.classes().should().declareNoConstructors(['legacy']);

      ClassPredicateBuilder(inverted: false).declareConstConstructor();
      ClassPredicateBuilder(inverted: false).declareFactoryConstructor();

      Heimdall.classes().should().declareConstConstructor();
      Heimdall.classes().should().declareFactoryConstructor();

      ClassPredicateBuilder(inverted: false).haveConstructorName('new');
      ClassPredicateBuilder(inverted: false).haveConstructorNameAny(['new', '_']);
      ClassPredicateBuilder(inverted: false).haveConstructorNameAll(['new']);
      ClassPredicateBuilder(inverted: false).haveConstructorNameNone(['legacy']);
      ClassPredicateBuilder(inverted: false).haveConstructorNameEndingWith('_');
      ClassPredicateBuilder(
        inverted: false,
      ).haveConstructorNameEndingWithAny(['_', 'named']);
      ClassPredicateBuilder(inverted: false).haveConstructorNameEndingWithAll(['_']);
      ClassPredicateBuilder(inverted: false).haveConstructorNameEndingWithNone(['legacy']);
      ClassPredicateBuilder(inverted: false).haveConstructorNameStartingWith('_');
      ClassPredicateBuilder(
        inverted: false,
      ).haveConstructorNameStartingWithAny(['_', 'named']);
      ClassPredicateBuilder(inverted: false).haveConstructorNameStartingWithAll(['_']);
      ClassPredicateBuilder(inverted: false).haveConstructorNameStartingWithNone(['legacy']);
      ClassPredicateBuilder(inverted: false).haveConstructorNameMatching(RegExp('_'));
      ClassPredicateBuilder(
        inverted: false,
      ).haveConstructorNameMatchingAny([RegExp('_')]);
      ClassPredicateBuilder(
        inverted: false,
      ).haveConstructorNameMatchingAll([RegExp('_')]);
      ClassPredicateBuilder(
        inverted: false,
      ).haveConstructorNameMatchingNone([RegExp('legacy')]);

      Heimdall.classes().should().haveConstructorName('new');
      Heimdall.classes().should().haveConstructorNameAny(['new', '_']);
      Heimdall.classes().should().haveConstructorNameAll(['new']);
      Heimdall.classes().should().haveConstructorNameNone(['legacy']);
      Heimdall.classes().should().haveConstructorNameEndingWith('_');
      Heimdall.classes().should().haveConstructorNameEndingWithAny([
        '_',
        'named',
      ]);
      Heimdall.classes().should().haveConstructorNameEndingWithAll(['_']);
      Heimdall.classes().should().haveConstructorNameEndingWithNone(['legacy']);
      Heimdall.classes().should().haveConstructorNameStartingWith('_');
      Heimdall.classes().should().haveConstructorNameStartingWithAny([
        '_',
        'named',
      ]);
      Heimdall.classes().should().haveConstructorNameStartingWithAll(['_']);
      Heimdall.classes().should().haveConstructorNameStartingWithNone(['legacy']);
      Heimdall.classes().should().haveConstructorNameMatching(RegExp('_'));
      Heimdall.classes().should().haveConstructorNameMatchingAny([RegExp('_')]);
      Heimdall.classes().should().haveConstructorNameMatchingAll([RegExp('_')]);
      Heimdall.classes().should().haveConstructorNameMatchingNone([
        RegExp('legacy'),
      ]);

      ClassPredicateBuilder(inverted: false).haveOnlyStaticMembers();
      ClassPredicateBuilder(inverted: false).haveAllStaticMembers(['create']);
      ClassPredicateBuilder(inverted: false).haveAnyStaticMembers(['create']);
      ClassPredicateBuilder(inverted: false).haveNoStaticMembers(['legacy']);
      ClassPredicateBuilder(inverted: false).haveOnlyPublicFields();
      ClassPredicateBuilder(inverted: false).haveAllPublicFields(['id']);
      ClassPredicateBuilder(inverted: false).haveAnyPublicFields(['id']);
      ClassPredicateBuilder(inverted: false).haveNoPublicFields(['_id']);

      Heimdall.classes().should().haveOnlyStaticMembers();
      Heimdall.classes().should().haveAllStaticMembers(['create']);
      Heimdall.classes().should().haveAnyStaticMembers(['create']);
      Heimdall.classes().should().haveNoStaticMembers(['legacy']);
      Heimdall.classes().should().haveOnlyPublicFields();
      Heimdall.classes().should().haveAllPublicFields(['id']);
      Heimdall.classes().should().haveAnyPublicFields(['id']);
      Heimdall.classes().should().haveNoPublicFields(['_id']);

      ClassPredicateBuilder(inverted: false).receiveParameter('id');
      ClassPredicateBuilder(
        inverted: false,
      ).receiveAllParameters(['id', 'name']);
      ClassPredicateBuilder(
        inverted: false,
      ).receiveAnyParameter(['id', 'name']);
      ClassPredicateBuilder(inverted: false).receiveNoParameters(['legacy']);

      Heimdall.classes().should().receiveParameter('id');
      Heimdall.classes().should().receiveAllParameters(['id', 'name']);
      Heimdall.classes().should().receiveAnyParameter(['id', 'name']);
      Heimdall.classes().should().receiveNoParameters(['legacy']);
    });
  });
}

Set<String> _publicBuilderMethodNames(
  HeimdallProject project, {
  required String relativePath,
  required String className,
}) {
  final file = project.fileByRelativePath(relativePath);
  if (file == null) {
    throw StateError('Could not find $relativePath in imported project.');
  }

  final declaration = file.declarations
      .whereType<ClassDeclaration>()
      .where((declaration) => declaration.namePart.typeName.lexeme == className)
      .single;

  final members = switch (declaration.body) {
    BlockClassBody(:final members) => members,
    _ => const <ClassMember>[],
  };

  return members.whereType<MethodDeclaration>().map((method) => method.name.lexeme).where((name) => !name.startsWith('_')).toSet();
}

String? _classRuleMethodKey(String methodName) {
  const infrastructureMethods = {
    'and',
    'or',
    'should',
    'andShould',
    'orShould',
    'not',
    'satisfy',
    'allowEmpty',
    'failOnEmpty',
  };

  if (infrastructureMethods.contains(methodName)) return null;
  return _stripFluentPrefix(methodName).toLowerCase();
}

String _stripFluentPrefix(String methodName) {
  for (final prefix in ['are', 'be']) {
    if (methodName.startsWith(prefix) && methodName.length > prefix.length && _isUppercase(methodName.codeUnitAt(prefix.length))) {
      return methodName.substring(prefix.length);
    }
  }
  return methodName;
}

bool _isUppercase(int codeUnit) {
  return codeUnit >= 65 && codeUnit <= 90;
}
