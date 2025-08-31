// 댓글 엔티티 클래스
class Comments {
  final String id;
  final String postId;
  final String authorId;
  final Author author;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int reportCount;

  Comments({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.author,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.reportCount,
  });

  Comments copyWith({
    String? id,
    String? postId,
    String? authorId,
    Author? author,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? reportCount,
  }) {
    return Comments(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      author: author ?? this.author,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reportCount: reportCount ?? this.reportCount,
    );
  }
}

class Author {
  final String nickname;
  final String? profileImageUrl;

  Author({required this.nickname, this.profileImageUrl});
}
