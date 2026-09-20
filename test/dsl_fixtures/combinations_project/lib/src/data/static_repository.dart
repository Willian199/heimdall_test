import '../domain/user.dart';

class StaticRepository {
  User parse(String id) => User.parse(id);
}
