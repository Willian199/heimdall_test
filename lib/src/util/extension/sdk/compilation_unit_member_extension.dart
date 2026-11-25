import 'package:heimdall_test/src/core.dart';

/// SDK queries for [CompilationUnitMember] nodes.
extension CompilationUnitMemberSdkExtension on CompilationUnitMember {
  /// Identifies SDK declarations read from the caller-configured libraries.
  ///
  /// Local/package homonyms and ambiguous references are not SDK types.
  String? sdkTypeName(String reference, HeimdallProject project) {
    final pieces = reference.split('.');
    if (pieces.length > 2 || pieces.any((piece) => piece.isEmpty)) {
      return null;
    }
    final name = pieces.last;
    final prefix = pieces.length == 2 ? pieces.first : null;
    final declarations = project.referenceTypes.visible(this, name, prefix: prefix);
    // Never is supplied by the compiler, without a declaration in the SDK AST.
    if (name == 'Never' && project.referenceTypes.isIntrinsicVisible(this, name, 'dart:core', prefix: prefix)) {
      return name;
    }
    if (declarations.length != 1 || !(declarations.single.library?.uri.startsWith('dart:') ?? false)) {
      return null;
    }
    return name;
  }
}
