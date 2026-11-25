import 'package:heimdall_test/heimdall_test.dart';

/// Shared queries for [ConstructorDeclaration] nodes.
extension ConstructorDeclarationExtension on ConstructorDeclaration {
  /// Returns the named constructor's location, or the start of an unnamed one.
  ({int line, int column}) get nameLocation {
    final offset = name?.offset ?? this.offset;
    return sourceLocationAt(offset);
  }

  /// Whether this is a private named constructor.
  bool get isPrivateConstructor => name?.lexeme.startsWith('_') ?? false;

  /// Whether this is an unnamed or public named constructor.
  bool get isPublicConstructor => !isPrivateConstructor;
}
