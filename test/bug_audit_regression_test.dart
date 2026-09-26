import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  const importer = HeimdallFileImporter(useCache: false);
  const fixture = 'test/bug_audit_fixtures';
  final hierarchy = importer.importPath(fixture);
  final relationships = hierarchy;

  group('bug audit: mixin interface inheritance', () {
    for (final className in ['DirectMixinWorker', 'ChildMixinWorker']) {
      test('$className is missed by implement', () {
        final report = Heimdall.classes().that().haveTypeName(className).should().implement('AuditContract').check(hierarchy);

        expect(report.checkedCount, 1);
        expect(report.findings, isEmpty);
      });

      test('$className is wrongly accepted by notImplement', () {
        final report = Heimdall.classes().that().haveTypeName(className).should().notImplement('AuditContract').check(hierarchy);

        expect(report.findings, hasLength(1));
      });
    }

    test('type-name suffix lookup also misses the inherited interface', () {
      final report = Heimdall.classes().that().haveTypeName('DirectMixinWorker').should().implementTypeNameEndingWith('Contract').check(hierarchy);

      expect(report.findings, isEmpty);
    });

    test('type-name prefix lookup also misses the inherited interface', () {
      final report = Heimdall.classes().that().haveTypeName('DirectMixinWorker').should().implementTypeNameStartingWith('Audit').check(hierarchy);

      expect(report.findings, isEmpty);
    });

    test('type-name pattern lookup also misses the inherited interface', () {
      final report = Heimdall.classes()
          .that()
          .haveTypeName('DirectMixinWorker')
          .should()
          .implementTypeNameMatching(RegExp('AuditContract'))
          .check(hierarchy);

      expect(report.findings, isEmpty);
    });

    test('implementAnyOf ignores an interface inherited through a mixin', () {
      final report = Heimdall.classes()
          .that()
          .haveTypeName('DirectMixinWorker')
          .should()
          .implementAnyOf(['MissingContract', 'AuditContract'])
          .check(hierarchy);

      expect(report.findings, isEmpty);
    });

    test('implementAllOf ignores an interface inherited through a mixin', () {
      final report = Heimdall.classes().that().haveTypeName('DirectMixinWorker').should().implementAllOf(['AuditContract']).check(hierarchy);

      expect(report.findings, isEmpty);
    });

    test('prefix any-of implementation lookup ignores a mixin interface', () {
      final report = Heimdall.classes()
          .that()
          .haveTypeName('DirectMixinWorker')
          .should()
          .implementTypeNameStartingWithAnyOf(['Missing', 'Audit'])
          .check(hierarchy);

      expect(report.findings, isEmpty);
    });

    test('suffix any-of implementation lookup ignores a mixin interface', () {
      final report = Heimdall.classes()
          .that()
          .haveTypeName('DirectMixinWorker')
          .should()
          .implementTypeNameEndingWithAnyOf(['Missing', 'Contract'])
          .check(hierarchy);

      expect(report.findings, isEmpty);
    });

    test('pattern any-of implementation lookup ignores a mixin interface', () {
      final report = Heimdall.classes()
          .that()
          .haveTypeName('DirectMixinWorker')
          .should()
          .implementTypeNameMatchingAnyOf([RegExp('Missing'), RegExp('AuditContract')])
          .check(hierarchy);

      expect(report.findings, isEmpty);
    });

    test('negated prefix implementation condition accepts a class with mixin interface', () {
      final report = Heimdall.classes().that().haveTypeName('DirectMixinWorker').should().notImplementTypeNameStartingWith('Audit').check(hierarchy);

      expect(report.findings, isNotEmpty);
    });

    test('negative implementation predicate selects a class with mixin interface', () {
      final report = Heimdall.classes()
          .that()
          .haveTypeName('DirectMixinWorker')
          .and()
          .notImplement('AuditContract')
          .should()
          .bePublic()
          .allowEmpty()
          .check(hierarchy);

      expect(report.checkedCount, 0);
    });

    test('suffix negative implementation condition accepts a class with mixin interface', () {
      final report = Heimdall.classes().that().haveTypeName('DirectMixinWorker').should().notImplementTypeNameEndingWith('Contract').check(hierarchy);

      expect(report.findings, isNotEmpty);
    });

    test('prefix any-of implementation selector misses concrete mixin users', () {
      final report = Heimdall.classes()
          .that()
          .implementTypeNameStartingWithAnyOf(['Audit', 'Missing'])
          .should()
          .bePublic()
          .allowEmpty()
          .check(hierarchy);

      expect(report.checkedCount, greaterThan(1));
    });

    test('regex any-of implementation selector misses concrete mixin users', () {
      final report = Heimdall.classes()
          .that()
          .implementTypeNameMatchingAnyOf([RegExp('AuditContract'), RegExp('Missing')])
          .should()
          .bePublic()
          .allowEmpty()
          .check(hierarchy);

      expect(report.checkedCount, greaterThan(1));
    });

    test('predicate selector misses classes implementing an interface through a mixin', () {
      final report = Heimdall.classes().that().implement('AuditContract').should().bePublic().allowEmpty().check(hierarchy);

      expect(report.checkedCount, greaterThan(1));
    });

    test('class aliases are omitted from the project type declaration collections', () {
      final alias = hierarchy
          .fileByRelativePath('lib/hierarchy_cases.dart')!
          .declarations
          .firstWhere((declaration) => declaration.toSource().contains('class AliasMixinWorker'));

      expect(alias.isTypeDeclaration, isTrue);
      expect(hierarchy.typeDeclarations, contains(alias));
      expect(hierarchy.classDeclarations, contains(alias));
    });

    test('public class aliases are omitted from public type declarations', () {
      final alias = hierarchy
          .fileByRelativePath('lib/hierarchy_cases.dart')!
          .declarations
          .firstWhere((declaration) => declaration.toSource().contains('class AliasMixinWorker'));

      expect(alias.isPublic, isTrue);
      expect(hierarchy.publicTypeDeclarations, contains(alias));
    });

    test('class DSL cannot select a public class alias', () {
      final report = Heimdall.classes().that().haveTypeName('AliasMixinWorker').should().bePublic().allowEmpty().check(hierarchy);

      expect(report.checkedCount, 1);
    });

    test('enum interface inherited from a mixin is missed', () {
      final report = Heimdall.classes().that().haveTypeName('EnumMixinWorker').should().implement('AuditContract').check(hierarchy);

      expect(report.findings, isEmpty);
    });
  });

  group('bug audit: returned list analysis', () {
    for (final (className, fieldName, methodName) in [
      ('ConditionalListField', 'value', 'props'),
      ('LoopListField', 'value', 'props'),
      ('BranchListFields', 'first', 'props'),
      ('BranchListFields', 'second', 'props'),
      ('ConditionalListShapes', 'nestedIf', 'nested'),
      ('ConditionalListShapes', 'conditionalBranch', 'branchAndAlways'),
      ('ConditionalListShapes', 'loopOnly', 'loopAndAlways'),
      ('ConditionalListShapes', 'loopConditional', 'loopAndConditional'),
    ]) {
      test('$className.$fieldName is treated as present in every returned list', () {
        final report = Heimdall.fields()
            .that()
            .haveName(fieldName)
            .and()
            .areDeclaredInClassesThat(
              HeimdallPredicate('are $className', (item, _) => item.name == className),
            )
            .should()
            .notBeIncludedInEveryReturnedListOf(methodName)
            .check(relationships);

        expect(report.checkedCount, 1);
        expect(report.findings, isEmpty);
      });
    }
  });

  group('bug audit: inferred public signatures', () {
    test('an unannotated top-level function returning Map keys length has a dynamic signature', () {
      final report = Heimdall.code().publicSignaturesShouldNotUseDynamic().check(hierarchy);
      expect(report.findings.any((finding) => finding.message.startsWith('keyCount ')), isTrue);
    });

    test('an unannotated top-level function returning Map values length has a dynamic signature', () {
      final report = Heimdall.code().publicSignaturesShouldNotUseDynamic().check(hierarchy);
      expect(report.findings.any((finding) => finding.message.startsWith('valueCount ')), isTrue);
    });

    for (final functionName in [
      'keyIsEmpty',
      'valueIsEmpty',
      'keyListLength',
      'valueListLength',
      'keyIsNotEmpty',
      'valueIsNotEmpty',
      'keyJoined',
      'valueJoined',
      'keyAny',
      'valueAny',
      'keyIteratorCanMove',
      'valueIteratorCanMove',
      'keyContains',
      'valueContains',
      'keyLengthPlus',
      'valueLengthPlus',
      'keyLengthComparison',
    ]) {
      test('$functionName has an implicit dynamic return despite its concrete return expression', () {
        final report = Heimdall.code().publicSignaturesShouldNotUseDynamic().check(hierarchy);
        expect(report.findings.any((finding) => finding.message.startsWith('$functionName ')), isTrue);
      });
    }

    test('Map entries with a dynamic key are not reported as dynamic', () {
      final report = Heimdall.code().publicSignaturesShouldNotUseDynamic().check(hierarchy);
      expect(report.findings.any((finding) => finding.message.startsWith('entry ')), isTrue);
    });

    for (final functionName in [
      'itemsAsList',
      'itemsFiltered',
      'itemsMapped',
      'itemsAsSet',
      'itemsSkipped',
      'itemsTaken',
      'itemsFirstWhere',
      'itemsLastWhere',
      'itemsSingleWhere',
      'itemsElementAt',
      'itemsRemoveAt',
      'itemsRemoveLast',
      'itemsExpanded',
      'itemsFollowedBy',
      'itemsGetRange',
      'itemsSublist',
      'itemsReversed',
      'itemsSkipWhile',
      'itemsTakeWhile',
      'itemsCast',
      'mapRemove',
      'mapPutIfAbsent',
      'mapCast',
      'mapUpdate',
    ]) {
      test('$functionName loses dynamic generic information from its result', () {
        final report = Heimdall.code().publicSignaturesShouldNotUseDynamic().check(hierarchy);
        expect(report.findings.any((finding) => finding.message.startsWith('$functionName ')), isTrue);
      });
    }
  });

  test('barrel rule rejects a normal Dart export with its default allowed pattern', () {
    final report = Heimdall.code().barrelFilesShouldOnlyExport(barrelPattern: 'lib/barrel/index.dart').check(hierarchy);

    expect(report.findings, isEmpty);
  });

  test('barrel default pattern rejects an allowed sibling export target', () {
    final report = Heimdall.code().barrelFilesShouldOnlyExport(barrelPattern: 'lib/barrel/other.dart').check(hierarchy);

    expect(report.findings, isEmpty);
  });

  test('barrel default pattern rejects a normal nested export target', () {
    final report = Heimdall.code().barrelFilesShouldOnlyExport(barrelPattern: 'lib/barrel/feature/index.dart').check(hierarchy);

    expect(report.findings, isEmpty);
  });

  test('pattern variable in an if-case guard is mistaken for a field read', () {
    final report = Heimdall.methods().that().haveName('readPatternGuard').should().notAccessField('value').check(hierarchy);

    expect(report.findings, isEmpty);
  });

  test('pattern variable in an if-element guard is mistaken for a field read', () {
    final report = Heimdall.methods().that().haveName('readPatternGuardInElement').should().notAccessField('value').check(hierarchy);

    expect(report.findings, isEmpty);
  });

  test('unqualified method invocation is mistaken for a constructor call', () {
    final report = Heimdall.methods().that().haveName('invokeMethod').should().notCallConstructor('Product').check(hierarchy);

    expect(report.findings, isEmpty);
  });

  test('notCallConstructor accepts a method whose parameter default creates that constructor', () {
    final report = Heimdall.methods().that().haveName('create').should().notCallConstructor('ProducedValue').check(hierarchy);

    expect(report.findings, hasLength(1));
  });

  test('notCallConstructor accepts a constructor whose parameter default creates that constructor', () {
    final report = Heimdall.constructors()
        .that()
        .haveName('new')
        .and()
        .areDeclaredInClassesThat(
          HeimdallPredicate('are DefaultConstructorParameter', (declaration, _) => declaration.name == 'DefaultConstructorParameter'),
        )
        .should()
        .notCallConstructor('ProducedValue')
        .check(hierarchy);

    expect(report.findings, hasLength(1));
  });

  test('notCallConstructorWithArguments accepts a method whose default contains matching arguments', () {
    final report = Heimdall.methods()
        .that()
        .haveName('create')
        .should()
        .notCallConstructorWithArguments('ProducedValue', positionalArguments: ['1'])
        .check(hierarchy);

    expect(report.findings, hasLength(1));
  });

  test('notCallConstructorWithArguments accepts a constructor whose default contains matching arguments', () {
    final report = Heimdall.constructors()
        .that()
        .haveName('new')
        .and()
        .areDeclaredInClassesThat(
          HeimdallPredicate('are DefaultConstructorParameter', (declaration, _) => declaration.name == 'DefaultConstructorParameter'),
        )
        .should()
        .notCallConstructorWithArguments('ProducedValue', positionalArguments: ['1'])
        .check(hierarchy);

    expect(report.findings, hasLength(1));
  });

  test('negated constructor prefix rule accepts an unqualified matching method call', () {
    final report = Heimdall.methods().that().haveName('invokeMethod').should().notCallConstructorTypeNameStartingWith('Prod').check(hierarchy);

    expect(report.findings, isEmpty);
  });

  test('negated constructor suffix rule accepts an unqualified matching method call', () {
    final report = Heimdall.methods().that().haveName('invokeMethod').should().notCallConstructorTypeNameEndingWith('duct').check(hierarchy);

    expect(report.findings, isEmpty);
  });

  test('negated constructor pattern rule accepts an unqualified matching method call', () {
    final report = Heimdall.methods().that().haveName('invokeMethod').should().notCallConstructorTypeNameMatching(RegExp('Product')).check(hierarchy);

    expect(report.findings, isEmpty);
  });

  group('bug audit: conditional directive branches', () {
    final file = hierarchy.fileByRelativePath('lib/uri_cases.dart')!;

    test('missing secondary import branch is not classified as unresolved local', () {
      final conditional = file.importDirectives.firstWhere(
        (directive) => directive.targetUris.contains('missing_secondary_import.dart'),
      );

      expect(conditional.targetFiles, isNotEmpty);
      expect(file.unresolvedLocalImports, contains(conditional));
    });

    test('missing secondary export branch is not classified as unresolved local', () {
      final conditional = file.exportDirectives.firstWhere(
        (directive) => directive.targetUris.contains('missing_secondary_export.dart'),
      );

      expect(conditional.targetFiles, isNotEmpty);
      expect(file.unresolvedLocalExports, contains(conditional));
    });

    test('out-of-scope secondary import branch is hidden by resolved primary branch', () {
      final conditional = file.importDirectives.firstWhere(
        (directive) => directive.targetUris.contains('../outside_branch.dart'),
      );

      expect(conditional.targetFiles, isNotEmpty);
      expect(file.resolvedImports, contains(conditional));
      expect(file.externalImports, contains(conditional));
    });

    test('internal conditional package branch hides external package branch', () {
      final conditional = file.importDirectives.firstWhere(
        (directive) => directive.targetUris.contains('package:external/widgets.dart'),
      );

      expect(conditional.targetUris, contains('package:heimdall_test/test/bug_audit_fixtures/lib/present_branch.dart'));
      expect(hierarchy.internalPackageImports, contains(conditional));
      expect(hierarchy.externalPackageImports, contains(conditional));
    });

    test('unsupported mailto directive URI is rejected', () {
      final uri = file.sourceUris.firstWhere((reference) => reference.target.startsWith('mailto:'));
      expect(uri.isValid, isFalse);
    });

    for (final unsupportedUri in ['custom:resource', 'data:text/plain,hello', 'urn:example:item']) {
      test('unsupported $unsupportedUri directive URI is rejected', () {
        final uri = file.sourceUris.firstWhere((reference) => reference.target == unsupportedUri);
        expect(uri.isValid, isFalse);
      });
    }

    test('upward relative import finding names only the safe primary branch', () {
      final report = Heimdall.dependencies().noFilesShouldDependOnUpperDirectories().check(hierarchy);
      final finding = report.findings.firstWhere((finding) => finding.filePath?.endsWith('uri_cases.dart') ?? false);

      expect(finding.message, contains('../outside_branch.dart'));
    });
  });

  test('pathShouldBeEmpty passes when the selected path contains no files', () {
    final report = Heimdall.code().pathShouldBeEmpty('lib/does_not_exist').check(hierarchy);
    expect(report.findings, isEmpty);
  });

  test('pathShouldBeEmpty passes when the path pattern has no matching candidates', () {
    final report = Heimdall.code().pathShouldBeEmpty('lib/never-created/**').check(hierarchy);
    expect(report.findings, isEmpty);
  });

  test('pathShouldBeEmpty passes when no source file exists in the requested directory', () {
    final report = Heimdall.code().pathShouldBeEmpty('lib/empty-directory').check(hierarchy);
    expect(report.findings, isEmpty);
  });

  test('ignored empty-selection finding is hidden from report but still throws on assertion', () {
    final wasFailOnEmpty = HeimdallConfiguration.failOnEmptySelection;
    final previousPatterns = [...HeimdallConfiguration.ignoredViolationPatterns];
    try {
      HeimdallConfiguration.failOnEmptySelection = true;
      HeimdallConfiguration.clearIgnoredViolationPatterns();
      HeimdallConfiguration.addIgnoredViolationPattern(r'Rule \.that\(\) predicate matched no items');

      final report = Heimdall.classes().that().haveTypeName('MissingAuditType').should().bePublic().check(hierarchy);

      expect(report.hasFindings, isFalse);
      expect(report.assertNoFindings, returnsNormally);
    } finally {
      HeimdallConfiguration.failOnEmptySelection = wasFailOnEmpty;
      HeimdallConfiguration.clearIgnoredViolationPatterns();
      HeimdallConfiguration.ignoredViolationPatterns.addAll(previousPatterns);
    }
  });
}
