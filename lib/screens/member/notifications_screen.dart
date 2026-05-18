import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    final dt = (timestamp as Timestamp).toDate();
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'donation': return Icons.favorite_outline;
      case 'live': return Icons.live_tv_outlined;
      case 'event': return Icons.event_outlined;
      case 'bulletin': return Icons.article_outlined;
      default: return Icons.notifications_outlined;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'donation': return AppTheme.success;
      case 'live': return AppTheme.error;
      case 'event': return AppTheme.gold;
      case 'bulletin': return AppTheme.navy;
      default: return AppTheme.navyMid;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: AppTheme.navy));
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) return _buildEmptyState();

                return ListView.separated(
                  padding: const EdgeInsets.all(14),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return _buildNotificationCard(data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppTheme.navy,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 16, left: 16, right: 16,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppTheme.white, size: 20),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 8),
          const Text('Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                  color: AppTheme.white)),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> data) {
    final type = data['type'] as String? ?? 'general';
    final title = data['title'] as String? ?? '';
    final body = data['body'] as String? ?? '';
    final color = _getColor(type);
    final icon = _getIcon(type);
    final time = _formatDate(data['createdAt']);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title,
                          style: const TextStyle(fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary)),
                    ),
                    Text(time,
                        style: const TextStyle(fontSize: 11,
                            color: AppTheme.textSecondary)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(body,
                    style: const TextStyle(fontSize: 13,
                        color: AppTheme.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_outlined, size: 64,
              color: AppTheme.textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text('No notifications yet',
              style: TextStyle(fontSize: 15, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
