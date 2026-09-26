import 'mailto:invalid@example.test';
import 'custom:resource';
import 'data:text/plain,hello';
import 'urn:example:item';

import 'safe_branch.dart' if (dart.library.io) '../outside_branch.dart';

import 'missing_conditional_import.dart' if (dart.library.io) 'present_branch.dart';

import 'present_branch.dart' if (dart.library.io) 'missing_secondary_import.dart';

import 'present_branch.dart' if (dart.library.io) '../outside_branch.dart';

import 'package:heimdall_test/test/bug_audit_fixtures/lib/present_branch.dart' if (dart.library.html) 'package:external/widgets.dart';

export 'missing_export.dart' if (dart.library.io) 'present_branch.dart';

export 'missing_conditional_export.dart' if (dart.library.io) 'present_branch.dart';

export 'present_branch.dart' if (dart.library.io) 'missing_secondary_export.dart';

class UriCases {}
