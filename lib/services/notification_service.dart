import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message: ${message.messageId}');
}

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;
  static final _db = FirebaseFirestore.instance;

  static Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _messaging.getToken();
    if (token != null) await _saveToken(token);

    _messaging.onTokenRefresh.listen(_saveToken);

    FirebaseMessaging.onMessage.listen((message) {
      print('Foreground message: ${message.notification?.title}');
    });
  }

  static Future<void> _saveToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final memberDoc = await _db.collection('members').doc(user.uid).get();
    if (memberDoc.exists) {
      await _db.collection('members').doc(user.uid).update({
        'fcmToken': token,
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    final adminDoc = await _db.collection('admins').doc(user.uid).get();
    if (adminDoc.exists) {
      await _db.collection('admins').doc(user.uid).update({
        'fcmToken': token,
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  static Future<void> sendNotificationToAll({
    required String title,
    required String body,
    String type = 'general',
  }) async {
    await _db.collection('notifications').add({
      'title': title,
      'body': body,
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _db.collection('notification_queue').add({
      'title': title,
      'body': body,
      'type': type,
      'target': 'all',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> sendNotificationToMember({
    required String memberId,
    required String title,
    required String body,
    String type = 'general',
  }) async {
    await _db.collection('notification_queue').add({
      'title': title,
      'body': body,
      'type': type,
      'target': 'member',
      'memberId': memberId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}
