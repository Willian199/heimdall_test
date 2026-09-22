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
    (file, project) {
      final findings = [
        for (final builderName in builderNames)
          for (final extension in _extensionsOn(file, builderName))
            if (!_hasSingularBaseInverse(extension, project))
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
  for (final file in featureFiles(project, featurePathPattern)) {
    final helpers = {
      for (final function in file.declarations.whereType<FunctionDeclaration>()) function.name.lexeme: function.functionExpression.toSource(),
    };
    for (final extension in _extensionsOn(file, builderName)) {
      for (final method in extension.body.members.whereType<MethodDeclaration>()) {
        final name = method.name.lexeme;
        // Quantifiers over negative atoms or over targets cannot be inferred
        // from the first All/Any/None word in the English method name.
        final operation = switch (name) {
          'notHaveParseErrorsMatchingAllOf' => 'anyOf',
          'resideOutsideOfAllPathsMatching' => 'noneOf',
          'haveAllImportsShareAnyPrefix' => 'anyOf',
          'haveNoPrefixSharedByAllImports' => 'noneOf',
          _ when RegExp(r'All([A-Z]|$)').hasMatch(name) => 'allOf',
          _ when RegExp(r'Any([A-Z]|$)').hasMatch(name) => 'anyOf',
          _ when RegExp(r'None([A-Z]|$)').hasMatch(name) => 'noneOf',
          _ => null,
        };
        if (operation == null) continue;
        var source = method.body.toSource();
        final visited = <String>{};
        // Follow private helpers rather than requiring redundant combinator
        // wrappers solely to make this structural test pass.
        var expanded = true;
        while (expanded) {
          expanded = false;
          for (final entry in helpers.entries) {
            if (!visited.contains(entry.key) && RegExp('\\b${RegExp.escape(entry.key)}\\b').hasMatch(source)) {
              visited.add(entry.key);
              source += '\n${entry.value}';
              expanded = true;
            }
          }
        }
        final combinatorType = name.startsWith('onlyDependOnClassesMatching') && name.endsWith('NoneOf') ? 'HeimdallPredicate' : targetType;
        if (!source.contains('$combinatorType.$operation(')) {
          throw StateError('${file.relativePath}: $builderName.$name must use $combinatorType.$operation');
        }
      }
    }
  }
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

bool _hasSingularBaseInverse(ExtensionDeclaration extension, HeimdallProject project) {
  final builder = extension.onClause?.extendedType.toSource();
  final firstName = extension.body.members.whereType<MethodDeclaration>().firstOrNull?.name.lexeme;
  // Path inverses live in separate features after removing duplicate aliases.
  final sibling = switch (firstName) {
    'resideInPath' => 'resideOutsideOfPath',
    'resideOutsideOfPath' => 'resideInPath',
    'onlyImportFrom' => 'importFromOutside',
    _ => null,
  };
  if (sibling != null && builder != null) {
    return project.files.any(
      (file) => _extensionsOn(file, builder).any(
        (extension) => extension.body.members.whereType<MethodDeclaration>().any((method) => method.name.lexeme == sibling),
      ),
    );
  }
  final methods = extension.body.members.whereType<MethodDeclaration>().toList();
  if (methods.length < 2) return false;

  final baseName = methods.first.name.lexeme;
  if (baseName.startsWith('not')) return true;

  return methods.skip(1).any((method) {
    final methodName = method.name.lexeme;
    if (methodName == baseName || (method.parameters?.toSource().contains('Iterable<') ?? false)) return false;
    return !_callsForbiddenNegation(method.body);
  });
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
