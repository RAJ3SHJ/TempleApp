import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../login_screen.dart';
import 'member_list_screen.dart';
import 'add_donation_screen.dart';
import 'search_filter_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String adminName;
  const AdminDashboardScreen({super.key, required this.adminName});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _recentDonations = [
    {'name': 'Rajesh Samuel', 'id': 'GBC-00123', 'category': 'Tithe', 'amount': 5000, 'date': '09 May 2026', 'mode': 'Cash'},
    {'name': 'Priya Mathew', 'id': 'GBC-00124', 'category': 'Offering', 'amount': 1200, 'date': '09 May 2026', 'mode': 'UPI'},
    {'name': 'Thomas Jacob', 'id': 'GBC-00125', 'category': 'Building Fund', 'amount': 10000, 'date': '08 May 2026', 'mode': 'Cheque'},
    {'name': 'Anu Kurian', 'id': 'GBC-00126', 'category': 'Tithe', 'amount': 5000, 'date': '08 May 2026', 'mode': 'Cash'},
    {'name': 'Suresh Philip', 'id': 'GBC-00127', 'category': 'Special Fund', 'amount': 2500, 'date': '07 May 2026', 'mode': 'UPI'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  // ── MOBILE LAYOUT ──
  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildMobileHeader(),
        Expanded(child: _buildDashboardContent(isDesktop: false)),
        _buildMobileBottomNav(),
      ],
    );
  }

  Widget _buildMobileHeader() {
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
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.adminName.isNotEmpty ? widget.adminName[0].toUpperCase() : 'A',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.white),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Admin: ${widget.adminName}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.white)),
              const Text('Grace Bible Church',
                  style: TextStyle(fontSize: 11, color: Colors.white70)),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: _showSignOutDialog,
            icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBottomNav() {
    final items = [
      {'icon': Icons.dashboard_outlined, 'label': 'Dashboard'},
      {'icon': Icons.people_outline, 'label': 'Members'},
      {'icon': Icons.add_circle_outline, 'label': 'Add'},
      {'icon': Icons.search_outlined, 'label': 'Search'},
      {'icon': Icons.more_horiz_outlined, 'label': 'More'},
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
          final isActive = _selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(items[index]['icon'] as IconData, size: 22,
                      color: isActive ? AppTheme.navy : AppTheme.textSecondary),
                  const SizedBox(height: 3),
                  Text(items[index]['label'] as String,
                      style: TextStyle(fontSize: 10,
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

  // ── DESKTOP LAYOUT ──
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        _buildDesktopSidebar(),
        Expanded(child: _buildDashboardContent(isDesktop: true)),
      ],
    );
  }

  Widget _buildDesktopSidebar() {
    final navItems = [
      {'icon': Icons.dashboard_outlined, 'label': 'Dashboard'},
      {'icon': Icons.people_outline, 'label': 'Members'},
      {'icon': Icons.receipt_long_outlined, 'label': 'Donations'},
      {'icon': Icons.search_outlined, 'label': 'Search'},
      {'icon': Icons.tag_outlined, 'label': 'Categories'},
    ];

    return Container(
      width: 220,
      color: AppTheme.navy,
      child: Column(
        children: [
          // Sidebar header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 20,
              left: 16,
              right: 16,
            ),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      widget.adminName.isNotEmpty ? widget.adminName[0].toUpperCase() : 'A',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.white),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(widget.adminName,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.white)),
                const Text('Administrator',
                    style: TextStyle(fontSize: 11, color: Colors.white54)),
              ],
            ),
          ),

          // Nav items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: navItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isActive = _selectedIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border(
                          left: BorderSide(
                            color: isActive ? AppTheme.white : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(item['icon'] as IconData, size: 18,
                              color: isActive ? AppTheme.white : Colors.white60),
                          const SizedBox(width: 10),
                          Text(item['label'] as String,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                                  color: isActive ? AppTheme.white : Colors.white60)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Sign out
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            padding: const EdgeInsets.all(12),
            child: GestureDetector(
              onTap: _showSignOutDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 18, color: Colors.white60),
                    SizedBox(width: 10),
                    Text('Sign Out', style: TextStyle(fontSize: 14, color: Colors.white60)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── DASHBOARD CONTENT ──
  Widget _buildDashboardContent({required bool isDesktop}) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 24 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop) ...[
            Text('Dashboard', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.navy)),
            const SizedBox(height: 4),
            Text('Welcome back, ${widget.adminName}',
                style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
            const SizedBox(height: 24),
          ],

          // Stats
          _buildStatsGrid(isDesktop: isDesktop),
          const SizedBox(height: 20),

          // Quick Actions
          _buildSectionLabel('Quick Actions'),
          const SizedBox(height: 10),
          _buildQuickActions(isDesktop: isDesktop),
          const SizedBox(height: 20),

          // Recent Donations
          _buildSectionLabel('Recent Donations'),
          const SizedBox(height: 10),
          _buildRecentDonations(isDesktop: isDesktop),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary, letterSpacing: 0.8),
    );
  }

  Widget _buildStatsGrid({required bool isDesktop}) {
    final stats = [
      {'label': 'Total Members', 'value': '2,847', 'icon': Icons.people_outline, 'sub': 'Active members'},
      {'label': 'This Month', 'value': '₹3,42,000', 'icon': Icons.account_balance_wallet_outlined, 'sub': 'May 2026'},
      {'label': 'Total Collected', 'value': '₹48.2L', 'icon': Icons.bar_chart_outlined, 'sub': 'All time'},
      {'label': 'This Year', 'value': '₹12.4L', 'icon': Icons.calendar_today_outlined, 'sub': '2026'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: isDesktop ? 1.8 : 1.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppTheme.navyLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(stat['icon'] as IconData, size: 18, color: AppTheme.navy),
              ),
              const Spacer(),
              Text(stat['value'] as String,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.navy)),
              const SizedBox(height: 2),
              Text(stat['label'] as String,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions({required bool isDesktop}) {
    final actions = [
      {'icon': Icons.person_add_outlined, 'label': 'Add Member', 'color': AppTheme.navy},
      {'icon': Icons.add_card_outlined, 'label': 'Add Donation', 'color': AppTheme.navy},
      {'icon': Icons.people_outline, 'label': 'View Members', 'color': AppTheme.navy},
      {'icon': Icons.search_outlined, 'label': 'Search', 'color': AppTheme.navy},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: isDesktop ? 2.5 : 2,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return GestureDetector(
          onTap: () {
            final label = action['label'] as String;
            if (label == 'Add Member') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AddMemberScreen()));
            } else if (label == 'Search') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => SearchFilterScreen()));
            } else if (label == 'Add Donation') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AddDonationScreen()));
            } else if (label == 'View Members') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => MemberListScreen()));
            }
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.navyLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(action['icon'] as IconData, size: 18, color: AppTheme.navy),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(action['label'] as String,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentDonations({required bool isDesktop}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          if (isDesktop)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: const [
                  Expanded(flex: 3, child: Text('Member', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary))),
                  Expanded(flex: 2, child: Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary))),
                  Expanded(flex: 2, child: Text('Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary))),
                  Expanded(flex: 1, child: Text('Mode', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary))),
                  Expanded(flex: 2, child: Text('Amount', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary))),
                ],
              ),
            ),
          ..._recentDonations.asMap().entries.map((entry) {
            final isLast = entry.key == _recentDonations.length - 1;
            final donation = entry.value;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: isDesktop
                      ? _buildDesktopDonationRow(donation)
                      : _buildMobileDonationRow(donation),
                ),
                if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16, color: AppTheme.border),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDesktopDonationRow(Map<String, dynamic> donation) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.navyLight,
                child: Text(
                  (donation['name'] as String).split(' ').map((e) => e[0]).take(2).join(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.navy),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(donation['name'] as String,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                  Text(donation['id'] as String,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ],
          ),
        ),
        Expanded(flex: 2, child: Text(donation['category'] as String,
            style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary))),
        Expanded(flex: 2, child: Text(donation['date'] as String,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary))),
        Expanded(flex: 1, child: Text(donation['mode'] as String,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary))),
        Expanded(
          flex: 2,
          child: Text('₹${(donation['amount'] as int).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.navy)),
        ),
      ],
    );
  }

  Widget _buildMobileDonationRow(Map<String, dynamic> donation) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppTheme.navyLight,
          child: Text(
            (donation['name'] as String).split(' ').map((e) => e[0]).take(2).join(),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.navy),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(donation['name'] as String,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
              Text('${donation['category']} · ${donation['date']}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ),
        Text('₹${donation['amount']}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.navy)),
      ],
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        content: const Text('Are you sure you want to sign out of the admin portal?',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              minimumSize: const Size(80, 38),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
