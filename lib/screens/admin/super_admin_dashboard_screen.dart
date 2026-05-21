import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../login_screen.dart';
import 'admin_accounts_screen.dart';
import 'send_notification_screen.dart';
import 'role_management_screen.dart';
import 'reports_screen.dart';

class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() => _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _auditLog = [
    {'action': 'Donation edited', 'admin': 'Admin Alex', 'detail': 'RC-0088', 'time': '2h ago', 'type': 'edit'},
    {'action': 'Member added', 'admin': 'Admin Sarah', 'detail': 'GBC-00248', 'time': '4h ago', 'type': 'add'},
    {'action': 'Donation deleted', 'admin': 'Admin Alex', 'detail': 'RC-0079', 'time': 'Yesterday', 'type': 'delete'},
    {'action': 'Member deactivated', 'admin': 'Admin Raju', 'detail': 'GBC-00201', 'time': '2 days ago', 'type': 'edit'},
    {'action': 'Category added', 'admin': 'Admin Sarah', 'detail': 'Missions', 'time': '3 days ago', 'type': 'add'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  // ── MOBILE ──
  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildMobileHeader(),
        Expanded(child: _buildContent(isDesktop: false)),
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
              color: Colors.amber.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.workspace_premium_outlined, size: 20, color: Colors.amber),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Super Admin', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.white)),
              Text('Grace Bible Church', style: TextStyle(fontSize: 11, color: Colors.white70)),
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
      {'icon': Icons.manage_accounts_outlined, 'label': 'Admins'},
      {'icon': Icons.key_outlined, 'label': 'Roles'},
      {'icon': Icons.bar_chart_outlined, 'label': 'Reports'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.white,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 8, top: 8),
      child: Row(
        children: List.generate(items.length, (index) {
          final isActive = _selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (index == 1) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AdminAccountsScreen()));
                } else if (index == 2) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => RoleManagementScreen()));
                } else if (index == 3) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ReportsScreen()));
                } else {
                  setState(() => _selectedIndex = index);
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

  // ── DESKTOP ──
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        _buildDesktopSidebar(),
        Expanded(child: _buildContent(isDesktop: true)),
      ],
    );
  }

  Widget _buildDesktopSidebar() {
    final navItems = [
      {'icon': Icons.dashboard_outlined, 'label': 'Dashboard'},
      {'icon': Icons.manage_accounts_outlined, 'label': 'Admin Accounts'},
      {'icon': Icons.key_outlined, 'label': 'Role Management'},
      {'icon': Icons.bar_chart_outlined, 'label': 'Reports & Export'},
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
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.workspace_premium_outlined, size: 22, color: Colors.amber),
                ),
                const SizedBox(height: 10),
                const Text('Super Admin',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.white)),
                const Text('Full Access',
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
                      if (index == 1) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => AdminAccountsScreen()));
                      } else if (index == 2) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => RoleManagementScreen()));
                      } else if (index == 3) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ReportsScreen()));
                      } else {
                        setState(() => _selectedIndex = index);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border(left: BorderSide(
                          color: isActive ? AppTheme.white : Colors.transparent, width: 3)),
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
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white12))),
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

  // ── CONTENT ──
  Widget _buildContent({required bool isDesktop}) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 24 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop) ...[
            const Text('Super Admin Dashboard',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.navy)),
            const SizedBox(height: 4),
            const Text('Full system access and control',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
            const SizedBox(height: 24),
          ],
          _buildStatsGrid(isDesktop: isDesktop),
          const SizedBox(height: 20),
          _buildSectionLabel('Quick Actions'),
          const SizedBox(height: 10),
          _buildQuickActions(isDesktop: isDesktop),
          const SizedBox(height: 20),
          _buildSectionLabel('Recent Audit Trail'),
          const SizedBox(height: 10),
          _buildAuditTrail(),
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
      {'label': 'Total Members', 'value': '2,847', 'icon': Icons.people_outline, 'color': AppTheme.navy},
      {'label': 'Total Collected', 'value': '₹48.2L', 'icon': Icons.account_balance_outlined, 'color': AppTheme.success},
      {'label': 'Active Admins', 'value': '6', 'icon': Icons.admin_panel_settings_outlined, 'color': AppTheme.navyMid},
      {'label': 'This Month', 'value': '₹3.4L', 'icon': Icons.calendar_today_outlined, 'color': AppTheme.gold},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        crossAxisSpacing: 10, mainAxisSpacing: 10,
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
                  color: (stat['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(stat['icon'] as IconData, size: 18, color: stat['color'] as Color),
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
      {'icon': Icons.manage_accounts_outlined, 'label': 'Admin Accounts', 'desc': 'Manage admin users'},
      {'icon': Icons.key_outlined, 'label': 'Role Management', 'desc': 'Set permissions'},
      {'icon': Icons.bar_chart_outlined, 'label': 'Reports', 'desc': 'View & export reports'},
      {'icon': Icons.notifications_outlined, 'label': 'Send Notification', 'desc': 'Notify all members'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        crossAxisSpacing: 10, mainAxisSpacing: 10,
        childAspectRatio: isDesktop ? 2 : 1.6,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return GestureDetector(
          onTap: () {
            if (index == 0) Navigator.push(context, MaterialPageRoute(builder: (_) => AdminAccountsScreen()));
            if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (_) => RoleManagementScreen()));
            if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => ReportsScreen()));
            if (index == 3) Navigator.push(context, MaterialPageRoute(builder: (_) => SendNotificationScreen()));
          },
          child: Container(
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
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: AppTheme.navyLight, borderRadius: BorderRadius.circular(10)),
                  child: Icon(action['icon'] as IconData, size: 18, color: AppTheme.navy),
                ),
                const SizedBox(height: 8),
                Text(action['label'] as String,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                Text(action['desc'] as String,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAuditTrail() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: _auditLog.asMap().entries.map((entry) {
          final isLast = entry.key == _auditLog.length - 1;
          final log = entry.value;
          final isAdd = log['type'] == 'add';
          final isDelete = log['type'] == 'delete';
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: isAdd ? AppTheme.successLight : isDelete ? AppTheme.errorLight : AppTheme.navyLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isAdd ? Icons.add_rounded : isDelete ? Icons.delete_outline_rounded : Icons.edit_outlined,
                        size: 18,
                        color: isAdd ? AppTheme.success : isDelete ? AppTheme.error : AppTheme.navy,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(log['action'] as String,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                          Text('${log['admin']} · ${log['detail']}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                    Text(log['time'] as String,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16, color: AppTheme.border),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        content: const Text('Are you sure you want to sign out?',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false),
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