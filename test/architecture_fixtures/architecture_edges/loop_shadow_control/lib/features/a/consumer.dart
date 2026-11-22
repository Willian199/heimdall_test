import '../b/api.dart';

class Consumer {
  int read() {
    var result = 0;
    for (var i = 0; i < 1; i++) {
      const count = 7;
      result += count;
    }
    return result;
  }
}
