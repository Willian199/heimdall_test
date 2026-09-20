class DioClient {}

class CancelToken {}

mixin DioAutoCancel {}

class AutoCancelingServiceImpl with DioAutoCancel {
  AutoCancelingServiceImpl(this.client);

  final DioClient client;
}

class ManualCancelingServiceImpl {
  ManualCancelingServiceImpl(this.client);

  final DioClient client;

  void cancel() {
    CancelToken();
  }
}

class PlainServiceImpl {}
