class Product {}
Product createProduct() => Product();
class A {
  final Product p;
  A.direct() : p = Product();
  A.method() : p = createProduct();
  A.body() : p = Product() { Product(); }
}
