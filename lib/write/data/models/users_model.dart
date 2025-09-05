import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory UsersModel.fromJson(Map<String, dynamic> json) {
    DateTime _toDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    return UsersModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      nickname: json['nickname'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      privacyConsent: PrivacyConsent.fromJson(json['privacyConsent'] ?? {}),
      stats: UserStats.fromJson(json['stats'] ?? {}),
      pushNotifications: json['pushNotifications'] ?? true,
      createdAt: _toDate(json['createdAt']),
      updatedAt: _toDate(json['updatedAt']),
      reportCount: json['reportCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'nickname': nickname,
      'profileImageUrl': profileImageUrl,
      'privacyConsent': privacyConsent.toJson(),
      'stats': stats.toJson(),
      'pushNotifications': pushNotifications,
      // createdAt/updatedAt는 datasource에서 serverTimestamp로 세팅
      'reportCount': reportCount,
      // 닉네임 중복검색용(소문자)
      'nicknameLower': nickname.toLowerCase(),
    };
  }

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
    DateTime _toDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    return PrivacyConsent(
      agreedAt: _toDate(json['agreedAt']),
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

// 사용자 통계 엔티티
class UserStats {
  final int postsCount;
  final int commentsCount;
  final int likesCount;
  final int commentsReceived;
  final int likesReceived;

  const UserStats({
    this.postsCount = 0,
    this.commentsCount = 0,
    this.likesCount = 0,
    this.commentsReceived = 0,
    this.likesReceived = 0,
  });

  UserStats copyWith({
    int? postsCount,
    int? commentsCount,
    int? likesCount,
    int? commentsReceived,
    int? likesReceieved,
  }) {
    return UserStats(
      postsCount: postsCount ?? this.postsCount,
      commentsCount: commentsCount ?? this.commentsCount,
      likesCount: likesCount ?? this.likesCount,
      commentsReceived: commentsReceived ?? this.commentsReceived,
      likesReceived: likesReceieved ?? this.likesReceived,
    );
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      postsCount: json['postsCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      likesCount: json['likesCount'] ?? 0,
      commentsReceived: json['commentsRecived'] ?? 0,
      likesReceived: json['likesRecieved'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postsCount': postsCount,
      'commentsCount': commentsCount,
      'likesCount': likesCount,
      'commentsReceived': commentsReceived,
      'likesReceived': likesReceived,
    };
  }
}
