import 'package:flutter_sns/write/domain/repository/post_repository.dart';

/// 게시글 삭제 UseCase
class DeletePostUseCase {
  final PostRepository _repository;

  DeletePostUseCase(this._repository);

  /// 권한 검사가 포함된 삭제
  Future<void> execute(String postId, String currentUserId) async {
    // 1. 게시글 조회하여 존재 여부 및 작성자 권한 확인
    final post = await _repository.getPostById(postId);

    // post가 null인 경우, 게시글이 없다는 예외를 발생시킵니다.
    if (post == null) {
      throw Exception('게시글을 찾을 수 없습니다.');
    }

    // 이 검사는 클라이언트에서 한 번 더 확인하는 것이지만,
    if (post.authorId != currentUserId) {
      throw Exception('자신이 작성한 게시글만 삭제할 수 있습니다.');
    }

    // 2. 권한 확인 완료 후, Repository에 삭제를 요청합니다.
    await _repository.deletePost(postId);
  }
}
