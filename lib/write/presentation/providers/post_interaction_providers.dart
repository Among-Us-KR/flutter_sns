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
    // 규칙에 따라 루트 'likes' 컬렉션을 사용하고, 문서 ID를 조합하여 만듭니다.
    final likeId = '${postId}_$userId';
    final likeRef = _firestore.collection('likes').doc(likeId);
    final likeDoc = await likeRef.get();

    if (likeDoc.exists) {
      // Unlike the post
      await likeRef.delete();
    } else {
      // Like the post. 규칙에 맞게 postId와 userId를 저장합니다.
      await likeRef.set({
        'postId': postId,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
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
