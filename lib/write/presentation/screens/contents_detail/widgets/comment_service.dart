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
      'authorId': currentUser.uid,
      'author': {'nickname': nickname, 'profileImageUrl': profileImageUrl},
      'content': sanitizedContent,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'reportCount': 0,
    };
    await newCommentRef.set(commentData);
  }
}

final commentServiceProvider = Provider((ref) {
  return CommentService(FirebaseFirestore.instance, FirebaseAuth.instance);
});
