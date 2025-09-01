import 'package:cloud_firestore/cloud_firestore.dart';

// 댓글 정보 DTO
class CommentsModel {
  final String id;
  final String postId;
  final String authorId;
  final Author author;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int reportCount;

  CommentsModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.author,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.reportCount,
  });

  // JSON에서 Comment 객체 생성
  factory CommentsModel.fromJson(Map<String, dynamic> json) {
    return CommentsModel(
      id: json['id'] ?? '',
      postId: json['postId'] ?? '',
      authorId: json['authorId'] ?? '',
      author: Author.fromJson(json['author'] ?? {}),
      content: json['content'] ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(json['updatedAt']),
      reportCount: json['reportCount'] ?? 0,
    );
  }

  // Firestore DocumentSnapshot에서 Comment 객체 생성
  factory CommentsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentsModel.fromJson(data..['id'] = doc.id); // document ID 추가
  }

  // Comment 객체를 JSON Map으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'authorId': authorId,
      'author': author.toJson(),
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'reportCount': reportCount,
    };
  }

  // Firestore 저장용 (Timestamp 사용, id 제외)
  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'authorId': authorId,
      'author': author.toJson(),
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'reportCount': reportCount,
    };
  }

  // Comment 객체 복사 (일부 필드 수정)
  CommentsModel copyWith({
    String? id,
    String? postId,
    String? authorId,
    Author? author,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? reportCount,
  }) {
    return CommentsModel(
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
}
