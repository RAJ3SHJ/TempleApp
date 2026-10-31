import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'admin/admin_login_screen.dart';

/// Public landing page: church photo, pastor details, fixed weekly events
/// and Member / Admin login links.
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
                      _eventsSection(),
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

  static const _events = [
    ['Services', '7am & 10am'],
    ['Youth Meeting', 'Every Saturday, 4pm\nVenue: In church'],
    ["Women's Fellowship", 'Every Wednesday, 6pm\nVenue: In church'],
    ['Sunday School', 'Sunday, 11am\nVenue: Parish Hall'],
  ];

  Widget _eventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text('Events',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.navy)),
        ),
        for (final e in _events)
          Container(
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
                Text(e[0],
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: AppTheme.navy)),
                const SizedBox(height: 6),
                Text(e[1],
                    style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary, height: 1.5)),
              ],
            ),
          ),
      ],
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pastor: photo with name and title directly below it
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                const SizedBox(width: 12),
                // Church name on the right half, left-aligned like a title
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text('CSI Church',
                              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: AppTheme.white, letterSpacing: 0.3)),
                        ),
                        SizedBox(height: 8),
                        Text('Sangareddy Pastorate', style: TextStyle(fontSize: 14, color: Colors.white70)),
                      ],
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
}
