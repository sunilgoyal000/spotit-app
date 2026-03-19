import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 📝 Submit report
  static Future<void> submitReport({
    required String userId,
    required String name,
    required String phone,
    required bool sharePhone,
    required String category,
    required String description,
    required String location,
    String? imageUrl,
  }) async {
    await _db.collection('reports').add({
      'userId': userId,
      'name': name,
      'phone': sharePhone ? phone : null,
      'category': category,
      'description': description,
      'location': location,
      'imageUrl': imageUrl,
      'status': 'pending', // default
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 📂 Fetch current user's reports
  static Stream<QuerySnapshot> myReports(String userId) {
    return _db
        .collection('reports')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // 📊 Dashboard stats (Total / Pending / Resolved)
  static Stream<Map<String, int>> reportStats(String userId) {
    return _db
        .collection('reports')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      int pending = 0;
      int resolved = 0;

      for (var doc in snapshot.docs) {
        final status = doc['status'];
        if (status == 'resolved') {
          resolved++;
        } else {
          pending++;
        }
      }

      return {
        'total': snapshot.docs.length,
        'pending': pending,
        'resolved': resolved,
      };
    });
  }
}
