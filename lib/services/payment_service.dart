import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentService {
  static final _db = FirebaseFirestore.instance;

  // Get first Sunday of a given month
  static DateTime getFirstSunday(int year, int month) {
    DateTime day = DateTime(year, month, 1);
    while (day.weekday != DateTime.sunday) {
      day = day.add(const Duration(days: 1));
    }
    return day;
  }

  // Check if current month payment is due
  static bool isPaymentDue(int year, int month) {
    final firstSunday = getFirstSunday(year, month);
    return DateTime.now().isAfter(firstSunday);
  }

  // Get month key e.g. "2026-05"
  static String getMonthKey(int year, int month) {
    return '$year-${month.toString().padLeft(2, '0')}';
  }

  // Get month display name e.g. "May 2026"
  static String getMonthName(String monthKey) {
    final parts = monthKey.split('-');
    final year = parts[0];
    final month = int.parse(parts[1]);
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[month - 1]} $year';
  }

  // Check if member has paid for a specific month
  static Future<Map<String, dynamic>?> getPaymentStatus(
      String memberId, String monthKey) async {
    final snap = await _db
        .collection('monthly_commitments')
        .where('memberId', isEqualTo: memberId)
        .where('month', isEqualTo: monthKey)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return snap.docs.first.data();
  }

  // Get all payment history for a member
  static Stream<QuerySnapshot> getMemberPaymentHistory(String memberId) {
    return _db
        .collection('monthly_commitments')
        .where('memberId', isEqualTo: memberId)
        .orderBy('month', descending: true)
        .snapshots();
  }

  // Mark payment for one or more months
  static Future<void> markPayment({
    required String memberId,
    required String memberName,
    required List<String> months,
    required double totalAmount,
    required String markedBy,
    required String paymentMode,
  }) async {
    final amountPerMonth = totalAmount / months.length;
    final batch = _db.batch();

    for (final month in months) {
      // Check if already exists
      final existing = await _db
          .collection('monthly_commitments')
          .where('memberId', isEqualTo: memberId)
          .where('month', isEqualTo: month)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        // Update existing
        batch.update(existing.docs.first.reference, {
          'isPaid': true,
          'amount': amountPerMonth,
          'paidDate': FieldValue.serverTimestamp(),
          'markedBy': markedBy,
          'paymentMode': paymentMode,
        });
      } else {
        // Create new
        final ref = _db.collection('monthly_commitments').doc();
        batch.set(ref, {
          'memberId': memberId,
          'memberName': memberName,
          'month': month,
          'isPaid': true,
          'amount': amountPerMonth,
          'paidDate': FieldValue.serverTimestamp(),
          'markedBy': markedBy,
          'paymentMode': paymentMode,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }

    await batch.commit();
  }

  // Get all due members for current month
  static Future<List<Map<String, dynamic>>> getDueMembers() async {
    final now = DateTime.now();
    final monthKey = getMonthKey(now.year, now.month);

    // Get all active members
    final members = await _db
        .collection('members')
        .where('isActive', isEqualTo: true)
        .get();

    // Get paid members for this month
    final paid = await _db
        .collection('monthly_commitments')
        .where('month', isEqualTo: monthKey)
        .where('isPaid', isEqualTo: true)
        .get();

    final paidIds = paid.docs
        .map((d) => d.data()['memberId'] as String)
        .toSet();

    // Return only due members (after first Sunday)
    if (!isPaymentDue(now.year, now.month)) return [];

    return members.docs
        .where((d) => !paidIds.contains(d.data()['memberId']))
        .map((d) => {...d.data(), 'docId': d.id})
        .toList();
  }

  // Generate last 12 months list
  static List<String> getLast12Months() {
    final now = DateTime.now();
    final months = <String>[];
    for (int i = 0; i < 12; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      months.add(getMonthKey(date.year, date.month));
    }
    return months;
  }
}
