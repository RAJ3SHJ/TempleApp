import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── MEMBERS ────────────────────────────────────────────────────────────────

  static Future<void> addMember({
    required String memberId,
    required String name,
    required String email,
    required String phone,
    required String password,
    String? address,
    String? sector,
    String? dateOfBirth,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _db.collection('members').doc(credential.user!.uid).set({
      'memberId': memberId,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address ?? '',
      'sector': sector ?? '',
      'dateOfBirth': dateOfBirth ?? '',
      'role': 'member',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot> getMembers() {
    return _db.collection('members').orderBy('name').snapshots();
  }

  static Future<DocumentSnapshot?> getMemberById(String memberId) async {
    final query = await _db.collection('members')
        .where('memberId', isEqualTo: memberId)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return query.docs.first;
  }

  // ─── ADMINS ─────────────────────────────────────────────────────────────────

  static Future<void> addAdmin({
    required String name,
    required String username,
    required String email,
    required String tempPassword,
    String role = 'admin',
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: tempPassword,
    );

    await _db.collection('admins').doc(credential.user!.uid).set({
      'name': name,
      'username': username.toLowerCase(),
      'email': email,
      'role': role,
      'isTempPassword': true,
      'tempPasswordExpiry': Timestamp.fromDate(
        DateTime.now().add(const Duration(hours: 24)),
      ),
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── DONATIONS ───────────────────────────────────────────────────────────────

  static Future<void> addDonation({
    required String memberId,
    required String memberName,
    required double amount,
    required String category,
    required String mode,
    String? notes,
  }) async {
    await _db.collection('donations').add({
      'memberId': memberId,
      'memberName': memberName,
      'amount': amount,
      'category': category,
      'mode': mode,
      'notes': notes ?? '',
      'date': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot> getDonations() {
    return _db.collection('donations')
        .orderBy('date', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getMemberDonations(String memberId) {
    return _db.collection('donations')
        .where('memberId', isEqualTo: memberId)
        .orderBy('date', descending: true)
        .snapshots();
  }

  // ─── EVENTS ──────────────────────────────────────────────────────────────────

  static Stream<QuerySnapshot> getEvents() {
    return _db.collection('events')
        .orderBy('date', descending: false)
        .snapshots();
  }

  static Future<void> addEvent({
    required String title,
    required String description,
    required DateTime date,
    String? location,
  }) async {
    await _db.collection('events').add({
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'location': location ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── PRAYER REQUESTS ─────────────────────────────────────────────────────────

  static Future<void> addPrayerRequest({
    required String memberId,
    required String memberName,
    required String request,
    bool isAnonymous = false,
  }) async {
    await _db.collection('prayer_requests').add({
      'memberId': memberId,
      'memberName': isAnonymous ? 'Anonymous' : memberName,
      'request': request,
      'isAnonymous': isAnonymous,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot> getPrayerRequests() {
    return _db.collection('prayer_requests')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ─── NOTIFICATIONS ───────────────────────────────────────────────────────────

  static Stream<QuerySnapshot> getNotifications() {
    return _db.collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<void> addNotification({
    required String title,
    required String body,
    String? type,
  }) async {
    await _db.collection('notifications').add({
      'title': title,
      'body': body,
      'type': type ?? 'general',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── BULLETIN ────────────────────────────────────────────────────────────────

  static Stream<QuerySnapshot> getBulletins() {
    return _db.collection('bulletins')
        .orderBy('date', descending: true)
        .snapshots();
  }

  // ─── VIDEOS ──────────────────────────────────────────────────────────────────

  static Stream<QuerySnapshot> getVideos() {
    return _db.collection('videos')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ─── CATEGORIES ──────────────────────────────────────────────────────────────

  static Stream<QuerySnapshot> getCategories() {
    return _db.collection('categories').orderBy('name').snapshots();
  }

  static Future<void> addCategory({required String name, String? description}) async {
    await _db.collection('categories').add({
      'name': name,
      'description': description ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── DASHBOARD STATS ─────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getDashboardStats() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final membersSnap = await _db.collection('members').count().get();
    final monthlySnap = await _db.collection('donations')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .get();
    final allSnap = await _db.collection('donations').get();

    double monthlyTotal = 0;
    double allTimeTotal = 0;

    for (final doc in monthlySnap.docs) {
      monthlyTotal += (doc.data()['amount'] as num).toDouble();
    }
    for (final doc in allSnap.docs) {
      allTimeTotal += (doc.data()['amount'] as num).toDouble();
    }

    return {
      'totalMembers': membersSnap.count ?? 0,
      'monthlyTotal': monthlyTotal,
      'allTimeTotal': allTimeTotal,
    };
  }
}
