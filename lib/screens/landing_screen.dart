import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'admin/admin_login_screen.dart';

/// Public landing page: church photo, pastor details, upcoming events and
/// announcements (published by admins) and a Login button at the bottom.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String _when(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final ap = d.hour >= 12 ? 'PM' : 'AM';
    return '${_days[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]} ${d.year} · $h:$m $ap';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _header(context),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _events(),
                      const SizedBox(height: 4),
                      _announcements(),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(minimumSize: const Size(0, 54)),
                          onPressed: () => Navigator.push(
                              context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                          child: const Text('Login', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.push(
                              context, MaterialPageRoute(builder: (_) => const AdminLoginScreen())),
                          child: const Text('Admin Login →',
                              style: TextStyle(color: AppTheme.navy, fontSize: 14, fontWeight: FontWeight.w500)),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(t,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.navy)),
      );

  Widget _empty(String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(t, style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
      );

  Widget _events() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').orderBy('date').snapshots(),
      builder: (context, snap) {
        if (snap.hasError) return _empty('Events could not be loaded right now.');
        if (!snap.hasData) return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
        final cutoff = DateTime.now().subtract(const Duration(hours: 6));
        final docs = snap.data!.docs.where((d) {
          final t = (d.data() as Map<String, dynamic>)['date'];
          return t is Timestamp && t.toDate().isAfter(cutoff);
        }).toList();
        if (docs.isEmpty) return _empty('No upcoming events.');
        return Column(
          children: docs.map((d) {
            final m = d.data() as Map<String, dynamic>;
            return _card(
              title: (m['title'] ?? '').toString(),
              lines: const [],
            );
          }).toList(),
        );
      },
    );
  }

  Widget _announcements() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('announcements')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snap) {
        if (snap.hasError) return _empty('Announcements could not be loaded right now.');
        if (!snap.hasData) return const SizedBox.shrink();
        final docs = snap.data!.docs;
        if (docs.isEmpty) return _empty('No announcements.');
        return Column(
          children: docs.map((d) {
            final m = d.data() as Map<String, dynamic>;
            return _card(
              title: (m['title'] ?? '').toString(),
              lines: [(m['description'] ?? '').toString()],
            );
          }).toList(),
        );
      },
    );
  }

  Widget _card({required String title, required List<String> lines, bool emphasizeFirst = false}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          for (var i = 0; i < lines.length; i++)
            if (lines[i].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(lines[i],
                    style: TextStyle(
                      fontSize: (emphasizeFirst && i == 0) ? 17 : 16,
                      fontWeight: (emphasizeFirst && i == 0) ? FontWeight.w600 : FontWeight.w400,
                      color: (emphasizeFirst && i == 0) ? AppTheme.navy : AppTheme.textSecondary,
                      height: 1.4,
                    )),
              ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.navy,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        bottom: 24,
        left: 20,
        right: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset('assets/images/church.jpg', height: 170, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: ClipOval(
                  child: Image.asset('assets/images/pastor.jpg',
                      width: 64, height: 64, fit: BoxFit.cover, alignment: Alignment.topCenter),
                ),
              ),
              const SizedBox(width: 30),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CSI Church',
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: AppTheme.white, letterSpacing: 0.3)),
                    SizedBox(height: 2),
                    Text('Sangareddy Pastorate', style: TextStyle(fontSize: 14, color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text('Rev. M. George Ebenezer Raju',
              style: TextStyle(fontSize: 11, color: Colors.white60, height: 1.3)),
          const Text('Presbyter-in-Charge & Chairman, MDCC',
              style: TextStyle(fontSize: 11, color: Colors.white60, height: 1.3)),
        ],
      ),
    );
  }
}
