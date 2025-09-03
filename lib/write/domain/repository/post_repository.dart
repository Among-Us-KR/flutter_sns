import 'dart:io';
import 'package:flutter_sns/write/domain/entities/posts.dart';

abstract class PostRepository {
  // 새 게시글 생성
  Future<String> createPost(Posts post);

  // 기존 게시글 수정
  Future<void> updatePost(Posts post);

  // 게시글 삭제
  Future<void> deletePost(String postId);

  // 이미지 파일 업로드
  Future<List<String>> uploadImages(List<File> images);

  // 특정 ID의 게시글 조회 (권한 검사용)
  Future<Posts?> getPostById(String postId);

  // 삭제 시 포스트 카운트 1 감소
  Future<void> decrementUserPostsCount(String uid);
}
