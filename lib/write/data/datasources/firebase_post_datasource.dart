// data/datasources/firebase_post_datasource.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/posts_model.dart';

class FirebasePostDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// 게시글 생성
  Future<String> createPost(PostsModel post) async {
    try {
      final docRef = await _firestore
          .collection('posts')
          .add(post.toFirestore());

      return docRef.id;
    } catch (e) {
      throw Exception('게시글 생성 실패: $e');
    }
  }

  /// 게시글 수정
  Future<void> updatePost(PostsModel post) async {
    try {
      await _firestore
          .collection('posts')
          .doc(post.id)
          .update(post.toFirestore());
    } catch (e) {
      throw Exception('게시글 수정 실패: $e');
    }
  }

  /// 게시글 삭제
  Future<void> deletePost(String postId) async {
    try {
      // 게시글과 연관된 이미지들도 삭제
      final postDoc = await _firestore.collection('posts').doc(postId).get();
      if (postDoc.exists) {
        final post = PostsModel.fromFirestore(postDoc);

        // Storage에서 이미지 삭제
        for (String imageUrl in post.images) {
          await _deleteImageFromStorage(imageUrl);
        }
      }

      // Firestore에서 문서 삭제
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      throw Exception('게시글 삭제 실패: $e');
    }
  }

  /// 특정 게시글 조회
  Future<PostsModel?> getPostById(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();

      if (doc.exists) {
        return PostsModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('게시글 조회 실패: $e');
    }
  }

  /// 이미지 업로드
  Future<List<String>> uploadImages(List<File> images) async {
    try {
      final List<String> downloadUrls = [];

      for (int i = 0; i < images.length; i++) {
        final file = images[i];
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final ref = _storage.ref().child('posts/$fileName');

        // 이미지 업로드
        final uploadTask = await ref.putFile(file);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      }

      return downloadUrls;
    } catch (e) {
      throw Exception('이미지 업로드 실패: $e');
    }
  }

  /// 카테고리별 게시글 조회
  Stream<List<PostsModel>> getPostsByCategory(String category) {
    try {
      return _firestore
          .collection('posts')
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => PostsModel.fromFirestore(doc))
                .toList(),
          );
    } catch (e) {
      throw Exception('카테고리별 게시글 조회 실패: $e');
    }
  }

  /// 특정 사용자 게시글 조회
  Stream<List<PostsModel>> getPostsByAuthor(String authorId) {
    try {
      return _firestore
          .collection('posts')
          .where('authorId', isEqualTo: authorId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => PostsModel.fromFirestore(doc))
                .toList(),
          );
    } catch (e) {
      throw Exception('작성자별 게시글 조회 실패: $e');
    }
  }

  /// Storage에서 이미지 삭제
  Future<void> _deleteImageFromStorage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // 이미지 삭제 실패는 로그만 남기고 계속 진행
      print('이미지 삭제 실패: $imageUrl, 에러: $e');
    }
  }

  /// 게시글 좋아요 증가
  Future<void> incrementLikes(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'stats.likesCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('좋아요 증가 실패: $e');
    }
  }

  /// 게시글 댓글 수 증가
  Future<void> incrementComments(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'stats.commentsCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('댓글 수 증가 실패: $e');
    }
  }
}
