import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  const importer = HeimdallFileImporter(useCache: false);
  const fixture = 'test/bug_sweep_fixtures';
  final project = importer.importPath(fixture);
  setUpAll(() => expect(project.parseErrors, isEmpty, reason: project.parseErrors.join('\n')));

  group('public signature inference through imported declarations', () {
    final report = Heimdall.code().publicSignaturesShouldNotUseDynamic(pathPattern: 'imported_signatures.dart').check(project);
    final messages = report.findings.map((finding) => finding.message).toList();

    for (final declaration in [
      'importedShownValue',
      'importedShownCall',
      'importedPrefixedValue',
      'importedPrefixedCall',
      'importedBarrelValue',
      'importedBarrelCall',
      'importedInstanceGetter',
      'importedInstanceMethod',
      'importedPrefixedInstanceGetter',
      'importedPrefixedInstanceMethod',
      'importedShownLocalValue',
      'importedShownConditionalValue',
      'importedShownListValue',
      'importedShownRecordValue',
      'importedPrefixedLocalValue',
      'importedPrefixedConditionalValue',
      'importedPrefixedListValue',
      'importedPrefixedRecordValue',
      'importedBarrelLocalValue',
      'importedBarrelConditionalValue',
      'importedBarrelListValue',
      'importedBarrelRecordValue',
      'importedShownMapValue',
      'importedShownIndexValue',
      'importedShownCoalesceValue',
      'importedPrefixedMapValue',
      'importedPrefixedIndexValue',
      'importedPrefixedCoalesceValue',
      'importedBarrelMapValue',
      'importedBarrelIndexValue',
      'importedBarrelCoalesceValue',
    ]) {
      test('$declaration is recognized as returning dynamic', () {
        expect(messages, contains('$declaration has public dynamic type'));
      });
    }
    // Equality has static type bool, even when its receiver is dynamic.
    for (final name in ['importedShownCompareValue', 'importedPrefixedCompareValue', 'importedBarrelCompareValue']) {
      test('$name returns bool', () {
        expect(messages, isNot(contains('$name has public dynamic type')));
      });
    }
  });

  group('record types are retained in member type names', () {
    final members = project.classMembers.where((member) => member.ownerName == 'RecordTypeNames');
    for (final (memberName, expectedType) in [
      ('positional', '(int, String)'),
      ('singlePositional', '(int,)'),
      ('named', '({int id, String label})'),
      ('nullable', '(int, String)?'),
      ('nested', '(int, (String, bool))'),
      ('recordList', 'List<(int, String)>'),
      ('positionalGetter', '(int, String)'),
      ('namedGetter', '({int id, String label})'),
      ('nullableGetter', '(int, String)?'),
      ('makePositional', '(int, String)'),
      ('makeNamed', '({int id, String label})'),
      ('makeNested', '(int, (String, bool))'),
    ]) {
      test('$memberName exposes $expectedType', () {
        final member = members.firstWhere((candidate) => candidate.name == memberName);
        expect(member.type, expectedType);
      });
    }
  });

  test('import visibility and lexical shadowing do not introduce dynamic', () {
    expect(Heimdall.code().publicSignaturesShouldNotUseDynamic(pathPattern: 'imported_controls.dart').check(project).findings, isEmpty);
  });

  group('record types can be selected by the declared type rules', () {
    for (final (memberName, expectedType) in [
      ('positional', '(int, String)'),
      ('singlePositional', '(int,)'),
      ('named', '({int id, String label})'),
      ('nullable', '(int, String)?'),
      ('nested', '(int, (String, bool))'),
      ('recordList', 'List<(int, String)>'),
    ]) {
      test('field $memberName matches its record type', () {
        final report = Heimdall.fields()
            .that()
            .haveName(memberName)
            .and()
            .areDeclaredInClassesThat(HeimdallPredicate('belongs to RecordTypeNames', (item, _) => item.name == 'RecordTypeNames'))
            .should()
            .haveDeclaredFieldTypeName(expectedType)
            .check(project);
        expect(report.findings, isEmpty);
      });
    }

    for (final (memberName, expectedType) in [
      ('positionalGetter', '(int, String)'),
      ('namedGetter', '({int id, String label})'),
      ('nullableGetter', '(int, String)?'),
      ('makePositional', '(int, String)'),
      ('makeNamed', '({int id, String label})'),
      ('makeNested', '(int, (String, bool))'),
    ]) {
      test('method $memberName matches its record return type', () {
        final report = Heimdall.methods()
            .that()
            .haveName(memberName)
            .and()
            .areDeclaredInClassesThat(HeimdallPredicate('belongs to RecordTypeNames', (item, _) => item.name == 'RecordTypeNames'))
            .should()
            .haveReturnType(expectedType)
            .check(project);
        expect(report.findings, isEmpty);
      });
    }
  });

  group('dynamic comparisons do not infer a dynamic public return', () {
    final report = Heimdall.code().publicSignaturesShouldNotUseDynamic(pathPattern: 'signature_binary_ops.dart').check(project);
    for (final declaration in [
      'binaryEqualNull',
      'binaryEqualInt',
      'binaryNotEqualNull',
      'binaryNotEqualString',
      'binaryEqualityNestedInList',
      'binaryEqualityNestedInRecord',
      'binaryEqualityParenthesized',
      'binaryEqualityNegated',
      'binaryEqualityAnd',
      'binaryEqualityOr',
      'binaryEqualityStoredLocally',
      'binaryEqualityInBranch',
      'binaryEqualityInSwitchBranch',
      'binaryEqualityCoalesced',
      'binaryEqualityInvokedClosure',
      'binaryInequalityInsideComparison',
    ]) {
      test('$declaration has a concrete bool return type', () {
        expect(report.findings.any((finding) => finding.message.startsWith('$declaration ')), isFalse);
      });
    }
    // Unlike equality, relational operators are dynamic method invocations.
    for (final name in ['binaryLessThan', 'binaryGreaterThan', 'binaryLessThanOrEqual', 'binaryGreaterThanOrEqual']) {
      test('$name retains a dynamic return type', () {
        expect(report.findings.map((finding) => finding.message), contains('$name has public dynamic type'));
      });
    }
  });

  group('generic inheritance keeps its type arguments during assignability checks', () {
    for (final (method, target) in [
      ('takesText', 'GenericBase<int>'),
      ('takesNested', 'GenericBase<List<int>>'),
      ('takesNullable', 'GenericBase<String>'),
      ('takesAliasBase', 'GenericBase<int>'),
      ('takesDeep', 'GenericBase<int>'),
      ('takesImplementer', 'GenericBase<int>'),
      ('takesDynamicChild', 'GenericBase<String>'),
      ('takesGenericAlias', 'GenericBase<List<int>>'),
    ]) {
      test('$method rejects incompatible $target', () {
        expect(Heimdall.methods().that().haveName(method).should().receiveParameterAssignableTo(target).check(project).findings, isNotEmpty);
      });
    }
    for (final (methodName, targetType) in [
      ('takesText', 'GenericBase<String>'),
      ('takesInt', 'GenericBase<int>'),
      ('takesNested', 'GenericBase<List<String>>'),
      ('takesNullable', 'GenericBase<String>?'),
      ('takesCovariant', 'GenericBase<Object>'),
      ('takesNestedCovariant', 'GenericBase<List<List<Object>>>'),
      ('takesGenericAlias', 'GenericBase<List<String>>'),
    ]) {
      test('$methodName accepts its inherited generic target $targetType', () {
        final report = Heimdall.methods().that().haveName(methodName).should().receiveParameterAssignableTo(targetType).check(project);
        expect(report.findings, isEmpty);
      });
    }

    for (final (fieldName, targetType) in [
      ('textChild', 'GenericBase<String>'),
      ('intChild', 'GenericBase<int>'),
      ('nestedChild', 'GenericBase<List<String>>'),
    ]) {
      test('field $fieldName is assignable to $targetType', () {
        final report = Heimdall.fields().that().haveName(fieldName).should().haveDeclaredFieldTypeAssignableTo(targetType).check(project);
        expect(report.findings, isEmpty);
      });
    }

    for (final (className, targetType) in [
      ('ConcreteStringChild', 'GenericBase<String>'),
      ('AliasStringChild', 'GenericBase<String>'),
    ]) {
      test('$className is assignable to $targetType', () {
        final report = Heimdall.classes().that().haveTypeName(className).should().beAssignableTo(targetType).check(project);
        expect(report.findings, isEmpty);
      });
    }

    for (final (methodName, targetType) in [
      ('takesAliasChild', 'GenericBase<String>'),
      ('takesAliasBase', 'GenericBase<String>'),
      ('takesImplementer', 'GenericBase<String>'),
      ('takesDeep', 'GenericBase<String>'),
    ]) {
      test('$methodName retains the generic target through aliases and inheritance', () {
        final report = Heimdall.methods().that().haveName(methodName).should().receiveParameterAssignableTo(targetType).check(project);
        expect(report.findings, isEmpty);
      });
    }

    for (final (fieldName, targetType) in [
      ('childAlias', 'GenericBase<String>'),
      ('baseAlias', 'GenericBase<String>'),
    ]) {
      test('field $fieldName keeps the generic target through its typedef', () {
        final report = Heimdall.fields().that().haveName(fieldName).should().haveDeclaredFieldTypeAssignableTo(targetType).check(project);
        expect(report.findings, isEmpty);
      });
    }

    for (final (className, targetType) in [
      ('ConcreteDeepChild', 'GenericBase<String>'),
      ('ConcreteImplementer', 'GenericBase<String>'),
    ]) {
      test('$className preserves generic hierarchy edges to $targetType', () {
        final report = Heimdall.classes().that().haveTypeName(className).should().beAssignableTo(targetType).check(project);
        expect(report.findings, isEmpty);
      });
    }
  });

  group('conditional URI findings point at the offending branch', () {
    final file = project.fileByRelativePath('lib/conditional_uris.dart')!;
    for (final (uri, isImport) in [
      ('package:external/io_secret.dart', true),
      ('package:external/web_secret.dart', true),
      ('package:external/io_export.dart', false),
      ('package:external/web_export.dart', false),
    ]) {
      for (final useRegex in [false, true]) {
        test('${isImport ? 'import' : 'export'} ${useRegex ? 'regex' : 'exact'} finding points at $uri', () {
          final report = isImport
              ? useRegex
                    ? Heimdall.files().that().resideInPath(file.relativePath).should().notImportUriMatching(RegExp(RegExp.escape(uri))).check(project)
                    : Heimdall.files().that().resideInPath(file.relativePath).should().notImportUri(uri).check(project)
              : useRegex
              ? Heimdall.files().that().resideInPath(file.relativePath).should().notExportUriMatching(RegExp(RegExp.escape(uri))).check(project)
              : Heimdall.files().that().resideInPath(file.relativePath).should().notExportUri(uri).check(project);
          final expectedOffset = file.content.indexOf("'$uri'");
          expect(expectedOffset, isNonNegative);
          expect(report.findings, isNotEmpty);
          expect(report.findings.first.line, file.sourceLocationAt(expectedOffset).lineNumber);
          expect(report.findings.first.column, file.sourceLocationAt(expectedOffset).columnNumber);
        });
      }
    }
  });
}
