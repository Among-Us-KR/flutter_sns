import 'package:flutter_sns/write/domain/repository/post_repository.dart';

/// 게시글 삭제 UseCase
class DeletePostUseCase {
  final PostRepository _repository;

  DeletePostUseCase(this._repository);

  /// 권한 검사가 포함된 삭제
  Future<void> execute(String postId, String currentUserId) async {
    // 입력값 검증
    if (postId.trim().isEmpty) {
      throw Exception('삭제할 게시글 ID가 올바르지 않습니다.');
    }

    if (currentUserId.trim().isEmpty) {
      throw Exception('사용자 정보가 올바르지 않습니다.');
    }

    // 1. 게시글 조회하여 존재 여부 확인
    final post = await _repository.getPostById(postId);
    if (post == null) {
      throw Exception('존재하지 않는 게시글입니다.');
    }

    // 2. 작성자 권한 확인
    if (post.authorId != currentUserId) {
      throw Exception('자신이 작성한 게시글만 삭제할 수 있습니다.');
    }

    // 3. 권한 확인 완료 후 삭제 실행
    await _repository.deletePost(postId);

    // 4. 사용자 게시글 수 감소
    // post.authorId를 사용하여 통계를 업데이트합니다.
    await _repository.decrementUserPostsCount(post.authorId);
  }
}
