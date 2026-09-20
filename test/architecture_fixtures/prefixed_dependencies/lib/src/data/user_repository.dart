import '../domain_a/user.dart' as a;
import '../domain_b/user.dart' as b;

class UserRepository extends b.Base {
  a.User? user;
}

@b.Marker()
class AnnotatedRepository {}

class AliasRepository extends b.Alias {}
