import 'package:bloc/bloc.dart';

import '../../domain/models/notification_model.dart';
import '../../domain/repositories/notification_repository.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc
    extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository notificationRepository;

  List<NotificationModel> _notifications = [];

  NotificationBloc({
    required this.notificationRepository,
  }) : super(NotificationInitialState()) {
    on<LoadNotificationsEvent>(_onLoadNotifications);
    on<RefreshNotificationsEvent>(_onRefreshNotifications);
    on<MarkNotificationAsReadEvent>(_onMarkAsRead);
  }

  Future<void> _onLoadNotifications(
      LoadNotificationsEvent event,
      Emitter<NotificationState> emit,
      ) async {
    emit(NotificationLoadingState());

    await _loadNotifications(emit);
  }

  Future<void> _onRefreshNotifications(
      RefreshNotificationsEvent event,
      Emitter<NotificationState> emit,
      ) async {
    await _loadNotifications(emit);
  }

  Future<void> _loadNotifications(
      Emitter<NotificationState> emit,
      ) async {
    try {
      _notifications =
      await notificationRepository.getUserNotifications();

      _notifications.sort((first, second) {
        final firstDate = first.createdAt ??
            DateTime.fromMillisecondsSinceEpoch(0);

        final secondDate = second.createdAt ??
            DateTime.fromMillisecondsSinceEpoch(0);

        return secondDate.compareTo(firstDate);
      });

      emit(
        NotificationLoadedState(
          notifications: List.unmodifiable(_notifications),
        ),
      );
    } catch (e) {
      emit(
        NotificationErrorState(
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onMarkAsRead(
      MarkNotificationAsReadEvent event,
      Emitter<NotificationState> emit,
      ) async {
    try {
      await notificationRepository.markNotificationAsRead(
        event.notificationId,
      );

      _notifications = _notifications.map((notification) {
        if (notification.id == event.notificationId) {
          return notification.copyWith(isRead: true);
        }

        return notification;
      }).toList();

      emit(
        NotificationActionSuccessState(
          notifications: List.unmodifiable(_notifications),
          message: 'Notificación marcada como leída',
        ),
      );
    } catch (e) {
      emit(
        NotificationActionErrorState(
          notifications: List.unmodifiable(_notifications),
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}