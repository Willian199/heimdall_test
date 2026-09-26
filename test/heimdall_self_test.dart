import 'package:heimdall_test/heimdall_test.dart';

import 'package:test/test.dart';

void main() {
  group('Heimdall self architecture', () {
    late final HeimdallProject project;

    setUpAll(() {
      HeimdallFileImporter.clearCache();
      project = const HeimdallFileImporter(useCache: false).importPath();
    });

    test('imports its own package library surface', () {
      expect(project.packageName, 'heimdall_test');
      expect(project.files, isNotEmpty);
      expect(
        project.files.map((file) => file.relativePath),
        everyElement(endsWith('.dart')),
      );

      expect(project.fileByRelativePath('heimdall_test.dart'), isNotNull);
      expect(
        project.typeDeclarations.map((declaration) => declaration.name),
        containsAll([
          'HeimdallFileImporter',
          'Heimdall',
          'HeimdallProject',
          'HeimdallRule',
        ]),
      );
    });

    test(
      'keeps all package sources parseable and free of forbidden directives',
      () {
        Heimdall.code().shouldParse().check(project).assertNoFindings();
        Heimdall.code().shouldNotImportDartMirrors().check(project).assertNoFindings();
        Heimdall.code().shouldNotUsePartOf().check(project).assertNoFindings();
        Heimdall.code().shouldNotImportPackage('heimdall').check(project).assertNoFindings();
      },
    );

    test('keeps public barrels exporting only package library entrypoints', () {
      Heimdall.code()
          .barrelFilesShouldOnlyExport(
            barrelPattern: '*.dart',
            allowedExportPatterns: [
              'heimdall.dart',
              'src/*.dart',
              'src/features/*_features/export.dart',
            ],
          )
          .check(project)
          .assertNoFindings();
    });

    test('keeps Dart source content reads inside importer parsing code', () {
      Heimdall.noFiles()
          .that()
          .satisfy(
            HeimdallPredicate(
              'are production files outside importer parsing code',
              (file, _) =>
                  file.relativePath != 'src/mapper/importer/importer.dart' && file.relativePath != 'src/mapper/importer/source_file_parser.dart',
            ),
          )
          .should()
          .containAllSource([
            'final content = file.readAsStringSync();',
            'parseFile(',
          ])
          .check(project)
          .assertNoFindings();
    });

    test('keeps built-in sight classes final', () {
      Heimdall.classes()
          .that()
          .resideInPath('src/library/**')
          .and()
          .haveTypeNameStartingWith('Heimdall')
          .and()
          .satisfy(HeimdallPredicate('are class declarations', (item, _) => item is ClassDeclaration))
          .should()
          .beFinal()
          .check(project)
          .assertNoFindings();
    });

    test('keeps built-in rule APIs free of meaningless wrappers', () {
      Heimdall.classes().that().resideInPath('src/library/**').should().satisfy(_notHaveMeaninglessRuleWrappers()).check(project).assertNoFindings();
    });

    test('keeps source file and type names conventional', () {
      Heimdall.files().that().resideInPath('src/**').should().haveNameMatching(RegExp(r'^[a-z][a-z0-9_]*\.dart$')).check(project).assertNoFindings();

      Heimdall.classes().that().resideInPath('src/**').should().satisfy(_havePascalCasePublicTypeNames()).check(project).assertNoFindings();
    });

    test('keeps core rule files named after their public rule class', () {
      const rulePaths = [
        'src/core/class_rules/**',
        'src/core/file_rules/**',
        'src/core/member_rules/**',
      ];

      for (final path in rulePaths) {
        Heimdall.files()
            .that()
            .resideInPath(path)
            .and()
            .resideOutsideOfPath('src/core/heimdall_builder_contracts.dart')
            .and()
            .resideOutsideOfPath('src/core/**/features/**')
            .and()
            .resideOutsideOfPath('src/core/member_rules/member_rules.dart')
            .should()
            .haveAtMostOnePublicClass()
            .check(project)
            .assertNoFindings();

        Heimdall.files()
            .that()
            .resideInPath(path)
            .and()
            .resideOutsideOfPath('src/core/heimdall_builder_contracts.dart')
            .and()
            .resideOutsideOfPath('src/core/**/features/**')
            .and()
            .resideOutsideOfPath('src/core/member_rules/member_rules.dart')
            .should()
            .havePublicClassNameMatchingFileName()
            .check(project)
            .assertNoFindings();
      }
    });

    test('keeps source layers depending in the documented direction', () {
      Heimdall.layers()
          .layer('Public')
          .definedBy(['*.dart'])
          .layer('Core')
          .definedBy([
            'src/core.dart',
            'src/core/(**)',
            'src/mapper/(**)',
          ])
          .layer('Dsl')
          .definedBy([
            'src/dsl.dart',
            'src/heimdall.dart',
            'src/dsl/(**)',
          ])
          .layer('Library')
          .definedBy(['src/library_rules.dart', 'src/library/(**)'])
          .layer('Plugins')
          .definedBy(['src/plugins.dart'])
          .whereLayer('Public')
          .mayOnlyAccessLayers(['Core', 'Dsl', 'Library', 'Plugins'])
          .whereLayer('Core')
          .mayOnlyAccessLayers(['Core', 'Dsl'])
          .whereLayer('Dsl')
          .mayOnlyAccessLayers(['Core', 'Dsl', 'Library'])
          .whereLayer('Library')
          .mayOnlyAccessLayers(['Core', 'Dsl', 'Library'])
          .whereLayer('Plugins')
          .mayOnlyAccessLayers(['Core'])
          .asRule()
          .as('Heimdall source layers')
          .check(project)
          .assertNoFindings();
    });
  });
}

HeimdallCondition<CompilationUnitMember> _havePascalCasePublicTypeNames() {
  final pascalCase = RegExp(r'^[A-Z][A-Za-z0-9]*$');
  return HeimdallCondition('have PascalCase public type names', (
    declaration,
    _,
  ) {
    final findings = !declaration.isPublic || pascalCase.hasMatch(declaration.name)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: declaration.sourcePath,
              line: declaration.line,
              message: '${declaration.name} should use PascalCase',
            ),
          ];
    return HeimdallFindings(
      subject: declaration,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _notHaveMeaninglessRuleWrappers() {
  return HeimdallCondition('not have meaningless rule wrappers', (
    declaration,
    _,
  ) {
    final findings = <HeimdallValidationInfo>[];
    for (final method in declaration.members.whereType<MethodDeclaration>()) {
      final wrappedRuleName = _singleReturnedLocalMethodName(method);
      if (wrappedRuleName == null) {
        continue;
      }

      findings.add(
        HeimdallValidationInfo(
          filePath: declaration.sourcePath,
          line: method.line,
          message: '${declaration.name}.${method.name.lexeme} only wraps $wrappedRuleName',
        ),
      );
    }
    return HeimdallFindings(
      subject: declaration,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

String? _singleReturnedLocalMethodName(MethodDeclaration method) {
  final body = method.body;
  if (body is! BlockFunctionBody) {
    return null;
  }

  final statements = body.block.statements.where((statement) => statement is! EmptyStatement).toList();
  if (statements.length != 1) {
    return null;
  }

  final statement = statements.single;
  if (statement is! ReturnStatement) {
    return null;
  }

  final expression = statement.expression;
  if (expression is! MethodInvocation) {
    return null;
  }
  if (expression.target != null) {
    return null;
  }

  final wrappedRuleName = expression.methodName.name;
  if (wrappedRuleName == method.name.lexeme) {
    return null;
  }
  if (wrappedRuleName.startsWith(RegExp('[A-Z]'))) {
    return null;
  }
  return wrappedRuleName;
}
