import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static Future<String> uploadImage(File file) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = FirebaseStorage.instance.ref().child('reports/$fileName.jpg');

    final uploadTask = await ref.putFile(file);
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    return downloadUrl;
  }
}
