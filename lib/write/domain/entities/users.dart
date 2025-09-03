// 유저 엔티티
class User {
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

  User({
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

  // User 객체 복사 (일부 필드 수정)
  User copyWith({
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
    return User(
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

// 사용자 통계 엔티티
class UserStats {
  final int postsCount;
  final int commentsCount;
  final int empathyReceived; // 추가된 필드
  final int punchReceived; // 추가된 필드

  const UserStats({
    this.postsCount = 0,
    this.commentsCount = 0,
    this.empathyReceived = 0,
    this.punchReceived = 0,
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
}

// 개인정보 동의 엔티티
class PrivacyConsent {
  final DateTime agreedAt;
  final String version;
  final String ipAddress;

  const PrivacyConsent({
    required this.agreedAt,
    required this.version,
    required this.ipAddress,
  });
}
