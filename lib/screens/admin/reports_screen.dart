import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          Container(
            color: AppTheme.navy,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              bottom: 16, left: 16, right: 16,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.white, size: 20),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 8),
                const Text('Reports & Export',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.white)),
              ],
            ),
          ),
          const Expanded(child: Center(child: Text('Coming in Module 20'))),
        ],
      ),
    );
  }
}