class FactoryProduct {
  FactoryProduct._();

  factory FactoryProduct.named() => FactoryProduct._();
}

class FactoryConsumer {
  FactoryProduct createFactory() => FactoryProduct.named();
}
