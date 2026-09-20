import '../domain/user.dart';

class TypeParameterHolder<User> {
  User? value;

  T echo<T extends User>(T value) => value;
}
