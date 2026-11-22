import '../c/model.dart';

extension FailureOps on Failure {
  Failure operator +(Failure other) => this;
}
