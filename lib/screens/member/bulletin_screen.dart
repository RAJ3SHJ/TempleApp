import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';

class BulletinScreen extends StatelessWidget {
  const BulletinScreen({super.key});

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '-';
    final dt = (timestamp as Timestamp).toDate();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
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
                  .collection('bulletins')
                  .orderBy('date', descending: true)
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
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return _buildBulletinCard(context, data, index == 0);
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
          const Text('Church Bulletin',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                  color: AppTheme.white)),
        ],
      ),
    );
  }

  Widget _buildBulletinCard(BuildContext context, Map<String, dynamic> data,
      bool isLatest) {
    final title = data['title'] as String? ?? '';
    final pastor = data['pastor'] as String? ?? '';
    final pastoralMessage = data['pastoralMessage'] as String? ?? '';
    final verse = data['verse'] as String? ?? '';
    final verseRef = data['verseRef'] as String? ?? '';
    final schedule = data['schedule'] as List<dynamic>? ?? [];
    final announcements = data['announcements'] as List<dynamic>? ?? [];
    final date = _formatDate(data['date']);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isLatest ? AppTheme.navy : AppTheme.border,
            width: isLatest ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLatest ? AppTheme.navy : AppTheme.navyLight,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isLatest)
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Latest',
                              style: TextStyle(fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.white)),
                        ),
                      Text(title,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700,
                              color: isLatest ? AppTheme.white : AppTheme.navy)),
                      const SizedBox(height: 3),
                      Text(date,
                          style: TextStyle(fontSize: 12,
                              color: isLatest ? Colors.white70 : AppTheme.textSecondary)),
                    ],
                  ),
                ),
                Icon(Icons.article_outlined,
                    color: isLatest ? Colors.white70 : AppTheme.navy, size: 24),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Verse
                if (verse.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.navyLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border(
                          left: BorderSide(color: AppTheme.navy, width: 3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(verse,
                            style: const TextStyle(fontSize: 13,
                                color: AppTheme.navy,
                                fontStyle: FontStyle.italic, height: 1.5)),
                        if (verseRef.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text('— $verseRef',
                              style: const TextStyle(fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.navy)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Pastoral Message
                if (pastoralMessage.isNotEmpty) ...[
                  const Text('Pastoral Message',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                          color: AppTheme.navy)),
                  const SizedBox(height: 6),
                  Text(pastoralMessage,
                      style: const TextStyle(fontSize: 13,
                          color: AppTheme.textSecondary, height: 1.6)),
                  if (pastor.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text('— $pastor',
                        style: const TextStyle(fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.navy)),
                  ],
                  const SizedBox(height: 14),
                ],

                // Schedule
                if (schedule.isNotEmpty) ...[
                  const Text('Service Schedule',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                          color: AppTheme.navy)),
                  const SizedBox(height: 8),
                  ...schedule.map((item) {
                    final s = item as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            child: Text(s['time'] as String? ?? '',
                                style: const TextStyle(fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.navy)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(s['event'] as String? ?? '',
                                style: const TextStyle(fontSize: 13,
                                    color: AppTheme.textPrimary)),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 14),
                ],

                // Announcements
                if (announcements.isNotEmpty) ...[
                  const Text('Announcements',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                          color: AppTheme.navy)),
                  const SizedBox(height: 8),
                  ...announcements.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.circle, size: 6, color: AppTheme.navy),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(item as String,
                              style: const TextStyle(fontSize: 13,
                                  color: AppTheme.textSecondary, height: 1.4)),
                        ),
                      ],
                    ),
                  )),
                ],
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
          Icon(Icons.article_outlined, size: 64,
              color: AppTheme.textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text('No bulletins yet',
              style: TextStyle(fontSize: 15, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
