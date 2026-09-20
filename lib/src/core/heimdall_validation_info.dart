import 'package:heimdall_test/heimdall_test.dart';

export 'heimdall_findings.dart';

/// A finding produced by a Heimdall rule.
final class HeimdallValidationInfo {
  /// Creates a finding with an optional source location.
  const HeimdallValidationInfo({
    required this.message,
    this.filePath,
    this.line,
    this.column,
  });

  /// Creates a finding with the source location of a Heimdall subject.
  ///
  /// Extracts [filePath], [line] and [column] from known subject types:
  /// - [CompilationUnitMember] — class, enum, mixin, extension type
  /// - [ClassMember] — method, field, constructor
  /// - [HeimdallSourceFile] — file-level findings (no line/column)
  ///
  /// Unknown types produce a finding with [message] only and no location.
  /// Add new subject types here when new Heimdall rule families are introduced.
  factory HeimdallValidationInfo.forSubject(
    Object? subject,
    String message,
  ) {
    if (subject is CompilationUnitMember) {
      final location = subject.location;

      return HeimdallValidationInfo(
        filePath: subject.sourcePath,
        line: location.lineNumber,
        column: location.columnNumber,
        message: message,
      );
    }
    if (subject is ClassMember) {
      final location = subject.location;

      return HeimdallValidationInfo(
        filePath: subject.sourcePath,
        line: location.lineNumber,
        column: location.columnNumber,
        message: message,
      );
    }
    if (subject is HeimdallSourceFile) {
      return HeimdallValidationInfo(
        filePath: subject.absolutePath,
        message: message,
      );
    }
    if (subject is HeimdallProject) {
      return HeimdallValidationInfo(
        filePath: subject.packageRootPath,
        message: message,
      );
    }
    // Subject type is not mapped — finding will have no source location.
    // If this appears in reports, add the missing type to HeimdallValidationInfo.forSubject.
    assert(
      false,
      'HeimdallValidationInfo.forSubject: unmapped subject type ${subject.runtimeType}. '
      'Add it to forSubject to include source location in findings.',
    );
    return HeimdallValidationInfo(message: message);
  }

  /// Problem description.
  final String message;

  /// Related file path, when available.
  final String? filePath;

  /// Related source line, when available.
  final int? line;

  /// Related source column, when available.
  final int? column;

  /// Returns this finding with a different [message], preserving location.
  HeimdallValidationInfo withMessage(String message) {
    return HeimdallValidationInfo(
      filePath: filePath,
      line: line,
      column: column,
      message: message,
    );
  }

  @override
  String toString() {
    final location = filePath == null
        ? ''
        : line == null
        ? '$filePath: '
        : column == null
        ? '$filePath:$line: '
        : '$filePath:$line:$column: ';
    return '$location$message';
  }
}
