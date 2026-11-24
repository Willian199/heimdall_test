import 'support.dart';

class Subject extends HeaderBox<dynamic Function<X extends num>({required X value})> with NamedClosure {}

Type nativeType() {
  return Subject().inferred;
}
