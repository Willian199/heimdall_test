library valid_library;

import 'dart:async' show Future;
import 'model.dart' show Model;
import './model.dart' hide Hidden;
import 'model.dart' as local;
import 'model.dart' deferred as lazy;
import 'package:uri_policy_external/model.dart' show ExternalModel;
import 'package:uri_policy_app_extra/model.dart';
import 'model.dart' if (dart.library.io) './model.dart' if (dart.library.html) 'model.dart';
export 'model.dart' show Model;
export 'model.dart' hide Hidden;
export 'package:uri_policy_external/model.dart';
export 'dart:async' show Future;
export 'model.dart' if (dart.library.io) './model.dart';
part 'relative_part.dart';
part 'named_part.dart';
