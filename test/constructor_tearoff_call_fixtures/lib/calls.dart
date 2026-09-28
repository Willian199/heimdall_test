// Exercise final local bindings, including an ordinary callback control.
// ignore_for_file: prefer_const_declarations, prefer_function_declarations_over_variables

class Product {
  const Product();
}

class FactoryCalls {
  Product throughTearOff() {
    final buildProduct = Product.new;
    return buildProduct();
  }

  Object unusedTearOff() {
    final buildProduct = Product.new;
    return buildProduct;
  }

  Product ordinaryCallback() {
    final buildProduct = () => throw StateError('Not a constructor binding');
    return buildProduct();
  }

  void shadowedCallback() {
    final buildProduct = Product.new;
    final invoke = (Product Function() buildProduct) => buildProduct();
    invoke(buildProduct);
  }
}
