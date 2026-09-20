import 'annotations.dart';

@Entity()
class User {
  const User(this.id);

  static User parse(String id) => User(id);

  final String id;
}

class DomainService {
  const DomainService();

  @Tracked()
  String normalize(String value) {
    return value.trim();
  }
}
