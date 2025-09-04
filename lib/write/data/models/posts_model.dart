import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sns/write/domain/entities/posts.dart' as domain;

// 게시글 정보 DTO
class PostsModel {
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

  PostsModel({
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

  // JSON에서 Post 객체 생성
  factory PostsModel.fromJson(Map<String, dynamic> json) {
    return PostsModel(
      id: json['id'] ?? '',
      authorId: json['authorId'] ?? '',
      author: Author.fromJson(json['author'] ?? {}),
      category: json['category'] ?? '',
      mode: json['mode'] ?? 'empathy',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      stats: PostStats.fromJson(json['stats'] ?? {}),
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(json['updatedAt']),
      reportCount: json['reportCount'] ?? 0,
    );
  }

  // Firestore DocumentSnapshot에서 Post 객체 생성
  factory PostsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostsModel.fromJson(data..['id'] = doc.id); // document ID 추가
  }

  // Post 객체를 JSON Map으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'author': author.toJson(),
      'category': category,
      'mode': mode,
      'title': title,
      'content': content,
      'images': images,
      'stats': stats.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'reportCount': reportCount,
    };
  }

  // Firestore 저장용 (Timestamp 사용, id 제외)
  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'author': author.toJson(),
      'category': category,
      'mode': mode,
      'title': title,
      'content': content,
      'images': images,
      'stats': stats.toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'reportCount': reportCount,
    };
  }

  // Post 객체 복사 (일부 필드 수정)
  PostsModel copyWith({
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
    return PostsModel(
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

  // PostsModel을 도메인 엔티티로 변환하는 toDomain() 메서드
  domain.Posts toDomain() {
    return domain.Posts(
      id: id,
      authorId: authorId,
      author: author.toDomain(),
      category: category,
      mode: mode,
      title: title,
      content: content,
      images: images,
      stats: stats.toDomain(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      reportCount: reportCount,
    );
  }
}

// 작성자 정보 클래스
class Author {
  final String nickname;
  final String? profileImageUrl;

  Author({required this.nickname, this.profileImageUrl});

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      nickname: json['nickname'] ?? '',
      profileImageUrl: json['profileImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'nickname': nickname, 'profileImageUrl': profileImageUrl};
  }

  // Author DTO를 도메인 엔티티로 변환하는 toDomain() 메서드 추가
  domain.Author toDomain() {
    return domain.Author(nickname: nickname, profileImageUrl: profileImageUrl);
  }
}

// 게시글 통계 클래스
class PostStats {
  final int likesCount;
  final int commentsCount;

  PostStats({required this.likesCount, required this.commentsCount});

  factory PostStats.fromJson(Map<String, dynamic> json) {
    return PostStats(
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'likesCount': likesCount, 'commentsCount': commentsCount};
  }

  // 통계 업데이트 메서드
  PostStats updateLikesCount(int increment) {
    return PostStats(
      likesCount: likesCount + increment,
      commentsCount: commentsCount,
    );
  }

  PostStats updateCommentsCount(int increment) {
    return PostStats(
      likesCount: likesCount,
      commentsCount: commentsCount + increment,
    );
  }

  // PostStats DTO를 도메인 엔티티로 변환하는 toDomain() 메서드 추가
  domain.PostStats toDomain() {
    return domain.PostStats(
      likesCount: likesCount,
      commentsCount: commentsCount,
    );
  }
}
