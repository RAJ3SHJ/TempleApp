import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../login_screen.dart';
import 'member_list_screen.dart';
import 'add_donation_screen.dart';
import 'search_filter_screen.dart';
import 'category_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String adminName;
  const AdminDashboardScreen({super.key, required this.adminName});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic> _stats = {
    'totalMembers': 0,
    'monthlyTotal': 0.0,
    'allTimeTotal': 0.0,
    'thisYearTotal': 0.0,
  };
  List<Map<String, dynamic>> _recentDonations = [];
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadRecentDonations();
  }

  void _loadStats() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfYear = DateTime(now.year, 1, 1);

      final membersSnap = await FirebaseFirestore.instance
          .collection('members').count().get();
      final allDonations = await FirebaseFirestore.instance
          .collection('donations').get();

      double monthlyTotal = 0;
      double allTimeTotal = 0;
      double yearTotal = 0;

      for (final doc in allDonations.docs) {
        final data = doc.data();
        final amount = (data['amount'] as num? ?? 0).toDouble();
        final date = (data['date'] as dynamic)?.toDate() as DateTime?;
        allTimeTotal += amount;
        if (date != null) {
          if (date.isAfter(startOfMonth)) monthlyTotal += amount;
          if (date.isAfter(startOfYear)) yearTotal += amount;
        }
      }

      if (mounted) {
        setState(() {
          _stats = {
            'totalMembers': membersSnap.count ?? 0,
            'monthlyTotal': monthlyTotal,
            'allTimeTotal': allTimeTotal,
            'thisYearTotal': yearTotal,
          };
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  void _loadRecentDonations() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('donations')
          .orderBy('date', descending: true)
          .limit(5)
          .get();

      if (mounted) {
        setState(() {
          _recentDonations = snap.docs.map((doc) {
            final data = doc.data();
            final date = (data['date'] as dynamic)?.toDate() as DateTime?;
            final dateStr = date != null
                ? '${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)} ${date.year}'
                : '-';
            return {
              'name': data['memberName'] ?? '',
              'id': data['memberId'] ?? '',
              'category': data['category'] ?? '',
              'amount': (data['amount'] as num? ?? 0).toDouble(),
              'date': dateStr,
              'mode': data['mode'] ?? '',
            };
          }).toList();
        });
      }
    } catch (e) {
      // Keep empty list
    }
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return '₹${amount.toStringAsFixed(0)}';
  }

  void _navigate(int index) {
    switch (index) {
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MemberListScreen()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => AddDonationScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => SearchFilterScreen()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryManagementScreen()));
        break;
    }
  }

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
        bottom: 16, left: 16, right: 16,
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
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
      {'icon': Icons.add_circle_outline, 'label': 'Donations'},
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
              onTap: () {
                if (index == 0) {
                  setState(() => _selectedIndex = 0);
                } else {
                  _navigate(index);
                }
              },
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
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 20, left: 16, right: 16,
            ),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: navItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isActive = _selectedIndex == index;
                  return GestureDetector(
                    onTap: () {
                      if (index == 0) {
                        setState(() => _selectedIndex = 0);
                      } else {
                        _navigate(index);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
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
                              style: TextStyle(fontSize: 14,
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
                  color: Colors.white.withValues(alpha: 0.08),
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
            const Text('Dashboard',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.navy)),
            const SizedBox(height: 4),
            Text('Welcome back, ${widget.adminName}',
                style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
            const SizedBox(height: 24),
          ],
          _buildStatsGrid(isDesktop: isDesktop),
          const SizedBox(height: 20),
          _buildSectionLabel('Quick Actions'),
          const SizedBox(height: 10),
          _buildQuickActions(isDesktop: isDesktop),
          const SizedBox(height: 20),
          _buildSectionLabel('Recent Donations'),
          const SizedBox(height: 10),
          _buildRecentDonations(isDesktop: isDesktop),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary, letterSpacing: 0.8));
  }

  Widget _buildStatsGrid({required bool isDesktop}) {
    final stats = [
      {
        'label': 'Total Members',
        'value': _isLoadingStats ? '...' : '${_stats['totalMembers']}',
        'icon': Icons.people_outline,
      },
      {
        'label': 'This Month',
        'value': _isLoadingStats ? '...' : _formatAmount(_stats['monthlyTotal']),
        'icon': Icons.account_balance_wallet_outlined,
      },
      {
        'label': 'Total Collected',
        'value': _isLoadingStats ? '...' : _formatAmount(_stats['allTimeTotal']),
        'icon': Icons.bar_chart_outlined,
      },
      {
        'label': 'This Year',
        'value': _isLoadingStats ? '...' : _formatAmount(_stats['thisYearTotal']),
        'icon': Icons.calendar_today_outlined,
      },
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
                width: 34, height: 34,
                decoration: BoxDecoration(
                    color: AppTheme.navyLight, borderRadius: BorderRadius.circular(10)),
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
      {'icon': Icons.person_add_outlined, 'label': 'Add Member'},
      {'icon': Icons.add_card_outlined, 'label': 'Add Donation'},
      {'icon': Icons.people_outline, 'label': 'View Members'},
      {'icon': Icons.search_outlined, 'label': 'Search'},
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
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMemberScreen()));
            } else if (label == 'Add Donation') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AddDonationScreen()));
            } else if (label == 'View Members') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MemberListScreen()));
            } else if (label == 'Search') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => SearchFilterScreen()));
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
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                      color: AppTheme.navyLight, borderRadius: BorderRadius.circular(10)),
                  child: Icon(action['icon'] as IconData, size: 18, color: AppTheme.navy),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(action['label'] as String,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentDonations({required bool isDesktop}) {
    if (_recentDonations.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: const Center(
          child: Text('No donations yet',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: _recentDonations.asMap().entries.map((entry) {
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
        }).toList(),
      ),
    );
  }

  Widget _buildDesktopDonationRow(Map<String, dynamic> donation) {
    final name = donation['name'] as String;
    final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join();
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.navyLight,
                child: Text(initials,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.navy)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary)),
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
          child: Text(_formatAmount((donation['amount'] as num).toDouble()),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.navy)),
        ),
      ],
    );
  }

  Widget _buildMobileDonationRow(Map<String, dynamic> donation) {
    final name = donation['name'] as String;
    final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join();
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppTheme.navyLight,
          child: Text(initials,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.navy)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary)),
              Text('${donation['category']} · ${donation['date']}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ),
        Text(_formatAmount((donation['amount'] as num).toDouble()),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.navy)),
      ],
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        content: const Text('Are you sure you want to sign out of the admin portal?',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
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
