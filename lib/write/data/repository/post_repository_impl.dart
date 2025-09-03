// data/repositories/post_repository_impl.dart
import 'dart:io';
import 'package:flutter_sns/write/data/datasources/firebase_user_datasource.dart';
import 'package:flutter_sns/write/domain/entities/posts.dart' as domain;
import 'package:flutter_sns/write/data/models/posts_model.dart' as dto;
import 'package:flutter_sns/write/domain/repository/post_repository.dart';
import '../datasources/firebase_post_datasource.dart';

/// PostRepository 인터페이스를 구현하는 클래스
/// 데이터 소스(Firebase)에서 데이터를 가져와 도메인 엔티티로 변환하는 역할
class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl(this._postDataSource, this._userDataSource);

  final FirebasePostDataSource _postDataSource;
  final FirebaseUserDataSource _userDataSource;

  @override
  Future<String> createPost(domain.Posts post) async {
    try {
      // 도메인 엔티티(Posts)를 DTO(PostsModel)로 변환
      final postModel = dto.PostsModel(
        id: post.id,
        authorId: post.authorId,
        author: dto.Author(
          nickname: post.author.nickname,
          profileImageUrl: post.author.profileImageUrl,
        ),
        category: post.category,
        mode: post.mode,
        title: post.title,
        content: post.content,
        images: post.images,
        stats: dto.PostStats(
          likesCount: post.stats.likesCount,
          commentsCount: post.stats.commentsCount,
        ),
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
        reportCount: post.reportCount,
      );

      // 데이터 소스를 통해 Firebase에 저장
      final postId = await _postDataSource.createPost(postModel);
      // 사용자 통계 업데이트 (postsCount +1)
      await _userDataSource.incrementUserPostsCount(post.authorId);

      return postId;
    } catch (e) {
      throw Exception('게시글 생성 중 오류 발생: $e');
    }
  }

  @override
  Future<void> updatePost(domain.Posts post) async {
    try {
      // 도메인 엔티티(Posts)를 DTO(PostsModel)로 변환
      final postModel = dto.PostsModel(
        id: post.id,
        authorId: post.authorId,
        author: dto.Author(
          nickname: post.author.nickname,
          profileImageUrl: post.author.profileImageUrl,
        ),
        category: post.category,
        mode: post.mode,
        title: post.title,
        content: post.content,
        images: post.images,
        stats: dto.PostStats(
          likesCount: post.stats.likesCount,
          commentsCount: post.stats.commentsCount,
        ),
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
        reportCount: post.reportCount,
      );

      // 데이터 소스를 통해 Firebase 업데이트
      await _postDataSource.updatePost(postModel);
    } catch (e) {
      throw Exception('게시글 수정 중 오류 발생: $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      // 삭제 전 게시글 정보 조회 (authorId 필요)
      final post = await _postDataSource.getPostById(postId);

      if (post != null) {
        // 게시글 삭제
        await _postDataSource.deletePost(postId);

        // 사용자 통계 업데이트 (postsCount -1)
        await _userDataSource.decrementUserPostsCount(post.authorId);
      }
    } catch (e) {
      throw Exception('게시글 삭제 중 오류 발생: $e');
    }
  }

  @override
  Future<List<String>> uploadImages(List<File> images) async {
    // try {
    // 단순 전달 (변환 불필요)
    return await _postDataSource.uploadImages(images);
    // } catch (e) {
    //   throw Exception('이미지 업로드 중 오류 발생: $e');
    // }
  }

  @override
  Future<domain.Posts?> getPostById(String postId) async {
    try {
      // 데이터 소스에서 DTO 가져오기
      final postModel = await _postDataSource.getPostById(postId);

      if (postModel != null) {
        // DTO를 도메인 엔티티로 변환
        return domain.Posts(
          id: postModel.id,
          authorId: postModel.authorId,
          author: domain.Author(
            nickname: postModel.author.nickname,
            profileImageUrl: postModel.author.profileImageUrl,
          ),
          category: postModel.category,
          mode: postModel.mode,
          title: postModel.title,
          content: postModel.content,
          images: postModel.images,
          stats: domain.PostStats(
            likesCount: postModel.stats.likesCount,
            commentsCount: postModel.stats.commentsCount,
          ),
          createdAt: postModel.createdAt,
          updatedAt: postModel.updatedAt,
          reportCount: postModel.reportCount,
        );
      }
      return null;
    } catch (e) {
      throw Exception('게시글 조회 중 오류 발생: $e');
    }
  }

  @override
  Future<void> decrementUserPostsCount(String uid) async {
    try {
      await _userDataSource.decrementUserPostsCount(uid);
    } catch (e) {
      throw Exception('사용자 게시글 수 감소 중 오류 발생: $e');
    }
  }
}
