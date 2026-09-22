import 'package:heimdall_test/heimdall_test.dart';

/// Returns the named constructor's location, or the start of an unnamed one.
({int line, int column}) constructorLocation(
  ConstructorDeclaration constructor,
) {
  final offset = constructor.name?.offset ?? constructor.offset;
  return constructor.sourceLocationAt(offset);
}

/// Returns the declared name's offset, falling back to the declaration start.
int declarationNameOffset(CompilationUnitMember item) {
  return switch (item) {
    ClassDeclaration(:final namePart) => namePart.offset,
    MixinDeclaration(:final name) => name.offset,
    EnumDeclaration(:final namePart) => namePart.offset,
    ExtensionDeclaration(:final name?) => name.offset,
    ExtensionTypeDeclaration(:final primaryConstructor) => primaryConstructor.typeName.offset,
    TypeAlias(:final name) => name.offset,
    FunctionDeclaration(:final name) => name.offset,
    TopLevelVariableDeclaration(:final variables) => variables.variables.first.name.offset,
    _ => item.offset,
  };
}
