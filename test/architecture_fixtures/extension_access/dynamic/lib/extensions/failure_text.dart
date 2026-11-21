import '../models/failure.dart';

extension FailureText on Failure {
  String get description => 'failure';
  String describe() => description;
  set description(String value) {}
}
