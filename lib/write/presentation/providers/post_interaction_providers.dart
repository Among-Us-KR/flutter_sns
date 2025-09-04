import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Service and Provider for post interactions (likes) ---

class PostInteractionService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PostInteractionService(this._firestore, this._auth);

  Future<void> toggleLike({required String postId}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('로그인이 필요합니다.');
    }
    final userId = currentUser.uid;
    final likeId = '${postId}_$userId';
    final likeRef = _firestore.collection('likes').doc(likeId);
    final postRef = _firestore.collection('posts').doc(postId);

    // 트랜잭션을 사용하여 '좋아요' 상태와 게시물의 '좋아요 수'를 원자적으로 업데이트합니다.
    await _firestore.runTransaction((transaction) async {
      final likeDoc = await transaction.get(likeRef);

      if (likeDoc.exists) {
        // Unlike: 'likes' 컬렉션에서 문서를 삭제하고 'posts'의 likesCount를 1 감소시킵니다.
        transaction.delete(likeRef);
        transaction.update(postRef, {
          'stats.likesCount': FieldValue.increment(-1),
        });
      } else {
        // Like: 'likes' 컬렉션에 문서를 추가하고 'posts'의 likesCount를 1 증가시킵니다.
        transaction.set(likeRef, {
          'postId': postId,
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        transaction.update(postRef, {
          'stats.likesCount': FieldValue.increment(1),
        });
      }
    });
  }

  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('로그인이 필요합니다.');
    }
    final userId = currentUser.uid;

    final postRef = _firestore.collection('posts').doc(postId);
    final newCommentRef = _firestore.collection('comments').doc();
    final userRef = _firestore.collection('users').doc(userId);

    await _firestore.runTransaction((transaction) async {
      // 댓글 작성에 필요한 사용자 정보를 가져옵니다.
      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists) {
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      }
      final userData = userDoc.data()!;
      final authorData = {
        'nickname': userData['nickname'] ?? '익명',
        'profileImageUrl': userData['profileImageUrl'],
      };

      // 1. 'comments' 컬렉션에 새 댓글 문서를 생성합니다.
      transaction.set(newCommentRef, {
        'postId': postId,
        'authorId': userId,
        'author': authorData,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. 'posts' 문서의 commentsCount를 1 증가시킵니다.
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
      // 댓글 작성자 본인만 삭제할 수 있도록 권한을 확인합니다.
      if (commentDoc.data()?['authorId'] != userId) {
        throw Exception('댓글을 삭제할 권한이 없습니다.');
      }
      transaction.delete(commentRef);
      transaction.update(postRef, {
        'stats.commentsCount': FieldValue.increment(-1),
      });
    });
  }

  /// 게시물을 신고하고 신고 횟수를 1 증가시킵니다.
  Future<void> reportPost({
    required String postId,
    String reason = '일반 신고', // 신고 사유 (추후 확장 가능)
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('로그인이 필요합니다.');
    }
    final reporterId = currentUser.uid;

    final postRef = _firestore.collection('posts').doc(postId);
    // 한 사용자가 같은 게시물을 여러 번 신고하는 것을 방지하기 위해 복합 ID를 사용합니다.
    final reportId = '${postId}_$reporterId';
    final reportRef = _firestore.collection('reports').doc(reportId);

    await _firestore.runTransaction((transaction) async {
      final postDoc = await transaction.get(postRef);
      if (!postDoc.exists) {
        throw Exception('신고할 게시물을 찾을 수 없습니다.');
      }

      final reportDoc = await transaction.get(reportRef);
      if (reportDoc.exists) {
        // 이미 신고한 경우, 아무 작업도 하지 않고 성공한 것처럼 처리하거나 예외를 던질 수 있습니다.
        throw Exception('이미 신고한 게시물입니다.');
      }

      // 1. 'reports' 컬렉션에 새로운 신고 문서를 생성합니다.
      transaction.set(reportRef, {
        'postId': postId,
        'postOwnerId': postDoc.data()?['authorId'], // 게시물 작성자 ID
        'reporterId': reporterId, // 신고자 ID
        'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. 'posts' 문서의 reportCount를 1 증가시킵니다.
      transaction.update(postRef, {'reportCount': FieldValue.increment(1)});
    });
  }
}

final postInteractionServiceProvider = Provider((ref) {
  return PostInteractionService(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});

final postLikesCountProvider = StreamProvider.family<int, String>((
  ref,
  postId,
) {
  return FirebaseFirestore.instance
      .collection('likes')
      .where('postId', isEqualTo: postId)
      .snapshots()
      .map((snapshot) => snapshot.size);
});

final isPostLikedProvider = StreamProvider.family<bool, String>((ref, postId) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return Stream.value(false);
  }
  // 루트 'likes' 컬렉션에서 조합된 ID로 문서를 직접 조회합니다.
  final likeId = '${postId}_$userId';
  return FirebaseFirestore.instance
      .collection('likes')
      .doc(likeId)
      .snapshots()
      .map((snapshot) => snapshot.exists);
});

final commentsCountProvider = StreamProvider.family<int, String>((ref, postId) {
  return FirebaseFirestore.instance
      .collection('comments')
      .where('postId', isEqualTo: postId)
      .snapshots()
      .map((snapshot) => snapshot.size);
});
