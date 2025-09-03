import 'dart:io';
import 'package:flutter_sns/write/domain/repository/users_repository.dart';

import '../../domain/entities/users.dart' as domain;
import '../datasources/firebase_user_datasource.dart';
import '../datasources/firebase_storage_datasource.dart';
import '../models/users_model.dart' as dto;

class UserRepositoryImpl implements UserRepository {
  final FirebaseUserDatasource _userDs;
  final FirebaseStorageDataSource _storageDs;

  UserRepositoryImpl(this._userDs, this._storageDs);

  // Domain <-> DTO 매핑
  dto.UsersModel _toDto(domain.User u) => dto.UsersModel(
    uid: u.uid,
    email: u.email,
    nickname: u.nickname,
    profileImageUrl: u.profileImageUrl,
    privacyConsent: dto.PrivacyConsent(
      agreedAt: u.privacyConsent.agreedAt,
      version: u.privacyConsent.version,
      ipAddress: u.privacyConsent.ipAddress,
    ),
    stats: dto.UserStats(
      postsCount: u.stats.postsCount,
      commentsCount: u.stats.commentsCount,
      empathyReceived: u.stats.empathyReceived,
      punchReceived: u.stats.punchReceived,
    ),
    pushNotifications: u.pushNotifications,
    createdAt: u.createdAt,
    updatedAt: u.updatedAt,
    reportCount: u.reportCount,
  );

  domain.User _toDomain(dto.UsersModel m) => domain.User(
    uid: m.uid,
    email: m.email,
    nickname: m.nickname,
    profileImageUrl: m.profileImageUrl,
    privacyConsent: domain.PrivacyConsent(
      agreedAt: m.privacyConsent.agreedAt,
      version: m.privacyConsent.version,
      ipAddress: m.privacyConsent.ipAddress,
    ),
    stats: domain.UserStats(
      postsCount: m.stats.postsCount,
      commentsCount: m.stats.commentsCount,
      empathyReceived: m.stats.empathyReceived,
      punchReceived: m.stats.punchReceived,
    ),
    pushNotifications: m.pushNotifications,
    createdAt: m.createdAt,
    updatedAt: m.updatedAt,
    reportCount: m.reportCount,
  );

  @override
  Future<domain.User> getUserProfile(String uid) async {
    final m = await _userDs.getUser(uid);
    if (m == null) {
      throw Exception('유저 문서가 존재하지 않습니다: $uid');
    }
    return _toDomain(m);
  }

  @override
  Future<void> updateUserProfile(domain.User user) async {
    await _userDs.updateUser(_toDto(user));
  }

  @override
  Future<void> updateUserStats(String uid, domain.UserStats stats) async {
    final cur = await _userDs.getUser(uid);
    if (cur == null) throw Exception('유저 문서가 존재하지 않습니다: $uid');
    final updated = cur.copyWith(
      stats: cur.stats.copyWith(
        postsCount: stats.postsCount,
        commentsCount: stats.commentsCount,
        empathyReceived: stats.empathyReceived,
        punchReceived: stats.punchReceived,
      ),
    );
    await _userDs.updateUser(updated);
  }

  @override
  Future<String> uploadProfileImage(String uid, File file) {
    return _storageDs.uploadProfileImage(uid, file);
  }

  @override
  Future<bool> isNicknameDuplicate(String nickname) {
    return _userDs.isNicknameDuplicate(nickname);
  }
}
