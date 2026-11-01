import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'admin/admin_login_screen.dart';

/// Public landing page: church photo, pastor details, Events and Upcoming Events
/// (managed by admins) in two columns, and Member / Admin login links.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

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
                      _twoColumns(),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.push(
                              context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                          child: const Text('Member Login →',
                              style: TextStyle(color: AppTheme.navy, fontSize: 14, fontWeight: FontWeight.w500)),
                        ),
                      ),
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

  Widget _twoColumns() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _column('Events', 'events', newestFirst: false)),
          Container(
            width: 3,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: AppTheme.navy,
          ),
          Expanded(child: _column('Upcoming Events', 'announcements', newestFirst: true)),
        ],
      ),
    );
  }

  Widget _column(String heading, String collection, {required bool newestFirst}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(heading,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.navy)),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection(collection).snapshots(),
          builder: (context, snap) {
            if (snap.hasError) {
              return const Text('Could not load right now.',
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary));
            }
            if (!snap.hasData) {
              return const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
              );
            }
            final docs = [...snap.data!.docs]..sort((a, b) {
                final ta = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                final tb = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                if (ta == null && tb == null) return 0;
                if (ta == null) return 1;
                if (tb == null) return -1;
                return newestFirst ? tb.compareTo(ta) : ta.compareTo(tb);
              });
            return Column(
              children: docs.map((d) {
                final m = d.data() as Map<String, dynamic>;
                final title = (m['title'] ?? '').toString().trim();
                final desc = (m['description'] ?? '').toString().trim();
                final venue = (m['location'] ?? '').toString().trim();
                if (title.isEmpty && desc.isEmpty && venue.isEmpty) return const SizedBox.shrink();
                return _card(title, desc, venue);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _card(String title, String desc, String venue) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(title,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.navy)),
          if (desc.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(desc,
                  style: const TextStyle(fontSize: 8, color: AppTheme.textPrimary, height: 1.5)),
            ),
          if (venue.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text('Venue: $venue',
                  style: const TextStyle(fontSize: 8, color: AppTheme.textPrimary, height: 1.5)),
            ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.navy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Church photo: full width, whole picture visible (no crop)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.navy, width: 4),
            ),
            child: Image.asset('assets/images/church.jpg', fit: BoxFit.fitWidth),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pastor: photo with name and title directly below it
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: ClipOval(
                    child: Image.asset('assets/images/pastor.jpg',
                        width: 64, height: 64, fit: BoxFit.cover, alignment: Alignment.topCenter),
                  ),
                ),
                const SizedBox(height: 6),
                const Text('Rev. M. George Ebenezer Raju',
                    style: TextStyle(fontSize: 11, color: Colors.white60, height: 1.3)),
                const Text('Presbyter-in-Charge & Chairman, MDCC',
                    style: TextStyle(fontSize: 11, color: Colors.white60, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
