import '../domain/user.dart';
import 'package:sample/src/domain/user.dart' as package_user;

UserRepository createRepository() => UserRepository();

class UserRepository {
  User find() => const User('1');

  package_user.User findPackageUser() => const package_user.User('2');
}
