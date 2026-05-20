import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../services/payment_service.dart';

class MonthlyTrackerScreen extends StatefulWidget {
  const MonthlyTrackerScreen({super.key});
  @override
  State<MonthlyTrackerScreen> createState() => _MonthlyTrackerScreenState();
}

class _MonthlyTrackerScreenState extends State<MonthlyTrackerScreen> {
  String _memberId = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMemberId();
  }

  void _loadMemberId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('members').doc(user.uid).get();
      if (mounted && doc.exists) {
        setState(() {
          _memberId = doc.data()?['memberId'] ?? '';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(context),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator(color: AppTheme.navy)),
            )
          else
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: PaymentService.getMemberPaymentHistory(_memberId),
                builder: (context, snapshot) {
                  final now = DateTime.now();
                  final months = PaymentService.getLast12Months();
                  final paidMonths = <String>{};

                  if (snapshot.hasData) {
                    for (final doc in snapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      if (data['isPaid'] == true) {
                        paidMonths.add(data['month'] as String);
                      }
                    }
                  }

                  final isDue = PaymentService.isPaymentDue(now.year, now.month);
                  final currentMonth = PaymentService.getMonthKey(now.year, now.month);
                  final currentPaid = paidMonths.contains(currentMonth);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        _buildCurrentStatus(isDue, currentPaid, currentMonth),
                        const SizedBox(height: 16),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('PAYMENT HISTORY',
                              style: TextStyle(fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                  letterSpacing: 0.8)),
                        ),
                        const SizedBox(height: 10),
                        ...months.map((month) => _buildMonthRow(
                          month,
                          paidMonths.contains(month),
                          month == currentMonth,
                        )),
                      ],
                    ),
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
          const Text('Monthly Tracker',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                  color: AppTheme.white)),
        ],
      ),
    );
  }

  Widget _buildCurrentStatus(bool isDue, bool isPaid, String monthKey) {
    final monthName = PaymentService.getMonthName(monthKey);
    final color = isPaid ? AppTheme.success : isDue ? AppTheme.error : AppTheme.gold;
    final bgColor = isPaid ? AppTheme.successLight : isDue ? AppTheme.errorLight : const Color(0xFFFEF3C7);
    final icon = isPaid ? Icons.check_circle_rounded : isDue ? Icons.warning_rounded : Icons.schedule_rounded;
    final status = isPaid ? 'PAID' : isDue ? 'DUE' : 'NOT DUE YET';
    final message = isPaid
        ? 'Your $monthName payment has been recorded.'
        : isDue
            ? 'Your $monthName payment is due. Please contact the church office.'
            : 'Payment for $monthName is not due yet.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This Month — $monthName',
                    style: const TextStyle(fontSize: 12,
                        color: AppTheme.textSecondary)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(status,
                      style: const TextStyle(fontSize: 12,
                          fontWeight: FontWeight.w700, color: AppTheme.white)),
                ),
                const SizedBox(height: 6),
                Text(message,
                    style: TextStyle(fontSize: 13, color: color, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthRow(String monthKey, bool isPaid, bool isCurrent) {
    final monthName = PaymentService.getMonthName(monthKey);
    final parts = monthKey.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final isDue = PaymentService.isPaymentDue(year, month);

    Color statusColor;
    String statusText;
    Color bgColor;

    if (isPaid) {
      statusColor = AppTheme.success;
      statusText = 'PAID';
      bgColor = AppTheme.successLight;
    } else if (isDue) {
      statusColor = AppTheme.error;
      statusText = 'DUE';
      bgColor = AppTheme.errorLight;
    } else {
      statusColor = AppTheme.textSecondary;
      statusText = '-';
      bgColor = AppTheme.border;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent ? AppTheme.navy : AppTheme.border,
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                if (isCurrent) ...[
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.navy,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('NOW',
                        style: TextStyle(fontSize: 9,
                            fontWeight: FontWeight.w700, color: AppTheme.white)),
                  ),
                ],
                Text(monthName,
                    style: TextStyle(fontSize: 14,
                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                        color: AppTheme.textPrimary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: bgColor, borderRadius: BorderRadius.circular(20),
            ),
            child: Text(statusText,
                style: TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w700, color: statusColor)),
          ),
        ],
      ),
    );
  }
}
