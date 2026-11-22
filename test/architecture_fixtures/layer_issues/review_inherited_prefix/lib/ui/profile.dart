import '../domain/model.dart' as model;

class Base {
  dynamic get model => null;
}

class Profile extends Base {
  int get value => model.answer() as int;
}
