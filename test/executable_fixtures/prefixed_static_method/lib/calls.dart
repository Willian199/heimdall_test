import 'product.dart' as catalog;

class Consumer {
  void createAndCall() {
    catalog.Product();
    catalog.Product.staticCall();
  }
}
