part of 'notification_bloc.dart';

abstract class NotificationEvent {}

class LoadNotificationsEvent extends NotificationEvent {}

class RefreshNotificationsEvent extends NotificationEvent {}

class MarkNotificationAsReadEvent extends NotificationEvent {
  final int notificationId;

  MarkNotificationAsReadEvent({
    required this.notificationId,
  });
}