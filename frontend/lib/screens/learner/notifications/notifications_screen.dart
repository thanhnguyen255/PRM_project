import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../viewmodels/viewmodels.dart';
import '../../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L06 — Notifications
// ════════════════════════════════════════════════════════════════════════════════
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          if (vm.unreadCount > 0)
            TextButton(
              onPressed: vm.markAllRead,
              child: const Text('Đánh dấu tất cả', style: TextStyle(color: AppColors.primary, fontSize: 13)),
            ),
        ],
      ),
      body: vm.isLoading
          ? const LoadingWidget()
          : vm.notifications.isEmpty
              ? const EmptyState(
                  icon: Icons.notifications_none_rounded,
                  title: 'Chưa có thông báo',
                  message: 'Các thông báo từ hệ thống sẽ xuất hiện ở đây.',
                )
              : RefreshIndicator(
                  onRefresh: vm.load,
                  color: AppColors.primary,
                  child: ListView.separated(
                    itemCount: vm.notifications.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final n = vm.notifications[i];
                      return NotificationCard(
                        title: n.title,
                        body: n.body,
                        isRead: n.isRead,
                        createdAt: n.createdAt,
                        onTap: () => vm.markRead(n.id),
                      );
                    },
                  ),
                ),
    );
  }
}
