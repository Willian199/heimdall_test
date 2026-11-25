import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/util/extension/named_type_extension.dart';
import 'package:heimdall_test/src/util/extension/record_type_annotation_extension.dart';

/// Shared queries for [TypeAnnotation] nodes.
extension TypeAnnotationExtension on TypeAnnotation? {
  /// The type name assembled from AST nodes, including generic arguments.
  String? get typeName => switch (this) {
    final NamedType type => type.typeName,
    final GenericFunctionType type => 'Function${type.question == null ? '' : '?'}',
    final RecordTypeAnnotation type => type.typeName,
    _ => null,
  };
}
