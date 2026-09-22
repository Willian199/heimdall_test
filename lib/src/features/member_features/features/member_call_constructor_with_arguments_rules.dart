import 'package:heimdall_test/heimdall_test.dart';
import 'package:heimdall_test/src/features/queries/executable_syntax_queries.dart';

/// Predicate-side call constructor rules.
extension MemberCallConstructorWithArgumentsPredicateRules on MemberPredicateBuilder {
  /// Matches the specified syntax.
  MemberPredicateBuilder callConstructorWithArguments(
    String typeName, {
    String constructorName = '',
    Map<String, String> namedArguments = const {},
    List<String>? positionalArguments,
    bool exactArguments = false,
  }) => satisfy(
    _matches(
      typeName,
      constructorName: constructorName,
      namedArguments: namedArguments,
      positionalArguments: positionalArguments,
      exactArguments: exactArguments,
    ),
  );

  /// Rejects the specified syntax.
  MemberPredicateBuilder notCallConstructorWithArguments(
    String typeName, {
    String constructorName = '',
    Map<String, String> namedArguments = const {},
    List<String>? positionalArguments,
    bool exactArguments = false,
  }) => satisfy(
    _matches(
      typeName,
      constructorName: constructorName,
      namedArguments: namedArguments,
      positionalArguments: positionalArguments,
      exactArguments: exactArguments,
      prohibited: true,
    ),
  );

  /// Matches all of [typeNames], using the same argument filters.
  MemberPredicateBuilder callAllConstructorsWithArguments(
    Iterable<String> typeNames, {
    String constructorName = '',
    Map<String, String> namedArguments = const {},
    List<String>? positionalArguments,
    bool exactArguments = false,
  }) {
    final values = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.allOf(
        values.map(
          (typeName) => _matches(
            typeName,
            constructorName: constructorName,
            namedArguments: namedArguments,
            positionalArguments: positionalArguments,
            exactArguments: exactArguments,
          ),
        ),
      ),
    );
  }

  /// Matches any of [typeNames], using the same argument filters.
  MemberPredicateBuilder callAnyConstructorWithArguments(
    Iterable<String> typeNames, {
    String constructorName = '',
    Map<String, String> namedArguments = const {},
    List<String>? positionalArguments,
    bool exactArguments = false,
  }) {
    final values = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.anyOf(
        values.map(
          (typeName) => _matches(
            typeName,
            constructorName: constructorName,
            namedArguments: namedArguments,
            positionalArguments: positionalArguments,
            exactArguments: exactArguments,
          ),
        ),
      ),
    );
  }

  /// Matches none of [typeNames], using the same argument filters.
  MemberPredicateBuilder callNoConstructorsWithArguments(
    Iterable<String> typeNames, {
    String constructorName = '',
    Map<String, String> namedArguments = const {},
    List<String>? positionalArguments,
    bool exactArguments = false,
  }) {
    final values = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallPredicate.noneOf(
        values.map(
          (typeName) => _matches(
            typeName,
            constructorName: constructorName,
            namedArguments: namedArguments,
            positionalArguments: positionalArguments,
            exactArguments: exactArguments,
          ),
        ),
      ),
    );
  }
}

/// Should-side call constructor rules.
extension MemberCallConstructorWithArgumentsShouldRules on MemberShouldBuilder {
  /// Matches the specified syntax.
  HeimdallRule<ClassMember> callConstructorWithArguments(
    String typeName, {
    String constructorName = '',
    Map<String, String> namedArguments = const {},
    List<String>? positionalArguments,
    bool exactArguments = false,
  }) => satisfy(
    _requires(
      typeName,
      constructorName: constructorName,
      namedArguments: namedArguments,
      positionalArguments: positionalArguments,
      exactArguments: exactArguments,
    ),
  );

  /// Rejects the specified syntax.
  HeimdallRule<ClassMember> notCallConstructorWithArguments(
    String typeName, {
    String constructorName = '',
    Map<String, String> namedArguments = const {},
    List<String>? positionalArguments,
    bool exactArguments = false,
  }) => satisfy(
    _requires(
      typeName,
      constructorName: constructorName,
      namedArguments: namedArguments,
      positionalArguments: positionalArguments,
      exactArguments: exactArguments,
      prohibited: true,
    ),
  );

  /// Matches all of [typeNames], using the same argument filters.
  HeimdallRule<ClassMember> callAllConstructorsWithArguments(
    Iterable<String> typeNames, {
    String constructorName = '',
    Map<String, String> namedArguments = const {},
    List<String>? positionalArguments,
    bool exactArguments = false,
  }) {
    final values = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.allOf(
        values.map(
          (typeName) => _requires(
            typeName,
            constructorName: constructorName,
            namedArguments: namedArguments,
            positionalArguments: positionalArguments,
            exactArguments: exactArguments,
          ),
        ),
      ),
    );
  }

  /// Matches any of [typeNames], using the same argument filters.
  HeimdallRule<ClassMember> callAnyConstructorWithArguments(
    Iterable<String> typeNames, {
    String constructorName = '',
    Map<String, String> namedArguments = const {},
    List<String>? positionalArguments,
    bool exactArguments = false,
  }) {
    final values = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.anyOf(
        values.map(
          (typeName) => _requires(
            typeName,
            constructorName: constructorName,
            namedArguments: namedArguments,
            positionalArguments: positionalArguments,
            exactArguments: exactArguments,
          ),
        ),
      ),
    );
  }

  /// Matches none of [typeNames], using the same argument filters.
  HeimdallRule<ClassMember> callNoConstructorsWithArguments(
    Iterable<String> typeNames, {
    String constructorName = '',
    Map<String, String> namedArguments = const {},
    List<String>? positionalArguments,
    bool exactArguments = false,
  }) {
    final values = typeNames.toNonEmptyList('typeNames');
    return satisfy(
      HeimdallCondition.noneOf(
        values.map(
          (typeName) => _requires(
            typeName,
            constructorName: constructorName,
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
  String typeName, {
  String constructorName = '',
  Map<String, String> namedArguments = const {},
  List<String>? positionalArguments,
  bool exactArguments = false,
  bool prohibited = false,
}) {
  final match = invocationMatcher(
    typeName,
    constructor: true,
    constructorName: constructorName,
    namedArguments: namedArguments,
    positionalArguments: positionalArguments,
    exactArguments: exactArguments,
  );
  return HeimdallPredicate(
    '${prohibited ? 'not ' : ''}call constructor $typeName.$constructorName with arguments $positionalArguments $namedArguments (exact: $exactArguments)',
    (item, _) => prohibited ? !scopedExpressions(item).any(match) : scopedExpressions(item).any(match),
  );
}

HeimdallCondition<ClassMember> _requires(
  String typeName, {
  String constructorName = '',
  Map<String, String> namedArguments = const {},
  List<String>? positionalArguments,
  bool exactArguments = false,
  bool prohibited = false,
}) {
  final match = invocationMatcher(
    typeName,
    constructor: true,
    constructorName: constructorName,
    namedArguments: namedArguments,
    positionalArguments: positionalArguments,
    exactArguments: exactArguments,
  );
  return syntaxCondition(
    '${prohibited ? 'not ' : ''}call constructor $typeName.$constructorName with arguments $positionalArguments $namedArguments (exact: $exactArguments)',
    match,
    prohibited: prohibited,
  );
}
