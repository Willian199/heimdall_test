import 'nested/path_targets.dart'
    if (dart.library.io) 'package:external/io_secret.dart'
    if (dart.library.html) 'package:external/web_secret.dart';

export 'nested/path_targets.dart'
    if (dart.library.io) 'package:external/io_export.dart'
    if (dart.library.html) 'package:external/web_export.dart';
