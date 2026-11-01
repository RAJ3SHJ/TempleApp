import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});
  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '-';
    final dt = (timestamp as Timestamp).toDate();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _getDay(dynamic timestamp) {
    if (timestamp == null) return '';
    final dt = (timestamp as Timestamp).toDate();
    return dt.day.toString().padLeft(2, '0');
  }

  String _getMonth(dynamic timestamp) {
    if (timestamp == null) return '';
    final dt = (timestamp as Timestamp).toDate();
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
        'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[dt.month - 1];
  }

  bool _isUpcoming(dynamic timestamp) {
    if (timestamp == null) return false;
    final dt = (timestamp as Timestamp).toDate();
    return dt.isAfter(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(context),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEventsTab(),
                _buildAnnouncementsTab(),
              ],
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
        bottom: 8, left: 16, right: 16,
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
          AnimatedBuilder(
            animation: _tabController,
            builder: (_, __) => Text(
                _tabController.index == 0 ? 'Events' : 'Upcoming Events',
                style: const TextStyle(fontSize: 18,
                    fontWeight: FontWeight.w600, color: AppTheme.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.navy,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.white,
        indicatorWeight: 3,
        labelColor: AppTheme.white,
        unselectedLabelColor: Colors.white54,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Events'),
          Tab(text: 'Upcoming Events'),
        ],
      ),
    );
  }

  Widget _buildEventsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.navy));
        }

        final docs = [...(snapshot.data?.docs ?? [])]..sort((a, b) {
            final ta = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            final tb = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            if (ta == null && tb == null) return 0;
            if (ta == null) return 1;
            if (tb == null) return -1;
            return ta.compareTo(tb);
          });
        if (docs.isEmpty) return _buildEmptyState('No events yet', Icons.event_outlined);

        return ListView.separated(
          padding: const EdgeInsets.all(14),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return _buildEventCard(data);
          },
        );
      },
    );
  }

  Widget _buildEventCard(Map<String, dynamic> data) {
    final title = (data['title'] as String? ?? '').trim();
    final description = (data['description'] as String? ?? '').trim();
    final venue = (data['location'] as String? ?? '').trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(title,
                style: const TextStyle(fontSize: 16,
                    fontWeight: FontWeight.w700, color: AppTheme.navy)),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(description,
                style: const TextStyle(fontSize: 14,
                    color: AppTheme.textPrimary, height: 1.4)),
          ],
          if (venue.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Venue: $venue',
                style: const TextStyle(fontSize: 14,
                    color: AppTheme.textSecondary, height: 1.4)),
          ],
        ],
      ),
    );
  }

  Widget _buildAnnouncementsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('announcements')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.navy));
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _buildEmptyState('No upcoming events yet', Icons.campaign_outlined);
        }

        return ListView.separated(
          padding: const EdgeInsets.all(14),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return _buildAnnouncementCard(data);
          },
        );
      },
    );
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> data) {
    final title = data['title'] as String? ?? '';
    final description = data['description'] as String? ?? '';
    final timestamp = data['createdAt'];
    String timeStr = '';
    if (timestamp != null) {
      final dt = (timestamp as Timestamp).toDate();
      final diff = DateTime.now().difference(dt);
      if (diff.inDays == 0) timeStr = 'Today';
      else if (diff.inDays == 1) timeStr = 'Yesterday';
      else timeStr = '${diff.inDays} days ago';
    }

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
              color: AppTheme.navyLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.campaign_outlined, color: AppTheme.navy, size: 20),
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
                    Text(timeStr,
                        style: const TextStyle(fontSize: 11,
                            color: AppTheme.textSecondary)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(description,
                    style: const TextStyle(fontSize: 13,
                        color: AppTheme.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64,
              color: AppTheme.textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(message,
              style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
