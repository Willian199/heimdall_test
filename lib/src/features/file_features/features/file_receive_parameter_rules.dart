import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/file_features/helpers/source_file_location.dart';
import 'package:heimdall_test/src/features/queries/parameter_queries.dart';

/// Predicate-side DSL for received parameter rules.
extension FileReceiveParameterPredicateRules on FilePredicateBuilder {
  /// Selects files that receive [parameterName].
  FilePredicateBuilder receiveParameter(String parameterName) {
    return satisfy(_fileReceivesParameter(parameterName));
  }

  /// Selects files that do not receive [parameterName].
  FilePredicateBuilder notReceiveParameter(String parameterName) {
    return satisfy(_fileDoesNotReceiveParameter(parameterName));
  }

  /// Selects files that receive every parameter in [parameterNames].
  FilePredicateBuilder receiveAllParameters(Iterable<String> parameterNames) {
    final parameterList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallPredicate.allOf(
        parameterList.map(_fileReceivesParameter),
        description: 'receive all parameters ${parameterList.join(', ')}',
      ),
    );
  }

  /// Selects files that receive at least one parameter in [parameterNames].
  FilePredicateBuilder receiveAnyParameter(Iterable<String> parameterNames) {
    final parameterList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        parameterList.map(_fileReceivesParameter),
        description: 'receive any parameter ${parameterList.join(', ')}',
      ),
    );
  }

  /// Selects files that receive none of [parameterNames].
  FilePredicateBuilder receiveNoParameters(Iterable<String> parameterNames) {
    final parameterList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        parameterList.map(_fileReceivesParameter),
        description: 'receive no parameters ${parameterList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for received parameter rules.
extension FileReceiveParameterShouldRules on FileShouldBuilder {
  /// Requires matching files to receive [parameterName].
  HeimdallRule<HeimdallSourceFile> receiveParameter(String parameterName) {
    return satisfy(_fileShouldReceiveParameter(parameterName));
  }

  /// Requires matching files to not receive [parameterName].
  HeimdallRule<HeimdallSourceFile> notReceiveParameter(String parameterName) {
    return satisfy(_fileShouldNotReceiveParameter(parameterName));
  }

  /// Requires matching files to receive every parameter in [parameterNames].
  HeimdallRule<HeimdallSourceFile> receiveAllParameters(
    Iterable<String> parameterNames,
  ) {
    final parameterList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallCondition.allOf(
        parameterList.map(_fileShouldReceiveParameter),
        description: 'receive all parameters ${parameterList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to receive at least one parameter in [parameterNames].
  HeimdallRule<HeimdallSourceFile> receiveAnyParameter(
    Iterable<String> parameterNames,
  ) {
    final parameterList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallCondition.anyOf(
        parameterList.map(_fileShouldReceiveParameter),
        description: 'receive any parameter ${parameterList.join(', ')}',
      ),
    );
  }

  /// Requires matching files to receive none of [parameterNames].
  HeimdallRule<HeimdallSourceFile> receiveNoParameters(
    Iterable<String> parameterNames,
  ) {
    final parameterList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallCondition.noneOf(
        parameterList.map(_fileShouldReceiveParameter),
        description: 'receive no parameters ${parameterList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<HeimdallSourceFile> _fileShouldReceiveParameter(
  String parameterName,
) {
  return HeimdallCondition('receive parameter $parameterName', (item, _) {
    final hasParameter = _executableParameters(item).any(
      (parameter) => isPositionalOrRequiredNamedParameter(
        parameter,
        parameterName,
      ),
    );
    final findings = hasParameter
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.absolutePath,
              message: 'does not receive parameter $parameterName',
            ),
          ];
    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<HeimdallSourceFile> _fileReceivesParameter(
  String parameterName,
) {
  return HeimdallPredicate(
    'receive parameter $parameterName',
    (item, _) => _executableParameters(item).any(
      (parameter) => isPositionalOrRequiredNamedParameter(
        parameter,
        parameterName,
      ),
    ),
  );
}

HeimdallCondition<HeimdallSourceFile> _fileShouldNotReceiveParameter(
  String parameterName,
) {
  return HeimdallCondition('not receive parameter $parameterName', (item, _) {
    final findings = _executableParameters(item)
        .where(
          (parameter) => isPositionalOrRequiredNamedParameter(
            parameter,
            parameterName,
          ),
        )
        .map(
          (parameter) => fileNodeFinding(
            item,
            parameter,
            'receives forbidden parameter $parameterName',
            offset: parameter.name?.offset,
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

HeimdallPredicate<HeimdallSourceFile> _fileDoesNotReceiveParameter(
  String parameterName,
) {
  return HeimdallPredicate(
    'not receive parameter $parameterName',
    (item, _) => !_executableParameters(item).any(
      (parameter) => isPositionalOrRequiredNamedParameter(
        parameter,
        parameterName,
      ),
    ),
  );
}

Iterable<FormalParameter> _executableParameters(HeimdallSourceFile item) sync* {
  for (final declaration in item.declarations) {
    if (declaration is FunctionDeclaration) {
      yield* declaration.functionExpression.parameters?.parameters ?? const [];
    }
  }
  for (final member in item.classMembers) {
    if (member is MethodDeclaration) {
      yield* member.parameters?.parameters ?? const [];
    }
    if (member is ConstructorDeclaration) {
      yield* member.parameters.parameters;
    }
  }
}
