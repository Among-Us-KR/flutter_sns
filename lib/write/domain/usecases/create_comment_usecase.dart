// // domain/usecases/create_comment_usecase.dart

// import 'package:flutter_sns/comment/domain/repository/comment_repository.dart';
// import 'package:flutter_sns/comment/domain/entities/comment.dart';
// import 'package:flutter_sns/write/domain/repository/post_repository.dart';
// import 'package:flutter_sns/profile/domain/repository/user_repository.dart';

// class CreateCommentUseCase {
//   final CommentRepository _commentRepository;
//   final PostRepository _postRepository;
//   final UserRepository _userRepository;

//   CreateCommentUseCase(this._commentRepository, this._postRepository, this._userRepository);

//   Future<void> execute(Comment comment, String postId) async {
//     // 1. 댓글 생성
//     await _commentRepository.createComment(comment, postId);

//     // 2. 게시글 정보 조회 (모드와 작성자 ID 확인)
//     final post = await _postRepository.getPostById(postId);

//     if (post != null) {
//       // 3. 게시글 작성자 통계 업데이트
//       if (post.mode == 'empathy') {
//         await _userRepository.incrementEmpathyCount(post.authorId);
//       } else if (post.mode == 'punch') {
//         await _userRepository.incrementPunchCount(post.authorId);
//       }
//     }
//   }
// }
