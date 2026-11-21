class Failure {
  const Failure();
}

class Other extends Failure {
  String get description => 'native';
}

class Parent {
  Failure get item => Failure();
}

mixin Specific on Parent {
  @override
  Other get item => Other();
}
