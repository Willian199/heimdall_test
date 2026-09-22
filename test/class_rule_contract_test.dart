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
      ClassPredicateBuilder(inverted: false).extendAnyOf(['Base', 'Entity']);
      ClassPredicateBuilder(inverted: false).extendAllOf(['Base', 'Entity']);
      ClassPredicateBuilder(inverted: false).extendNoneOf(['Base', 'Entity']);

      Heimdall.classes().should().extend('Base');
      Heimdall.classes().should().extendAnyOf(['Base', 'Entity']);
      Heimdall.classes().should().extendAllOf(['Base', 'Entity']);
      Heimdall.classes().should().extendNoneOf(['Base', 'Entity']);
    });

    test(
      'exposes extend type name ending with variants on predicate and should builders',
      () {
        ClassPredicateBuilder(inverted: false).extendTypeNameEndingWith('Base');
        ClassPredicateBuilder(
          inverted: false,
        ).extendTypeNameEndingWithAnyOf(['Base', 'Entity']);
        ClassPredicateBuilder(
          inverted: false,
        ).extendTypeNameEndingWithAllOf(['Base', 'Entity']);
        ClassPredicateBuilder(
          inverted: false,
        ).extendTypeNameEndingWithNoneOf(['Base', 'Entity']);

        Heimdall.classes().should().extendTypeNameEndingWith('Base');
        Heimdall.classes().should().extendTypeNameEndingWithAnyOf(['Base', 'Entity']);
        Heimdall.classes().should().extendTypeNameEndingWithAllOf(['Base', 'Entity']);
        Heimdall.classes().should().extendTypeNameEndingWithNoneOf(['Base', 'Entity']);
      },
    );

    test(
      'exposes extend type name starting with variants on predicate and should builders',
      () {
        ClassPredicateBuilder(inverted: false).extendTypeNameStartingWith('Base');
        ClassPredicateBuilder(
          inverted: false,
        ).extendTypeNameStartingWithAnyOf(['Base', 'Entity']);
        ClassPredicateBuilder(
          inverted: false,
        ).extendTypeNameStartingWithAllOf(['Base', 'Entity']);
        ClassPredicateBuilder(
          inverted: false,
        ).extendTypeNameStartingWithNoneOf(['Base', 'Entity']);

        Heimdall.classes().should().extendTypeNameStartingWith('Base');
        Heimdall.classes().should().extendTypeNameStartingWithAnyOf([
          'Base',
          'Entity',
        ]);
        Heimdall.classes().should().extendTypeNameStartingWithAllOf([
          'Base',
          'Entity',
        ]);
        Heimdall.classes().should().extendTypeNameStartingWithNoneOf([
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
        ).extendTypeNameMatchingAnyOf([RegExp('Base'), RegExp('Entity')]);
        ClassPredicateBuilder(
          inverted: false,
        ).extendTypeNameMatchingAllOf([RegExp('Base')]);
        ClassPredicateBuilder(
          inverted: false,
        ).extendTypeNameMatchingNoneOf([RegExp('Legacy')]);

        Heimdall.classes().should().extendTypeNameMatching(RegExp('Base'));
        Heimdall.classes().should().extendTypeNameMatchingAnyOf([
          RegExp('Base'),
          RegExp('Entity'),
        ]);
        Heimdall.classes().should().extendTypeNameMatchingAllOf([RegExp('Base')]);
        Heimdall.classes().should().extendTypeNameMatchingNoneOf([RegExp('Legacy')]);
      },
    );

    test('exposes class type name variants on predicate and should builders', () {
      ClassPredicateBuilder(inverted: false).haveTypeName('User');
      ClassPredicateBuilder(inverted: false).haveTypeNameEqualToAnyOf(['User', 'Account']);
      ClassPredicateBuilder(inverted: false).haveTypeNameEqualToAllOf(['User']);
      ClassPredicateBuilder(inverted: false).haveTypeNameEqualToNoneOf(['Legacy']);

      Heimdall.classes().should().haveTypeName('User');
      Heimdall.classes().should().haveTypeNameEqualToAnyOf(['User', 'Account']);
      Heimdall.classes().should().haveTypeNameEqualToAllOf(['User']);
      Heimdall.classes().should().haveTypeNameEqualToNoneOf(['Legacy']);
    });

    test(
      'exposes class type name ending with variants on predicate and should builders',
      () {
        ClassPredicateBuilder(inverted: false).haveTypeNameEndingWith('Repository');
        ClassPredicateBuilder(
          inverted: false,
        ).haveTypeNameEndingWithAnyOf(['Repository', 'Gateway']);
        ClassPredicateBuilder(
          inverted: false,
        ).haveTypeNameEndingWithAllOf(['Repository']);
        ClassPredicateBuilder(
          inverted: false,
        ).haveTypeNameEndingWithNoneOf(['Legacy']);

        Heimdall.classes().should().haveTypeNameEndingWith('Repository');
        Heimdall.classes().should().haveTypeNameEndingWithAnyOf([
          'Repository',
          'Gateway',
        ]);
        Heimdall.classes().should().haveTypeNameEndingWithAllOf(['Repository']);
        Heimdall.classes().should().haveTypeNameEndingWithNoneOf(['Legacy']);
      },
    );

    test(
      'exposes class type name starting with variants on predicate and should builders',
      () {
        ClassPredicateBuilder(inverted: false).haveTypeNameStartingWith('User');
        ClassPredicateBuilder(
          inverted: false,
        ).haveTypeNameStartingWithAnyOf(['User', 'Account']);
        ClassPredicateBuilder(
          inverted: false,
        ).haveTypeNameStartingWithAllOf(['User']);
        ClassPredicateBuilder(
          inverted: false,
        ).haveTypeNameStartingWithNoneOf(['Legacy']);

        Heimdall.classes().should().haveTypeNameStartingWith('User');
        Heimdall.classes().should().haveTypeNameStartingWithAnyOf([
          'User',
          'Account',
        ]);
        Heimdall.classes().should().haveTypeNameStartingWithAllOf(['User']);
        Heimdall.classes().should().haveTypeNameStartingWithNoneOf(['Legacy']);
      },
    );

    test(
      'exposes class type name matching variants on predicate and should builders',
      () {
        ClassPredicateBuilder(inverted: false).haveTypeNameMatching(RegExp('User'));
        ClassPredicateBuilder(
          inverted: false,
        ).haveTypeNameMatchingAnyOf([RegExp('User'), RegExp('Account')]);
        ClassPredicateBuilder(
          inverted: false,
        ).haveTypeNameMatchingAllOf([RegExp('User')]);
        ClassPredicateBuilder(
          inverted: false,
        ).haveTypeNameMatchingNoneOf([RegExp('Legacy')]);

        Heimdall.classes().should().haveTypeNameMatching(RegExp('User'));
        Heimdall.classes().should().haveTypeNameMatchingAnyOf([
          RegExp('User'),
          RegExp('Account'),
        ]);
        Heimdall.classes().should().haveTypeNameMatchingAllOf([RegExp('User')]);
        Heimdall.classes().should().haveTypeNameMatchingNoneOf([RegExp('Legacy')]);
      },
    );

    test('exposes mixin variants on predicate and should builders', () {
      ClassPredicateBuilder(inverted: false).applyMixin('Auditable');
      ClassPredicateBuilder(inverted: false).applyMixinAnyOf(['Auditable', 'Tracked']);
      ClassPredicateBuilder(inverted: false).applyMixinAllOf(['Auditable']);
      ClassPredicateBuilder(inverted: false).applyMixinNoneOf(['Legacy']);

      Heimdall.classes().should().applyMixin('Auditable');
      Heimdall.classes().should().applyMixinAnyOf(['Auditable', 'Tracked']);
      Heimdall.classes().should().applyMixinAllOf(['Auditable']);
      Heimdall.classes().should().applyMixinNoneOf(['Legacy']);
    });

    test(
      'exposes mixin ending and starting variants on predicate and should builders',
      () {
        ClassPredicateBuilder(inverted: false).applyMixinTypeNameEndingWith('Behavior');
        ClassPredicateBuilder(
          inverted: false,
        ).applyMixinTypeNameEndingWithAnyOf(['Behavior', 'Tracking']);
        ClassPredicateBuilder(inverted: false).applyMixinTypeNameEndingWithAllOf(['Behavior']);
        ClassPredicateBuilder(inverted: false).applyMixinTypeNameEndingWithNoneOf(['Legacy']);

        ClassPredicateBuilder(inverted: false).applyMixinTypeNameStartingWith('Audit');
        ClassPredicateBuilder(
          inverted: false,
        ).applyMixinTypeNameStartingWithAnyOf(['Audit', 'Track']);
        ClassPredicateBuilder(inverted: false).applyMixinTypeNameStartingWithAllOf(['Audit']);
        ClassPredicateBuilder(inverted: false).applyMixinTypeNameStartingWithNoneOf(['Legacy']);

        Heimdall.classes().should().applyMixinTypeNameEndingWith('Behavior');
        Heimdall.classes().should().applyMixinTypeNameEndingWithAnyOf([
          'Behavior',
          'Tracking',
        ]);
        Heimdall.classes().should().applyMixinTypeNameEndingWithAllOf(['Behavior']);
        Heimdall.classes().should().applyMixinTypeNameEndingWithNoneOf(['Legacy']);

        Heimdall.classes().should().applyMixinTypeNameStartingWith('Audit');
        Heimdall.classes().should().applyMixinTypeNameStartingWithAnyOf(['Audit', 'Track']);
        Heimdall.classes().should().applyMixinTypeNameStartingWithAllOf(['Audit']);
        Heimdall.classes().should().applyMixinTypeNameStartingWithNoneOf(['Legacy']);
      },
    );

    test('exposes mixin matching variants on predicate and should builders', () {
      ClassPredicateBuilder(inverted: false).applyMixinTypeNameMatching(RegExp('Behavior'));
      ClassPredicateBuilder(
        inverted: false,
      ).applyMixinTypeNameMatchingAnyOf([RegExp('Behavior'), RegExp('Tracking')]);
      ClassPredicateBuilder(
        inverted: false,
      ).applyMixinTypeNameMatchingAllOf([RegExp('Behavior')]);
      ClassPredicateBuilder(
        inverted: false,
      ).applyMixinTypeNameMatchingNoneOf([RegExp('Legacy')]);

      Heimdall.classes().should().applyMixinTypeNameMatching(RegExp('Behavior'));
      Heimdall.classes().should().applyMixinTypeNameMatchingAnyOf([
        RegExp('Behavior'),
        RegExp('Tracking'),
      ]);
      Heimdall.classes().should().applyMixinTypeNameMatchingAllOf([RegExp('Behavior')]);
      Heimdall.classes().should().applyMixinTypeNameMatchingNoneOf([RegExp('Legacy')]);
    });

    test('exposes annotation variants on predicate and should builders', () {
      ClassPredicateBuilder(inverted: false).areAnnotatedWith('Entity');
      ClassPredicateBuilder(
        inverted: false,
      ).areAnnotatedWithAnyOf(['Entity', 'Aggregate']);
      ClassPredicateBuilder(inverted: false).areAnnotatedWithAllOf(['Entity']);
      ClassPredicateBuilder(inverted: false).areAnnotatedWithNoneOf(['Legacy']);

      Heimdall.classes().should().beAnnotatedWith('Entity');
      Heimdall.classes().should().beAnnotatedWithAnyOf(['Entity', 'Aggregate']);
      Heimdall.classes().should().beAnnotatedWithAllOf(['Entity']);
      Heimdall.classes().should().beAnnotatedWithNoneOf(['Legacy']);
    });

    test(
      'exposes annotation type name ending and starting variants on predicate and should builders',
      () {
        ClassPredicateBuilder(
          inverted: false,
        ).areAnnotatedWithTypeNameEndingWith('Entity');
        ClassPredicateBuilder(
          inverted: false,
        ).areAnnotatedWithTypeNameEndingWithAnyOf(['Entity', 'Aggregate']);
        ClassPredicateBuilder(
          inverted: false,
        ).areAnnotatedWithTypeNameEndingWithAllOf(['Entity']);
        ClassPredicateBuilder(
          inverted: false,
        ).areAnnotatedWithTypeNameEndingWithNoneOf(['Legacy']);

        ClassPredicateBuilder(
          inverted: false,
        ).areAnnotatedWithTypeNameStartingWith('Domain');
        ClassPredicateBuilder(
          inverted: false,
        ).areAnnotatedWithTypeNameStartingWithAnyOf(['Domain', 'Infra']);
        ClassPredicateBuilder(
          inverted: false,
        ).areAnnotatedWithTypeNameStartingWithAllOf(['Domain']);
        ClassPredicateBuilder(
          inverted: false,
        ).areAnnotatedWithTypeNameStartingWithNoneOf(['Legacy']);

        Heimdall.classes().should().beAnnotatedWithTypeNameEndingWith('Entity');
        Heimdall.classes().should().beAnnotatedWithTypeNameEndingWithAnyOf([
          'Entity',
          'Aggregate',
        ]);
        Heimdall.classes().should().beAnnotatedWithTypeNameEndingWithAllOf(['Entity']);
        Heimdall.classes().should().beAnnotatedWithTypeNameEndingWithNoneOf(['Legacy']);

        Heimdall.classes().should().beAnnotatedWithTypeNameStartingWith('Domain');
        Heimdall.classes().should().beAnnotatedWithTypeNameStartingWithAnyOf([
          'Domain',
          'Infra',
        ]);

        Heimdall.classes().should().beAnnotatedWithTypeNameStartingWithAllOf(['Domain']);
        Heimdall.classes().should().beAnnotatedWithTypeNameStartingWithNoneOf(['Legacy']);
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
        ).areAnnotatedWithTypeNameMatchingAnyOf([
          RegExp('Entity'),
          RegExp('Aggregate'),
        ]);
        ClassPredicateBuilder(
          inverted: false,
        ).areAnnotatedWithTypeNameMatchingAllOf([RegExp('Entity')]);
        ClassPredicateBuilder(
          inverted: false,
        ).areAnnotatedWithTypeNameMatchingNoneOf([RegExp('Legacy')]);

        Heimdall.classes().should().beAnnotatedWithTypeNameMatching(
          RegExp('Entity'),
        );

        Heimdall.classes().should().beAnnotatedWithTypeNameMatchingAnyOf([
          RegExp('Entity'),
          RegExp('Aggregate'),
        ]);
        Heimdall.classes().should().beAnnotatedWithTypeNameMatchingAllOf([
          RegExp('Entity'),
        ]);
        Heimdall.classes().should().beAnnotatedWithTypeNameMatchingNoneOf([
          RegExp('Legacy'),
        ]);
      },
    );

    test('exposes implement variants on predicate and should builders', () {
      ClassPredicateBuilder(inverted: false).implement('Gateway');
      ClassPredicateBuilder(inverted: false).implementAnyOf(['Gateway', 'Port']);
      ClassPredicateBuilder(inverted: false).implementAllOf(['Gateway']);
      ClassPredicateBuilder(inverted: false).implementNoneOf(['Legacy']);

      Heimdall.classes().should().implement('Gateway');
      Heimdall.classes().should().implementAnyOf(['Gateway', 'Port']);
      Heimdall.classes().should().implementAllOf(['Gateway']);
      Heimdall.classes().should().implementNoneOf(['Legacy']);
    });

    test(
      'exposes implement type name ending and starting variants on predicate and should builders',
      () {
        ClassPredicateBuilder(inverted: false).implementTypeNameEndingWith('Gateway');
        ClassPredicateBuilder(
          inverted: false,
        ).implementTypeNameEndingWithAnyOf(['Gateway', 'Port']);
        ClassPredicateBuilder(
          inverted: false,
        ).implementTypeNameEndingWithAllOf(['Gateway']);
        ClassPredicateBuilder(
          inverted: false,
        ).implementTypeNameEndingWithNoneOf(['Legacy']);

        ClassPredicateBuilder(inverted: false).implementTypeNameStartingWith('Gate');
        ClassPredicateBuilder(
          inverted: false,
        ).implementTypeNameStartingWithAnyOf(['Gate', 'Port']);
        ClassPredicateBuilder(inverted: false).implementTypeNameStartingWithAllOf(['Gate']);
        ClassPredicateBuilder(
          inverted: false,
        ).implementTypeNameStartingWithNoneOf(['Legacy']);

        Heimdall.classes().should().implementTypeNameEndingWith('Gateway');
        Heimdall.classes().should().implementTypeNameEndingWithAnyOf([
          'Gateway',
          'Port',
        ]);
        Heimdall.classes().should().implementTypeNameEndingWithAllOf(['Gateway']);
        Heimdall.classes().should().implementTypeNameEndingWithNoneOf(['Legacy']);

        Heimdall.classes().should().implementTypeNameStartingWith('Gate');
        Heimdall.classes().should().implementTypeNameStartingWithAnyOf(['Gate', 'Port']);
        Heimdall.classes().should().implementTypeNameStartingWithAllOf(['Gate']);
        Heimdall.classes().should().implementTypeNameStartingWithNoneOf(['Legacy']);
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
        ).implementTypeNameMatchingAnyOf([RegExp('Gateway'), RegExp('Port')]);
        ClassPredicateBuilder(
          inverted: false,
        ).implementTypeNameMatchingAllOf([RegExp('Gateway')]);
        ClassPredicateBuilder(
          inverted: false,
        ).implementTypeNameMatchingNoneOf([RegExp('Legacy')]);

        Heimdall.classes().should().implementTypeNameMatching(RegExp('Gateway'));

        Heimdall.classes().should().implementTypeNameMatchingAnyOf([
          RegExp('Gateway'),
          RegExp('Port'),
        ]);
        Heimdall.classes().should().implementTypeNameMatchingAllOf([
          RegExp('Gateway'),
        ]);
        Heimdall.classes().should().implementTypeNameMatchingNoneOf([
          RegExp('Legacy'),
        ]);
      },
    );

    test('exposes assignable variants on predicate and should builders', () {
      ClassPredicateBuilder(inverted: false).areAssignableTo('Entity');
      ClassPredicateBuilder(
        inverted: false,
      ).areAssignableToAnyOf(['Entity', 'Aggregate']);
      ClassPredicateBuilder(inverted: false).areAssignableToAllOf(['Entity']);
      ClassPredicateBuilder(inverted: false).areAssignableToNoneOf(['Legacy']);

      Heimdall.classes().should().beAssignableTo('Entity');
      Heimdall.classes().should().beAssignableToAnyOf(['Entity', 'Aggregate']);
      Heimdall.classes().should().beAssignableToAllOf(['Entity']);
      Heimdall.classes().should().beAssignableToNoneOf(['Legacy']);
    });

    test(
      'exposes assignable type name ending and starting variants on predicate and should builders',
      () {
        ClassPredicateBuilder(
          inverted: false,
        ).areAssignableToTypeNameEndingWith('Entity');
        ClassPredicateBuilder(
          inverted: false,
        ).areAssignableToTypeNameEndingWithAnyOf(['Entity', 'Aggregate']);
        ClassPredicateBuilder(
          inverted: false,
        ).areAssignableToTypeNameEndingWithAllOf(['Entity']);
        ClassPredicateBuilder(
          inverted: false,
        ).areAssignableToTypeNameEndingWithNoneOf(['Legacy']);

        ClassPredicateBuilder(
          inverted: false,
        ).areAssignableToTypeNameStartingWith('Domain');
        ClassPredicateBuilder(
          inverted: false,
        ).areAssignableToTypeNameStartingWithAnyOf(['Domain', 'Core']);
        ClassPredicateBuilder(
          inverted: false,
        ).areAssignableToTypeNameStartingWithAllOf(['Domain']);
        ClassPredicateBuilder(
          inverted: false,
        ).areAssignableToTypeNameStartingWithNoneOf(['Legacy']);

        Heimdall.classes().should().beAssignableToTypeNameEndingWith('Entity');
        Heimdall.classes().should().beAssignableToTypeNameEndingWithAnyOf([
          'Entity',
          'Aggregate',
        ]);
        Heimdall.classes().should().beAssignableToTypeNameEndingWithAllOf(['Entity']);
        Heimdall.classes().should().beAssignableToTypeNameEndingWithNoneOf(['Legacy']);

        Heimdall.classes().should().beAssignableToTypeNameStartingWith('Domain');
        Heimdall.classes().should().beAssignableToTypeNameStartingWithAnyOf([
          'Domain',
          'Core',
        ]);
        Heimdall.classes().should().beAssignableToTypeNameStartingWithAllOf([
          'Domain',
        ]);
        Heimdall.classes().should().beAssignableToTypeNameStartingWithNoneOf([
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
        ).areAssignableToTypeNameMatchingAnyOf([RegExp('Entity'), RegExp('Aggregate')]);
        ClassPredicateBuilder(
          inverted: false,
        ).areAssignableToTypeNameMatchingAllOf([RegExp('Entity')]);
        ClassPredicateBuilder(
          inverted: false,
        ).areAssignableToTypeNameMatchingNoneOf([RegExp('Legacy')]);

        Heimdall.classes().should().beAssignableToTypeNameMatching(
          RegExp('Entity'),
        );
        Heimdall.classes().should().beAssignableToTypeNameMatchingAnyOf([
          RegExp('Entity'),
          RegExp('Aggregate'),
        ]);
        Heimdall.classes().should().beAssignableToTypeNameMatchingAllOf([
          RegExp('Entity'),
        ]);
        Heimdall.classes().should().beAssignableToTypeNameMatchingNoneOf([
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
      ClassPredicateBuilder(inverted: false).notDependOnClassesThat(target);
      ClassPredicateBuilder(inverted: false).onlyDependOnClassesThat(target);

      Heimdall.classes().should().dependOnClassesThat(target);
      Heimdall.classes().should().notDependOnClassesThat(target);
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
      ).resideOutsideOfAllPaths(['test', 'example']);
      ClassPredicateBuilder(inverted: false).resideOutsideOfPath('test');
      ClassPredicateBuilder(
        inverted: false,
      ).resideOutsideOfAtLeastOnePath(['test', 'example']);
      ClassPredicateBuilder(
        inverted: false,
      ).resideOutsideOfAllPaths(['test', 'example']);
      ClassPredicateBuilder(
        inverted: false,
      ).resideInAllPaths(['lib/src', '**/*.dart']);

      Heimdall.classes().should().resideInPath('lib/src');
      Heimdall.classes().should().resideInAnyPath(['lib/src', 'test']);
      Heimdall.classes().should().resideInAllPaths(['lib/src', '**/*.dart']);
      Heimdall.classes().should().resideOutsideOfAllPaths(['test', 'example']);
      Heimdall.classes().should().resideOutsideOfPath('test');
      Heimdall.classes().should().resideOutsideOfAtLeastOnePath(['test', 'example']);
      Heimdall.classes().should().resideOutsideOfAllPaths(['test', 'example']);
      Heimdall.classes().should().resideInAllPaths([
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
      ).resideOutsideOfAllPathsMatching([RegExp('example')]);

      Heimdall.classes().should().resideInPathMatching(RegExp('src'));
      Heimdall.classes().should().resideInAnyPathMatching([
        RegExp('src'),
        RegExp('test'),
      ]);
      Heimdall.classes().should().resideInAllPathsMatching([RegExp(r'\.dart$')]);
      Heimdall.classes().should().resideOutsideOfAllPathsMatching([RegExp('example')]);
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

      ClassPredicateBuilder(inverted: false).declareConstructor();
      ClassPredicateBuilder(inverted: false).declareAnyConstructor(['new', '_']);
      ClassPredicateBuilder(inverted: false).declareAllConstructors(['new']);
      ClassPredicateBuilder(inverted: false).declareNoConstructors(['legacy']);
      ClassPredicateBuilder(inverted: false).declareConstructorWithNameEndingWith('_');
      ClassPredicateBuilder(
        inverted: false,
      ).declareConstructorWithNameEndingWithAnyOf(['_', 'named']);
      ClassPredicateBuilder(inverted: false).declareConstructorWithNameEndingWithAllOf(['_']);
      ClassPredicateBuilder(inverted: false).declareConstructorWithNameEndingWithNoneOf(['legacy']);
      ClassPredicateBuilder(inverted: false).declareConstructorWithNameStartingWith('_');
      ClassPredicateBuilder(
        inverted: false,
      ).declareConstructorWithNameStartingWithAnyOf(['_', 'named']);
      ClassPredicateBuilder(inverted: false).declareConstructorWithNameStartingWithAllOf(['_']);
      ClassPredicateBuilder(inverted: false).declareConstructorWithNameStartingWithNoneOf(['legacy']);
      ClassPredicateBuilder(inverted: false).declareConstructorWithNameMatching(RegExp('_'));
      ClassPredicateBuilder(
        inverted: false,
      ).declareConstructorWithNameMatchingAnyOf([RegExp('_')]);
      ClassPredicateBuilder(
        inverted: false,
      ).declareConstructorWithNameMatchingAllOf([RegExp('_')]);
      ClassPredicateBuilder(
        inverted: false,
      ).declareConstructorWithNameMatchingNoneOf([RegExp('legacy')]);

      Heimdall.classes().should().declareConstructor();
      Heimdall.classes().should().declareAnyConstructor(['new', '_']);
      Heimdall.classes().should().declareAllConstructors(['new']);
      Heimdall.classes().should().declareNoConstructors(['legacy']);
      Heimdall.classes().should().declareConstructorWithNameEndingWith('_');
      Heimdall.classes().should().declareConstructorWithNameEndingWithAnyOf([
        '_',
        'named',
      ]);
      Heimdall.classes().should().declareConstructorWithNameEndingWithAllOf(['_']);
      Heimdall.classes().should().declareConstructorWithNameEndingWithNoneOf(['legacy']);
      Heimdall.classes().should().declareConstructorWithNameStartingWith('_');
      Heimdall.classes().should().declareConstructorWithNameStartingWithAnyOf([
        '_',
        'named',
      ]);
      Heimdall.classes().should().declareConstructorWithNameStartingWithAllOf(['_']);
      Heimdall.classes().should().declareConstructorWithNameStartingWithNoneOf(['legacy']);
      Heimdall.classes().should().declareConstructorWithNameMatching(RegExp('_'));
      Heimdall.classes().should().declareConstructorWithNameMatchingAnyOf([RegExp('_')]);
      Heimdall.classes().should().declareConstructorWithNameMatchingAllOf([RegExp('_')]);
      Heimdall.classes().should().declareConstructorWithNameMatchingNoneOf([
        RegExp('legacy'),
      ]);

      ClassPredicateBuilder(inverted: false).haveOnlyStaticMembers();
      ClassPredicateBuilder(inverted: false).haveStaticMembersNamedAllOf(['create']);
      ClassPredicateBuilder(inverted: false).haveStaticMemberNamedAnyOf(['create']);
      ClassPredicateBuilder(inverted: false).haveNoStaticMembersNamed(['legacy']);
      ClassPredicateBuilder(inverted: false).haveOnlyPublicFields();
      ClassPredicateBuilder(inverted: false).havePublicFieldsNamedAllOf(['id']);
      ClassPredicateBuilder(inverted: false).havePublicFieldNamedAnyOf(['id']);
      ClassPredicateBuilder(inverted: false).haveNoPublicFieldsNamed(['_id']);

      Heimdall.classes().should().haveOnlyStaticMembers();
      Heimdall.classes().should().haveStaticMembersNamedAllOf(['create']);
      Heimdall.classes().should().haveStaticMemberNamedAnyOf(['create']);
      Heimdall.classes().should().haveNoStaticMembersNamed(['legacy']);
      Heimdall.classes().should().haveOnlyPublicFields();
      Heimdall.classes().should().havePublicFieldsNamedAllOf(['id']);
      Heimdall.classes().should().havePublicFieldNamedAnyOf(['id']);
      Heimdall.classes().should().haveNoPublicFieldsNamed(['_id']);

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
  if (methodName.startsWith('notBe')) return 'Not${methodName.substring(5)}';
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
