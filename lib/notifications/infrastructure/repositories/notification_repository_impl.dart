import 'package:dio/dio.dart';

import '../../domain/models/notification_model.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final Dio dio;

  NotificationRepositoryImpl({
    required this.dio,
  });

  @override
  Future<List<NotificationModel>> getUserNotifications() async {
    try {
      final response = await dio.get(
        '/v1/monitoring/notifications/user',
      );

      if (response.statusCode == 200) {
        if (response.data is! List) {
          throw Exception(
            'La respuesta de notificaciones no tiene el formato esperado.',
          );
        }

        final List<dynamic> data = response.data;

        return data
            .whereType<Map<String, dynamic>>()
            .map(NotificationModel.fromJson)
            .toList();
      }

      if (response.statusCode == 404) {
        return [];
      }

      if (response.statusCode == 401) {
        throw Exception(
          'La sesión no está autorizada. Inicia sesión nuevamente.',
        );
      }

      throw Exception(
        'Error al obtener notificaciones: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(
        'Error de conexión al obtener notificaciones: ${e.message}',
      );
    }
  }

  @override
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      final response = await dio.put(
        '/v1/monitoring/notifications/$notificationId/read',
      );

      final statusCode = response.statusCode;

      if (statusCode != 200 && statusCode != 204) {
        if (statusCode == 401) {
          throw Exception(
            'La sesión no está autorizada. Inicia sesión nuevamente.',
          );
        }

        throw Exception(
          'Error al marcar la notificación: $statusCode',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        'Error de conexión al actualizar la notificación: ${e.message}',
      );
    }
  }
}