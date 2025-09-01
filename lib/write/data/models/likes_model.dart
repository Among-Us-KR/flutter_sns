import 'package:cloud_firestore/cloud_firestore.dart';

// 좋아요 정보 DTO
class LikesModel {
  final String id;
  final String postId;
  final String userId;
  final DateTime createdAt;

  LikesModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.createdAt,
  });

  // JSON에서 Like 객체 생성
  factory LikesModel.fromJson(Map<String, dynamic> json) {
    return LikesModel(
      id: json['id'] ?? '',
      postId: json['postId'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt']),
    );
  }

  // Firestore DocumentSnapshot에서 Like 객체 생성
  factory LikesModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LikesModel.fromJson(data..['id'] = doc.id); // document ID 추가
  }

  // Like 객체를 JSON Map으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Firestore 저장용 (Timestamp 사용, id 제외)
  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Like 객체 복사 (일부 필드 수정)
  LikesModel copyWith({
    String? id,
    String? postId,
    String? userId,
    DateTime? createdAt,
  }) {
    return LikesModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // 고유 문서 ID 생성 ({userId}_{postId} 형태)
  static String generateDocumentId(String userId, String postId) {
    return '${userId}_${postId}';
  }

  // 현재 Like의 문서 ID 반환
  String get documentId => generateDocumentId(userId, postId);
}
