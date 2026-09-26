import 'package:heimdall_test/heimdall_test.dart';

/// Returns constructors, optionally restricted to the owner named [className].
Iterable<ConstructorDeclaration> fileConstructors(
  HeimdallSourceFile item, {
  String? className,
}) {
  if (className == null) {
    return item.constructors;
  }
  
  return item.constructors.where((constructor) => constructor.ownerName == className);
}
