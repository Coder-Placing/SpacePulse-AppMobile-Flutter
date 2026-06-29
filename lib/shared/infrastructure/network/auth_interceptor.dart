import 'package:dio/dio.dart';
import 'package:tfmoviles2/shared/domain/services/storage_service.dart';

class AuthInterceptor extends Interceptor {
  final StorageService storageService;

  AuthInterceptor(this.storageService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await storageService.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }
}
