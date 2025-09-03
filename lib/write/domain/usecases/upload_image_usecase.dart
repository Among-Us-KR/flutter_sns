import 'dart:io';
import 'package:flutter_sns/write/domain/repository/upload_repository.dart';

class UploadImageUseCase {
  final UploadRepository repository;

  UploadImageUseCase(this.repository);

  Future<String?> execute(String uid, File file) {
    return repository.uploadProfileImage(uid, file);
  }
}
