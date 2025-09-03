// domain/usecases/update_post_usecase.dart
import 'package:flutter_sns/write/domain/entities/posts.dart';
import 'package:flutter_sns/write/domain/repository/post_repository.dart';

/// 게시글 수정 UseCase
class UpdatePostUseCase {
  final PostRepository _repository;

  UpdatePostUseCase(this._repository);

  Future<void> execute(Posts post) async {
    // ID 검증
    if (post.id.trim().isEmpty) {
      throw Exception('수정할 게시글 ID가 올바르지 않습니다.');
    }

    // 비즈니스 규칙 검증
    _validatePost(post);

    // 수정 시간 업데이트
    final updatedPost = post.copyWith(updatedAt: DateTime.now());

    // Repository를 통해 게시글 수정
    await _repository.updatePost(updatedPost);
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
