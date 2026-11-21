import '../c/model.dart';

extension FailureText<T extends Failure> on T {
  String get description => 'failure';
}
