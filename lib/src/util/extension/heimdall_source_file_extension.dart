import 'package:heimdall_test/heimdall_test.dart';

/// Shared queries for [HeimdallSourceFile] nodes.
extension HeimdallSourceFileExtension on HeimdallSourceFile {
  /// Returns constructors, optionally restricted to the owner named [className].
  Iterable<ConstructorDeclaration> constructorsForClass({
    String? className,
  }) {
    if (className == null) {
      return constructors;
    }

    return constructors.where((constructor) => constructor.ownerName == className);
  }

  /// Creates a finding positioned at [node] or at a custom source [offset].
  HeimdallValidationInfo nodeFinding(
    AstNode node,
    String message, {
    int? offset,
  }) {
    final location = sourceLocationAt(offset ?? node.offset);
    return HeimdallValidationInfo(
      filePath: absolutePath,
      line: location.lineNumber,
      column: location.columnNumber,
      message: message,
    );
  }
}
