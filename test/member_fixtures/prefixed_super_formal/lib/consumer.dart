import 'model/base.dart' as models;

class Base {
  Base(this.value);
  final int value;
}

class Child extends models.Base {
  Child(super.value);
}
