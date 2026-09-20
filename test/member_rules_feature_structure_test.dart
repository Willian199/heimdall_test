import 'package:heimdall_test/heimdall_test.dart';
import 'package:test/test.dart';

import 'feature_structure_helpers.dart';

const _memberRuleFeaturesPath = 'src/features/member_features/features/*.dart';
const _memberFeaturesExportPath = 'src/features/member_features/export.dart';
const _packageExportPath = 'heimdall_test.dart';

void main() {
  group('Member rule feature structure', () {
    final project = const HeimdallFileImporter(useCache: false).importPath();

    test('imports member rule feature files', () {
      Heimdall.files().that().resideInPath(_memberRuleFeaturesPath).should().haveNoParseErrors().check(project).assertNoFindings();
    });

    test('each feature declares predicate and should extensions', () {
      Heimdall.files()
          .that()
          .resideInPath(_memberRuleFeaturesPath)
          .should()
          .declareExtensionOn('MemberPredicateBuilder')
          .and()
          .declareExtensionOn('MemberShouldBuilder')
          .check(project)
          .assertNoFindings();
    });

    test('each member rule extension exposes a singular base inverse', () {
      Heimdall.files()
          .that()
          .resideInPath(_memberRuleFeaturesPath)
          .should()
          .satisfy(
            extensionsDeclareSingularBaseInverse(
              builderNames: ['MemberPredicateBuilder', 'MemberShouldBuilder'],
              ruleGroupName: 'member',
            ),
          )
          .check(project)
          .assertNoFindings();
    });

    test('predicate descriptions are readable DSL text', () {
      Heimdall.files()
          .that()
          .resideInPath(_memberRuleFeaturesPath)
          .should()
          .satisfy(predicateDescriptionsAreReadable(ruleGroupName: 'member'))
          .check(project)
          .assertNoFindings();
    });

    test('condition descriptions are readable DSL text', () {
      Heimdall.files()
          .that()
          .resideInPath(_memberRuleFeaturesPath)
          .should()
          .satisfy(conditionDescriptionsAreReadable(ruleGroupName: 'member'))
          .check(project)
          .assertNoFindings();
    });

    test('feature methods use explicit inverse helpers', () {
      Heimdall.files()
          .that()
          .resideInPath(_memberRuleFeaturesPath)
          .should()
          .satisfy(
            featureExtensionMethodsUseExplicitInverses(
              builderNames: ['MemberPredicateBuilder', 'MemberShouldBuilder'],
              ruleGroupName: 'member',
            ),
          )
          .check(project)
          .assertNoFindings();
    });

    test('predicate extensions expose all, any, and none variants', () {
      assertFeatureExtensionVariantCallsStaticMethods(
        project: project,
        featurePathPattern: _memberRuleFeaturesPath,
        builderName: 'MemberPredicateBuilder',
        targetType: 'HeimdallPredicate',
      );
    });

    test('should extensions expose all, any, and none variants', () {
      assertFeatureExtensionVariantCallsStaticMethods(
        project: project,
        featurePathPattern: _memberRuleFeaturesPath,
        builderName: 'MemberShouldBuilder',
        targetType: 'HeimdallCondition',
      );
    });

    test('member feature export barrel exports every feature', () {
      Heimdall.files()
          .that()
          .resideInPath(_memberFeaturesExportPath)
          .should()
          .satisfy(
            exportEveryFeature(
              project: project,
              featurePathPattern: _memberRuleFeaturesPath,
              ruleGroupName: 'member',
            ),
          )
          .check(project)
          .assertNoFindings();
    });

    test('package export barrel exports member features barrel', () {
      Heimdall.files()
          .that()
          .resideInPath(_packageExportPath)
          .should()
          .exportUri('src/features/member_features/export.dart')
          .check(project)
          .assertNoFindings();
    });
  });
}
