import '../domain/model.dart';

class Base {
  int answer() => 7;
}

class Profile extends Base {
  int get value => answer();
}
