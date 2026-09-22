import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  group('Architecture rules', () {
    HeimdallProject importArchitectureFixture(String name) {
      return const HeimdallFileImporter(useCache: false).importPath(
        'test/architecture_fixtures/$name',
      );
    }

    test('layer rules only count declarations assigned to layers', () {
      final project = importArchitectureFixture('layer_assignment');

      final result = Heimdall.layers()
          .layer('Data')
          .definedBy(['data'])
          .layer('Domain')
          .definedBy(['domain'])
          .whereLayer('Data')
          .mayOnlyAccessLayers(['Domain'])
          .consideringOnlyDependenciesInLayers()
          .asRule()
          .check(project);

      expect(result.checkedCount, 3);
      expect(result.findings, isEmpty);
    });

    test('layer rules can report dependencies outside declared layers', () {
      final project = importArchitectureFixture('layer_assignment');

      final result = Heimdall.layers()
          .layer('Data')
          .definedBy(['data'])
          .layer('Domain')
          .definedBy(['domain'])
          .whereLayer('Data')
          .mayOnlyAccessLayers(['Domain'])
          .consideringAllDependencies()
          .asRule()
          .check(project);

      expect(result.checkedCount, 3);
      expect(result.findings, hasLength(1));
      expect(
        result.findings.single.message,
        contains('accesses undeclared layer'),
      );
    });

    test(
      'layer rules only use dependencies referenced by each declaration',
      () {
        final project = importArchitectureFixture('referenced_dependencies');

        final result = Heimdall.layers()
            .layer('Data')
            .definedBy(['data'])
            .layer('Domain')
            .definedBy(['domain'])
            .whereLayer('Data')
            .mayNotAccessAnyLayer()
            .asRule()
            .check(project);

        expect(result.findings, hasLength(1));
        expect(result.findings.single.message, contains('UsesDomain'));
      },
    );

    test('class dependencies distinguish homonymous prefixed imports', () {
      final project = importArchitectureFixture('prefixed_dependencies');

      final domainA = Heimdall.classes()
          .that()
          .haveTypeName('UserRepository')
          .should()
          .notDependOnClassesThat(
            HeimdallPredicate(
              'are the domain A user',
              (item, _) => item.name == 'User' && item.relativePath.contains('/domain_a/'),
            ),
          )
          .check(project);
      final domainB = Heimdall.classes()
          .that()
          .haveTypeName('UserRepository')
          .should()
          .notDependOnClassesThat(
            HeimdallPredicate(
              'are the domain B user',
              (item, _) => item.name == 'User' && item.relativePath.contains('/domain_b/'),
            ),
          )
          .check(project);

      expect(domainA.findings, hasLength(1));
      expect(domainA.findings.single.message, contains('forbidden User'));
      expect(domainB.findings, isEmpty);
    });

    test('transitive type relationships preserve import prefixes', () {
      final project = importArchitectureFixture('prefixed_dependencies');

      final rootA = Heimdall.classes()
          .that()
          .haveTypeName('UserRepository')
          .and()
          .areAssignableTo('RootA')
          .should()
          .haveTypeName('UserRepository')
          .check(project);
      final rootB = Heimdall.classes()
          .that()
          .haveTypeName('UserRepository')
          .and()
          .areAssignableTo('RootB')
          .should()
          .haveTypeName('UserRepository')
          .check(project);

      expect(rootA.checkedCount, 0);
      expect(rootA.findings, hasLength(1));
      expect(rootB.checkedCount, 1);
      expect(rootB.findings, isEmpty);

      final aliasRootA = Heimdall.classes()
          .that()
          .haveTypeName('AliasRepository')
          .and()
          .areAssignableTo('RootA')
          .should()
          .haveTypeName('AliasRepository')
          .check(project);
      final aliasRootB = Heimdall.classes()
          .that()
          .haveTypeName('AliasRepository')
          .and()
          .areAssignableTo('RootB')
          .should()
          .haveTypeName('AliasRepository')
          .check(project);

      expect(aliasRootA.checkedCount, 0);
      expect(aliasRootB.checkedCount, 1);
      expect(aliasRootB.findings, isEmpty);
    });

    test('class dependencies recognize prefixed annotations', () {
      final project = importArchitectureFixture('prefixed_dependencies');

      final domainA = Heimdall.classes()
          .that()
          .haveTypeName('AnnotatedRepository')
          .should()
          .notDependOnClassesThat(
            HeimdallPredicate(
              'are the domain A marker',
              (item, _) => item.name == 'Marker' && item.relativePath.contains('/domain_a/'),
            ),
          )
          .check(project);
      final domainB = Heimdall.classes()
          .that()
          .haveTypeName('AnnotatedRepository')
          .should()
          .notDependOnClassesThat(
            HeimdallPredicate(
              'are the domain B marker',
              (item, _) => item.name == 'Marker' && item.relativePath.contains('/domain_b/'),
            ),
          )
          .check(project);

      expect(domainA.findings, isEmpty);
      expect(domainB.findings, hasLength(1));
      expect(domainB.findings.single.message, contains('forbidden Marker'));
    });

    test('conditional imports participate in dependency rules and slices', () {
      final project = importArchitectureFixture('conditional_dependencies');
      final consumer = project.files.singleWhere(
        (file) => file.relativePath.endsWith('consumer.dart'),
      );
      final conditionalImport = consumer.importDirectives.single;

      final classes = Heimdall.classes()
          .that()
          .haveTypeName('Consumer')
          .should()
          .notDependOnClassesThat(
            HeimdallPredicate(
              'reside in feature B',
              (item, _) => item.relativePath.contains('/features/b/'),
            ),
          )
          .check(project);
      final slices = Heimdall.slices(
        'lib/src/features/(*)',
      ).shouldNotDependOnEachOther().check(project);
      final uriRule = Heimdall.files().that().haveName('consumer.dart').should().notImportUri('../b/service_io.dart').check(project);
      final layers = Heimdall.layers()
          .layer('A')
          .definedBy(['features/a'])
          .layer('B')
          .definedBy(['features/b'])
          .whereLayer('A')
          .mayOnlyAccessLayers(['A'])
          .consideringOnlyDependenciesInLayers()
          .asRule()
          .check(project);

      expect(conditionalImport.targetUri, 'service_stub.dart');
      expect(conditionalImport.conditionalTargetUris, ['../b/service_io.dart']);
      expect(
        conditionalImport.targetFiles.map((file) => file.relativePath),
        containsAll([
          'lib/src/features/a/service_stub.dart',
          'lib/src/features/b/service_io.dart',
        ]),
      );
      expect(
        conditionalImport.resolvedTargets
            .singleWhere(
              (target) => target.file.relativePath.endsWith('service_io.dart'),
            )
            .uri,
        '../b/service_io.dart',
      );
      expect(classes.findings, hasLength(1));
      expect(slices.findings, hasLength(1));
      expect(slices.findings.single.message, contains('Slice a depends on b'));
      expect(uriRule.findings, hasLength(1));
      expect(uriRule.findings.single.message, contains('../b/service_io.dart'));
      expect(layers.findings, hasLength(1));
      expect(layers.findings.single.message, contains('via ../b/service_io.dart'));
      expect(layers.findings.single.message, isNot(contains('via service_stub.dart')));
    });

    test('layer rule reports every problematic file', () {
      final project = importArchitectureFixture('layered_architecture');

      final result = Heimdall.layers()
          .layer('Widget')
          .definedBy(const ['..view/widget..'])
          .layer('View')
          .definedBy(const ['..view..'])
          .layer('Cubit')
          .definedBy(const ['..cubit..'])
          .layer('State')
          .definedBy(const ['..state..'])
          .layer('UseCase')
          .definedBy(const ['..use_case..'])
          .layer('Repository')
          .definedBy(const ['data/repository'])
          .layer('Service')
          .definedBy(const ['data/service'])
          .layer('DTO')
          .definedBy(const ['..dto..'])
          .consideringOnlyDependenciesInLayers()
          .whereLayer('Widget')
          .mayOnlyAccessLayers(const [
            'UseCase',
            'Widget',
            'Cubit',
            'State',
            'DTO',
          ])
          .whereLayer('View')
          .mayOnlyAccessLayers(const [
            'UseCase',
            'View',
            'Widget',
            'Cubit',
            'State',
            'DTO',
          ])
          .whereLayer('Cubit')
          .mayOnlyAccessLayers(const [
            'Cubit',
            'UseCase',
            'Repository',
            'State',
            'DTO',
          ])
          .whereLayer('State')
          .mayOnlyAccessLayers(const ['State', 'DTO'])
          .whereLayer('UseCase')
          .mayOnlyAccessLayers(const ['UseCase', 'Repository', 'DTO'])
          .whereLayer('Repository')
          .mayOnlyAccessLayers(const ['Repository', 'Service', 'DTO'])
          .whereLayer('Service')
          .mayOnlyAccessLayers(const ['Service', 'DTO'])
          .whereLayer('DTO')
          .mayOnlyAccessLayers(const ['DTO'])
          .asRule()
          .as('Layered architecture (View -> Cubit -> UseCase -> Repository -> Service)')
          .check(project);

      expect(result.checkedCount, 8);
      expect(result.findings, hasLength(8));
      expect(
        result.findings.map((finding) => finding.message),
        containsAll([
          contains('UserWidget in layer Widget may not access Repository'),
          contains('UserPage in layer View may not access Service'),
          contains('UserCubit in layer Cubit may not access Service'),
          contains('UserState in layer State may not access Cubit'),
          contains('LoadUserUseCase in layer UseCase may not access Service'),
          contains('UserRepository in layer Repository may not access UseCase'),
          contains('UserService in layer Service may not access Repository'),
          contains('UserDto in layer DTO may not access Cubit'),
        ]),
      );
      expect(
        result.findings.map((finding) => finding.filePath?.replaceAll(r'\', '/')).whereType<String>(),
        containsAll([
          endsWith('view/widget/user_widget.dart'),
          endsWith('view/user_page.dart'),
          endsWith('cubit/user_cubit.dart'),
          endsWith('state/user_state.dart'),
          endsWith('use_case/load_user_use_case.dart'),
          endsWith('data/repository/user_repository.dart'),
          endsWith('data/service/user_service.dart'),
          endsWith('dto/user_dto.dart'),
        ]),
      );
    });

    test('file-level dependency sights report each offending import once', () {
      final project = importArchitectureFixture('duplicate_file_import');

      final result = Heimdall.dependencies().noFilesShouldDependOnUpperDirectories().check(project);

      expect(result.checkedCount, 2);
      expect(result.findings, hasLength(1));
      expect(
        result.findings.single.message,
        contains('lib/src/data/repositories.dart imports ../domain/user.dart'),
      );
    });

    test('slice cycle rules report project cycles', () {
      final project = importArchitectureFixture('realm_cycle');

      final result = Heimdall.slices(
        'lib/src/features/(*)',
      ).shouldBeFreeOfCycles().check(project);

      expect(result.checkedCount, 1);
      expect(result.findings, hasLength(1));
    });

    test('slice rules only capture paths that match the complete pattern', () {
      final project = importArchitectureFixture('realm_cycle');

      final result = Heimdall.slices(
        'lib/src/features/(*)/domain/**',
      ).shouldBeFreeOfCycles().check(project);

      expect(result.checkedCount, 1);
      expect(result.findings, isEmpty);
    });

    test('checks slice architecture rules', () {
      final project = importArchitectureFixture('onion_slices');

      final slices = Heimdall.slices(
        'lib/src/(*)',
      ).shouldNotDependOnEachOther().check(project);

      expect(slices.findings, isNotEmpty);
    });

    test('slice rules include files with only top-level declarations', () {
      final project = importArchitectureFixture('top_level_slice_dependency');

      final result = Heimdall.slices(
        'lib/src/features/(*)',
      ).shouldNotDependOnEachOther().check(project);

      expect(result.findings, hasLength(1));
      expect(result.findings.single.message, contains('Slice a depends on b'));
    });
  });

  group('Architecture sample fixtures', () {
    const featureRoot = 'lib/src/features/(*)';
    const modelPath = '$featureRoot/model/*.dart';
    const repositoryPath = '$featureRoot/repository/*.dart';
    const viewModelPath = '$featureRoot/view_model/*.dart';
    const viewPath = '$featureRoot/view/*.dart';

    HeimdallLayers mvvmLayers() {
      return Heimdall.layers()
          .layer('View')
          .definedBy([viewPath])
          .layer('ViewModel')
          .definedBy([viewModelPath])
          .layer('Repository')
          .definedBy([repositoryPath])
          .layer('Model')
          .definedBy([modelPath])
          .whereLayer('View')
          .mayOnlyAccessLayers(['ViewModel'])
          .whereLayer('ViewModel')
          .mayOnlyAccessLayers(['Model', 'Repository'])
          .whereLayer('Repository')
          .mayOnlyAccessLayers(['Model'])
          .whereLayer('Model')
          .mayNotAccessAnyLayer();
    }

    HeimdallProject importFixture(String name) {
      return const HeimdallFileImporter(useCache: false).importPath(
        'test/$name',
      );
    }

    test(
      'checks the MVVM-shaped fixture without treating it as fully correct Flutter',
      () {
        final project = importFixture('flutter_mvvm_architecture');

        final layers = mvvmLayers().asRule().check(project);
        final views = Heimdall.classes().that().resideInPath(viewPath).should().haveTypeNameEndingWith('Page').check(project);
        final viewModels = Heimdall.classes().that().resideInPath(viewModelPath).should().haveTypeNameEndingWith('ViewModel').check(project);
        final repositories = Heimdall.classes().that().resideInPath(repositoryPath).should().haveTypeNameEndingWith('Repository').check(project);
        final immutableState = Heimdall.classes().should().haveOnlyFinalFields().check(project);
        final flutterWidgetNaming = Heimdall.classes()
            .that()
            .areAssignableTo('Widget')
            .should()
            .haveTypeNameEndingWith('Widget')
            .as('Flutter widgets should end with Widget')
            .check(project);

        expect(project.files, hasLength(4));
        expect(layers.checkedCount, 4);
        expect(layers.findings, isEmpty);
        expect(views.findings, isEmpty);
        expect(viewModels.findings, isEmpty);
        expect(repositories.findings, isEmpty);
        expect(immutableState.findings, hasLength(1));
        expect(
          immutableState.findings.single.message,
          contains('TodoRepository declares no fields'),
        );
        expect(flutterWidgetNaming.findings, isNotEmpty);
        expect(
          flutterWidgetNaming.findings.single.message,
          contains('Rule .that() predicate matched no items'),
        );
      },
    );

    test('reports concrete violations in a problematic architecture', () {
      final project = importFixture('problematic_architecture');

      final layers = mvvmLayers().asRule().check(project);
      final views = Heimdall.classes().that().resideInPath(viewPath).should().haveTypeNameEndingWith('Page').check(project);
      final viewModels = Heimdall.classes().that().resideInPath(viewModelPath).should().haveTypeNameEndingWith('ViewModel').check(project);
      final immutableState = Heimdall.classes().should().haveOnlyFinalFields().check(project);

      expect(project.files, hasLength(4));
      expect(layers.findings, hasLength(5));
      expect(
        layers.findings.map((finding) => finding.message),
        containsAll([
          contains('Todo in layer Model may not access ViewModel'),
          contains('TodoRepository in layer Repository may not access View'),
          contains('TodoPresenter in layer ViewModel may not access View'),
          contains('TodoWidget in layer View may not access Model'),
          contains('TodoWidget in layer View may not access Repository'),
        ]),
      );
      expect(views.findings, hasLength(1));
      expect(
        views.findings.single.message,
        contains('TodoWidget should end with Page'),
      );
      expect(viewModels.findings, hasLength(1));
      expect(
        viewModels.findings.single.message,
        contains('TodoPresenter should end with ViewModel'),
      );
      expect(immutableState.findings, hasLength(2));
      expect(
        immutableState.findings.map((finding) => finding.message),
        containsAll([
          contains('Todo.id is not final'),
          contains('TodoWidget.selectedTodo is not final'),
        ]),
      );
    });
  });
}
