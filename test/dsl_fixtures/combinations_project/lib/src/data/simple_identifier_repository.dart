import '../domain/user.dart';

class SimpleIdentifierRepository {
  String describe() {
    final User = 'local variable with an imported type name';
    return User.toLowerCase();
  }
}
