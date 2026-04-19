import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userRepositoryProvider = Provider((ref) => UserRepository());

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Save user profile if not exists
  Future<void> saveUser(User user) async {
    final ref = _db.collection('users').doc(user.uid);

    final doc = await ref.get();
    if (doc.exists) return; // already saved

    await ref.set({
      'uid': user.uid,
      'email': user.email,
      'name': user.displayName ?? 'User',
      'photoUrl': user.photoURL,
      'provider': user.providerData.isNotEmpty ? user.providerData.first.providerId : 'password',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
