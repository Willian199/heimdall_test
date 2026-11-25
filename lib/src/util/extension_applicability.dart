import 'package:analyzer/dart/ast/ast.dart';
import 'package:heimdall_test/src/mapper/model/heimdall_project.dart';
import 'package:heimdall_test/src/util/type_assignability.dart';
import 'package:heimdall_test/src/util/type_use.dart';

/// An applicable extension with its on-type instantiated for a receiver.
final class ExtensionApplicability {
  /// Creates a match retaining its instantiated on-type and resolution project.
  ExtensionApplicability(this.extension, this._onType, this._project);

  /// Extension whose type arguments satisfy the receiver and declared bounds.
  final ExtensionDeclaration extension;
  final TypeUse _onType;
  final HeimdallProject _project;

  /// Compares instantiated on-types without dropping source qualification.
  bool isMoreSpecificThan(ExtensionApplicability other) {
    final subtype = TypeAssignability.isAssignableTypeUse(_onType, other._onType, _project, allowDynamicDowncast: false);
    final reverse = TypeAssignability.isAssignableTypeUse(other._onType, _onType, _project, allowDynamicDowncast: false);
    return subtype && (!reverse || extension.typeParameters == null && other.extension.typeParameters != null);
  }
}
