import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DonationHistoryScreen extends StatefulWidget {
  const DonationHistoryScreen({super.key});

  @override
  State<DonationHistoryScreen> createState() => _DonationHistoryScreenState();
}

// Donation Model
class Donation {
  final String id;
  final String category;
  final String date;
  final double amount;
  final String paymentMode;
  final String receiptNo;
  final bool isVerified;

  Donation({
    required this.id,
    required this.category,
    required this.date,
    required this.amount,
    required this.paymentMode,
    required this.receiptNo,
    this.isVerified = true,
  });
}

class _DonationHistoryScreenState extends State<DonationHistoryScreen> {
  String _selectedFilter = 'All';

  // Dummy data
  final List<Donation> _allDonations = [
    Donation(
      id: '1',
      category: 'Tithe',
      date: '09 May 2026',
      amount: 5000,
      paymentMode: 'Cash',
      receiptNo: 'RC-0091',
    ),
    Donation(
      id: '2',
      category: 'Offering',
      date: '02 May 2026',
      amount: 1500,
      paymentMode: 'UPI',
      receiptNo: 'RC-0088',
    ),
    Donation(
      id: '3',
      category: 'Building Fund',
      date: '20 Apr 2026',
      amount: 10000,
      paymentMode: 'Cheque',
      receiptNo: 'RC-0081',
    ),
    Donation(
      id: '4',
      category: 'Tithe',
      date: '01 Apr 2026',
      amount: 5000,
      paymentMode: 'Cash',
      receiptNo: 'RC-0075',
    ),
    Donation(
      id: '5',
      category: 'Special Fund',
      date: '15 Mar 2026',
      amount: 2500,
      paymentMode: 'UPI',
      receiptNo: 'RC-0068',
    ),
    Donation(
      id: '6',
      category: 'Offering',
      date: '01 Mar 2026',
      amount: 1200,
      paymentMode: 'Cash',
      receiptNo: 'RC-0061',
    ),
    Donation(
      id: '7',
      category: 'Tithe',
      date: '01 Feb 2026',
      amount: 5000,
      paymentMode: 'Cash',
      receiptNo: 'RC-0054',
    ),
    Donation(
      id: '8',
      category: 'Building Fund',
      date: '15 Jan 2026',
      amount: 10000,
      paymentMode: 'Cheque',
      receiptNo: 'RC-0047',
    ),
    Donation(
      id: '9',
      category: 'Tithe',
      date: '01 Jan 2026',
      amount: 5000,
      paymentMode: 'Cash',
      receiptNo: 'RC-0041',
    ),
    Donation(
      id: '10',
      category: 'Special Fund',
      date: '25 Dec 2025',
      amount: 3000,
      paymentMode: 'UPI',
      receiptNo: 'RC-0038',
    ),
  ];

  List<Donation> get _filteredDonations {
    if (_selectedFilter == 'All') return _allDonations;
    return _allDonations
        .where((d) => d.category == _selectedFilter)
        .toList();
  }

  double get _totalAllTime {
    return _allDonations.fold(0, (sum, d) => sum + d.amount);
  }

  double get _totalThisYear {
    return _allDonations
        .where((d) => d.date.contains('2026'))
        .fold(0, (sum, d) => sum + d.amount);
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      final formatted = amount.toInt().toString();
      if (formatted.length > 3) {
        return '₹${formatted.substring(0, formatted.length - 3)},${formatted.substring(formatted.length - 3)}';
      }
    }
    return '₹${amount.toInt()}';
  }

  String _getCategoryInitial(String category) {
    return category[0].toUpperCase();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Tithe':
        return AppTheme.navy;
      case 'Offering':
        return AppTheme.navyMid;
      case 'Building Fund':
        return AppTheme.gold;
      case 'Special Fund':
        return const Color(0xFF7C3AED);
      default:
        return AppTheme.navy;
    }
  }

  IconData _getPaymentIcon(String mode) {
    switch (mode) {
      case 'UPI':
        return Icons.phone_android_outlined;
      case 'Cheque':
        return Icons.description_outlined;
      default:
        return Icons.payments_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterTabs(),
          Expanded(
            child: _filteredDonations.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(14),
                    itemCount: _filteredDonations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _buildDonationCard(_filteredDonations[index]);
                    },
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
        bottom: 20,
        left: 16,
        right: 16,
      ),
      child: Column(
        children: [
          // Top row
          Row(
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
                'Donation History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _headerStat(
                  label: 'All Time Total',
                  value: _formatAmount(_totalAllTime),
                  sub: 'Since 2019',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _headerStat(
                  label: 'This Year',
                  value: _formatAmount(_totalThisYear),
                  sub: '2026',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerStat({
    required String label,
    required String value,
    required String sub,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.white,
            ),
          ),
          Text(
            sub,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = ['All', 'Tithe', 'Offering', 'Building Fund', 'Special Fund'];
    return Container(
      color: AppTheme.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.navy : AppTheme.navyLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppTheme.white : AppTheme.navy,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDonationCard(Donation donation) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Category Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _getCategoryColor(donation.category).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getCategoryInitial(donation.category),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _getCategoryColor(donation.category),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donation.category,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 11,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      donation.date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _getPaymentIcon(donation.paymentMode),
                      size: 11,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      donation.paymentMode,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  donation.receiptNo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Amount & Badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatAmount(donation.amount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.navy,
                ),
              ),
              const SizedBox(height: 5),
              if (donation.isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.successLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 11,
                        color: AppTheme.success,
                      ),
                      SizedBox(width: 3),
                      Text(
                        'Verified',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
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
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No donations found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'No records for $_selectedFilter category',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}