import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/core/heimdall_validation_info.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_source_file.dart';

/// URI literals matching a rule, including every conditional branch.
Iterable<StringLiteral> matchingDirectiveUris(UriBasedDirective directive, bool Function(String) matches) sync* {
  final configurations = switch (directive) {
    ImportDirective() => directive.configurations,
    ExportDirective() => directive.configurations,
    _ => <Configuration>[],
  };
  for (final uri in [directive.uri, ...configurations.map((configuration) => configuration.uri)]) {
    if (uri.stringValue case final value? when matches(value)) {
      yield uri;
    }
  }
}

/// Creates a finding positioned at [node] or at a custom source [offset].
HeimdallValidationInfo fileNodeFinding(
  HeimdallSourceFile file,
  AstNode node,
  String message, {
  int? offset,
}) {
  final location = file.sourceLocationAt(offset ?? node.offset);
  return HeimdallValidationInfo(
    filePath: file.absolutePath,
    line: location.lineNumber,
    column: location.columnNumber,
    message: message,
  );
}
