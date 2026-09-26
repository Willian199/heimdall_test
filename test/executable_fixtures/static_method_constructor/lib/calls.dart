class Product {
  Product.named(this.value);

  final int value;

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
