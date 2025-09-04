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

    // 1. 댓글 작성자의 정보와 게시물 작성자의 정보를 동시에 가져옵니다. (네트워크 효율성 개선)
    final userDocFuture = _firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final postDocFuture = _firestore.collection('posts').doc(postId).get();

    final results = await Future.wait([userDocFuture, postDocFuture]);

    // Dart 3의 패턴 매칭을 사용하여 더 안전하게 타입을 확인하고 변수를 할당합니다.
    if (results case [
      final DocumentSnapshot<Map<String, dynamic>> userDoc,
      final DocumentSnapshot<Map<String, dynamic>> postDoc,
    ]) {
      // userDoc과 postDoc이 올바른 타입으로 안전하게 할당되었습니다.
      // 이 블록 안에서 나머지 로직을 수행합니다.

      final userData = userDoc.data();
      final nickname = userData?['nickname'] as String? ?? '이름없음';
      final profileImageUrl = userData?['profileImageUrl'] as String?;

      // 2. 알림 기능을 위해 게시물 원본 작성자의 ID를 가져옵니다.
      final postOwnerId = postDoc.data()?['authorId'];
      if (postOwnerId == null) {
        throw Exception('게시물 작성자 정보를 찾을 수 없습니다.');
      }

      final newCommentRef = _firestore.collection('comments').doc();

      final commentData = {
        'postId': postId,
        'userId': currentUser.uid, // Firestore 규칙과 일치시키기 위해 'userId'로 변경
        'postOwnerId': postOwnerId, // 알림 기능을 위해 게시물 작성자 ID 추가
        'author': {'nickname': nickname, 'profileImageUrl': profileImageUrl},
        'content': sanitizedContent,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'reportCount': 0,
      };
      await newCommentRef.set(commentData);
    } else {
      // Future.wait의 결과가 예상과 다른 경우(예: null)에 대한 예외 처리
      throw Exception('사용자 또는 게시물 정보를 가져오는 데 실패했습니다.');
    }
  }
}

final commentServiceProvider = Provider((ref) {
  return CommentService(FirebaseFirestore.instance, FirebaseAuth.instance);
});
