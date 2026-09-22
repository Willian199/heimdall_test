import 'dart:convert';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:heimdall_test/heimdall_test.dart';

/// Internal syntax matcher shared by file and member DSL features.
typedef SyntaxMatch = bool Function(Expression expression);

/// Returns cached expressions for a file or member.
Iterable<Expression> scopedExpressions(Object subject) {
  return switch (subject) {
    ClassMember() => subject.executableExpressions,
    HeimdallSourceFile() => subject.expressions,
    _ => const <Expression>[],
  };
}

/// Matches actual postfix assertions, without attempting flow analysis.
bool isNullAssertion(Expression expression) => expression is PostfixExpression && expression.operator.lexeme == '!';

/// Matches expression tokens, preserving literal contents and token boundaries.
SyntaxMatch expressionMatcher(String source) {
  final key = _expressionKey(source);
  return (expression) => _tokenKey(expression) == key;
}

/// Matches a syntactically named call and its argument expressions.
SyntaxMatch invocationMatcher(
  String name, {
  required bool constructor,
  String? receiver,
  String constructorName = '',
  Map<String, String> namedArguments = const {},
  List<String>? positionalArguments,
  bool exactArguments = false,
}) {
  if (name.trim().isEmpty) throw ArgumentError.value(name, 'name', 'Must not be empty');
  final named = namedArguments.map((name, source) => MapEntry(name, _expressionKey(source)));
  final positional = positionalArguments?.map(_expressionKey).toList();
  return (expression) {
    ArgumentList? arguments;
    if (constructor) {
      if (expression is InstanceCreationExpression) {
        final call = expression.constructorName;
        final type = call.type;
        final prefix = type.importPrefix?.name.lexeme;
        final typeName = prefix == null ? type.name.lexeme : '$prefix.${type.name.lexeme}';
        final actualName = call.name?.name ?? '';
        final matches = (typeName == name || type.name.lexeme == name) && actualName == constructorName;
        // The parser can represent `new Type.named()` as a prefixed type.
        final splitNamed = actualName.isEmpty && prefix == name && type.name.lexeme == constructorName;
        if (!matches && !splitNamed) return false;
        arguments = expression.argumentList;
      } else if (expression is MethodInvocation) {
        if (!_matchesConstructorReference(expression, name, constructorName)) return false;
        arguments = expression.argumentList;
      }
    } else if (expression is MethodInvocation && expression.methodName.name == name) {
      if (receiver != null && (expression.realTarget?.toSource() ?? '') != receiver) return false;
      arguments = expression.argumentList;
    }
    if (arguments == null) return false;
    final actualNamed = <String, Expression>{};
    final actualPositional = <Expression>[];
    for (final argument in arguments.arguments) {
      if (argument is NamedExpression) {
        actualNamed[argument.name.label.name] = argument.expression;
      } else {
        actualPositional.add(argument);
      }
    }
    for (final entry in named.entries) {
      final actual = actualNamed[entry.key];
      if (actual == null || _tokenKey(actual) != entry.value) return false;
    }
    if (positional != null) {
      if (actualPositional.length != positional.length) return false;
      for (var index = 0; index < positional.length; index++) {
        if (_tokenKey(actualPositional[index]) != positional[index]) return false;
      }
    }
    return !exactArguments || (actualNamed.length == named.length && actualPositional.length == (positional?.length ?? 0));
  };
}

bool _matchesConstructorReference(MethodInvocation invocation, String typeName, String constructorName) {
  if (invocation.isCascaded) return false;
  final target = invocation.target?.toSource();
  final reference = target == null ? invocation.methodName.name : '$target.${invocation.methodName.name}';
  final expected = constructorName.isEmpty ? typeName : '$typeName.$constructorName';
  if (reference == expected) {
    if (typeName.contains('.')) {
      return _hasImportPrefix(invocation, typeName.substring(0, typeName.lastIndexOf('.')));
    }
    return true;
  }
  if (!reference.endsWith('.$expected')) return false;
  final prefix = reference.substring(0, reference.length - expected.length - 1);
  return _hasImportPrefix(invocation, prefix);
}

bool _hasImportPrefix(MethodInvocation invocation, String prefix) {
  for (var node = invocation.parent; node != null; node = node.parent) {
    if (node is CompilationUnit) {
      return node.directives.whereType<ImportDirective>().any((directive) => directive.prefix?.name == prefix);
    }
  }
  return false;
}

/// Reports matching expressions or the subject when required syntax is missing.
HeimdallCondition<T> syntaxCondition<T>(String description, SyntaxMatch match, {bool prohibited = false}) {
  return HeimdallCondition(description, (subject, _) {
    final matches = scopedExpressions(subject as Object).where(match).toList();
    final passed = prohibited ? matches.isEmpty : matches.isNotEmpty;
    return HeimdallFindings(
      subject: subject,
      passed: passed,
      findings: [
        for (final expression in matches) _expressionFinding(subject, expression, description),
        if (!prohibited && matches.isEmpty) HeimdallValidationInfo.forSubject(subject, 'Should $description'),
      ],
    );
  });
}

HeimdallValidationInfo _expressionFinding(Object subject, Expression expression, String message) {
  final offset = isNullAssertion(expression) ? (expression as PostfixExpression).operator.offset : expression.offset;
  if (subject is ClassMember) {
    final location = subject.sourceLocationAt(offset);
    return HeimdallValidationInfo(filePath: subject.sourcePath, line: location.line, column: location.column, message: message);
  }
  final file = subject as HeimdallSourceFile;
  final location = file.sourceLocationAt(offset);
  return HeimdallValidationInfo(filePath: file.absolutePath, line: location.lineNumber, column: location.columnNumber, message: message);
}

String _expressionKey(String source) {
  final result = parseString(content: 'final _heimdallExpression = $source;', throwIfDiagnostics: false);
  if (result.errors.isNotEmpty || result.unit.declarations.length != 1) {
    throw ArgumentError.value(source, 'expression', 'Expected a single Dart expression');
  }
  final declaration = result.unit.declarations.single;
  if (declaration is! TopLevelVariableDeclaration || declaration.variables.variables.length != 1) {
    throw ArgumentError.value(source, 'expression', 'Expected a single Dart expression');
  }
  final expression = declaration.variables.variables.single.initializer;
  if (expression == null) throw ArgumentError.value(source, 'expression', 'Expected a Dart expression');
  return _tokenKey(expression);
}

String _tokenKey(AstNode node) {
  final lexemes = <String>[];
  var token = node.beginToken;
  while (true) {
    lexemes.add(token.lexeme);
    if (identical(token, node.endToken) || token.isEof) break;
    final next = token.next;
    if (next == null) break;
    token = next;
  }
  return jsonEncode(lexemes);
}
