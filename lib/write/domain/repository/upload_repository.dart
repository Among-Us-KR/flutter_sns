import 'dart:io';

abstract class UploadRepository {
  Future<String?> uploadProfileImage(String uid, File file);
}