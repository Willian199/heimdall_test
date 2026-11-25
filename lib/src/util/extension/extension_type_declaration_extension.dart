import 'package:analyzer/dart/ast/ast.dart';

/// Shared queries for [ExtensionTypeDeclaration] nodes.
extension ExtensionTypeDeclarationExtension on ExtensionTypeDeclaration {
  /// The primary constructor declared directly by this extension type.
  ///
  /// The constructor remains a direct AST child across analyzer 13.x, while
  /// the getter exposing it changes between minor versions.
  PrimaryConstructorDeclaration get extensionTypePrimaryConstructor => childEntities.whereType<PrimaryConstructorDeclaration>().single;
}
