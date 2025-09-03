import 'package:cloud_firestore/cloud_firestore.dart';

// 유저 정보 DTO
class UsersModel {
  final String uid;
  final String email;
  final String nickname;
  final String? profileImageUrl;
  final PrivacyConsent privacyConsent;
  final UserStats stats;
  final bool pushNotifications;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int reportCount;

  UsersModel({
    required this.uid,
    required this.email,
    required this.nickname,
    this.profileImageUrl,
    required this.privacyConsent,
    required this.stats,
    required this.pushNotifications,
    required this.createdAt,
    required this.updatedAt,
    required this.reportCount,
  });

  // JSON에서 User 객체 생성
  factory UsersModel.fromJson(Map<String, dynamic> json) {
    return UsersModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      nickname: json['nickname'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      privacyConsent: PrivacyConsent.fromJson(json['privacyConsent'] ?? {}),
      stats: UserStats.fromJson(json['stats'] ?? {}),
      pushNotifications: json['pushNotifications'] ?? true,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(json['updatedAt']),
      reportCount: json['reportCount'] ?? 0,
    );
  }

  // User 객체를 JSON Map으로 변환
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'nickname': nickname,
      'profileImageUrl': profileImageUrl,
      'privacyConsent': privacyConsent.toJson(),
      'stats': stats.toJson(),
      'pushNotifications': pushNotifications,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'reportCount': reportCount,
    };
  }

  // User 객체 복사 (일부 필드 수정)
  UsersModel copyWith({
    String? uid,
    String? email,
    String? nickname,
    String? profileImageUrl,
    PrivacyConsent? privacyConsent,
    UserStats? stats,
    bool? pushNotifications,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? reportCount,
  }) {
    return UsersModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      privacyConsent: privacyConsent ?? this.privacyConsent,
      stats: stats ?? this.stats,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reportCount: reportCount ?? this.reportCount,
    );
  }
}

// 개인정보 동의 클래스
class PrivacyConsent {
  final DateTime agreedAt;
  final String version;
  final String ipAddress;

  PrivacyConsent({
    required this.agreedAt,
    required this.version,
    required this.ipAddress,
  });

  factory PrivacyConsent.fromJson(Map<String, dynamic> json) {
    return PrivacyConsent(
      agreedAt: json['agreedAt'] is Timestamp
          ? (json['agreedAt'] as Timestamp).toDate()
          : DateTime.parse(
              json['agreedAt'] ?? DateTime.now().toIso8601String(),
            ),
      version: json['version'] ?? '1.0',
      ipAddress: json['ipAddress'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agreedAt': agreedAt.toIso8601String(),
      'version': version,
      'ipAddress': ipAddress,
    };
  }
}

// 사용자 통계 클래스
class UserStats {
  final int postsCount;
  final int commentsCount;
  final int empathyReceived; // 추가된 필드
  final int punchReceived; // 추가된 필드

  UserStats({
    required this.postsCount,
    required this.commentsCount,
    required this.empathyReceived, // 생성자 업데이트
    required this.punchReceived, // 생성자 업데이트
  });

  UserStats copyWith({
    int? postsCount,
    int? commentsCount,
    int? empathyReceived,
    int? punchReceived,
  }) {
    return UserStats(
      postsCount: postsCount ?? this.postsCount,
      commentsCount: commentsCount ?? this.commentsCount,
      empathyReceived: empathyReceived ?? this.empathyReceived,
      punchReceived: punchReceived ?? this.punchReceived,
    );
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      postsCount: json['postsCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      empathyReceived: json['empathyReceived'] ?? 0, // fromJson 업데이트
      punchReceived: json['punchReceived'] ?? 0, // fromJson 업데이트
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postsCount': postsCount,
      'commentsCount': commentsCount,
      'empathyReceived': empathyReceived, // toJson 업데이트
      'punchReceived': punchReceived, // toJson 업데이트
    };
  }

  // 통계 업데이트 메서드
  UserStats updatePostsCount(int increment) {
    return UserStats(
      postsCount: postsCount + increment,
      commentsCount: commentsCount,
      empathyReceived: empathyReceived,
      punchReceived: punchReceived,
    );
  }

  UserStats updateCommentsCount(int increment) {
    return UserStats(
      postsCount: postsCount,
      commentsCount: commentsCount + increment,
      empathyReceived: empathyReceived,
      punchReceived: punchReceived,
    );
  }

  // 기존 updateLikesReceived는 공감/팩폭으로 분리해야 함
  UserStats updateEmpathyReceived(int increment) {
    return UserStats(
      postsCount: postsCount,
      commentsCount: commentsCount,
      empathyReceived: empathyReceived + increment,
      punchReceived: punchReceived,
    );
  }

  UserStats updatePunchReceived(int increment) {
    return UserStats(
      postsCount: postsCount,
      commentsCount: commentsCount,
      empathyReceived: empathyReceived,
      punchReceived: punchReceived + increment,
    );
  }
}
