import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/executable_syntax_queries.dart';

/// Predicate-side call method rules.
extension MemberCallMethodWithArgumentsPredicateRules on MemberPredicateBuilder {
  /// Matches the specified syntax.
  MemberPredicateBuilder callMethodWithArguments(
    String methodName, {
    String? receiver,
    Map<String, String> namedArguments = const {},
    List<String>? positionalArguments,
    bool exactArguments = false,
  }) => satisfy(
    _matches(
      methodName,
      receiver: receiver,
      namedArguments: namedArguments,
      positionalArguments: positionalArguments,
      exactArguments: exactArguments,
    ),
  );

  /// Rejects the specified syntax.
  MemberPredicateBuilder notCallMethodWithArguments(
    String methodName, {
    String? receiver,
    Map<String, String> namedArguments = const {},
    List<String>? positionalArguments,
    bool exactArguments = false,
  }) => satisfy(
    _matches(
      methodName,
      receiver: receiver,
      namedArguments: namedArguments,
      positionalArguments: positionalArguments,
      exactArguments: exactArguments,
      prohibited: true,
    ),
  );

  /// Matches all of [methodNames], using the same argument filters.
  MemberPredicateBuilder callAllMethodsWithArguments(
    Iterable<String> methodNames, {
    String? receiver,
    Map<String, String> namedArguments = const {},
    List<String>? positionalArguments,
    bool exactArguments = false,
  }) {
    final values = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallPredicate.allOf(
        values.map(
          (methodName) => _matches(
            methodName,
            receiver: receiver,
            namedArguments: namedArguments,
            positionalArguments: positionalArguments,
            exactArguments: exactArguments,
          ),
        ),
      ),
    );
  }

  /// Matches any of [methodNames], using the same argument filters.
  MemberPredicateBuilder callAnyMethodWithArguments(
    Iterable<String> methodNames, {
    String? receiver,
    Map<String, String> namedArguments = const {},
    List<String>? positionalArguments,
    bool exactArguments = false,
  }) {
    final values = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        values.map(
          (methodName) => _matches(
            methodName,
            receiver: receiver,
            namedArguments: namedArguments,
            positionalArguments: positionalArguments,
            exactArguments: exactArguments,
          ),
        ),
      ),
    );
  }

  /// Matches none of [methodNames], using the same argument filters.
  MemberPredicateBuilder callNoMethodsWithArguments(
    Iterable<String> methodNames, {
    String? receiver,
    Map<String, String> namedArguments = const {},
    List<String>? positionalArguments,
    bool exactArguments = false,
  }) {
    final values = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        values.map(
          (methodName) => _matches(
            methodName,
            receiver: receiver,
            namedArguments: namedArguments,
            positionalArguments: positionalArguments,
            exactArguments: exactArguments,
          ),
        ),
      ),
    );
  }
}

/// Should-side call method rules.
extension MemberCallMethodWithArgumentsShouldRules on MemberShouldBuilder {
  /// Matches the specified syntax.
  HeimdallRule<ClassMember> callMethodWithArguments(
    String methodName, {
    String? receiver,
    Map<String, String> namedArguments = const {},
    List<String>? positionalArguments,
    bool exactArguments = false,
  }) => satisfy(
    _requires(
      methodName,
      receiver: receiver,
      namedArguments: namedArguments,
      positionalArguments: positionalArguments,
      exactArguments: exactArguments,
    ),
  );

  /// Rejects the specified syntax.
  HeimdallRule<ClassMember> notCallMethodWithArguments(
    String methodName, {
    String? receiver,
    Map<String, String> namedArguments = const {},
    List<String>? positionalArguments,
    bool exactArguments = false,
  }) => satisfy(
    _requires(
      methodName,
      receiver: receiver,
      namedArguments: namedArguments,
      positionalArguments: positionalArguments,
      exactArguments: exactArguments,
      prohibited: true,
    ),
  );

  /// Matches all of [methodNames], using the same argument filters.
  HeimdallRule<ClassMember> callAllMethodsWithArguments(
    Iterable<String> methodNames, {
    String? receiver,
    Map<String, String> namedArguments = const {},
    List<String>? positionalArguments,
    bool exactArguments = false,
  }) {
    final values = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallCondition.allOf(
        values.map(
          (methodName) => _requires(
            methodName,
            receiver: receiver,
            namedArguments: namedArguments,
            positionalArguments: positionalArguments,
            exactArguments: exactArguments,
          ),
        ),
      ),
    );
  }

  /// Matches any of [methodNames], using the same argument filters.
  HeimdallRule<ClassMember> callAnyMethodWithArguments(
    Iterable<String> methodNames, {
    String? receiver,
    Map<String, String> namedArguments = const {},
    List<String>? positionalArguments,
    bool exactArguments = false,
  }) {
    final values = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallCondition.anyOf(
        values.map(
          (methodName) => _requires(
            methodName,
            receiver: receiver,
            namedArguments: namedArguments,
            positionalArguments: positionalArguments,
            exactArguments: exactArguments,
          ),
        ),
      ),
    );
  }

  /// Matches none of [methodNames], using the same argument filters.
  HeimdallRule<ClassMember> callNoMethodsWithArguments(
    Iterable<String> methodNames, {
    String? receiver,
    Map<String, String> namedArguments = const {},
    List<String>? positionalArguments,
    bool exactArguments = false,
  }) {
    final values = methodNames.toNonEmptyList('methodNames');
    return satisfy(
      HeimdallCondition.noneOf(
        values.map(
          (methodName) => _requires(
            methodName,
            receiver: receiver,
            namedArguments: namedArguments,
            positionalArguments: positionalArguments,
            exactArguments: exactArguments,
          ),
        ),
      ),
    );
  }
}

HeimdallPredicate<ClassMember> _matches(
  String methodName, {
  String? receiver,
  Map<String, String> namedArguments = const {},
  List<String>? positionalArguments,
  bool exactArguments = false,
  bool prohibited = false,
}) {
  final match = invocationMatcher(
    methodName,
    constructor: false,
    receiver: receiver,
    namedArguments: namedArguments,
    positionalArguments: positionalArguments,
    exactArguments: exactArguments,
  );
  return HeimdallPredicate(
    '${prohibited ? 'not ' : ''}call method $methodName with arguments $positionalArguments $namedArguments (receiver: $receiver, exact: $exactArguments)',
    (item, project) => prohibited ? !hasSyntaxMatch(item, project, match) : hasSyntaxMatch(item, project, match),
  );
}

HeimdallCondition<ClassMember> _requires(
  String methodName, {
  String? receiver,
  Map<String, String> namedArguments = const {},
  List<String>? positionalArguments,
  bool exactArguments = false,
  bool prohibited = false,
}) {
  final match = invocationMatcher(
    methodName,
    constructor: false,
    receiver: receiver,
    namedArguments: namedArguments,
    positionalArguments: positionalArguments,
    exactArguments: exactArguments,
  );
  return syntaxCondition(
    '${prohibited ? 'not ' : ''}call method $methodName with arguments $positionalArguments $namedArguments (receiver: $receiver, exact: $exactArguments)',
    match,
    prohibited: prohibited,
  );
}
