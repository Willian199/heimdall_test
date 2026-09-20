import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

import 'feature_structure_helpers.dart';

const _fileRuleFeaturesPath = 'src/features/file_features/features/*.dart';
const _fileFeaturesExportPath = 'src/features/file_features/export.dart';
const _packageExportPath = 'heimdall_test.dart';
const List<String> _fileDiagnosticSourcePaths = [
  _fileRuleFeaturesPath,
  'src/features/file_features/helpers/*.dart',
  'src/core/file_rules/*.dart',
  'src/library/code_sight.dart',
];

void main() {
  group('File rule feature structure', () {
    final project = const HeimdallFileImporter(useCache: false).importPath();

    test('imports file rule feature files', () {
      Heimdall.files().that().resideInPath(_fileRuleFeaturesPath).should().haveNoParseErrors().check(project).assertNoFindings();
    });

    test('each feature declares a file rule extension', () {
      Heimdall.files()
          .that()
          .resideInPath(_fileRuleFeaturesPath)
          .should()
          .declareExtensionOn('FilePredicateBuilder')
          .and()
          .declareExtensionOn('FileShouldBuilder')
          .check(project)
          .assertNoFindings();
    });

    test('each file rule extension exposes a singular base inverse', () {
      Heimdall.files()
          .that()
          .resideInPath(_fileRuleFeaturesPath)
          .should()
          .satisfy(
            extensionsDeclareSingularBaseInverse(
              builderNames: ['FilePredicateBuilder', 'FileShouldBuilder'],
              ruleGroupName: 'file',
            ),
          )
          .check(project)
          .assertNoFindings();
    });

    test('predicate descriptions are readable DSL text', () {
      Heimdall.files()
          .that()
          .resideInPath(_fileRuleFeaturesPath)
          .should()
          .satisfy(predicateDescriptionsAreReadable(ruleGroupName: 'file'))
          .check(project)
          .assertNoFindings();
    });

    test('condition descriptions are readable DSL text', () {
      Heimdall.files()
          .that()
          .resideInPath(_fileRuleFeaturesPath)
          .should()
          .satisfy(conditionDescriptionsAreReadable(ruleGroupName: 'file'))
          .check(project)
          .assertNoFindings();
    });

    test('file findings do not repeat the file path in messages', () {
      Heimdall.files()
          .that()
          .resideInAnyPath(_fileDiagnosticSourcePaths)
          .should()
          .containNoSourceMatching([
            RegExp(r"message:\s*'\$\{(?:item|file)\.relativePath\}"),
          ])
          .check(project)
          .assertNoFindings();
    });

    test('feature methods use explicit inverse helpers', () {
      Heimdall.files()
          .that()
          .resideInPath(_fileRuleFeaturesPath)
          .should()
          .satisfy(
            featureExtensionMethodsUseExplicitInverses(
              builderNames: ['FilePredicateBuilder', 'FileShouldBuilder'],
              ruleGroupName: 'file',
            ),
          )
          .check(project)
          .assertNoFindings();
    });

    test('predicate extensions expose all, any, and none variants', () {
      assertFeatureExtensionVariantCallsStaticMethods(
        project: project,
        featurePathPattern: _fileRuleFeaturesPath,
        builderName: 'FilePredicateBuilder',
        targetType: 'HeimdallPredicate',
      );
    });

    test('should extensions expose all, any, and none variants', () {
      assertFeatureExtensionVariantCallsStaticMethods(
        project: project,
        featurePathPattern: _fileRuleFeaturesPath,
        builderName: 'FileShouldBuilder',
        targetType: 'HeimdallCondition',
      );
    });

    test('file feature export barrel exports every feature', () {
      Heimdall.files()
          .that()
          .resideInPath(_fileFeaturesExportPath)
          .should()
          .satisfy(
            exportEveryFeature(
              project: project,
              featurePathPattern: _fileRuleFeaturesPath,
              ruleGroupName: 'file',
            ),
          )
          .check(project)
          .assertNoFindings();
    });

    test('package export barrel exports file features barrel', () {
      Heimdall.files()
          .that()
          .resideInPath(_packageExportPath)
          .should()
          .exportUri('src/features/file_features/export.dart')
          .check(project)
          .assertNoFindings();
    });
  });
}
