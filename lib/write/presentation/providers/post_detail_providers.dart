import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sns/write/domain/entities/comments.dart'
    as comment_entity;
import 'package:flutter_sns/write/domain/entities/posts.dart';
import 'package:flutter_sns/write/presentation/screens/contents_detail/widgets/firestore_mapper.dart';

// 특정 게시물 하나의 스트림을 제공하는 프로바이더
final postProvider = StreamProvider.family<Posts, String>((ref, postId) {
  return FirebaseFirestore.instance
      .collection('posts')
      .doc(postId)
      .snapshots()
      .map(postFromFirestore);
});

// 특정 게시물의 댓글 목록 스트림을 제공하는 프로바이더
final commentsProvider =
    StreamProvider.family<List<comment_entity.Comments>, String>((ref, postId) {
      return FirebaseFirestore.instance
          .collection('comments')
          .where('postId', isEqualTo: postId)
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.map(commentFromFirestore).toList());
    });
