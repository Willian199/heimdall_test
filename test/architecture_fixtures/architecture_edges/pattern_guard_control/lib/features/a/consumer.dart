import '../b/api.dart';

class Consumer {
  bool matches(int value) => switch (value) {
    final n when n > cutoff => true,
    _ => false,
  };
}
