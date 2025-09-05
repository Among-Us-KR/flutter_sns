// domain/usecases/update_post_usecase.dart
import 'package:flutter_sns/write/domain/entities/posts.dart';
import 'package:flutter_sns/write/domain/repository/post_repository.dart';

/// 게시글 수정 UseCase
class UpdatePostUseCase {
  final PostRepository _repository;

  UpdatePostUseCase(this._repository);

  /// 게시글 업데이트 로직을 실행하는 메서드
  Future<void> execute(Posts post, String currentUserId) async {
    // 1. 게시글 ID 유효성 검증
    if (post.id.trim().isEmpty) {
      throw Exception('수정할 게시글 ID가 올바르지 않습니다.');
    }

    // 2. 게시글 작성자 권한 확인
    // 현재 사용자가 게시글 작성자인지 확인하는 로직 추가
    if (post.authorId != currentUserId) {
      throw Exception('자신이 작성한 게시글만 수정할 수 있습니다.');
    }

    // 3. 비즈니스 규칙에 따른 유효성 검증
    _validatePost(post);

    // 4. 수정 시간 업데이트
    final updatedPost = post.copyWith(updatedAt: DateTime.now());

    // 5. Repository를 통해 게시글 수정
    await _repository.updatePost(updatedPost);
  }

  /// 게시글의 제목, 내용, 카테고리 등 필드 유효성 검사
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
    const validCategories = <String>[
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

    // 이미지 수 검증
    if (post.images.length > 5) {
      throw Exception('이미지는 최대 5개까지 업로드 가능합니다.');
    }
  }
}
