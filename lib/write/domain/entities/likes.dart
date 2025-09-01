// 좋아요 엔티티 클래스
class Likes {
  final String id;
  final String postId;
  final String userId;
  final DateTime createdAt;

  Likes({
    required this.id,
    required this.postId,
    required this.userId,
    required this.createdAt,
  });

  Likes copyWith({
    String? id,
    String? postId,
    String? userId,
    DateTime? createdAt,
  }) {
    return Likes(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
