import 'dart:io';
import 'package:flutter_sns/write/domain/repository/users_repository.dart';

class UploadProfileImageUseCase {
  final UserRepository _userRepository;

  UploadProfileImageUseCase(this._userRepository);

  Future<String> execute(String uid, File file) async {
    // 1. 비즈니스 규칙 검증
    _validateImage(file);

    // 2. Repository를 통해 이미지 업로드
    return await _userRepository.uploadProfileImage(uid, file);
  }

  void _validateImage(File file) {
    if (!file.existsSync()) {
      throw Exception('존재하지 않는 이미지 파일입니다.');
    }

    // 파일 크기 검증 (5MB 제한)
    final fileSize = file.lengthSync();
    if (fileSize > 5 * 1024 * 1024) {
      throw Exception('이미지 파일 크기는 5MB 이내여야 합니다.');
    }

    // 파일 확장자 검증
    final extension = file.path.split('.').last.toLowerCase();
    final validExtensions = ['jpg', 'jpeg', 'png', 'heic', 'webp'];
    if (!validExtensions.contains(extension)) {
      throw Exception('지원하지 않는 이미지 형식입니다. (jpg, png, heic, webp만 지원)');
    }
  }
}
