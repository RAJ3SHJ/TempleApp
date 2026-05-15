import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String time;
  final String type;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<AppNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = [
      AppNotification(
        id: '1',
        title: 'Donation Recorded',
        message: '₹5,000 Tithe has been recorded against your account for 09 May 2026.',
        time: '2 days ago',
        type: 'donation',
        isRead: false,
      ),
      AppNotification(
        id: '2',
        title: 'Live Service Starting',
        message: 'Sunday Morning Worship is starting now. Join us on YouTube!',
        time: 'Today, 9:30 AM',
        type: 'live',
        isRead: false,
      ),
      AppNotification(
        id: '3',
        title: 'New Event Added',
        message: 'Annual Thanksgiving Service has been added for May 18, 2026 at 10:00 AM.',
        time: '5 days ago',
        type: 'event',
        isRead: true,
      ),
      AppNotification(
        id: '4',
        title: 'New Bulletin Published',
        message: 'Weekly Bulletin for May 10, 2026 is now available. Tap to read.',
        time: 'Today, 8:00 AM',
        type: 'bulletin',
        isRead: false,
      ),
      AppNotification(
        id: '5',
        title: 'Donation Recorded',
        message: '₹1,500 Offering has been recorded against your account for 02 May 2026.',
        time: '1 week ago',
        type: 'donation',
        isRead: true,
      ),
      AppNotification(
        id: '6',
        title: 'Prayer Request Update',
        message: 'Our pastoral team has acknowledged your prayer request. You are in our prayers.',
        time: '1 week ago',
        type: 'prayer',
        isRead: true,
      ),
      AppNotification(
        id: '7',
        title: 'New Announcement',
        message: 'Church Choir Auditions are now open. Join us every Saturday 4-6 PM.',
        time: '8 May 2026',
        type: 'announcement',
        isRead: true,
      ),
    ];
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      for (var n in _notifications) {
        n.isRead = true;
      }
    });
  }

  void _markRead(String id) {
    setState(() {
      final notification = _notifications.firstWhere((n) => n.id == id);
      notification.isRead = true;
    });
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'donation': return Icons.receipt_long_outlined;
      case 'live': return Icons.live_tv_outlined;
      case 'event': return Icons.calendar_month_outlined;
      case 'bulletin': return Icons.newspaper_outlined;
      case 'prayer': return Icons.favorite_outlined;
      case 'announcement': return Icons.campaign_outlined;
      default: return Icons.notifications_outlined;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'donation': return AppTheme.success;
      case 'live': return const Color(0xFFDC2626);
      case 'event': return AppTheme.navy;
      case 'bulletin': return AppTheme.gold;
      case 'prayer': return const Color(0xFF7C3AED);
      case 'announcement': return AppTheme.navyMid;
      default: return AppTheme.navy;
    }
  }

  Color _getIconBgColor(String type) {
    switch (type) {
      case 'donation': return AppTheme.successLight;
      case 'live': return AppTheme.errorLight;
      case 'event': return AppTheme.navyLight;
      case 'bulletin': return const Color(0xFFFEF3C7);
      case 'prayer': return const Color(0xFFEDE9FE);
      case 'announcement': return AppTheme.navyLight;
      default: return AppTheme.navyLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _notifications.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(14),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(_notifications[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppTheme.navy,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 16,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.white, size: 20),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 8),
          const Text(
            'Notifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.white),
          ),
          if (_unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_unreadCount new',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
          const Spacer(),
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteNotification(notification.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFDC2626),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
      ),
      child: GestureDetector(
        onTap: () => _markRead(notification.id),
        child: Container(
          decoration: BoxDecoration(
            color: notification.isRead ? AppTheme.white : AppTheme.navyLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead ? AppTheme.border : AppTheme.navy.withOpacity(0.2),
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _getIconBgColor(notification.type),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIcon(notification.type),
                  size: 20,
                  color: _getIconColor(notification.type),
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.navy,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.time,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 64,
              color: AppTheme.textSecondary.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text('No notifications yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary.withOpacity(0.6))),
          const SizedBox(height: 6),
          Text('You\'re all caught up!',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary.withOpacity(0.5))),
        ],
      ),
    );
  }
}