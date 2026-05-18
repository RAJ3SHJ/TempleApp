import 'package:cloud_firestore/cloud_firestore.dart';

class MemberIdService {
  static Future<String> generateNextMemberId() async {
    final db = FirebaseFirestore.instance;

    // Get all members and find highest ID number
    final members = await db.collection('members').get();

    int maxNumber = 0;
    for (final doc in members.docs) {
      final memberId = doc.data()['memberId'] as String? ?? '';
      if (memberId.startsWith('GBC-')) {
        final numberStr = memberId.replaceAll('GBC-', '');
        final number = int.tryParse(numberStr) ?? 0;
        if (number > maxNumber) maxNumber = number;
      }
    }

    final nextNumber = maxNumber + 1;
    return 'GBC-${nextNumber.toString().padLeft(5, '0')}';
  }
}
