// import 'firebase_storage_datasource.dart';
// import 'upload_repository.dart';
import 'package:flutter_sns/write/data/datasources/firebase_storage_datasource.dart';
import 'package:flutter_sns/write/domain/repository/upload_repository.dart';
import 'dart:io';

class UploadRepositoryImpl implements UploadRepository {
  final FirebaseStorageDataSource dataSource;

  UploadRepositoryImpl(this.dataSource);

  @override
  Future<String?> uploadProfileImage(String uid, File file) {
    return dataSource.uploadProfileImage(uid, file);
  }
}