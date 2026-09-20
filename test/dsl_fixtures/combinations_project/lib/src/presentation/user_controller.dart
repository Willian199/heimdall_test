import '../data/user_repository.dart';

class UserController {
  UserController(this.repository);

  final UserRepository repository;
  static final String route = '/users';

  String show() {
    final user = repository.find();
    return user.id.toUpperCase();
  }
}

class _HiddenPresenter {
  String show() => 'hidden';
}
