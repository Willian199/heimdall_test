import '../domain/user.dart';

UserRepository createRepository() => UserRepository();

class UserRepository {
  User find() => const User('1');
}
