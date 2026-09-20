import 'package:heimdall_test/heimdall_test.dart';

/// Predicate-side DSL for constructor parameter rules.
extension ClassReceiveParameterPredicateRules on ClassPredicateBuilder {
  /// Selects classes that receive [parameterName] in a constructor.
  ClassPredicateBuilder receiveParameter(String parameterName) {
    return satisfy(_classReceivesParameter(parameterName));
  }

  /// Selects classes that do not receive [parameterName] in a constructor.
  ClassPredicateBuilder noReceiveParameter(String parameterName) {
    return satisfy(_classDoesNotReceiveParameter(parameterName));
  }

  /// Selects classes that receive every parameter in [parameterNames].
  ClassPredicateBuilder receiveAllParameters(Iterable<String> parameterNames) {
    final parameterList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallPredicate.allOf(
        parameterList.map(_classReceivesParameter),
        description: 'receive all parameters ${parameterList.join(', ')}',
      ),
    );
  }

  /// Selects classes that receive at least one parameter in [parameterNames].
  ClassPredicateBuilder receiveAnyParameter(Iterable<String> parameterNames) {
    final parameterList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        parameterList.map(_classReceivesParameter),
        description: 'receive any parameter ${parameterList.join(', ')}',
      ),
    );
  }

  /// Selects classes that receive none of [parameterNames].
  ClassPredicateBuilder receiveNoParameters(Iterable<String> parameterNames) {
    final parameterList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        parameterList.map(_classReceivesParameter),
        description: 'receive no parameters ${parameterList.join(', ')}',
      ),
    );
  }
}

/// Condition-side DSL for constructor parameter rules.
extension ClassReceiveParameterShouldRules on ClassShouldBuilder {
  /// Requires matching classes to receive [parameterName] in a constructor.
  HeimdallRule<CompilationUnitMember> receiveParameter(String parameterName) {
    return satisfy(_classShouldReceiveParameter(parameterName));
  }

  /// Requires matching classes to not receive [parameterName] in a constructor.
  HeimdallRule<CompilationUnitMember> noReceiveParameter(String parameterName) {
    return satisfy(_classShouldNotReceiveParameter(parameterName));
  }

  /// Requires matching classes to receive every parameter in [parameterNames].
  HeimdallRule<CompilationUnitMember> receiveAllParameters(
    Iterable<String> parameterNames,
  ) {
    final parameterList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallCondition.allOf(
        parameterList.map(_classShouldReceiveParameter),
        description: 'receive all parameters ${parameterList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to receive at least one parameter in [parameterNames].
  HeimdallRule<CompilationUnitMember> receiveAnyParameter(
    Iterable<String> parameterNames,
  ) {
    final parameterList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallCondition.anyOf(
        parameterList.map(_classShouldReceiveParameter),
        description: 'receive any parameter ${parameterList.join(', ')}',
      ),
    );
  }

  /// Requires matching classes to receive none of [parameterNames].
  HeimdallRule<CompilationUnitMember> receiveNoParameters(
    Iterable<String> parameterNames,
  ) {
    final parameterList = parameterNames.toNonEmptyList('parameterNames');
    return satisfy(
      HeimdallCondition.noneOf(
        parameterList.map(_classShouldReceiveParameter),
        description: 'receive no parameters ${parameterList.join(', ')}',
      ),
    );
  }
}

HeimdallCondition<CompilationUnitMember> _classShouldReceiveParameter(
  String parameterName,
) {
  return HeimdallCondition('receive parameter $parameterName', (item, _) {
    final findings = _receivesParameter(item, parameterName)
        ? const <HeimdallValidationInfo>[]
        : [
            HeimdallValidationInfo(
              filePath: item.sourcePath,
              line: item.line,
              message: '${item.name} does not receive parameter $parameterName',
            ),
          ];

    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallCondition<CompilationUnitMember> _classShouldNotReceiveParameter(
  String parameterName,
) {
  return HeimdallCondition('not receive parameter $parameterName', (item, _) {
    final findings = _matchingParameters(item, parameterName).map(
      (match) {
        final location = match.constructor.sourceLocationAt(
          match.parameter.offset,
        );
        return HeimdallValidationInfo(
          filePath: item.sourcePath,
          line: location.line,
          column: location.column,
          message: '${item.name} receives prohibited parameter $parameterName',
        );
      },
    ).toList();

    return HeimdallFindings(
      subject: item,
      passed: findings.isEmpty,
      findings: findings,
    );
  });
}

HeimdallPredicate<CompilationUnitMember> _classReceivesParameter(
  String parameterName,
) {
  return HeimdallPredicate(
    'receive parameter $parameterName',
    (item, _) => _receivesParameter(item, parameterName),
  );
}

HeimdallPredicate<CompilationUnitMember> _classDoesNotReceiveParameter(
  String parameterName,
) {
  return HeimdallPredicate(
    'not receive parameter $parameterName',
    (item, _) => _matchingParameters(item, parameterName).isEmpty,
  );
}

bool _receivesParameter(CompilationUnitMember item, String parameterName) {
  return item.constructors.any(
    (constructor) => constructor.parameters.parameters.any(
      (parameter) => _isPositionalOrRequiredNamedParameter(
        parameter,
        parameterName,
      ),
    ),
  );
}

Iterable<({ConstructorDeclaration constructor, FormalParameter parameter})> _matchingParameters(
  CompilationUnitMember item,
  String parameterName,
) sync* {
  for (final constructor in item.constructors) {
    for (final parameter in constructor.parameters.parameters) {
      if (_isPositionalOrRequiredNamedParameter(parameter, parameterName)) {
        yield (constructor: constructor, parameter: parameter);
      }
    }
  }
}

bool _isPositionalOrRequiredNamedParameter(
  FormalParameter parameter,
  String name,
) {
  if (parameter.name?.lexeme != name) return false;
  if (parameter is! DefaultFormalParameter) return true;
  if (!parameter.isNamed) return true;
  return parameter.isRequiredNamed;
}
