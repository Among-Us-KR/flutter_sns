import 'dart:io';
import 'package:flutter_sns/write/data/models/posts_model.dart';

abstract class UploadRepository {
  Future<String?> uploadProfileImage(String uid, File file);
}

abstract class PostRepository {
  Future<String> createPost(PostsModel post);
  Future<void> updatePost(PostsModel post);
  Future<void> deletePost(String postId);
  Future<List<String>> uploadImages(List<File> images);
  Stream<List<PostsModel>> getPosts();
  Future<PostsModel?> getPostById(String postId);
}
