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
  CollectionReference<Map<String, dynamic>> get _comments =>
      _firestore.collection('comments');
  CollectionReference<Map<String, dynamic>> get _likes =>
      _firestore.collection('likes');

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

  /// 사용자가 작성한 모든 게시글을 조회
  Future<List<PostsModel>> getPostsByUserId(String userId) async {
    try {
      final querySnapshot = await _posts
          .where('authorId', isEqualTo: userId)
          .get();
      final List<PostsModel> posts = [];
      for (final doc in querySnapshot.docs) {
        try {
          // 데이터 파싱 중 오류가 발생할 수 있는 문서를 건너뜁니다.
          posts.add(PostsModel.fromFirestore(doc));
        } catch (e) {
          print('게시글(${doc.id}) 파싱 실패, 건너뜁니다: $e');
        }
      }
      return posts;
    } catch (e) {
      throw Exception('사용자 게시글 조회 실패: $e');
    }
  }

  /// 사용자가 좋아요를 누른 모든 게시글 ID를 조회
  Future<List<String>> getLikedPostIds(String userId) async {
    try {
      final querySnapshot = await _likes
          .where('userId', isEqualTo: userId)
          .get();
      // 데이터 무결성을 위해 postId가 null이거나 String이 아닌 경우를 필터링합니다.
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            if (data.containsKey('postId') && data['postId'] is String) {
              return data['postId'] as String;
            }
            return null;
          })
          .whereType<String>() // null 값을 걸러냅니다.
          .toList();
    } catch (e) {
      throw Exception('사용자 좋아요 게시글 ID 조회 실패: $e');
    }
  }

  /// 사용자가 댓글을 단 모든 게시글 ID를 조회
  Future<List<String>> getCommentedPostIds(String userId) async {
    try {
      final querySnapshot = await _comments
          .where('authorId', isEqualTo: userId)
          .get();
      // 중복된 postId를 제거하기 위해 Set을 사용
      return querySnapshot.docs
          .map((doc) => doc.data()['postId'] as String)
          .toSet()
          .toList();
    } catch (e) {
      throw Exception('사용자 댓글 게시글 ID 조회 실패: $e');
    }
  }

  /// 주어진 게시글 ID 목록에 해당하는 모든 게시글을 조회
  Future<List<PostsModel>> getPostsByIds(List<String> postIds) async {
    if (postIds.isEmpty) {
      return [];
    }
    // Firestore의 `whereIn` 쿼리에는 최대 10개의 값만 포함될 수 있으므로, 목록을 나누어 처리
    const chunkSize = 10;
    List<PostsModel> posts = [];
    for (int i = 0; i < postIds.length; i += chunkSize) {
      final chunk = postIds.sublist(
        i,
        i + chunkSize > postIds.length ? postIds.length : i + chunkSize,
      );
      final querySnapshot = await _posts
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final doc in querySnapshot.docs) {
        try {
          // 데이터 파싱 중 오류가 발생할 수 있는 문서를 건너뜁니다.
          posts.add(PostsModel.fromFirestore(doc));
        } catch (e) {
          print('게시글(${doc.id}) 파싱 실패, 건너뜁니다: $e');
        }
      }
    }
    return posts;
  }

  /// 사용자가 작성한 모든 댓글을 조회
  Future<List<Map<String, dynamic>>> getUserComments(String userId) async {
    try {
      final querySnapshot = await _comments
          .where('authorId', isEqualTo: userId)
          .get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('사용자 댓글 조회 실패: $e');
    }
  }
}
