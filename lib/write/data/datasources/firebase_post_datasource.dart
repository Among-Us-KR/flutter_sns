// data/datasources/firebase_post_datasource.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

import '../models/posts_model.dart';

class FirebasePostDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  FirebasePostDataSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _auth = auth ?? FirebaseAuth.instance;

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

  /// 게시글 삭제 (Storage 이미지도 정리)
  Future<void> deletePost(String postId) async {
    try {
      final postDoc = await _firestore.collection('posts').doc(postId).get();
      if (postDoc.exists) {
        final post = PostsModel.fromFirestore(postDoc);
        // Storage에서 이미지 삭제
        for (final imageUrl in post.images) {
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
  ///
  /// - 로그인 사용자의 UID/타임스탬프 기반 경로에 업로드
  /// - 파일 존재 확인
  /// - PNG/JPEG에 맞는 contentType 지정
  Future<List<String>> uploadImages(List<File> images) async {
    try {
      if (images.isEmpty) return [];

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final uid = _auth.currentUser!.uid;
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final urls = <String>[];

      for (int i = 0; i < images.length; i++) {
        final file = images[i];

        if (!await file.exists()) {
          throw Exception('이미지 파일이 존재하지 않습니다: ${file.path}');
        }

        // 확장자/Content-Type 추정
        final ext = p.extension(file.path).toLowerCase().replaceFirst('.', '');
        final isPng = ext == 'png';
        final contentType = isPng ? 'image/png' : 'image/jpeg';

        // 저장 경로: post/{uid}/{timestamp}_{index}.(png|jpg)
        final objectPath = 'post/$uid/${nowMs}_$i.${isPng ? 'png' : 'jpg'}';
        final ref = _storage.ref(objectPath);

        // 메타데이터와 함께 업로드
        final metadata = SettableMetadata(
          contentType: contentType,
          customMetadata: {'ownerId': uid},
        );
        final task = await ref.putFile(file, metadata);

        final url = await task.ref.getDownloadURL();
        urls.add(url);
      }
      return urls;
    } catch (e) {
      throw Exception('이미지 업로드 실패: $e');
    }
  }

  /// 카테고리별 게시글 조회 (실시간 스트림)
  Stream<List<PostsModel>> getPostsByCategory(String category) {
    try {
      return _firestore
          .collection('posts')
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snap) =>
                snap.docs.map((d) => PostsModel.fromFirestore(d)).toList(),
          );
    } catch (e) {
      throw Exception('카테고리별 게시글 조회 실패: $e');
    }
  }

  /// 특정 사용자 게시글 조회 (실시간 스트림)
  Stream<List<PostsModel>> getPostsByAuthor(String authorId) {
    try {
      return _firestore
          .collection('posts')
          .where('authorId', isEqualTo: authorId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snap) =>
                snap.docs.map((d) => PostsModel.fromFirestore(d)).toList(),
          );
    } catch (e) {
      throw Exception('작성자별 게시글 조회 실패: $e');
    }
  }

  /// Storage에서 이미지 삭제 (실패해도 진행)
  Future<void> _deleteImageFromStorage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // 삭제 실패는 치명적이지 않으므로 로그만 남기고 계속 진행
      // ignore: avoid_print
      print('이미지 삭제 실패: $imageUrl, 에러: $e');
    }
  }
}
