import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/bloc/notification_bloc.dart';
import '../../domain/models/notification_model.dart';
import '../../../shared/presentation/design/app_colors.dart';

class NotificationDetailView extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailView({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationBloc, NotificationState>(
      listener: (context, state) {
        if (state is NotificationActionSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }

        if (state is NotificationActionErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      builder: (context, state) {
        NotificationModel currentNotification = notification;

        if (state is NotificationLoadedState) {
          currentNotification = state.notifications.firstWhere(
                (item) => item.id == notification.id,
            orElse: () => notification,
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.white,
            elevation: 0,
            title: const Text(
              'Detalle de alerta',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMainCard(currentNotification),

                  const SizedBox(height: 28),

                  const Text(
                    'Mensaje',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF343A48),
                      ),
                    ),
                    child: Text(
                      currentNotification.message,
                      style: const TextStyle(
                        color: Color(0xFFD1D5DB),
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Información',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF343A48),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildInformationRow(
                          icon: Icons.space_dashboard_outlined,
                          label: 'Espacio',
                          value: currentNotification.spaceId != null
                              ? '#${currentNotification.spaceId}'
                              : 'No asociado',
                        ),
                        const Divider(
                          color: Color(0xFF343A48),
                          height: 28,
                        ),
                        _buildInformationRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Fecha',
                          value: _formatDate(
                            currentNotification.createdAt,
                          ),
                        ),
                        const Divider(
                          color: Color(0xFF343A48),
                          height: 28,
                        ),
                        _buildInformationRow(
                          icon: Icons.visibility_outlined,
                          label: 'Estado',
                          value: currentNotification.isRead
                              ? 'Leída'
                              : 'No leída',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: currentNotification.isRead
                          ? null
                          : () {
                        context.read<NotificationBloc>().add(
                          MarkNotificationAsReadEvent(
                            notificationId:
                            currentNotification.id,
                          ),
                        );
                      },
                      icon: Icon(
                        currentNotification.isRead
                            ? Icons.check_circle
                            : Icons.mark_email_read_outlined,
                      ),
                      label: Text(
                        currentNotification.isRead
                            ? 'Notificación leída'
                            : 'Marcar como leída',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryButton,
                        foregroundColor: AppColors.white,
                        disabledBackgroundColor:
                        const Color(0xFF343A48),
                        disabledForegroundColor:
                        const Color(0xFF9CA3AF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainCard(NotificationModel item) {
    final bool critical = _isCriticalNotification(item);

    final Color accentColor = critical
        ? Colors.redAccent
        : item.isRead
        ? const Color(0xFF6B7280)
        : Colors.blueAccent;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor,
          width: item.isRead ? 1 : 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.isRead ? 'Leída' : 'No leída',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.secondaryText,
          size: 21,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
            ),
          ),
        ),

        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  bool _isCriticalNotification(NotificationModel item) {
    final text = '${item.title} ${item.message}'.toLowerCase();

    return text.contains('crítica') ||
        text.contains('critica') ||
        text.contains('fuera de rango') ||
        text.contains('humedad elevada') ||
        text.contains('temperatura elevada');
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Sin fecha';

    final localDate = date.toLocal();

    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');

    return '$day/$month/${localDate.year} · $hour:$minute';
  }
}