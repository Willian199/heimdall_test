import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/features/queries/type_annotation_queries.dart';

/// Returns the explicit return type of a method (including accessors).
///
/// Fields and constructors have no return type. Missing annotations are not
/// inferred; named types retain their prefix, generic arguments and nullability.
String? memberReturnTypeName(ClassMember member) {
  return member is MethodDeclaration ? typeAnnotationName(member.returnType) : null;
}
