import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/themes/app_colors.dart';


class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Mock Notifications Data
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'New Profile Scan',
        'message': '@john_doe just scanned your QR code!',
        'time': '2 mins ago',
        'type': 'scan',
        'isUnread': true,
      },
      {
        'title': 'Welcome to LinkMeUp',
        'message': 'Start sharing your world today!',
        'time': '1 hour ago',
        'type': 'system',
        'isUnread': false,
      },
      {
        'title': 'Profile Updated',
        'message': 'Your social links were successfully saved.',
        'time': 'Yesterday',
        'type': 'update',
        'isUnread': false,
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("Clear All", style: TextStyle(color: AppColors.primaryPurple)),
          ),
        ],
        backgroundColor: Colors.transparent,
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(context)
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = notifications[index];
                return _NotificationTile(item: item, isDark: isDark)
                    .animate(delay: (100 * index).ms)
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: 0.1, end: 0);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 80,
            color: AppColors.gray300.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "No notifications yet",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isDark;

  const _NotificationTile({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;

    switch (item['type']) {
      case 'scan':
        icon = Icons.qr_code_scanner_rounded;
        iconColor = AppColors.primaryPurple;
        break;
      case 'update':
        icon = Icons.sync_rounded;
        iconColor = AppColors.primaryBlue;
        break;
      default:
        icon = Icons.info_outline_rounded;
        iconColor = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: item['isUnread']
            ? Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      item['time'],
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item['message'],
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
