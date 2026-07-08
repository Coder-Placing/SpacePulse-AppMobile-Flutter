import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:tfmoviles2/iam/domain/repositories/auth_repository.dart';
import 'package:tfmoviles2/iam/infrastructure/repositories/auth_repository_impl.dart';
import 'package:tfmoviles2/spaces/domain/repositories/space_repository.dart';
import 'package:tfmoviles2/spaces/infrastructure/repositories/space_repository_impl.dart';
import 'package:tfmoviles2/tasks/domain/repositories/task_repository.dart';
import 'package:tfmoviles2/tasks/infrastructure/repositories/task_repository_impl.dart';

import 'package:tfmoviles2/shared/domain/services/storage_service.dart';
import 'package:tfmoviles2/shared/infrastructure/network/auth_interceptor.dart';
import 'package:tfmoviles2/shared/infrastructure/services/secure_storage_service.dart';

import 'package:tfmoviles2/iot/domain/repositories/iot_repository.dart';
import 'package:tfmoviles2/iot/infrastructure/repositories/iot_repository_impl.dart';
import 'package:tfmoviles2/iot/application/bloc/IotBloc.dart';

import 'package:tfmoviles2/notifications/application/bloc/notification_bloc.dart';
import 'package:tfmoviles2/notifications/domain/repositories/notification_repository.dart';
import 'package:tfmoviles2/notifications/infrastructure/repositories/notification_repository_impl.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<StorageService>(() => SecureStorageService());

  final dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:52888/api',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    validateStatus: (status) => true,
  ));

  dio.interceptors.add(AuthInterceptor(getIt<StorageService>()));
  dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

  getIt.registerLazySingleton<Dio>(() => dio);

  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
    dio: getIt<Dio>(),
    storageService: getIt<StorageService>(),
  ));

  getIt.registerLazySingleton<SpaceRepository>(() => SpaceRepositoryImpl(
    dio: getIt<Dio>(),
  ));

  getIt.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(
    dio: getIt<Dio>(),
  ));

  getIt.registerLazySingleton<IotRepository>(() => IotRepositoryImpl(
    dio: getIt<Dio>(),
  ));

  getIt.registerFactory<IotBloc>(() => IotBloc(
    iotRepository: getIt<IotRepository>(),
  ));

  getIt.registerLazySingleton<NotificationRepository>(() => NotificationRepositoryImpl(
      dio: getIt<Dio>(),
    ),
  );

  getIt.registerFactory<NotificationBloc>(() => NotificationBloc(
      notificationRepository: getIt<NotificationRepository>(),
    ),
  );
}