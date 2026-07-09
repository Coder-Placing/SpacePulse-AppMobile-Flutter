import '../models/notification_model.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getUserNotifications();

  Future<void> markNotificationAsRead(int notificationId);
}