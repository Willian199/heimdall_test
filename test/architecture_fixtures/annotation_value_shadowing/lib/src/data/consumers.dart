// ignore: unused_import
import '../domain/user.dart';
import '../domain/user.dart' as domain;

class Marker {
  const Marker();
}

const User = Marker();

@User
class LocalAnnotationConsumer {}

@domain.User()
class ImportedAnnotationConsumer {}
