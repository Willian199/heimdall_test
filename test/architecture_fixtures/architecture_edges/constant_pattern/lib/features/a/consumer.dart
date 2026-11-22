import '../b/api.dart';

class Consumer {
  bool matches(int value) => switch (value) {
    cutoff => true,
    _ => false,
  };
}
