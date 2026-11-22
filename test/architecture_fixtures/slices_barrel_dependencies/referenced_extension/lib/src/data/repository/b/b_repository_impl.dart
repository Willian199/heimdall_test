import 'package:my_package/src/data/repository/a/a_repository.dart';
import 'package:my_package/src/data/repository/b/b_repository.dart';

final class BRepositoryImpl implements BRepository {
  final ARepository a = throw UnimplementedError();
}
