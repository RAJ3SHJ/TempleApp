import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class LiveTelecastScreen extends StatefulWidget {
  const LiveTelecastScreen({super.key});

  @override
  State<LiveTelecastScreen> createState() => _LiveTelecastScreenState();
}

class PastLivestream {
  final String title;
  final String date;
  final String duration;
  final int views;

  PastLivestream({
    required this.title,
    required this.date,
    required this.duration,
    required this.views,
  });
}

class _LiveTelecastScreenState extends State<LiveTelecastScreen> {
  final bool _isLive = true;

  final List<PastLivestream> _pastStreams = [
    PastLivestream(title: 'Sunday Service — May 3, 2026', date: '3 May 2026', duration: '1h 45min', views: 1200),
    PastLivestream(title: 'Good Friday Service 2026', date: '18 Apr 2026', duration: '2h 10min', views: 3400),
    PastLivestream(title: 'Easter Sunday Celebration', date: '20 Apr 2026', duration: '1h 30min', views: 4100),
    PastLivestream(title: 'Sunday Service — Apr 27, 2026', date: '27 Apr 2026', duration: '1h 50min', views: 980),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildLivePlayer(),
                  const SizedBox(height: 14),
                  _buildLiveInfo(),
                  const SizedBox(height: 14),
                  _buildPastStreams(),
                  const SizedBox(height: 20),
                ],
              ),
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
            'Live Telecast',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.white),
          ),
          const Spacer(),
          if (_isLive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.white),
                  SizedBox(width: 5),
                  Text('LIVE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLivePlayer() {
    return Container(
      color: Colors.black,
      height: 220,
      child: Stack(
        children: [
          // Player background
          Container(
            color: const Color(0xFF0A0A1A),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.live_tv_outlined, size: 52, color: Colors.white38),
                  const SizedBox(height: 12),
                  if (_isLive) ...[
                    const Text(
                      'Sunday Morning Worship',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF0000),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 6),
                          Text('Watch on YouTube', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                        ],
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'No Live Service Right Now',
                      style: TextStyle(fontSize: 15, color: Colors.white54),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Join us every Sunday at 10:00 AM',
                      style: TextStyle(fontSize: 13, color: Colors.white38),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Live indicator overlay
          if (_isLive)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: Colors.white),
                    SizedBox(width: 4),
                    Text('LIVE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLiveInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sunday Morning Worship',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              '10 May 2026 · Started 09:30 AM',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppTheme.border),
            const SizedBox(height: 14),
            Row(
              children: [
                _infoChip(Icons.people_outline_rounded, '248 watching'),
                const SizedBox(width: 16),
                _infoChip(Icons.access_time_rounded, 'Started 45 min ago'),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppTheme.border),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.navyLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: AppTheme.navy),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This live service is streamed via our YouTube channel. Tap Watch on YouTube to join.',
                      style: TextStyle(fontSize: 13, color: AppTheme.navy, height: 1.5),
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

  Widget _infoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.navy),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildPastStreams() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PREVIOUS LIVESTREAMS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary, letterSpacing: 0.8),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: _pastStreams.asMap().entries.map((entry) {
                final isLast = entry.key == _pastStreams.length - 1;
                final stream = entry.value;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.navyLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.play_circle_outline_rounded, color: AppTheme.navy, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(stream.title,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Text(stream.date, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                    const SizedBox(width: 8),
                                    Text('·', style: const TextStyle(color: AppTheme.textSecondary)),
                                    const SizedBox(width: 8),
                                    Text('${stream.views} views', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary, size: 20),
                        ],
                      ),
                    ),
                    if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16, color: AppTheme.border),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}