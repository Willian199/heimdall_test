class Product {
  Product.named(int value);

  static void staticCall(int value) {}
}

class Consumer {
  void create() {
    Product.named(1);
  }

  void onlyStatic() {
    Product.staticCall(1);
  }
}
