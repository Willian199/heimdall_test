import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/file_features/helpers/source_file_location.dart';

/// Predicate-side DSL for declared method rules.
extension FileDeclareMethodPredicateRules on FilePredicateBuilder {
  /// Selects files that declare a function or class method named [methodName].
  FilePredicateBuilder declareMethod(String methodName) {
    return satisfy(_fileDeclaresMethod(methodName));
  }

  /// Selects files that do not declare a function or class method named [methodName].
  FilePredicateBuilder notDeclareMethod(String methodName) {
    return satisfy(_fileDoesNotDeclareMethod(methodName));
  }

  /// Selects files that declare every method in [methodNames].
  FilePredicateBuilder declareAllMethods(Iterable<String> methodNames) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallPredicate.allOf(
        methodList.map(_fileDeclaresMethod),
        description: 'declare all methods ${methodList.join(', ')}',
      ),
    );
  }

  /// Selects files that declare at least one method in [methodNames].
  FilePredicateBuilder declareAnyMethod(Iterable<String> methodNames) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        methodList.map(_fileDeclaresMethod),
        description: 'declare any method ${methodList.join(', ')}',
      ),
    );
  }

  /// Selects files that declare none of [methodNames].
  FilePredicateBuilder declareNoMethods(Iterable<String> methodNames) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        methodList.map(_fileDeclaresMethod),
        description: 'declare no methods ${methodList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for declared method rules.
extension FileDeclareMethodShouldRules on FileShouldBuilder {
  /// Requires matching files to declare a function or class method named [methodName].
  HeimdallRule<HeimdallSourceFile> declareMethod(String methodName) {
    return satisfy(_fileShouldDeclareMethod(methodName));
  }

  /// Requires matching files to not declare a function or class method named [methodName].
  HeimdallRule<HeimdallSourceFile> notDeclareMethod(String methodName) {
    return satisfy(_fileShouldNotDeclareMethod(methodName));
  }

  /// Requires matching files to declare every method in [methodNames].
  HeimdallRule<HeimdallSourceFile> declareAllMethods(
    Iterable<String> methodNames,
  ) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallCondition.allOf(
        methodList.map(_fileShouldDeclareMethod),
        description: 'declare all methods ${methodList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to declare at least one method in [methodNames].
  HeimdallRule<HeimdallSourceFile> declareAnyMethod(
    Iterable<String> methodNames,
  ) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallCondition.anyOf(
        methodList.map(_fileShouldDeclareMethod),
        description: 'declare any method ${methodList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to declare none of [methodNames].
  HeimdallRule<HeimdallSourceFile> declareNoMethods(
    Iterable<String> methodNames,
  ) {
    final methodList = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallCondition.noneOf(
        methodList.map(_fileShouldDeclareMethod),
        description: 'declare no methods ${methodList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<HeimdallSourceFile> _fileShouldDeclareMethod(
  String methodName,
) {
  return HeimdallCondition('declare method $methodName', (item, _) {
    final hasTopLevelFunction = item.topLevelFunctions.any(
      (declaration) => declaration.name.lexeme == methodName,
    );
    final hasClassMethod = item.methods.any(
      (member) => member.name.lexeme == methodName,
    );
    final findings = hasTopLevelFunction || hasClassMethod
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              message: 'does not declare method $methodName',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<HeimdallSourceFile> _fileDeclaresMethod(String methodName) {
  return HeimdallPredicate(
    'declare method $methodName',
    (item, _) => _declaresMethod(item, methodName),
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldNotDeclareMethod(
  String methodName,
) {
  return HeimdallCondition('not declare method $methodName', (item, _) {
    final findings = _matchingMethods(item, methodName)
        .map(
          (match) => fileNodeFinding(
            item,
            match.node,
            'declares forbidden method $methodName',
            offset: match.offset,
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

HeimdallPredicate<HeimdallSourceFile> _fileDoesNotDeclareMethod(
  String methodName,
) {
  return HeimdallPredicate(
    'not declare method $methodName',
    (item, _) => _matchingMethods(item, methodName).isEmpty,
  );
}

bool _declaresMethod(HeimdallSourceFile item, String methodName) {
  final hasTopLevelFunction = item.topLevelFunctions.any(
    (declaration) => declaration.name.lexeme == methodName,
  );
  final hasClassMethod = item.methods.any(
    (member) => member.name.lexeme == methodName,
  );
  return hasTopLevelFunction || hasClassMethod;
}

Iterable<({AstNode node, int offset})> _matchingMethods(
  HeimdallSourceFile item,
  String methodName,
) sync* {
  for (final declaration in item.topLevelFunctions) {
    if (declaration.name.lexeme == methodName) {
      yield (node: declaration, offset: declaration.name.offset);
    }
  }
  for (final member in item.methods) {
    if (member.name.lexeme == methodName) {
      yield (node: member, offset: member.name.offset);
    }
  }
}
