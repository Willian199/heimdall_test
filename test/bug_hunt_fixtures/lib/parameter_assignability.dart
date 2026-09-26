class AssignabilityBase {}

enum AssignabilityResultKind { ok, error }

class AssignabilityChild<T> extends AssignabilityBase {}

typedef AssignabilityChildAlias<T> = AssignabilityChild<T>;

class NullableParameterExample {
  void acceptsNullable(AssignabilityBase? value) {}
}

class GenericParameterExample {
  void acceptsGeneric(AssignabilityChild<String> value) {}

  void acceptsGenericAlias(AssignabilityChildAlias<String> value) {}
}

class FunctionParameterExample {
  // Exercise the valid legacy syntax as well as modern function types.
  // ignore: use_function_type_syntax_for_parameters
  void acceptsCallback(void callback(String value)) {}

  void acceptsModernCallback(void Function(String) callback) {}

  void acceptsNullableCallback(void Function(String)? callback) {}
}

class GenericSuperParameterBase<T> {
  GenericSuperParameterBase(this.value);

  final T value;
}

class GenericSuperParameterChild extends GenericSuperParameterBase<String> {
  GenericSuperParameterChild.copy(super.value);
}

class NestedSuperParameterBase<T> {
  NestedSuperParameterBase(this.value);

  final List<T?> value;
}

class NestedSuperParameterChild extends NestedSuperParameterBase<String> {
  NestedSuperParameterChild.nested(super.value);
}

class NullableNestedSuperParameterChild
    extends NestedSuperParameterBase<String?> {
  NullableNestedSuperParameterChild.nestedNullable(super.value);
}
