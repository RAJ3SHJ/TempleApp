import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SetupService {
  static Future<void> createSuperAdmin({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('admins')
          .doc(credential.user!.uid)
          .set({
        'name': 'Super Admin',
        'username': 'superadmin',
        'email': email,
        'role': 'superadmin',
        'isTempPassword': false,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error: $e');
    }
  }
}
