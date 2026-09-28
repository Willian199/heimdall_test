// Lexical URI fixture: ':' in a later segment is valid URI syntax but cannot
// name an ordinary file on Windows. Resolution is intentionally not tested.
// ignore: uri_does_not_exist
import 'nested/version:part.dart';

class RelativeColonUriConsumer {}
