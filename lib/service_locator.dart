import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:tfmoviles2/iam/domain/repositories/auth_repository.dart';
import 'package:tfmoviles2/iam/infrastructure/repositories/auth_repository_impl.dart';
import 'package:tfmoviles2/shared/domain/services/storage_service.dart';
import 'package:tfmoviles2/shared/infrastructure/network/auth_interceptor.dart';
import 'package:tfmoviles2/shared/infrastructure/services/secure_storage_service.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Services
  getIt.registerLazySingleton<StorageService>(() => SecureStorageService());

  // Network
  final dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:52888/api',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    validateStatus: (status) => true, // Permite ver errores 4xx y 5xx sin lanzar excepción
  ));

  dio.interceptors.add(AuthInterceptor(getIt<StorageService>()));
  // Opcional: Añadir log de peticiones
  dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

  getIt.registerLazySingleton<Dio>(() => dio);

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
        dio: getIt<Dio>(),
        storageService: getIt<StorageService>(),
      ));
}
