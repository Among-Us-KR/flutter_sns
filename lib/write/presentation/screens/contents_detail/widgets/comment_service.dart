import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sns/utils/xss.dart';

class CommentService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CommentService(this._firestore, this._auth);

  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('로그인이 필요합니다.');
    }

    final sanitizedContent = XssFilter.sanitize(content);
    if (sanitizedContent.isEmpty) {
      throw Exception('댓글 내용을 입력해주세요.');
    }

    // Firestore에서 현재 사용자의 닉네임과 프로필 이미지 URL 가져오기
    final userDoc = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final userData = userDoc.data();
    final nickname = userData?['nickname'] as String? ?? '이름없음';
    final profileImageUrl = userData?['profileImageUrl'] as String?;

    final newCommentRef = _firestore.collection('comments').doc();

    final commentData = {
      'postId': postId,
      'userId': currentUser.uid,
      'author': {'nickname': nickname, 'profileImageUrl': profileImageUrl},
      'content': sanitizedContent,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'reportCount': 0,
    };

    // Firestore 보안 규칙에 따라, 다른 사람의 게시물('posts' 문서)을 수정할 권한이 없습니다.
    // 따라서 댓글을 추가할 때 게시물의 댓글 수를 직접 업데이트하는 로직을 제거하고,
    // 'comments' 컬렉션에 새 댓글을 추가하는 작업만 수행합니다.
    // 게시물의 댓글 수를 실시간으로 정확하게 반영하려면 서버 측 로직(예: Cloud Function)을 사용해야 합니다.
    await newCommentRef.set(commentData);
  }
}

final commentServiceProvider = Provider((ref) {
  return CommentService(FirebaseFirestore.instance, FirebaseAuth.instance);
});
