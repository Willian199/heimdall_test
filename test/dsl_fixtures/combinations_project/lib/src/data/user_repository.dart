import '../domain/user.dart';

class UserRepository {
  final DomainService service = const DomainService();

  User find() {
    service.normalize('  Ada  ');
    return const User('1');
  }
}
