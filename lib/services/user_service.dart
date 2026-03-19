import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static final _db = FirebaseFirestore.instance;

  /// Save user profile if not exists
  static Future<void> saveUser(User user) async {
    final ref = _db.collection('users').doc(user.uid);

    final doc = await ref.get();
    if (doc.exists) return; // ✅ already saved

    await ref.set({
      'uid': user.uid,
      'email': user.email,
      'name': user.displayName ?? 'User',
      'photoUrl': user.photoURL,
      'provider': user.providerData.first.providerId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
