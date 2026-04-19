import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userRepositoryProvider = Provider((ref) => UserRepository());

final userProfileProvider = StreamProvider.autoDispose.family<Map<String, dynamic>?, String>(
  (ref, uid) => UserRepository().watchProfile(uid),
);

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Create user document on first sign-in (does not overwrite existing).
  Future<void> saveUser(User user) async {
    final ref = _db.collection('users').doc(user.uid);
    final doc = await ref.get();
    if (doc.exists) return;

    await ref.set({
      'uid': user.uid,
      'email': user.email,
      'name': user.displayName ?? 'User',
      'photoUrl': user.photoURL,
      'phone': null,
      'gender': null,
      'dob': null,
      'city': null,
      'bio': null,
      'provider': user.providerData.isNotEmpty
          ? user.providerData.first.providerId
          : 'password',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Live stream of the user's Firestore profile document.
  Stream<Map<String, dynamic>?> watchProfile(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snap) => snap.data());
  }

  /// Merge-update only the supplied fields.
  Future<void> updateProfile(String uid, Map<String, dynamic> fields) async {
    await _db.collection('users').doc(uid).set(
      {...fields, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }
}
