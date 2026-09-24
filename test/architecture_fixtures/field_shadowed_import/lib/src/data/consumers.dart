import '../domain/user.dart';
import '../domain/user.dart' as domain;

class ActualConsumer {
  User? user;
}

class EarlierFieldConsumer {
  final Object User = Object();

  String describe() => User.toString();
}

class FieldShadowedConsumer {
  String describe() => User.toString();

  final Object User = Object();
}

class TypeAndFieldConsumer {
  domain.User? user;

  String describe() => User.toString();

  final Object User = Object();
}
