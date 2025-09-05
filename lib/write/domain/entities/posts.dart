// 게시글 엔티티 클래스
class Posts {
  final String id;
  final String authorId;
  final Author author;
  final String category;
  final String mode;
  final String title;
  final String content;
  final List<String> images;
  final PostStats stats;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int reportCount;

  Posts({
    required this.id,
    required this.authorId,
    required this.author,
    required this.category,
    required this.mode,
    required this.title,
    required this.content,
    required this.images,
    required this.stats,
    required this.createdAt,
    required this.updatedAt,
    required this.reportCount,
  });

  Posts copyWith({
    String? id,
    String? authorId,
    Author? author,
    String? category,
    String? mode,
    String? title,
    String? content,
    List<String>? images,
    PostStats? stats,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? reportCount,
  }) {
    return Posts(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      author: author ?? this.author,
      category: category ?? this.category,
      mode: mode ?? this.mode,
      title: title ?? this.title,
      content: content ?? this.content,
      images: images ?? this.images,
      stats: stats ?? this.stats,
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

class PostStats {
  final int likesCount;
  final int commentsCount;
  final int empathyCommentsCount; // 추가
  final int punchCommentsCount; // 추가

  const PostStats({
    this.likesCount = 0,
    this.commentsCount = 0,
    this.empathyCommentsCount = 0,
    this.punchCommentsCount = 0,
  });

  PostStats copyWith({int? likesCount, int? commentsCount}) {
    return PostStats(
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }
}
