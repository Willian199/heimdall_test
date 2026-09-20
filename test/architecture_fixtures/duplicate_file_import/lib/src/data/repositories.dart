import '../domain/user.dart';

class FirstRepository {
  User find() => const User('1');
}

class SecondRepository {
  User find() => const User('2');
}
