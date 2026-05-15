import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class BulletinScreen extends StatelessWidget {
  const BulletinScreen({super.key});

  final List<Map<String, dynamic>> _bulletins = const [
    {
      'id': '1',
      'title': 'Weekly Bulletin — May 10, 2026',
      'date': '10 May 2026',
      'isLatest': true,
      'pastoralMessage':
          'Dear members, we are blessed to gather again this Sunday in worship and fellowship. This week we continue our series on the Gospel of John. Let us remember to keep one another in prayer and continue to serve with joy and gratitude in our hearts.',
      'pastor': 'Pastor David Thomas',
      'schedule': [
        {'time': '09:00 AM', 'event': 'Pre-Service Prayer'},
        {'time': '10:00 AM', 'event': 'Sunday Worship Service'},
        {'time': '10:00 AM', 'event': 'Children\'s Sunday School'},
        {'time': '12:00 PM', 'event': 'Fellowship Lunch'},
        {'time': '06:30 PM', 'event': 'Wednesday Prayer Meeting'},
      ],
      'announcements': [
        'Choir auditions are open every Saturday 4–6 PM',
        'Sunday School enrollment now open for ages 4–12',
        'Volunteer sign-ups for Community Outreach Day on June 1st',
      ],
      'verse': '"This is the day the Lord has made; let us rejoice and be glad in it."',
      'verseRef': 'Psalm 118:24',
    },
    {
      'id': '2',
      'title': 'Weekly Bulletin — May 3, 2026',
      'date': '3 May 2026',
      'isLatest': false,
      'pastoralMessage':
          'Grace and peace to all our members. As we enter the month of May, let us be intentional about our faith walk and our commitment to the Body of Christ.',
      'pastor': 'Pastor David Thomas',
      'schedule': [
        {'time': '10:00 AM', 'event': 'Sunday Worship Service'},
        {'time': '11:30 AM', 'event': 'Youth Fellowship'},
        {'time': '06:30 PM', 'event': 'Wednesday Prayer Meeting'},
      ],
      'announcements': [
        'Monthly fasting prayer on May 7th',
        'New members orientation on May 10th',
      ],
      'verse': '"I can do all things through Christ who strengthens me."',
      'verseRef': 'Philippians 4:13',
    },
    {
      'id': '3',
      'title': 'Weekly Bulletin — April 26, 2026',
      'date': '26 Apr 2026',
      'isLatest': false,
      'pastoralMessage':
          'Beloved, as we reflect on the resurrection of our Lord, let us carry the joy of Easter into every area of our lives.',
      'pastor': 'Pastor David Thomas',
      'schedule': [
        {'time': '10:00 AM', 'event': 'Sunday Worship Service'},
        {'time': '06:30 PM', 'event': 'Wednesday Prayer Meeting'},
      ],
      'announcements': [
        'Easter special offering received — thank you for your generosity',
        'Bible study series on Romans begins next week',
      ],
      'verse': '"He is not here; he has risen, just as he said."',
      'verseRef': 'Matthew 28:6',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(14),
              itemCount: _bulletins.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildBulletinCard(context, _bulletins[index]);
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
        bottom: 16,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppTheme.white,
              size: 20,
            ),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 8),
          const Text(
            'Church Bulletin',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletinCard(
      BuildContext context, Map<String, dynamic> bulletin) {
    final isLatest = bulletin['isLatest'] as bool;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BulletinDetailScreen(bulletin: bulletin),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLatest ? AppTheme.navy : AppTheme.border,
            width: isLatest ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isLatest)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.navy,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Latest',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.white,
                      ),
                    ),
                  ),
                if (isLatest) const SizedBox(width: 8),
                Text(
                  bulletin['date'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              bulletin['title'] as String,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              bulletin['pastoralMessage'] as String,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.navyLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.format_quote_rounded,
                      size: 16, color: AppTheme.navy),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bulletin['verse'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.navy,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Bulletin Detail Screen
class BulletinDetailScreen extends StatelessWidget {
  final Map<String, dynamic> bulletin;
  const BulletinDetailScreen({super.key, required this.bulletin});

  @override
  Widget build(BuildContext context) {
    final schedule =
        bulletin['schedule'] as List<Map<String, dynamic>>;
    final announcements = bulletin['announcements'] as List<String>;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Header
          Container(
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
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppTheme.white,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Bulletin Detail',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.navy,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.church_rounded,
                                color: Colors.white70, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Grace Bible Church',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          bulletin['title'] as String,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bulletin['date'] as String,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Pastoral Message
                  _sectionCard(
                    title: 'Pastoral Message',
                    icon: Icons.volunteer_activism_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bulletin['pastoralMessage'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                            height: 1.75,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '— ${bulletin['pastor']}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Schedule
                  _sectionCard(
                    title: "This Week's Schedule",
                    icon: Icons.schedule_outlined,
                    child: Column(
                      children: schedule.asMap().entries.map((entry) {
                        final isLast = entry.key == schedule.length - 1;
                        final item = entry.value;
                        return Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 80,
                                    child: Text(
                                      item['time'] as String,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.navy,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item['event'] as String,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast)
                              const Divider(
                                  height: 1, color: AppTheme.border),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Announcements
                  _sectionCard(
                    title: 'Announcements',
                    icon: Icons.campaign_outlined,
                    child: Column(
                      children: announcements.asMap().entries.map((entry) {
                        final isLast =
                            entry.key == announcements.length - 1;
                        return Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.only(
                                        top: 6, right: 10),
                                    decoration: const BoxDecoration(
                                      color: AppTheme.navy,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textPrimary,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast)
                              const Divider(
                                  height: 1, color: AppTheme.border),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Verse
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.navyLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.format_quote_rounded,
                            color: AppTheme.navy, size: 28),
                        const SizedBox(height: 8),
                        Text(
                          bulletin['verse'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: AppTheme.navy,
                            height: 1.7,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          bulletin['verseRef'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.navy),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.border),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}