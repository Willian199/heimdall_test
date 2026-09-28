import 'dart:async' as sdk;
import 'helpers.dart' as dep;
import 'helpers.dart' show importedFunction;

class Product {
  Product();
  Product.named({int value = 0});
}

class Calls {
  void constructorAsMethod() {
    Product();
  }

  void namedConstructorAsMethod() {
    Product.named();
  }

  void sdkPrefixed() {
    sdk.Future.wait<int>([]);
  }

  void sdkPrefixedConstructor() {
    sdk.Completer<int>();
  }

  void explicitNew() {
    Product.new();
  }

  void importedFunctionAsConstructor() {
    importedFunction();
  }

  void fieldInvocation() {
    dep.Holder.callback();
  }

  void getterInvocation() {
    dep.Holder.getter();
  }
}

class Initializers extends Product {
  Initializers() : super.named(value: 1);
  Initializers.redirect() : this();
}

class Access {
  int field = 1;
  int method() => 1;
  int globalRead() => topValue;
  Object typeRead() => Product;
  Object methodTearoff() => method;
  Object importPrefixRead() => dep.Holder;
}

const topValue = 1;
