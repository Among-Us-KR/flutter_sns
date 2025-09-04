import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sns/write/domain/entities/comments.dart'
    as comment_entity;
import 'package:flutter_sns/write/domain/entities/posts.dart';

// Firestore 데이터를 Posts 엔티티로 변환하는 헬퍼 함수
Posts postFromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data();
  if (data == null) throw StateError('Missing data for post ${doc.id}');

  // 중첩된 author 객체 처리
  final authorData = data['author'];
  final authorMap = (authorData is Map)
      ? Map<String, dynamic>.from(authorData)
      : <String, dynamic>{};
  final author = Author(
    nickname: authorMap['nickname'] as String? ?? 'Unknown User',
    profileImageUrl: authorMap['profileImageUrl'] as String?,
  );

  // 중첩된 stats 객체 처리
  final statsData = data['stats'];
  final statsMap = (statsData is Map)
      ? Map<String, dynamic>.from(statsData)
      : <String, dynamic>{};
  final stats = PostStats(
    likesCount: statsMap['likesCount'] as int? ?? 0,
    commentsCount: statsMap['commentsCount'] as int? ?? 0,
  );

  // 이미지 리스트 처리
  final imagesData = data['images'];
  final images = (imagesData is List)
      ? imagesData.map((item) => item.toString()).toList()
      : <String>[];

  // 타임스탬프 처리
  final createdAtData = data['createdAt'];
  final updatedAtData = data['updatedAt'];
  final createdAt = (createdAtData is Timestamp)
      ? createdAtData.toDate()
      : DateTime.now();
  final updatedAt = (updatedAtData is Timestamp)
      ? updatedAtData.toDate()
      : DateTime.now();

  return Posts(
    id: doc.id,
    authorId: data['authorId'] as String? ?? '',
    author: author,
    category: data['category'] as String? ?? '',
    mode: data['mode'] as String? ?? '',
    title: data['title'] as String? ?? '',
    content: data['content'] as String? ?? '',
    images: images,
    stats: stats,
    createdAt: createdAt,
    updatedAt: updatedAt,
    reportCount: data['reportCount'] as int? ?? 0,
  );
}

// Firestore 데이터를 Comments 엔티티로 변환하는 헬퍼 함수
comment_entity.Comments commentFromFirestore(
  DocumentSnapshot<Map<String, dynamic>> doc,
) {
  final data = doc.data();
  if (data == null) throw StateError('Missing data for comment ${doc.id}');

  // 중첩된 author 객체 처리 (더 안전하게)
  final authorData = data['author'];
  final authorMap = (authorData is Map)
      ? Map<String, dynamic>.from(authorData)
      : <String, dynamic>{};
  final author = comment_entity.Author(
    nickname: authorMap['nickname'] as String? ?? 'Unknown User',
    profileImageUrl: authorMap['profileImageUrl'] as String?,
  );

  // 타임스탬프 처리
  final createdAtData = data['createdAt'];
  final updatedAtData = data['updatedAt'];
  final createdAt = (createdAtData is Timestamp)
      ? createdAtData.toDate()
      : DateTime.now();
  final updatedAt = (updatedAtData is Timestamp)
      ? updatedAtData.toDate()
      : DateTime.now();

  // reportCount 처리
  final reportCountData = data['reportCount'];
  final reportCount = (reportCountData is num) ? reportCountData.toInt() : 0;

  return comment_entity.Comments(
    id: doc.id,
    postId: data['postId'] as String? ?? '',
    // Firestore에는 'userId'로 저장되지만, 앱의 다른 부분과의 호환성을 위해
    // 'Comments' 엔티티의 'authorId' 필드에 매핑합니다.
    authorId: data['userId'] as String? ?? '',
    author: author,
    content: data['content'] as String? ?? '',
    createdAt: createdAt,
    updatedAt: updatedAt,
    reportCount: reportCount,
  );
}
