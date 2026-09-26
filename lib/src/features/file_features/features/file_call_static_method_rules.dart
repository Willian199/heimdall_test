import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/file_features/helpers/source_file_location.dart';
import 'package:heimdall_test/src/features/queries/static_method_queries.dart';

/// Predicate-side DSL for static method invocation rules.
extension FileCallStaticMethodPredicateRules on FilePredicateBuilder {
  /// Selects files that call [methodName] on [targetType].
  FilePredicateBuilder callStaticMethod(String targetType, String methodName) {
    return satisfy(_fileCallsStaticMethod(targetType, methodName));
  }

  /// Selects files that do not call [methodName] on [targetType].
  FilePredicateBuilder notCallStaticMethod(
    String targetType,
    String methodName,
  ) {
    return satisfy(_fileDoesNotCallStaticMethod(targetType, methodName));
  }

  /// Selects files that call every method in [methodNames] on [targetType].
  FilePredicateBuilder callAllStaticMethods(
    String targetType,
    Iterable<String> methodNames,
  ) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallPredicate.allOf(
        methodList.map((methodName) => _fileCallsStaticMethod(targetType, methodName)),
        description: 'call all static methods ${methodList.join(', ')} on $targetType',
      ),
    );
  }

  /// Selects files that call at least one method in [methodNames] on [targetType].
  FilePredicateBuilder callAnyStaticMethod(
    String targetType,
    Iterable<String> methodNames,
  ) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        methodList.map((methodName) => _fileCallsStaticMethod(targetType, methodName)),
        description: 'call any static method ${methodList.join(', ')} on $targetType',
      ),
    );
  }

  /// Selects files that call no methods in [methodNames] on [targetType].
  FilePredicateBuilder callNoStaticMethods(
    String targetType,
    Iterable<String> methodNames,
  ) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        methodList.map((methodName) => _fileCallsStaticMethod(targetType, methodName)),
        description: 'call no static methods ${methodList.join(', ')} on $targetType',
      ),
    );
  }
}

/// Condition-side DSL for static method invocation rules.
extension FileCallStaticMethodShouldRules on FileShouldBuilder {
  /// Requires matching files to call [methodName] on [targetType].
  HeimdallRule<HeimdallSourceFile> callStaticMethod(
    String targetType,
    String methodName,
  ) {
    return satisfy(_fileShouldCallStaticMethod(targetType, methodName));
  }

  /// Requires matching files to not call [methodName] on [targetType].
  HeimdallRule<HeimdallSourceFile> notCallStaticMethod(
    String targetType,
    String methodName,
  ) {
    return satisfy(_fileShouldNotCallStaticMethod(targetType, methodName));
  }

  /// Requires matching files to call every method in [methodNames] on [targetType].
  HeimdallRule<HeimdallSourceFile> callAllStaticMethods(
    String targetType,
    Iterable<String> methodNames,
  ) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallCondition.allOf(
        methodList.map((methodName) => _fileShouldCallStaticMethod(targetType, methodName)),
        description: 'call all static methods ${methodList.join(', ')} on $targetType',
      ),
    );
  }

  /// Requires matching files to call at least one method in [methodNames] on [targetType].
  HeimdallRule<HeimdallSourceFile> callAnyStaticMethod(
    String targetType,
    Iterable<String> methodNames,
  ) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallCondition.anyOf(
        methodList.map((methodName) => _fileShouldCallStaticMethod(targetType, methodName)),
        description: 'call any static method ${methodList.join(', ')} on $targetType',
      ),
    );
  }

  /// Requires matching files to call no methods in [methodNames] on [targetType].
  HeimdallRule<HeimdallSourceFile> callNoStaticMethods(
    String targetType,
    Iterable<String> methodNames,
  ) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallCondition.noneOf(
        methodList.map((methodName) => _fileShouldCallStaticMethod(targetType, methodName)),
        description: 'call no static methods ${methodList.join(', ')} on $targetType',
      ),
    );
  }
}

HeimdallCondition<HeimdallSourceFile> _fileShouldCallStaticMethod(
  String targetType,
  String methodName,
) {
  return HeimdallCondition('call static method $targetType.$methodName', (
    item,
    project,
  ) {
    final findings = _callsStaticMethod(item, targetType, methodName, project)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              message: 'does not call static method $targetType.$methodName',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<HeimdallSourceFile> _fileCallsStaticMethod(
  String targetType,
  String methodName,
) {
  return HeimdallPredicate(
    'call static method $targetType.$methodName',
    (item, project) => _callsStaticMethod(item, targetType, methodName, project),
  );
}

bool _callsStaticMethod(
  HeimdallSourceFile item,
  String targetType,
  String methodName,
  HeimdallProject project,
) {
  return item.declarations.any(
    (declaration) => astNodeHasStaticMethodInvocation(declaration, targetType, methodName, project),
  );
}

HeimdallPredicate<HeimdallSourceFile> _fileDoesNotCallStaticMethod(
  String targetType,
  String methodName,
) {
  return HeimdallPredicate(
    'not call static method $targetType.$methodName',
    (item, project) => !_callsStaticMethod(item, targetType, methodName, project),
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldNotCallStaticMethod(
  String targetType,
  String methodName,
) {
  return HeimdallCondition('not call static method $targetType.$methodName', (item, project) {
    final findings = _staticMethodInvocations(item, targetType, methodName, project)
        .map(
          (invocation) => fileNodeFinding(
            item,
            invocation,
            'calls forbidden static method $targetType.$methodName',
            offset: staticMethodInvocationNameOffset(invocation),
          ),
        )
        .toList();
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

Iterable<AstNode> _staticMethodInvocations(
  HeimdallSourceFile item,
  String targetType,
  String methodName,
  HeimdallProject project,
) sync* {
  for (final declaration in item.declarations) {
    yield* astNodeStaticMethodInvocations(declaration, targetType, methodName, project);
  }
}
