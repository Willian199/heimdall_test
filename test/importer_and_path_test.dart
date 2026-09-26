import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  group('Importer, cache, options, and paths', () {
    const basicProject = 'test/importer_fixtures/basic_project';
    const optionsProject = 'test/importer_fixtures/options_project';

    test('imports Dart files and declarations', () {
      final project = const HeimdallFileImporter(
        useCache: false,
      ).importPath(basicProject);

      expect(project.files, hasLength(2));
      expect(
        project.files.map((file) => file.relativePath),
        orderedEquals([
          'lib/src/data/user_repository.dart',
          'lib/src/domain/user.dart',
        ]),
      );
      expect(
        project.declarations.map((declaration) => declaration.name),
        containsAll(['User', 'UserRepository', 'createRepository']),
      );
      expect(
        project.dependencies.where(
          (dependency) => dependency.targetFile != null,
        ),
        isNotEmpty,
      );
      expect(project.dependencies.whereType<ImportDirective>(), isNotEmpty);

      final repository = project.declarations.singleWhere(
        (declaration) => declaration.name == 'UserRepository',
      );
      final packageImport = project.dependencies.singleWhere(
        (dependency) => dependency.targetUri == 'package:sample/src/domain/user.dart',
      );

      expect(
        repository,
        isA<ClassDeclaration>()
            .having(
              (declaration) => declaration.relativePath,
              'relativePath',
              'lib/src/data/user_repository.dart',
            )
            .having((declaration) => declaration.line, 'line', 6)
            .having(
              _classMemberNames,
              'members',
              containsAll(['find', 'findPackageUser']),
            ),
      );
      expect(
        packageImport,
        isA<ImportDirective>()
            .having((dependency) => dependency.line, 'line', 2)
            .having(
              (dependency) => dependency.targetFile?.relativePath,
              'targetFile',
              'lib/src/domain/user.dart',
            )
            .having(
              (dependency) => dependency.originPath,
              'originPath',
              endsWith('user_repository.dart'),
            ),
      );
    });

    test('keeps declaration metadata as immutable import snapshots', () {
      final project = const HeimdallFileImporter(
        useCache: false,
      ).importPath(basicProject);
      final file = project.files.singleWhere(
        (file) => file.relativePath.endsWith('user_repository.dart'),
      );
      final repository = project.declarations.singleWhere(
        (declaration) => declaration.name == 'UserRepository',
      );
      final method = repository.methods.first;
      final packageImport = project.dependencies.singleWhere(
        (dependency) => dependency.targetUri == 'package:sample/src/domain/user.dart',
      );

      expect(identical(repository.members, repository.members), isTrue);
      expect(identical(repository.methods, repository.methods), isTrue);
      expect(identical(repository.fields, repository.fields), isTrue);
      expect(identical(repository.annotations, repository.annotations), isTrue);
      expect(identical(method.annotations, method.annotations), isTrue);
      expect(() => repository.members.clear(), throwsUnsupportedError);
      expect(() => repository.methods.clear(), throwsUnsupportedError);
      expect(() => method.annotations.clear(), throwsUnsupportedError);
      expect(file.declarations.clear, throwsUnsupportedError);
      expect(() => file.typeDeclarations.clear(), throwsUnsupportedError);
      expect(file.directives.clear, throwsUnsupportedError);
      expect(file.dependencies.clear, throwsUnsupportedError);
      expect(file.parseErrors.clear, throwsUnsupportedError);
      expect(() => file.methods.clear(), throwsUnsupportedError);
      expect(() => file.importDirectives.clear(), throwsUnsupportedError);
      expect(() => project.declarations.clear(), throwsUnsupportedError);
      expect(() => project.typeDeclarations.clear(), throwsUnsupportedError);
      expect(() => project.methods.clear(), throwsUnsupportedError);
      expect(() => project.importDirectives.clear(), throwsUnsupportedError);
      expect(() => project.filesByPath.clear(), throwsUnsupportedError);
      expect(
        () => project.exportedTypeDeclarationsOf(file).clear(),
        throwsUnsupportedError,
      );
      expect(
        () => attachDeclarationContext(
          node: repository,
          sourcePath: file.absolutePath,
          relativePath: file.relativePath,
          lineInfo: file.lineInfo,
        ),
        throwsStateError,
      );
      expect(
        () => attachMemberContext(
          node: method,
          owner: repository,
          sourcePath: file.absolutePath,
          relativePath: file.relativePath,
          lineInfo: file.lineInfo,
        ),
        throwsStateError,
      );
      expect(
        () => attachDependencyContext(
          directive: packageImport,
          originPath: file.absolutePath,
          lineInfo: file.lineInfo,
        ),
        throwsStateError,
      );
      expect(
        () => attachDependencyTarget(
          directive: packageImport,
          targetPath: packageImport.targetPath,
          targetFile: packageImport.targetFile,
        ),
        throwsStateError,
      );
    });

    test('reuses line information from an imported fixture', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(basicProject);
      final file = project.fileByRelativePath('lib/src/domain/user.dart')!;

      expect(identical(file.lineInfo, file.lineInfo), isTrue);
    });

    test('reuses cached imports until the cache is cleared', () {
      const importer = HeimdallFileImporter();

      HeimdallFileImporter.clearCache();
      final first = importer.importPath(basicProject);
      final second = importer.importPath(basicProject);

      expect(identical(first, second), isTrue);

      HeimdallFileImporter.clearCache();

      final third = importer.importPath(basicProject);

      expect(identical(first, third), isFalse);
      expect(third.files, hasLength(2));
    });

    test('uses separate cache entries for predicate options without keys', () {
      HeimdallFileImporter.clearCache();
      final firstPredicateImporter = HeimdallFileImporter(
        importOptions: [
          PathPredicateImportOption((path) => path.endsWith('.dart')),
        ],
      );
      final secondPredicateImporter = HeimdallFileImporter(
        importOptions: [
          PathPredicateImportOption((path) => path.endsWith('.dart')),
        ],
      );

      final firstPredicate = firstPredicateImporter.importPath(basicProject);
      final secondPredicate = secondPredicateImporter.importPath(basicProject);

      expect(identical(firstPredicate, secondPredicate), isFalse);
    });

    test('uses stable cache keys for equivalent import options', () {
      const firstImporter = HeimdallFileImporter(
        importOptions: [ExcludeTestsImportOption()],
      );
      const secondImporter = HeimdallFileImporter(
        importOptions: [ExcludeTestsImportOption()],
      );

      final first = firstImporter.importPath(basicProject);
      final second = secondImporter.importPath(basicProject);

      expect(identical(first, second), isTrue);
    });

    test('imports library files and excludes generated Dart files', () {
      final project = const HeimdallFileImporter(
        importOptions: [
          IncludeLibraryImportOption(),
          ExcludeGeneratedDartImportOption(),
        ],
        useCache: false,
      ).importPath(optionsProject);

      expect(
        project.files.map((file) => file.relativePath),
        allOf(
          everyElement(startsWith('lib/')),
          isNot(contains('lib/src/data/generated.g.dart')),
        ),
      );
    });

    test('recognizes package root when importing a subdirectory', () {
      final project = const HeimdallFileImporter(useCache: false).importPath(
        '$basicProject/lib',
      );

      expect(project.rootPath, endsWith('lib'));
      expect(
        project.packageRootPath.replaceAll(r'\', '/'),
        endsWith(basicProject),
      );
      expect(project.packageName, 'sample');
      expect(
        project.fileByRelativePath('src/data/user_repository.dart'),
        isNotNull,
      );
      expect(
        project.dependencies.where(
          (dependency) => dependency.targetFile?.relativePath == 'src/domain/user.dart',
        ),
        isNotEmpty,
      );
    });

    test('parses pubspec YAML and uses the package language version', () {
      final quotedNameProject = const HeimdallFileImporter(useCache: false).importPath(
        basicProject,
      );
      final oldLanguageProject = const HeimdallFileImporter(useCache: false).importPath(
        'test/importer_fixtures/language_project',
      );

      expect(quotedNameProject.packageName, 'sample');
      expect(
        quotedNameProject.dependencies.where(
          (dependency) => dependency.targetUri == 'package:sample/src/domain/user.dart' && dependency.targetFile != null,
        ),
        isNotEmpty,
      );
      expect(oldLanguageProject.files.single.parseErrors, isNotEmpty);
    });

    test('matches ArchUnit-like capture path patterns', () {
      expect(
        pathMatches(
          'lib/src/features/orders/service.dart',
          'lib/src/features/(*)/service.dart',
        ),
        isTrue,
      );
      expect(
        pathMatches(
          'lib/src/features/admin/users/service.dart',
          'lib/src/features/(**)/service.dart',
        ),
        isTrue,
      );
      expect(
        pathMatches('lib/src/user/service/foo.dart', '..service..'),
        isTrue,
      );
      expect(
        [
          pathMatches(
            r'lib\src\features\orders\service.dart',
            'lib/src/features/(*)/service.dart',
          ),
          pathMatches(
            'lib/src/features/admin/users/service.dart',
            'lib/src/features/(*)/service.dart',
          ),
          pathMatches(
            'lib/src/features/admin/users/service.dart',
            'lib/src/features/(**)/service.dart',
          ),
          pathMatches('lib/src/user/repository/foo.dart', '..service..'),
          pathMatches('lib/src/user/service/foo.dart', 'lib/src/user/*.dart'),
          pathMatches('lib/src/database/repository.dart', 'data'),
          pathMatches('lib/src/data/repository.dart', 'lib/src/data'),
          pathMatches('lib/src/features/user/data/repository/foo.dart', 'data/repository'),
          pathMatches('lib/src/data', 'lib/src/data'),
          pathMatches('lib/src/data/repository.dart', 'lib/src/data/**'),
          pathMatches(
            'lib/src/features/user/data/repository/foo.dart',
            '**data/repository/**',
          ),
          pathMatches(
            'lib/src/features/user/data/service/foo.dart',
            '..data/service..',
          ),
          pathMatches(
            'lib/src/features/user/data/service/foo_impl.dart',
            '/data/**/*impl.dart',
          ),
          pathMatches(
            'lib/src/features/user/data/foo_impl.dart',
            '/data/**/*impl.dart',
          ),
          pathMatches(
            'lib/src/features/todo/view/widget/todo_widget.dart',
            'view/widget',
          ),
          pathMatches(
            'lib/src/features/todo/view_model/todo_widget.dart',
            'view/widget',
          ),
        ],
        orderedEquals([
          true,
          false,
          true,
          false,
          false,
          false,
          false,
          true,
          true,
          true,
          true,
          true,
          true,
          true,
          true,
          false,
        ]),
      );
      expect(
        [
          captureSlicePathSegment(
            'lib/src/features/user/domain/user.dart',
            '/features/(*)/domain/**',
          ),
          captureSlicePathSegment(
            'lib/src/features/user/domain/user.dart',
            'lib/**/(*)/domain/**',
          ),
          captureSlicePathSegment(
            'lib/src/features/user/domain/user.dart',
            'lib/src/features/(*)',
          ),
          captureSlicePathSegment(
            'lib/src/features/user/application/user.dart',
            'lib/src/features/(*)/domain/**',
          ),
        ],
        orderedEquals(['user', 'user', 'user', null]),
      );
    });
  });
}

Iterable<String> _classMemberNames(ClassDeclaration declaration) {
  final body = declaration.body;
  if (body is! BlockClassBody) {
    return const [];
  }
  return body.members.map((member) => member.name);
}
