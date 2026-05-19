import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import 'donation_history_screen.dart';
import 'profile_screen.dart';
import 'events_screen.dart';
import 'prayer_request_screen.dart';
import 'bulletin_screen.dart';
import 'contact_screen.dart';
import 'video_library_screen.dart';
import 'live_telecast_screen.dart';
import 'notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String memberId;
  const DashboardScreen({super.key, required this.memberId});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? _memberData;
  double _totalDonations = 0;
  double _thisMonthDonations = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Load member data
        final memberDoc = await FirebaseFirestore.instance
            .collection('members').doc(user.uid).get();
        if (memberDoc.exists && mounted) {
          setState(() => _memberData = memberDoc.data());
        }

        // Load donation totals
        final memberId = _memberData?['memberId'] ?? widget.memberId;
        final donations = await FirebaseFirestore.instance
            .collection('donations')
            .where('memberId', isEqualTo: memberId)
            .get();

        double total = 0;
        double thisMonth = 0;
        final now = DateTime.now();
        for (final doc in donations.docs) {
          final amount = (doc.data()['amount'] as num? ?? 0).toDouble();
          total += amount;
          final date = (doc.data()['date'] as Timestamp?)?.toDate();
          if (date != null && date.month == now.month && date.year == now.year) {
            thisMonth += amount;
          }
        }

        if (mounted) {
          setState(() {
            _totalDonations = total;
            _thisMonthDonations = thisMonth;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _formattedDate {
    final now = DateTime.now();
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'];
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday',
        'Friday', 'Saturday', 'Sunday'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  void _onServiceTap(String title) {
    switch (title) {
      case 'Donation History':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DonationHistoryScreen()));
        break;
      case 'Events':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const EventsScreen()));
        break;
      case 'Prayer Request':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerRequestScreen()));
        break;
      case 'Live Telecast':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveTelecastScreen()));
        break;
      case 'Video Library':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const VideoLibraryScreen()));
        break;
      case 'Contact Church':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactScreen()));
        break;
      case 'Bulletin':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const BulletinScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _memberData?['name'] as String? ?? 'Member';
    final memberId = _memberData?['memberId'] as String? ?? widget.memberId;

    final services = [
      {'icon': Icons.favorite_outline, 'title': 'Donation History', 'color': AppTheme.navy},
      {'icon': Icons.event_outlined, 'title': 'Events', 'color': AppTheme.navy},
      {'icon': Icons.volunteer_activism_outlined, 'title': 'Prayer Request', 'color': AppTheme.navy},
      {'icon': Icons.live_tv_outlined, 'title': 'Live Telecast', 'color': AppTheme.navy},
      {'icon': Icons.video_library_outlined, 'title': 'Video Library', 'color': AppTheme.navy},
      {'icon': Icons.article_outlined, 'title': 'Bulletin', 'color': AppTheme.navy},
      {'icon': Icons.phone_outlined, 'title': 'Contact Church', 'color': AppTheme.navy},
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Home Tab
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.navy))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(context, name, memberId),
                      _buildDonationSummary(),
                      _buildServicesGrid(services),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
          // Notifications Tab
          const NotificationsScreen(),
          // Profile Tab
          ProfileScreen(memberId: memberId),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader(BuildContext context, String name, String memberId) {
    return Container(
      color: AppTheme.navy,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 24, left: 20, right: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$_greeting,',
                        style: const TextStyle(fontSize: 14, color: Colors.white70)),
                    const SizedBox(height: 2),
                    Text(name,
                        style: const TextStyle(fontSize: 22,
                            fontWeight: FontWeight.w700, color: AppTheme.white)),
                    const SizedBox(height: 4),
                    Text(memberId,
                        style: const TextStyle(fontSize: 13, color: Colors.white60)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_outlined,
                      color: AppTheme.white, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(_formattedDate,
              style: const TextStyle(fontSize: 12, color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildDonationSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Giving',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 4),
                Text('₹${_totalDonations.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 22,
                        fontWeight: FontWeight.w700, color: AppTheme.navy)),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: AppTheme.border),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('This Month',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 4),
                  Text('₹${_thisMonthDonations.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 22,
                          fontWeight: FontWeight.w700, color: AppTheme.navy)),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const DonationHistoryScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.navyLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('View All',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: AppTheme.navy)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid(List<Map<String, dynamic>> services) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SERVICES',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary, letterSpacing: 0.8)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.0,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return GestureDetector(
                onTap: () => _onServiceTap(service['title'] as String),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.navyLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(service['icon'] as IconData,
                            size: 22, color: AppTheme.navy),
                      ),
                      const SizedBox(height: 8),
                      Text(service['title'] as String,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_outlined, 'activeIcon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.notifications_outlined, 'activeIcon': Icons.notifications_rounded, 'label': 'Notifications'},
      {'icon': Icons.person_outline_rounded, 'activeIcon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.white,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 8,
        top: 8,
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final isActive = _currentIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentIndex = index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isActive
                        ? items[index]['activeIcon'] as IconData
                        : items[index]['icon'] as IconData,
                    size: 24,
                    color: isActive ? AppTheme.navy : AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 3),
                  Text(items[index]['label'] as String,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive ? AppTheme.navy : AppTheme.textSecondary)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
