class GenericBase<T> {}

class GenericChild<T> extends GenericBase<T> {}

class ConcreteStringChild extends GenericBase<String> {}

typedef StringBaseAlias = GenericBase<String>;
typedef StringChildAlias = GenericChild<String>;

class GenericIntermediate<T> extends GenericChild<T> {}

class ConcreteDeepChild extends GenericIntermediate<String> {}

class GenericImplementer<T> implements GenericBase<T> {}

class ConcreteImplementer implements GenericBase<String> {}

class AliasStringChild extends StringBaseAlias {}

class GenericFieldOwner {
  GenericChild<String> textChild;

  GenericChild<int> intChild;

  GenericChild<List<String>> nestedChild;
}

class GenericParameterOwner {
  void takesDynamicChild(GenericChild<dynamic> value) {}

  void takesNestedCovariant(GenericChild<List<List<String>>> value) {}

  void takesGenericAlias(ForwardedAlias<String> value) {}

  void takesText(GenericChild<String> value) {}

  void takesInt(GenericChild<int> value) {}

  void takesNested(GenericChild<List<String>> value) {}

  void takesNullable(GenericChild<String>? value) {}

  void takesCovariant(GenericChild<String> value) {}
}

typedef ForwardedAlias<T> = GenericChild<List<T>>;

class GenericAliasParameterOwner {
  void takesAliasChild(StringChildAlias value) {}

  void takesAliasBase(StringBaseAlias value) {}

  void takesImplementer(GenericImplementer<String> value) {}

  void takesDeep(ConcreteDeepChild value) {}
}

class GenericAliasFieldOwner {
  StringChildAlias childAlias;

  StringBaseAlias baseAlias;
}
