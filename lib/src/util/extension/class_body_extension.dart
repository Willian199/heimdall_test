import 'package:analyzer/dart/ast/ast.dart';

/// Shared queries for [ClassBody] nodes.
extension ClassBodyExtension on ClassBody {
  /// Declared members, or an empty list for a semicolon body.
  List<ClassMember> get syntaxMembers => switch (this) {
    BlockClassBody(:final members) => members,
    _ => const [],
  };
}
