import 'package:heimdall_test/heimdall_test.dart';

HeimdallCondition<HeimdallSourceFile> extensionsDeclareMethods({
  required Iterable<String> builderNames,
  required int target,
  required String ruleGroupName,
}) {
  return HeimdallCondition(
    'declare $target methods per $ruleGroupName rule extension',
    (file, _) {
      final findings = [
        for (final builderName in builderNames) ...extensionMethodFindings(file, builderName, target),
      ];
      return HeimdallFindings(
        subject: file,
        passed: findings.isEmpty,
        findings: findings,
      );
    },
  );
}

HeimdallCondition<HeimdallSourceFile> exportEveryFeature({
  required HeimdallProject project,
  required String featurePathPattern,
  required String ruleGroupName,
}) {
  final expectedExports = featureFiles(project, featurePathPattern).map((file) => 'features/${basename(file.relativePath)}').toList();

  return HeimdallCondition('export every $ruleGroupName rule feature', (file, _) {
    final findings = <HeimdallValidationInfo>[];
    if (expectedExports.isEmpty) {
      findings.add(
        HeimdallValidationInfo(
          filePath: file.absolutePath,
          message: 'No $ruleGroupName rule feature files matched $featurePathPattern',
        ),
      );
      return HeimdallFindings(
        subject: file,
        passed: false,
        findings: findings,
      );
    }

    final actualExports = file.dependencies.whereType<ExportDirective>().map((directive) => directive.targetUri).whereType<String>().toSet();
    findings.addAll(
      expectedExports
          .where((export) => !actualExports.contains(export))
          .map(
            (export) => HeimdallValidationInfo(
              filePath: file.absolutePath,
              message: '${file.relativePath} does not export $export',
            ),
          ),
    );
    return HeimdallFindings(
      subject: file,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<HeimdallSourceFile> extensionsDeclareSingularBaseInverse({
  required Iterable<String> builderNames,
  required String ruleGroupName,
}) {
  return HeimdallCondition(
    'declare a singular inverse for the base $ruleGroupName rule method',
    (file, _) {
      final findings = [
        for (final builderName in builderNames)
          for (final extension in _extensionsOn(file, builderName))
            if (!_hasSingularBaseInverse(extension))
              HeimdallValidationInfo(
                filePath: file.absolutePath,
                line: extension.line,
                message:
                    '${file.relativePath} extension ${extension.name?.lexeme ?? '<anonymous>'} '
                    'on $builderName does not declare a singular base inverse method',
              ),
      ];
      return HeimdallFindings(
        subject: file,
        passed: findings.isEmpty,
        findings: findings,
      );
    },
  );
}

HeimdallCondition<HeimdallSourceFile> predicateDescriptionsAreReadable({
  required String ruleGroupName,
}) {
  return HeimdallCondition(
    'declare readable $ruleGroupName predicate descriptions',
    (file, _) {
      final findings = [
        for (final declaration in file.declarations)
          for (final creation in _instanceCreationsOf(declaration, 'HeimdallPredicate'))
            if (_hasGeneratedPredicateDescription(creation, ruleGroupName))
              HeimdallValidationInfo(
                filePath: file.absolutePath,
                line: _lineAtOffset(file, creation.offset),
                message:
                    '${file.relativePath} declares a HeimdallPredicate description '
                    'that looks like a generated helper name: ${creation.argumentList.arguments.first.toSource()}',
              ),
      ];
      return HeimdallFindings(
        subject: file,
        passed: findings.isEmpty,
        findings: findings,
      );
    },
  );
}

HeimdallCondition<HeimdallSourceFile> conditionDescriptionsAreReadable({
  required String ruleGroupName,
}) {
  return HeimdallCondition(
    'declare readable $ruleGroupName condition descriptions',
    (file, _) {
      final findings = [
        for (final declaration in file.declarations) ...[
          for (final creation in _instanceCreationsOf(declaration, 'HeimdallCondition'))
            if (_hasGeneratedDescription(creation.argumentList.arguments.firstOrNull, ruleGroupName))
              _unreadableDescriptionFinding(
                file,
                creation.offset,
                'HeimdallCondition',
                creation.argumentList.arguments.first,
              ),
          for (final invocation in _functionInvocationsOf(declaration))
            if (_conditionHelperNames.contains(invocation.methodName.name) &&
                _hasGeneratedDescription(invocation.argumentList.arguments.firstOrNull, ruleGroupName))
              _unreadableDescriptionFinding(
                file,
                invocation.offset,
                invocation.methodName.name,
                invocation.argumentList.arguments.first,
              ),
        ],
      ];
      return HeimdallFindings(
        subject: file,
        passed: findings.isEmpty,
        findings: findings,
      );
    },
  );
}

HeimdallCondition<HeimdallSourceFile> featureExtensionMethodsUseExplicitInverses({
  required Iterable<String> builderNames,
  required String ruleGroupName,
}) {
  return HeimdallCondition(
    'use explicit $ruleGroupName feature inverses',
    (file, _) {
      final findings = [
        for (final builderName in builderNames)
          for (final extension in _extensionsOn(file, builderName))
            for (final method in extension.body.members.whereType<MethodDeclaration>())
              if (_callsGenericNot(method.body))
                HeimdallValidationInfo(
                  filePath: file.absolutePath,
                  line: method.line,
                  message:
                      '${file.relativePath} method ${method.name.lexeme} on $builderName '
                      'uses generic negation instead of an explicit inverse helper',
                ),
      ];
      return HeimdallFindings(
        subject: file,
        passed: findings.isEmpty,
        findings: findings,
      );
    },
  );
}

void assertFeatureExtensionVariantCallsStaticMethods({
  required HeimdallProject project,
  required String featurePathPattern,
  required String builderName,
  required String targetType,
}) {
  _assertFeatureExtensionVariantCallsStaticMethod(
    project: project,
    featurePathPattern: featurePathPattern,
    builderName: builderName,
    methodNamePattern: RegExp(r'All([A-Z]|$)'),
    targetType: targetType,
    staticMethodName: 'allOf',
  );
  _assertFeatureExtensionVariantCallsStaticMethod(
    project: project,
    featurePathPattern: featurePathPattern,
    builderName: builderName,
    methodNamePattern: RegExp(r'Any([A-Z]|$)'),
    targetType: targetType,
    staticMethodName: 'anyOf',
  );
  _assertFeatureExtensionVariantCallsStaticMethod(
    project: project,
    featurePathPattern: featurePathPattern,
    builderName: builderName,
    methodNamePattern: RegExp(r'None([A-Z]|$)'),
    targetType: targetType,
    staticMethodName: 'noneOf',
  );
}

void _assertFeatureExtensionVariantCallsStaticMethod({
  required HeimdallProject project,
  required String featurePathPattern,
  required String builderName,
  required RegExp methodNamePattern,
  required String targetType,
  required String staticMethodName,
}) {
  Heimdall.members()
      .that()
      .resideInPath(featurePathPattern)
      .and()
      .areDeclaredInExtensions(builderName)
      .and()
      .haveNameMatching(methodNamePattern)
      .should()
      .callStaticMethod(targetType, staticMethodName)
      .check(project)
      .assertNoFindings();
}

Iterable<ExtensionDeclaration> _extensionsOn(
  HeimdallSourceFile file,
  String builderName,
) {
  return file.declarations.whereType<ExtensionDeclaration>().where(
    (declaration) => declaration.onClause?.extendedType.toSource() == builderName,
  );
}

Iterable<HeimdallValidationInfo> extensionMethodFindings(
  HeimdallSourceFile file,
  String builderName,
  int target,
) sync* {
  for (final extension in _extensionsOn(file, builderName)) {
    final methodCount = extension.body.members.whereType<MethodDeclaration>().length;

    if (methodCount == target) continue;

    yield HeimdallValidationInfo(
      filePath: file.absolutePath,
      line: extension.line,
      message:
          '${file.relativePath} extension ${extension.name?.lexeme ?? '<anonymous>'} '
          'on $builderName declares $methodCount methods, expected $target',
    );
  }
}

bool _hasSingularBaseInverse(ExtensionDeclaration extension) {
  final methods = extension.body.members.whereType<MethodDeclaration>().toList();
  if (methods.length < 2) return false;

  final baseName = methods.first.name.lexeme;
  if (baseName.startsWith('not')) return true;

  return methods.skip(1).any((method) {
    final methodName = method.name.lexeme;
    if (methodName == baseName || _isVariantMethod(methodName)) return false;
    return !_callsForbiddenNegation(method.body);
  });
}

bool _isVariantMethod(String methodName) {
  return RegExp('(All|Any|None|No)[A-Z]').hasMatch(methodName);
}

bool _callsForbiddenNegation(AstNode node) {
  if (node is MethodInvocation && node.methodName.name == 'not') return true;
  if (node is MethodInvocation &&
      node.methodName.name == 'noneOf' &&
      node.target is SimpleIdentifier &&
      const {'HeimdallPredicate', 'HeimdallCondition'}.contains((node.target! as SimpleIdentifier).name)) {
    return true;
  }
  return node.childEntities.whereType<AstNode>().any(_callsForbiddenNegation);
}

bool _callsGenericNot(AstNode node) {
  if (node is MethodInvocation && node.methodName.name == 'not') return true;
  return node.childEntities.whereType<AstNode>().any(_callsGenericNot);
}

Iterable<InstanceCreationExpression> _instanceCreationsOf(
  AstNode root,
  String typeName,
) sync* {
  if (root is InstanceCreationExpression && root.constructorName.type.toSource() == typeName) {
    yield root;
  }

  for (final child in root.childEntities.whereType<AstNode>()) {
    yield* _instanceCreationsOf(child, typeName);
  }
}

bool _hasGeneratedPredicateDescription(
  InstanceCreationExpression creation,
  String ruleGroupName,
) {
  return _hasGeneratedDescription(creation.argumentList.arguments.firstOrNull, ruleGroupName);
}

bool _hasGeneratedDescription(Expression? description, String ruleGroupName) {
  if (description == null) return false;

  final descriptionSource = description.toSource();
  final generatedDescriptionPattern = RegExp(
    "'${RegExp.escape(ruleGroupName)}(?:Matches|Does|Should|Must|Have|Be|Call|Access|Receive|Reside|Declare)[A-Z]",
  );
  final satisfiesBuilderMethodPattern = RegExp("'satisfy [a-z][A-Za-z0-9_]*'");
  return generatedDescriptionPattern.hasMatch(descriptionSource) || satisfiesBuilderMethodPattern.hasMatch(descriptionSource);
}

Iterable<MethodInvocation> _functionInvocationsOf(AstNode root) sync* {
  if (root is MethodInvocation && root.target == null) {
    yield root;
  }

  for (final child in root.childEntities.whereType<AstNode>()) {
    yield* _functionInvocationsOf(child);
  }
}

HeimdallValidationInfo _unreadableDescriptionFinding(
  HeimdallSourceFile file,
  int offset,
  String source,
  Expression description,
) {
  return HeimdallValidationInfo(
    filePath: file.absolutePath,
    line: _lineAtOffset(file, offset),
    message:
        '${file.relativePath} declares a $source description '
        'that looks like a generated helper name: ${description.toSource()}',
  );
}

int _lineAtOffset(HeimdallSourceFile file, int offset) {
  final end = offset < 0
      ? 0
      : offset > file.content.length
      ? file.content.length
      : offset;
  return '\n'.allMatches(file.content.substring(0, end)).length + 1;
}

List<HeimdallSourceFile> featureFiles(
  HeimdallProject project,
  String featurePathPattern,
) {
  return project.files.where((file) => pathMatches(file.relativePath, featurePathPattern)).toList()
    ..sort((a, b) => a.relativePath.compareTo(b.relativePath));
}

String basename(String path) {
  return path.replaceAll(r'\', '/').split('/').last;
}

const _conditionHelperNames = {
  'memberCondition',
  'prohibitedMemberCondition',
};

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
