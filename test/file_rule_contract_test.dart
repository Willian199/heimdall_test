import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

void main() {
  group('File rule DSL contract', () {
    test('keeps predicate and should builder file methods in sync', () {
      final project = const HeimdallFileImporter(useCache: false).importPath();
      final predicateMethods = _publicBuilderMethodNames(
        project,
        relativePath: 'src/core/file_rules/file_predicate_builder.dart',
        className: 'FilePredicateBuilder',
      );
      final shouldMethods = _publicBuilderMethodNames(
        project,
        relativePath: 'src/core/file_rules/file_should_builder.dart',
        className: 'FileShouldBuilder',
      );

      final predicateContractNames = predicateMethods.map(_fileRuleMethodKey).whereType<String>().toSet();
      final shouldContractNames = shouldMethods.map(_fileRuleMethodKey).whereType<String>().toSet();

      expect(
        predicateContractNames.difference(shouldContractNames),
        isEmpty,
        reason: 'Every public FilePredicateBuilder file rule method must have a matching FileShouldBuilder method.',
      );
      expect(
        shouldContractNames.difference(predicateContractNames),
        isEmpty,
        reason: 'Every public FileShouldBuilder file rule method must have a matching FilePredicateBuilder method.',
      );
    });

    test('keeps two-sided file rule feature methods in sync', () {
      final project = const HeimdallFileImporter(useCache: false).importPath();
      final predicateMethods = _publicTwoSidedFeatureMethodNames(
        project,
        builderName: 'FilePredicateBuilder',
      );
      final shouldMethods = _publicTwoSidedFeatureMethodNames(
        project,
        builderName: 'FileShouldBuilder',
      );

      final predicateContractNames = predicateMethods.map(_fileRuleMethodKey).whereType<String>().toSet();
      final shouldContractNames = shouldMethods.map(_fileRuleMethodKey).whereType<String>().toSet();

      expect(
        predicateContractNames.difference(shouldContractNames),
        isEmpty,
        reason: 'Every two-sided file predicate feature method must have a matching should feature method.',
      );
      expect(
        shouldContractNames.difference(predicateContractNames),
        isEmpty,
        reason: 'Every two-sided file should feature method must have a matching predicate feature method.',
      );
    });

    test('exposes import URI pattern and policy variants', () {
      final predicate = FilePredicateBuilder(inverted: false);
      final should = Heimdall.files().should();

      predicate
        ..exportUri('domain/user.dart')
        ..exportAllUris(['domain/user.dart'])
        ..exportAnyUri(['missing.dart', 'domain/user.dart'])
        ..exportNoUris(['missing.dart'])
        ..exportUriMatching(RegExp(r'\.dart$'))
        ..exportAllUrisMatching([RegExp(r'\.dart$')])
        ..exportAnyUriMatching([RegExp('missing'), RegExp(r'\.dart$')])
        ..exportNoUrisMatching([RegExp('missing')])
        ..importUriMatching(RegExp('^package:'))
        ..importAllUrisMatching([RegExp('^dart:'), RegExp('^package:')])
        ..importAnyUriMatching([RegExp('^dart:'), RegExp('^package:')])
        ..importNoUrisMatching([RegExp(r'\.g\.dart$')])
        ..useOnlyPackageOrSdkImports()
        ..notUseRelativeImports()
        ..onlyImportFrom(['dart:', 'package:heimdall_test/']);
      should
        ..exportUri('domain/user.dart')
        ..exportAllUris(['domain/user.dart'])
        ..exportAnyUri(['missing.dart', 'domain/user.dart'])
        ..exportNoUris(['missing.dart'])
        ..exportUriMatching(RegExp(r'\.dart$'))
        ..exportAllUrisMatching([RegExp(r'\.dart$')])
        ..exportAnyUriMatching([RegExp('missing'), RegExp(r'\.dart$')])
        ..exportNoUrisMatching([RegExp('missing')])
        ..importUriMatching(RegExp('^package:'))
        ..importAllUrisMatching([RegExp('^dart:'), RegExp('^package:')])
        ..importAnyUriMatching([RegExp('^dart:'), RegExp('^package:')])
        ..importNoUrisMatching([RegExp(r'\.g\.dart$')])
        ..useOnlyPackageOrSdkImports()
        ..notUseRelativeImports()
        ..onlyImportFrom(['dart:', 'package:heimdall_test/']);
    });

    test('exposes file content and library structure variants', () {
      final predicate = FilePredicateBuilder(inverted: false);
      final should = Heimdall.files().should();

      predicate
        ..declareExtensionOn('FilePredicateBuilder')
        ..declareAllExtensionsOn(['FilePredicateBuilder'])
        ..declareAnyExtensionOn(['MissingBuilder', 'FilePredicateBuilder'])
        ..declareNoExtensionsOn(['MissingBuilder'])
        ..callStaticMethod('HeimdallPredicate', 'allOf')
        ..callAllStaticMethods('HeimdallPredicate', ['allOf'])
        ..callAnyStaticMethod('HeimdallPredicate', ['missing', 'allOf'])
        ..callNoStaticMethods('HeimdallPredicate', ['missing'])
        ..haveAtMostTopLevelClasses(1)
        ..haveMoreThanTopLevelClasses(1)
        ..haveAtMostTopLevelClasses(2)
        ..haveMoreThanTopLevelClasses(1)
        ..haveAtMostOnePublicClassNamed('User')
        ..haveMoreThanOnePublicClassNamed('User')
        ..haveNoTopLevelVariables()
        ..haveNoTopLevelFunctions()
        ..haveNoParseErrors()
        ..haveParseErrors()
        ..haveNoParseErrorsMatching(RegExp('syntax'))
        ..haveParseErrorsMatching(RegExp('syntax'))
        ..haveLibraryDirective()
        ..havePartOfDirective()
        ..haveNoPartOfDirective()
        ..beEmpty()
        ..haveDocumentationComment()
        ..haveNoDocumentationComment();
      should
        ..declareExtensionOn('FilePredicateBuilder')
        ..declareAllExtensionsOn(['FilePredicateBuilder'])
        ..declareAnyExtensionOn(['MissingBuilder', 'FilePredicateBuilder'])
        ..declareNoExtensionsOn(['MissingBuilder'])
        ..callStaticMethod('HeimdallPredicate', 'allOf')
        ..callAllStaticMethods('HeimdallPredicate', ['allOf'])
        ..callAnyStaticMethod('HeimdallPredicate', ['missing', 'allOf'])
        ..callNoStaticMethods('HeimdallPredicate', ['missing'])
        ..haveAtMostTopLevelClasses(1)
        ..haveMoreThanTopLevelClasses(1)
        ..haveAtMostTopLevelClasses(2)
        ..haveMoreThanTopLevelClasses(1)
        ..haveAtMostOnePublicClassNamed('User')
        ..haveMoreThanOnePublicClassNamed('User')
        ..haveNoTopLevelVariables()
        ..haveNoTopLevelFunctions()
        ..haveNoParseErrors()
        ..haveParseErrors()
        ..haveNoParseErrorsMatching(RegExp('syntax'))
        ..haveParseErrorsMatching(RegExp('syntax'))
        ..haveLibraryDirective()
        ..havePartOfDirective()
        ..haveNoPartOfDirective()
        ..beEmpty()
        ..haveDocumentationComment()
        ..haveNoDocumentationComment();
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

String? _fileRuleMethodKey(String methodName) {
  const infrastructureMethods = {
    'and',
    'or',
    'should',
    'andShould',
    'orShould',
    'not',
    'satisfy',
    'shouldExist',
    'shouldNotExist',
    'exist',
    'allowEmpty',
    'failOnEmpty',
  };

  if (infrastructureMethods.contains(methodName)) return null;
  return methodName.toLowerCase();
}

Set<String> _publicTwoSidedFeatureMethodNames(
  HeimdallProject project, {
  required String builderName,
}) {
  return project.files
      .where(
        (file) => pathMatches(
          file.relativePath,
          'src/features/file_features/features/*.dart',
        ),
      )
      .where(
        (file) => _extensionsOn(file, 'FilePredicateBuilder').isNotEmpty && _extensionsOn(file, 'FileShouldBuilder').isNotEmpty,
      )
      .expand((file) => _extensionsOn(file, builderName))
      .expand((extension) => extension.body.members)
      .whereType<MethodDeclaration>()
      .map((method) => method.name.lexeme)
      .where((name) => !name.startsWith('_'))
      .toSet();
}

Iterable<ExtensionDeclaration> _extensionsOn(
  HeimdallSourceFile file,
  String builderName,
) {
  return file.declarations.whereType<ExtensionDeclaration>().where(
    (declaration) => declaration.onClause?.extendedType.toSource() == builderName,
  );
}
