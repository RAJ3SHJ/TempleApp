import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';

class DonationHistoryScreen extends StatefulWidget {
  const DonationHistoryScreen({super.key});
  @override
  State<DonationHistoryScreen> createState() => _DonationHistoryScreenState();
}

class _DonationHistoryScreenState extends State<DonationHistoryScreen> {
  String _selectedFilter = 'All';
  String _memberId = '';

  @override
  void initState() {
    super.initState();
    _loadMemberId();
  }

  void _loadMemberId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('members')
          .doc(user.uid)
          .get();
      if (mounted && doc.exists) {
        setState(() => _memberId = doc.data()?['memberId'] ?? '');
      }
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '-';
    final dt = (timestamp as Timestamp).toDate();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  String _getMonth(dynamic timestamp) {
    if (timestamp == null) return '';
    final dt = (timestamp as Timestamp).toDate();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Tithe': return AppTheme.navy;
      case 'Offering': return AppTheme.success;
      case 'Building Fund': return AppTheme.gold;
      case 'Special Fund': return const Color(0xFF7C3AED);
      default: return AppTheme.navyMid;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(context),
          if (_memberId.isEmpty)
            const Expanded(
              child: Center(child: CircularProgressIndicator(color: AppTheme.navy)),
            )
          else
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('donations')
                    .where('memberId', isEqualTo: _memberId)
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: AppTheme.navy));
                  }

                  final allDocs = snapshot.data?.docs ?? [];
                  final filtered = _selectedFilter == 'All'
                      ? allDocs
                      : allDocs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return _getMonth(data['date']) == _selectedFilter;
                        }).toList();

                  // Get unique months for filter
                  final months = allDocs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _getMonth(data['date']);
                  }).toSet().toList();

                  // Calculate totals
                  double total = 0;
                  double thisMonth = 0;
                  final now = DateTime.now();
                  for (final doc in allDocs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final amount = (data['amount'] as num? ?? 0).toDouble();
                    total += amount;
                    final date = (data['date'] as Timestamp?)?.toDate();
                    if (date != null && date.month == now.month && date.year == now.year) {
                      thisMonth += amount;
                    }
                  }

                  return Column(
                    children: [
                      _buildSummary(total, thisMonth, allDocs.length),
                      _buildFilterChips(['All', ...months]),
                      Expanded(
                        child: filtered.isEmpty
                            ? _buildEmptyState()
                            : ListView.separated(
                                padding: const EdgeInsets.all(14),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final data = filtered[index].data()
                                      as Map<String, dynamic>;
                                  return _buildDonationCard(data);
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppTheme.navy,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 16, left: 16, right: 16,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppTheme.white, size: 20),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 8),
          const Text('Donation History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                  color: AppTheme.white)),
        ],
      ),
    );
  }

  Widget _buildSummary(double total, double thisMonth, int count) {
    return Container(
      color: AppTheme.navy,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          _summaryCard('Total Given', '₹${total.toStringAsFixed(0)}', Icons.favorite_outline),
          const SizedBox(width: 10),
          _summaryCard('This Month', '₹${thisMonth.toStringAsFixed(0)}', Icons.calendar_today_outlined),
          const SizedBox(width: 10),
          _summaryCard('Transactions', '$count', Icons.receipt_long_outlined),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: Colors.white70),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                    color: AppTheme.white)),
            Text(label,
                style: const TextStyle(fontSize: 10, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(List<String> filters) {
    return Container(
      color: AppTheme.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.navy : AppTheme.navyLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(filter,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                        color: isSelected ? AppTheme.white : AppTheme.navy)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDonationCard(Map<String, dynamic> data) {
    final category = data['category'] as String? ?? '';
    final amount = (data['amount'] as num? ?? 0).toDouble();
    final mode = data['mode'] as String? ?? '';
    final date = _formatDate(data['date']);
    final color = _getCategoryColor(category);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.favorite_outline, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 3),
                Text('$date · $mode',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${amount.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                      color: AppTheme.navy)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.successLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Verified',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                        color: AppTheme.success)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64,
              color: AppTheme.textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text('No donations found',
              style: TextStyle(fontSize: 15, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
