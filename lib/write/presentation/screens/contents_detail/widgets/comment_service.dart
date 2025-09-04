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

    final postRef = _firestore.collection('posts').doc(postId);
    final userRef = _firestore.collection('users').doc(currentUser.uid);
    final newCommentRef = _firestore.collection('comments').doc();

    // 트랜잭션을 사용하여 댓글 추가와 게시물 댓글 수 업데이트를 원자적으로 처리합니다.
    await _firestore.runTransaction((transaction) async {
      // 1. 댓글 작성자와 게시물 정보를 가져옵니다.
      final userDoc = await transaction.get(userRef);
      final postDoc = await transaction.get(postRef);

      if (!userDoc.exists) {
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      }
      if (!postDoc.exists) {
        throw Exception('게시물을 찾을 수 없습니다.');
      }

      final userData = userDoc.data()!;
      final nickname = userData['nickname'] as String? ?? '이름없음';
      final profileImageUrl = userData['profileImageUrl'] as String?;

      final postOwnerId = postDoc.data()!['authorId'];

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

      // 2. 'comments' 컬렉션에 새 댓글 문서를 생성합니다.
      transaction.set(newCommentRef, commentData);

      // 3. 'posts' 문서의 commentsCount를 1 증가시킵니다.
      transaction.update(postRef, {
        'stats.commentsCount': FieldValue.increment(1),
      });
    });
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('로그인이 필요합니다.');
    }
    final userId = currentUser.uid;

    final postRef = _firestore.collection('posts').doc(postId);
    final commentRef = _firestore.collection('comments').doc(commentId);

    await _firestore.runTransaction((transaction) async {
      final commentDoc = await transaction.get(commentRef);
      if (!commentDoc.exists) {
        throw Exception('삭제할 댓글을 찾을 수 없습니다.');
      }
      if (commentDoc.data()?['userId'] != userId) {
        throw Exception('댓글을 삭제할 권한이 없습니다.');
      }
      transaction.delete(commentRef);
      transaction.update(postRef, {
        'stats.commentsCount': FieldValue.increment(-1),
      });
    });
  }
}

final commentServiceProvider = Provider((ref) {
  return CommentService(FirebaseFirestore.instance, FirebaseAuth.instance);
});
