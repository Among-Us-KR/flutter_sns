import 'dart:io';
import 'package:flutter_sns/write/domain/entities/posts.dart'
    hide Author, PostStats;
import 'package:flutter_sns/write/domain/repository/post_repository.dart';
import 'package:flutter_sns/write/data/models/posts_model.dart';
import '../datasources/firebase_post_datasource.dart';

/// PostRepository 인터페이스를 구현하는 클래스
/// 데이터 소스(Firebase)에서 데이터를 가져와 도메인 엔티티로 변환하는 역할
class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl(this._dataSource);
  final FirebasePostDataSource _dataSource;

  @override
  Future<String> createPost(Posts post) async {
    try {
      // 도메인 엔티티(Posts)를 DTO(PostsModel)로 변환
      final postModel = PostsModel(
        id: post.id,
        authorId: post.authorId,
        author: Author(
          nickname: post.author.nickname,
          profileImageUrl: post.author.profileImageUrl,
        ),
        category: post.category,
        mode: post.mode,
        title: post.title,
        content: post.content,
        images: post.images,
        stats: PostStats(
          likesCount: post.stats.likesCount,
          commentsCount: post.stats.commentsCount,
        ),
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
        reportCount: post.reportCount,
      );

      // 데이터 소스를 통해 Firebase에 저장
      return await _dataSource.createPost(postModel);
    } catch (e) {
      throw Exception('게시글 생성 중 오류 발생: $e');
    }
  }

  @override
  Future<void> updatePost(Posts post) async {
    try {
      // 도메인 엔티티(Posts)를 DTO(PostsModel)로 변환
      final postModel = PostsModel(
        id: post.id,
        authorId: post.authorId,
        author: Author(
          nickname: post.author.nickname,
          profileImageUrl: post.author.profileImageUrl,
        ),
        category: post.category,
        mode: post.mode,
        title: post.title,
        content: post.content,
        images: post.images,
        stats: PostStats(
          likesCount: post.stats.likesCount,
          commentsCount: post.stats.commentsCount,
        ),
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
        reportCount: post.reportCount,
      );

      // 데이터 소스를 통해 Firebase 업데이트
      await _dataSource.updatePost(postModel);
    } catch (e) {
      throw Exception('게시글 수정 중 오류 발생: $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      // 단순 전달 (변환 불필요)
      await _dataSource.deletePost(postId);
    } catch (e) {
      throw Exception('게시글 삭제 중 오류 발생: $e');
    }
  }

  @override
  Future<List<String>> uploadImages(List<File> images) async {
    try {
      // 단순 전달 (변환 불필요)
      return await _dataSource.uploadImages(images);
    } catch (e) {
      throw Exception('이미지 업로드 중 오류 발생: $e');
    }
  }
}
