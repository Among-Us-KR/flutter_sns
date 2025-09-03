import 'package:flutter_sns/write/domain/repository/post_repository.dart';
import 'package:flutter_sns/write/domain/entities/posts.dart';

class GetPostUseCase {
  final PostRepository _repository;

  GetPostUseCase(this._repository);

  Future<Posts?> execute(String postId) async {
    return await _repository.getPostById(postId);
  }
}
