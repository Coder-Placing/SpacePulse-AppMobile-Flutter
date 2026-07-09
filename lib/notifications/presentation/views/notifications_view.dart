import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/bloc/notification_bloc.dart';
import '../../domain/models/notification_model.dart';
import '../../../service_locator.dart';
import '../../../shared/presentation/design/app_colors.dart';
import 'notification_detail_view.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NotificationBloc>()
        ..add(LoadNotificationsEvent()),
      child: const _NotificationsContent(),
    );
  }
}

class _NotificationsContent extends StatefulWidget {
  const _NotificationsContent();

  @override
  State<_NotificationsContent> createState() =>
      _NotificationsContentState();
}

class _NotificationsContentState
    extends State<_NotificationsContent> {
  final TextEditingController _searchController =
  TextEditingController();

  String _selectedFilter = 'Todas';
  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Alertas',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Eventos y notificaciones recientes',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 22),

                  _buildSearchField(),

                  const SizedBox(height: 22),

                  const Text(
                    'Filtros',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _buildFilterButton('Todas'),
                      const SizedBox(width: 10),
                      _buildFilterButton('No leídas'),
                      const SizedBox(width: 10),
                      _buildFilterButton('Leídas'),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: _buildStateContent(state),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchText = value.trim().toLowerCase();
        });
      },
      style: const TextStyle(
        color: AppColors.white,
      ),
      decoration: InputDecoration(
        hintText: 'Buscar alerta...',
        hintStyle: const TextStyle(
          color: Color(0xFF6B7280),
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: Color(0xFF9CA3AF),
        ),
        suffixIcon: _searchText.isNotEmpty
            ? IconButton(
          onPressed: () {
            _searchController.clear();

            setState(() {
              _searchText = '';
            });
          },
          icon: const Icon(
            Icons.close,
            color: Color(0xFF9CA3AF),
          ),
        )
            : null,
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFF343A48),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.blueAccent,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String text) {
    final bool selected = _selectedFilter == text;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          setState(() {
            _selectedFilter = text;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryButton
                : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppColors.primaryButton
                  : const Color(0xFF343A48),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: selected
                  ? AppColors.white
                  : const Color(0xFF9CA3AF),
              fontSize: 12,
              fontWeight: selected
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStateContent(NotificationState state) {
    if (state is NotificationInitialState ||
        state is NotificationLoadingState) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.blueAccent,
        ),
      );
    }

    if (state is NotificationErrorState) {
      return _buildErrorState(state.message);
    }

    if (state is NotificationLoadedState) {
      final filteredNotifications =
      _filterNotifications(state.notifications);

      if (state.notifications.isEmpty) {
        return _buildEmptyState(
          title: 'No tienes alertas activas',
          description:
          'Aquí aparecerán tus notificaciones recientes.',
        );
      }

      if (filteredNotifications.isEmpty) {
        return _buildEmptyState(
          title: 'No se encontraron alertas',
          description:
          'Prueba cambiando el filtro o la búsqueda.',
        );
      }

      return RefreshIndicator(
        color: Colors.blueAccent,
        backgroundColor: AppColors.cardBackground,
        onRefresh: () async {
          context
              .read<NotificationBloc>()
              .add(RefreshNotificationsEvent());
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            top: 2,
            bottom: 24,
          ),
          itemCount: filteredNotifications.length,
          separatorBuilder: (_, __) =>
          const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final notification =
            filteredNotifications[index];

            return _buildNotificationCard(notification);
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }

  List<NotificationModel> _filterNotifications(
      List<NotificationModel> notifications,
      ) {
    final filtered = notifications.where((notification) {
      final matchesFilter = switch (_selectedFilter) {
        'No leídas' => !notification.isRead,
        'Leídas' => notification.isRead,
        _ => true,
      };

      final searchableText =
      '${notification.title} ${notification.message}'
          .toLowerCase();

      final matchesSearch = _searchText.isEmpty ||
          searchableText.contains(_searchText);

      return matchesFilter && matchesSearch;
    }).toList();

    filtered.sort((first, second) {
      if (first.isRead != second.isRead) {
        return first.isRead ? 1 : -1;
      }

      final firstDate = first.createdAt ??
          DateTime.fromMillisecondsSinceEpoch(0);

      final secondDate = second.createdAt ??
          DateTime.fromMillisecondsSinceEpoch(0);

      return secondDate.compareTo(firstDate);
    });

    return filtered;
  }

  Widget _buildNotificationCard(
      NotificationModel notification,
      ) {
    final bool critical =
    _isCriticalNotification(notification);

    final Color accentColor = critical
        ? Colors.redAccent
        : notification.isRead
        ? const Color(0xFF4B5563)
        : Colors.blueAccent;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        final notificationBloc =
        context.read<NotificationBloc>();

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: notificationBloc,
              child: NotificationDetailView(
                notification: notification,
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: accentColor,
            width: notification.isRead ? 1 : 1.4,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                critical
                    ? Icons.warning_amber_rounded
                    : Icons.notifications_outlined,
                color: Colors.white,
                size: 23,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    notification.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFB5BBC5),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    _formatDate(notification.createdAt),
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            if (!notification.isRead)
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required String title,
    required String description,
  }) {
    return RefreshIndicator(
      color: Colors.blueAccent,
      backgroundColor: AppColors.cardBackground,
      onRefresh: () async {
        context
            .read<NotificationBloc>()
            .add(RefreshNotificationsEvent());
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 100),

          const Icon(
            Icons.notifications_none,
            color: Color(0xFF6B7280),
            size: 82,
          ),

          const SizedBox(height: 24),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.redAccent,
            size: 62,
          ),

          const SizedBox(height: 18),

          const Text(
            'No se pudieron cargar las alertas',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 22),

          ElevatedButton.icon(
            onPressed: () {
              context
                  .read<NotificationBloc>()
                  .add(LoadNotificationsEvent());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryButton,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  bool _isCriticalNotification(
      NotificationModel notification,
      ) {
    final text =
    '${notification.title} ${notification.message}'
        .toLowerCase();

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
    final month =
    localDate.month.toString().padLeft(2, '0');
    final hour =
    localDate.hour.toString().padLeft(2, '0');
    final minute =
    localDate.minute.toString().padLeft(2, '0');

    return '$day/$month/${localDate.year} · $hour:$minute';
  }
}