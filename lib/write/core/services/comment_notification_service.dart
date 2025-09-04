// Firestore 댓글 실시간 감지 및 알림 트리거
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sns/utils/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _subscription;

  void subscribeToComments() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    _subscription?.cancel();

    _subscription = _firestore
        .collection('comments')
        .where('postOwnerId', isEqualTo: currentUser.uid)
        .snapshots()
        .listen((snapshot) async {
          for (final docChange in snapshot.docChanges) {
            if (docChange.type != DocumentChangeType.added) continue;

            final commentData = docChange.doc.data();
            if (commentData == null) continue;

            final commenterId = commentData['commenterId'];
            final commentContent = commentData['content'] ?? '댓글 내용 없음';
            final commentId = commentData['commentId'];

            if (commenterId == null || commentId == null) continue;

            final ownerDoc = await _firestore
                .collection('users')
                .doc(currentUser.uid)
                .get();

            final pushAllowed = ownerDoc.data()?['pushNotifications'] ?? false;
            if (!pushAllowed) continue;

            await NotificationService.showNotification(
              id: commentId.hashCode,
              title: '새 댓글이 달렸습니다!',
              body: commentContent,
            );
          }
        });
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
