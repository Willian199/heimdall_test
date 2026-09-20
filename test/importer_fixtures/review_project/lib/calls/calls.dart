import 'product.dart';
import 'product.dart' as p;
class Calls {
  void plain() { Product(); }
  void named() { Product.named(); }
  void explicitNew() { new Product.named(); }
  void constant() { const Product.named(); }
  void prefixed() { p.Product(); }
  void prefixedNamed() { p.Product.named(); }
  void prefixedNew() { new p.Product.named(); }
  void methodsOnly(Product product) { Product.staticCall(); product.namedMethod(); }
}
