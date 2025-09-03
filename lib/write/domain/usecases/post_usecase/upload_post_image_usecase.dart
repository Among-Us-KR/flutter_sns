import 'dart:io';

import 'package:flutter_sns/write/domain/repository/post_repository.dart';

/// 이미지 업로드 UseCase
class UploadPostImagesUseCase {
  final PostRepository _repository;

  UploadPostImagesUseCase(this._repository);

  Future<List<String>> execute(List<File> images) async {
    // 비즈니스 규칙 검증
    _validateImages(images);

    // Repository를 통해 이미지 업로드
    return await _repository.uploadImages(images);
  }

  void _validateImages(List<File> images) {
    if (images.isEmpty) {
      throw Exception('업로드할 이미지가 없습니다.');
    }

    if (images.length > 5) {
      throw Exception('이미지는 최대 5개까지 업로드 가능합니다.');
    }

    // 각 이미지 파일 검증
    for (final image in images) {
      if (!image.existsSync()) {
        throw Exception('존재하지 않는 이미지 파일입니다.');
      }

      // 파일 크기 검증 (10MB 제한)
      final fileSize = image.lengthSync();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('이미지 파일 크기는 10MB 이내여야 합니다.');
      }

      // 파일 확장자 검증
      final extension = image.path.split('.').last.toLowerCase();
      final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      if (!validExtensions.contains(extension)) {
        throw Exception('지원하지 않는 이미지 형식입니다. (jpg, png, gif, webp만 지원)');
      }
    }
  }
}
