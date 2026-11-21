import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  group('ExcludeGeneratedDartImportOption', () {
    const fixtureRoot = 'test/importer_fixtures/generated_options_project';
    const ordinaryPaths = [
      'lib/model.dart',
      'lib/modelXcustom.dart',
      'lib/nested.mocks.dart/service.dart',
    ];
    const customPaths = ['lib/model.custom.dart', 'lib/model.generated.dart'];
    const generatedPaths = [
      'lib/model.freezed.dart',
      'lib/model.g.dart',
      'lib/model.gen.dart',
      'lib/model.gr.dart',
      'lib/model.mocks.dart',
    ];
    final defaultOption = ExcludeGeneratedDartImportOption();
    final customOption = ExcludeGeneratedDartImportOption(
      additionalSuffixes: ['.generated.dart', '.custom.dart'],
    );

    for (final suffixes in [
      [''],
      ['.custom.dart', ''],
    ]) {
      test('asserts on construction with empty suffixes in $suffixes', () {
        expect(
          () => ExcludeGeneratedDartImportOption(additionalSuffixes: suffixes),
          throwsA(isA<AssertionError>()),
        );
      });
    }

    test('constant defaults match the unnamed constructor without custom suffixes', () {
      const option = ExcludeGeneratedDartImportOption.defaults();

      expect(option.cacheKey, defaultOption.cacheKey);
      expect(option.additionalSuffixes, isEmpty);
      for (final path in [...ordinaryPaths, ...customPaths, ...generatedPaths]) {
        expect(option.includes(path), defaultOption.includes(path), reason: path);
      }
    });

    test('copies suffixes so later mutations cannot invalidate the option', () {
      final suffixes = ['.custom.dart'];
      final option = ExcludeGeneratedDartImportOption(additionalSuffixes: suffixes);
      final cacheKey = option.cacheKey;
      suffixes
        ..clear()
        ..add('');

      expect(option.includes('/project/lib/model.dart'), isTrue);
      expect(option.includes('/project/lib/model.custom.dart'), isFalse);
      expect(option.cacheKey, cacheKey);
      expect(() => option.additionalSuffixes.add(''), throwsUnsupportedError);
    });

    for (final suffix in ['.g.dart', '.freezed.dart', '.gr.dart', '.gen.dart', '.mocks.dart']) {
      test('excludes $suffix with default and custom options', () {
        for (final option in [defaultOption, customOption]) {
          expect(option.includes('/project/lib/model$suffix'), isFalse);
          expect(option.includes('C:\\project\\lib\\model$suffix'), isFalse);
        }
      });
    }

    test('adds custom suffixes without affecting the default option', () {
      for (final suffix in customOption.additionalSuffixes) {
        expect(customOption.includes('/project/lib/model$suffix'), isFalse);
        expect(defaultOption.includes('/project/lib/model$suffix'), isTrue);
      }
    });

    test('includes ordinary files and matches only literal trailing suffixes', () {
      for (final option in [defaultOption, customOption]) {
        for (final path in [
          '/project/lib/model.dart',
          '/project/lib/model.gen.dart.bak',
          '/project/lib/model.mocks.dart/model.dart',
          '/project/lib/model.GEN.dart',
          '/project/lib/modelXcustom.dart',
        ]) {
          expect(option.includes(path), isTrue, reason: path);
        }
      }
    });

    test('cache keys distinguish custom suffix lists without delimiter collisions', () {
      expect(customOption.cacheKey, isNot(defaultOption.cacheKey));
      expect(
        customOption.cacheKey,
        ExcludeGeneratedDartImportOption(
          additionalSuffixes: ['.generated.dart', '.custom.dart'],
        ).cacheKey,
      );
      expect(
        ExcludeGeneratedDartImportOption(additionalSuffixes: ['a,b']).cacheKey,
        isNot(ExcludeGeneratedDartImportOption(additionalSuffixes: ['a', 'b']).cacheKey),
      );
    });

    test('default importer excludes generated fixture files and their declarations', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(fixtureRoot);

      expect(
        project.files.map((file) => file.relativePath),
        unorderedEquals([...ordinaryPaths, ...customPaths]),
      );
      expect(
        project.declarations.map((declaration) => declaration.name),
        unorderedEquals(['Model', 'SimilarSuffixModel', 'NestedService', 'CustomGeneratedModel', 'CustomModel']),
      );
    });

    test('custom importer excludes additional fixture files and keeps ordinary declarations', () {
      final project = HeimdallFileImporter(
        importOptions: [customOption],
        useCache: false,
      ).importPath(fixtureRoot);

      expect(project.files.map((file) => file.relativePath), unorderedEquals(ordinaryPaths));
      expect(
        project.declarations.map((declaration) => declaration.name),
        unorderedEquals(['Model', 'SimilarSuffixModel', 'NestedService']),
      );
    });

    test('include-all importer parses every generated fixture and declaration', () {
      final project = const HeimdallFileImporter(
        importOptions: [IncludeAllImportOption()],
        useCache: false,
      ).importPath(fixtureRoot);

      expect(
        project.files.map((file) => file.relativePath),
        unorderedEquals([...ordinaryPaths, ...customPaths, ...generatedPaths]),
      );
      expect(project.files.expand((file) => file.parseErrors), isEmpty);
      expect(
        project.declarations.map((declaration) => declaration.name),
        unorderedEquals([
          'Model',
          'SimilarSuffixModel',
          'NestedService',
          'CustomGeneratedModel',
          'CustomModel',
          'GeneratedModel',
          'FrozenModel',
          'GeneratedRouter',
          'GeneratedAssets',
          'MockModel',
        ]),
      );
    });

    test('importer caches different fixture suffix configurations separately', () {
      HeimdallFileImporter.clearCache();
      addTearDown(HeimdallFileImporter.clearCache);
      const defaultImporter = HeimdallFileImporter();
      final customImporter = HeimdallFileImporter(importOptions: [customOption]);
      final defaultProject = defaultImporter.importPath(fixtureRoot);
      final customProject = customImporter.importPath(fixtureRoot);

      expect(
        defaultProject.files.map((file) => file.relativePath),
        unorderedEquals([...ordinaryPaths, ...customPaths]),
      );
      expect(
        customProject.files.map((file) => file.relativePath),
        unorderedEquals(ordinaryPaths),
      );
      expect(identical(defaultProject, customProject), isFalse);
      expect(identical(defaultImporter.importPath(fixtureRoot), defaultProject), isTrue);
      expect(identical(customImporter.importPath(fixtureRoot), customProject), isTrue);
    });
  });
}
