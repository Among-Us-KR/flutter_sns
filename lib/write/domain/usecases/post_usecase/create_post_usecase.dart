import 'package:flutter_sns/write/domain/entities/posts.dart';
import 'package:flutter_sns/write/domain/repository/post_repository.dart';

/// 게시글 생성 UseCase
class CreatePostUseCase {
  final PostRepository _repository;

  CreatePostUseCase(this._repository);

  Future<String> execute(Posts post) async {
    // 비즈니스 규칙 검증
    _validatePost(post);

    // Repository를 통해 게시글 생성
    return await _repository.createPost(post);
  }

  void _validatePost(Posts post) {
    // 제목 검증
    if (post.title.trim().isEmpty) {
      throw Exception('제목을 입력해주세요.');
    }
    if (post.title.length > 30) {
      throw Exception('제목은 30자 이내로 입력해주세요.');
    }

    // 내용 검증
    if (post.content.trim().isEmpty) {
      throw Exception('내용을 입력해주세요.');
    }
    if (post.content.length > 1000) {
      throw Exception('내용은 1000자 이내로 입력해주세요.');
    }

    // 카테고리 검증
    final validCategories = [
      '멍청스',
      '고민스',
      '대박스',
      '행복스',
      '슬펐스',
      '빡쳤스',
      '놀랐스',
      '솔직스',
    ];
    if (!validCategories.contains(post.category)) {
      throw Exception('올바른 카테고리를 선택해주세요.');
    }

    if (post.images.length > 5) {
      throw Exception('이미지는 최대 5개까지 업로드 가능합니다.');
    }
  }
}
