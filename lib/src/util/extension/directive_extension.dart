import 'package:analyzer/dart/ast/ast.dart';

/// Shared queries for [Directive] nodes.
extension DirectiveExtension on Directive {
  /// Whether this directive imports, exports or declares a library part.
  bool get isDependencyDirective => this is ImportDirective || this is ExportDirective || this is PartDirective || this is PartOfDirective;
}
