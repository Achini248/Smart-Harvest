import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../widgets/notification_item.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationBloc>().add(const LoadNotificationsEvent());
    });
  }

  int _getUnreadCount(List<dynamic> notifications) {
    return notifications.where((n) => !n.isRead).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              int unreadCount = 0;
              if (state is NotificationLoadedState) {
                unreadCount = _getUnreadCount(state.notifications);
              }
              return unreadCount > 0
                  ? Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Stack(
                        children: [
                          IconButton(
                            onPressed: () => context.read<NotificationBloc>().add(const LoadNotificationsEvent()),
                            icon: const Icon(Icons.refresh),
                          ),
                          Positioned(
                            right: 12,
                            top: 12,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    )
                  : IconButton(
                      onPressed: () => context.read<NotificationBloc>().add(const LoadNotificationsEvent()),
                      icon: const Icon(Icons.refresh),
                    );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoadingState) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
          }
          if (state is NotificationEmptyState) {
            return _buildEmptyState();
          }
          if (state is NotificationErrorState) {
            return _buildErrorState(state.message);
          }
          if (state is NotificationLoadedState) {
            return RefreshIndicator(
              onRefresh: () async => context.read<NotificationBloc>().add(const RefreshNotificationsEvent()),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.notifications.length,
                itemBuilder: (context, index) => NotificationItem(
                  notification: state.notifications[index],
                  onTap: () {},
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          const Text('No notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('You\'ll see order updates, price changes and weather alerts here', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<NotificationBloc>().add(const RefreshNotificationsEvent()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
