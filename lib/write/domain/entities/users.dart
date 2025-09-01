// 사용자 엔티티 클래스
class Users {
  final String userID;
  final String email;
  final String nickname;
  final String? profileImageUrl;
  final PrivacyConsent privacyConsent;
  final UserStats stats;
  final bool pushNotifications;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int reportCount;

  Users({
    required this.userID,
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

  Users copyWith({
    String? userID,
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
    return Users(
      userID: userID ?? this.userID,
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

class PrivacyConsent {
  final DateTime agreedAt;
  final String version;
  final String ipAddress;

  PrivacyConsent({
    required this.agreedAt,
    required this.version,
    required this.ipAddress,
  });
}

class UserStats {
  final int postsCount;
  final int commentsCount;
  final int likesReceived;

  UserStats({
    required this.postsCount,
    required this.commentsCount,
    required this.likesReceived,
  });

  UserStats copyWith({
    int? postsCount,
    int? commentsCount,
    int? likesReceived,
  }) {
    return UserStats(
      postsCount: postsCount ?? this.postsCount,
      commentsCount: commentsCount ?? this.commentsCount,
      likesReceived: likesReceived ?? this.likesReceived,
    );
  }
}
