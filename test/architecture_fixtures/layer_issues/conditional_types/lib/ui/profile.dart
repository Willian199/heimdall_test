import '../domain/model.dart' if (dart.library.html) '../domain/web.dart';

class Profile {
  final User user = User();
  final Address address = Address();
}
