import 'dart:io';
import 'package:flutter_sns/write/domain/entities/comments.dart';
import 'package:flutter_sns/write/domain/entities/posts.dart';

abstract class PostRepository {
  Future<String> createPost(Posts post);
  Future<List<String>> uploadImages(List<File> images);
  Future<void> updatePost(Posts post);
  Future<void> deletePost(String postId);
  Future<Posts?> getPostById(String postId);
  Future<List<Posts>> getUserPosts(String userId);
  Future<List<Posts>> getUserLikedPosts(String userId);
  Future<List<Comments>> getUserComments(String userId);
  Future<List<Posts>> getUserCommentedPosts(String userId);
}
