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

  CollectionReference<Map<String, dynamic>> get _posts =>
      _firestore.collection('posts');

  /// 게시글 생성: createdAt/updatedAt 서버시간으로 강제 세팅
  Future<String> createPost(PostsModel post) async {
    try {
      final data = post.toFirestore();
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _posts.add(data);
      return docRef.id;
    } catch (e) {
      throw Exception('게시글 생성 실패: $e');
    }
  }

  /// 게시글 수정: updatedAt 서버시간 갱신
  Future<void> updatePost(PostsModel post) async {
    try {
      final data = post.toFirestore();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _posts.doc(post.id).update(data);
    } catch (e) {
      throw Exception('게시글 수정 실패: $e');
    }
  }

  /// 게시글 삭제 (Storage 이미지도 정리)
  Future<void> deletePost(String postId) async {
    try {
      final doc = await _posts.doc(postId).get();
      if (doc.exists) {
        final post = PostsModel.fromFirestore(doc);
        for (final url in post.images) {
          await _deleteImageFromStorage(url);
        }
      }
      await _posts.doc(postId).delete();
    } catch (e) {
      throw Exception('게시글 삭제 실패: $e');
    }
  }

  /// 특정 게시글 조회
  Future<PostsModel?> getPostById(String postId) async {
    try {
      final doc = await _posts.doc(postId).get();
      if (!doc.exists) return null;
      return PostsModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('게시글 조회 실패: $e');
    }
  }

  /// 이미지 업로드 (로그인 필수)
  /// 경로: post/{uid}/{timestamp}_{index}.(jpg|png)
  /// Storage 규칙과 맞추기 위해 metadata.customMetadata.ownerId 설정
  Future<List<String>> uploadImages(List<File> images) async {
    try {
      if (images.isEmpty) return [];
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }
      final uid = user.uid;
      final nowMs = DateTime.now().millisecondsSinceEpoch;

      final urls = <String>[];
      for (int i = 0; i < images.length; i++) {
        final file = images[i];

        if (!await file.exists()) {
          throw Exception('이미지 파일이 존재하지 않습니다: ${file.path}');
        }

        final ext = p.extension(file.path).toLowerCase().replaceFirst('.', '');
        final isPng = ext == 'png';
        final contentType = isPng ? 'image/png' : 'image/jpeg';

        final objectPath = 'post/$uid/${nowMs}_$i.${isPng ? 'png' : 'jpg'}';
        final ref = _storage.ref(objectPath);

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

  Future<void> _deleteImageFromStorage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (_) {
      // 삭제 실패는 무시 (로그만 남기고 넘어가도 됨)
    }
  }
}
