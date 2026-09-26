extension on String {
  String get internalOnly => trim();
}

extension PublicStringExtension on String {
  String get exported => toUpperCase();
}
