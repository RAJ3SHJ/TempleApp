import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class Event {
  final String id;
  final String title;
  final String date;
  final String day;
  final String month;
  final String time;
  final String location;
  final String category;
  final bool isUpcoming;

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.day,
    required this.month,
    required this.time,
    required this.location,
    required this.category,
    this.isUpcoming = true,
  });
}

class Announcement {
  final String id;
  final String title;
  final String description;
  final String postedOn;
  final String icon;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.postedOn,
    required this.icon,
  });
}

class _EventsScreenState extends State<EventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Event> _events = [
    Event(
      id: '1',
      title: 'Annual Thanksgiving Service',
      date: '18',
      day: 'Sunday',
      month: 'MAY',
      time: '10:00 AM',
      location: 'Main Hall',
      category: 'Special',
      isUpcoming: true,
    ),
    Event(
      id: '2',
      title: 'Youth Bible Study',
      date: '22',
      day: 'Thursday',
      month: 'MAY',
      time: '6:00 PM',
      location: 'Room 2',
      category: 'Youth',
      isUpcoming: true,
    ),
    Event(
      id: '3',
      title: 'Community Outreach Day',
      date: '01',
      day: 'Saturday',
      month: 'JUN',
      time: '8:00 AM',
      location: 'Church Ground',
      category: 'Community',
      isUpcoming: true,
    ),
    Event(
      id: '4',
      title: 'Women\'s Prayer Fellowship',
      date: '07',
      day: 'Friday',
      month: 'JUN',
      time: '5:00 PM',
      location: 'Room 1',
      category: 'Prayer',
      isUpcoming: true,
    ),
    Event(
      id: '5',
      title: 'Good Friday Service',
      date: '18',
      day: 'Friday',
      month: 'APR',
      time: '10:00 AM',
      location: 'Main Hall',
      category: 'Special',
      isUpcoming: false,
    ),
    Event(
      id: '6',
      title: 'Easter Sunday Celebration',
      date: '20',
      day: 'Sunday',
      month: 'APR',
      time: '9:00 AM',
      location: 'Main Hall',
      category: 'Special',
      isUpcoming: false,
    ),
  ];

  final List<Announcement> _announcements = [
    Announcement(
      id: '1',
      title: 'Church Choir Auditions Open',
      description:
          'We are looking for talented singers to join our choir. Auditions will be held every Saturday from 4–6 PM.',
      postedOn: '8 May 2026',
      icon: '🎵',
    ),
    Announcement(
      id: '2',
      title: 'Sunday School Enrollment',
      description:
          'Enrollment for Sunday School 2026 is now open for children aged 4–12. Contact the church office for details.',
      postedOn: '5 May 2026',
      icon: '📚',
    ),
    Announcement(
      id: '3',
      title: 'Volunteer Opportunity',
      description:
          'We need volunteers for our upcoming Community Outreach Day on June 1st. Sign up at the reception.',
      postedOn: '1 May 2026',
      icon: '🤝',
    ),
    Announcement(
      id: '4',
      title: 'New Church App Launched',
      description:
          'Our church app is now live! Share with fellow members to stay connected and track your donations.',
      postedOn: '28 Apr 2026',
      icon: '📱',
    ),
  ];

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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Special':
        return AppTheme.navy;
      case 'Youth':
        return const Color(0xFF7C3AED);
      case 'Community':
        return AppTheme.success;
      case 'Prayer':
        return AppTheme.gold;
      default:
        return AppTheme.navy;
    }
  }

  Color _getCategoryBgColor(String category) {
    switch (category) {
      case 'Special':
        return AppTheme.navyLight;
      case 'Youth':
        return const Color(0xFFEDE9FE);
      case 'Community':
        return AppTheme.successLight;
      case 'Prayer':
        return const Color(0xFFFEF3C7);
      default:
        return AppTheme.navyLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(),
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
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppTheme.white,
              size: 20,
            ),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 8),
          const Text(
            'Events & Announcements',
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

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.navy,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.white,
        indicatorWeight: 3,
        labelColor: AppTheme.white,
        unselectedLabelColor: Colors.white54,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(text: 'Events'),
          Tab(text: 'Announcements'),
        ],
      ),
    );
  }

  Widget _buildEventsTab() {
    final upcoming = _events.where((e) => e.isUpcoming).toList();
    final past = _events.where((e) => !e.isUpcoming).toList();

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _sectionLabel('Upcoming Events'),
        ...upcoming.map((e) => _buildEventCard(e, isUpcoming: true)),
        const SizedBox(height: 8),
        _sectionLabel('Past Events'),
        ...past.map((e) => _buildEventCard(e, isUpcoming: false)),
      ],
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event, {required bool isUpcoming}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date box
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isUpcoming ? AppTheme.navy : AppTheme.navyLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  event.date,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isUpcoming ? AppTheme.white : AppTheme.navy,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.month,
                  style: TextStyle(
                    fontSize: 10,
                    color: isUpcoming
                        ? Colors.white70
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${event.day} · ${event.time}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event.location,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryBgColor(event.category),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    event.category,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getCategoryColor(event.category),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: _announcements.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final announcement = _announcements[index];
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.navyLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        announcement.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          announcement.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Posted ${announcement.postedOn}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppTheme.border),
              const SizedBox(height: 12),
              Text(
                announcement.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                  height: 1.65,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}