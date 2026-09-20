// ignore_for_file: undefined_class

class Tracked {
  const Tracked();
}

class Helper {}

class UserService {
  final String name = 'heimdall';
  static final String version = Helper().toString();
  static final ExternalWidget externalWidget = throw UnimplementedError();

  @Tracked()
  String findName({required String prefix}) => '$prefix${name.toUpperCase()}';

  void _dynamicAction(dynamic cubit) {}

  void _neverAction(Never cubit) {}

  void _nullableAction(ChildCubit? cubit) {}

  void _externalAction(ExternalWidget widget) {}

  UserService._({required String token}) {
    token.toString();
    Helper();
  }
}

class Cubit {}

class ParentCubit extends Cubit {}

class ChildCubit extends Cubit {}

class ViewCubit extends Cubit {}

class BaseWidget {
  final ParentCubit cubit;

  BaseWidget({required this.cubit});
}

class CubitWidget extends BaseWidget {
  final ChildCubit childCubit;
  final ViewCubit viewCubit;
  final ChildCubit? optionalCubit;
  final ChildCubit primaryCubit = ChildCubit(), secondaryCubit = ChildCubit();

  CubitWidget({
    required this.childCubit,
    required this.viewCubit,
    this.optionalCubit,
    required super.cubit,
  });

  void publicAction(ChildCubit cubit) {}

  void _privateAction(ChildCubit cubit) {}
}
