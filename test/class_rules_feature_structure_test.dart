import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

import 'feature_structure_helpers.dart';

const _classRuleFeaturesPath = 'src/features/class_features/features/*.dart';
const _classFeaturesExportPath = 'src/features/class_features/export.dart';
const _packageExportPath = 'heimdall_test.dart';

void main() {
  group('Class rule feature structure', () {
    final project = const HeimdallFileImporter(useCache: false).importPath();

    test('imports class rule feature files', () {
      Heimdall.files().that().resideInPath(_classRuleFeaturesPath).should().haveNoParseErrors().check(project).assertNoFindings();
    });

    test('each feature declares predicate and should extensions', () {
      Heimdall.files()
          .that()
          .resideInPath(_classRuleFeaturesPath)
          .should()
          .declareExtensionOn('ClassPredicateBuilder')
          .and()
          .declareExtensionOn('ClassShouldBuilder')
          .check(project)
          .assertNoFindings();
    });

    test('each class rule extension exposes a singular base inverse', () {
      Heimdall.files()
          .that()
          .resideInPath(_classRuleFeaturesPath)
          .should()
          .satisfy(
            extensionsDeclareSingularBaseInverse(
              builderNames: ['ClassPredicateBuilder', 'ClassShouldBuilder'],
              ruleGroupName: 'class',
            ),
          )
          .check(project)
          .assertNoFindings();
    });

    test('predicate descriptions are readable DSL text', () {
      Heimdall.files()
          .that()
          .resideInPath(_classRuleFeaturesPath)
          .should()
          .satisfy(predicateDescriptionsAreReadable(ruleGroupName: 'class'))
          .check(project)
          .assertNoFindings();
    });

    test('condition descriptions are readable DSL text', () {
      Heimdall.files()
          .that()
          .resideInPath(_classRuleFeaturesPath)
          .should()
          .satisfy(conditionDescriptionsAreReadable(ruleGroupName: 'class'))
          .check(project)
          .assertNoFindings();
    });

    test('feature methods use explicit inverse helpers', () {
      Heimdall.files()
          .that()
          .resideInPath(_classRuleFeaturesPath)
          .should()
          .satisfy(
            featureExtensionMethodsUseExplicitInverses(
              builderNames: ['ClassPredicateBuilder', 'ClassShouldBuilder'],
              ruleGroupName: 'class',
            ),
          )
          .check(project)
          .assertNoFindings();
    });

    test('predicate extensions expose all, any, and none variants', () {
      assertFeatureExtensionVariantCallsStaticMethods(
        project: project,
        featurePathPattern: _classRuleFeaturesPath,
        builderName: 'ClassPredicateBuilder',
        targetType: 'HeimdallPredicate',
      );
    });

    test('should extensions expose all, any, and none variants', () {
      assertFeatureExtensionVariantCallsStaticMethods(
        project: project,
        featurePathPattern: _classRuleFeaturesPath,
        builderName: 'ClassShouldBuilder',
        targetType: 'HeimdallCondition',
      );
    });

    test('class feature export barrel exports every feature', () {
      Heimdall.files()
          .that()
          .resideInPath(_classFeaturesExportPath)
          .should()
          .satisfy(
            exportEveryFeature(
              project: project,
              featurePathPattern: _classRuleFeaturesPath,
              ruleGroupName: 'class',
            ),
          )
          .check(project)
          .assertNoFindings();
    });

    test('package export barrel exports class features barrel', () {
      Heimdall.files()
          .that()
          .resideInPath(_packageExportPath)
          .should()
          .exportUri('src/features/class_features/export.dart')
          .check(project)
          .assertNoFindings();
    });
  });
}
