extension type ProductId(int value) {
  factory ProductId.parse(String source) => ProductId(int.parse(source));
}

class ExtensionConsumer {
  void createExtension() {
    ProductId(1);
  }

  void parseExtension() {
    ProductId.parse('1');
  }
}
