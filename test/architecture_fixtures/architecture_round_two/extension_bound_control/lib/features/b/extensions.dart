import '../c/model.dart';

extension NumericBox<T extends num> on Box<T> {
  String get label => 'numeric';
}
