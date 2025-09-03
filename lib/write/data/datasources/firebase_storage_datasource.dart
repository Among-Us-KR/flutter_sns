
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageDataSource {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadProfileImage(String uid, File file) async {
    final ref = _storage.ref().child('user_profiles/$uid.jpg');

    try {
      await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception('Storage 업로드 실패: ${e.code}');
    }
  }
}