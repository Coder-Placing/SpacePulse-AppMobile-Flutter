part of 'notification_bloc.dart';

abstract class NotificationState {}

class NotificationInitialState extends NotificationState {}

class NotificationLoadingState extends NotificationState {}

class NotificationLoadedState extends NotificationState {
  final List<NotificationModel> notifications;

  NotificationLoadedState({
    required this.notifications,
  });
}

class NotificationActionSuccessState extends NotificationLoadedState {
  final String message;

  NotificationActionSuccessState({
    required super.notifications,
    required this.message,
  });
}

class NotificationActionErrorState extends NotificationLoadedState {
  final String message;

  NotificationActionErrorState({
    required super.notifications,
    required this.message,
  });
}

class NotificationErrorState extends NotificationState {
  final String message;

  NotificationErrorState({
    required this.message,
  });
}