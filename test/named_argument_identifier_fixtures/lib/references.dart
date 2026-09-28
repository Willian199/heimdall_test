void consume({int? value}) {}

class NamedArgumentOnly {
  void call() {
    consume(value: 1);
  }
}
