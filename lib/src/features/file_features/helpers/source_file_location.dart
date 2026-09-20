import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/core/heimdall_validation_info.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_source_file.dart';

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
