import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reportRepositoryProvider = Provider((ref) => ReportRepository());

final myReportsProvider = StreamProvider.autoDispose.family<QuerySnapshot, String>((ref, userId) {
  final repo = ref.watch(reportRepositoryProvider);
  return repo.myReports(userId);
});

final reportStatsProvider = StreamProvider.autoDispose.family<Map<String, int>, String>((ref, userId) {
  final repo = ref.watch(reportRepositoryProvider);
  return repo.reportStats(userId);
});

class ReportRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> submitReport({
    required String userId,
    required String name,
    required String phone,
    required bool sharePhone,
    required String category,
    required String description,
    required String location,
    required double lat,
    required double lng,
    required String district,
    String? imageUrl,
  }) async {
    await _db.collection('reports').add({
      'userId': userId,
      'name': name,
      'phone': sharePhone ? phone : null,
      'category': category,
      'description': description,
      'location': location,
      'lat': lat,
      'lng': lng,
      'district': district,
      'imageUrl': imageUrl,
      'status': 'pending', // default
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> myReports(String userId) {
    return _db
        .collection('reports')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<Map<String, int>> reportStats(String userId) {
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
