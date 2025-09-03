import 'dart:io';
import 'package:flutter_sns/write/domain/repository/users_repository.dart';
import 'package:flutter_sns/write/domain/entities/users.dart' as domain;
import 'package:flutter_sns/write/data/datasources/user_datasource.dart';
import 'package:flutter_sns/write/data/datasources/firebase_storage_datasource.dart';
import 'package:flutter_sns/write/data/models/users_model.dart' as dto;

class UserRepositoryImpl implements UserRepository {
  final UserDatasource _ds;
  final FirebaseStorageDataSource _storageDs;

  UserRepositoryImpl(this._ds, this._storageDs);

  @override
  Future<domain.User> getUserProfile(String uid) async {
    final m = await _ds.getUser(uid);
    if (m == null) {
      throw Exception('사용자 정보가 없습니다.');
    }
    return domain.User(
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
  }

  @override
  Future<void> updateUserProfile(domain.User u) async {
    // 도메인 -> DTO 매핑
    final m = dto.UsersModel(
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
      createdAt: u.createdAt, // createUser 시에만 사용됨
      updatedAt: u.updatedAt,
      reportCount: u.reportCount,
    );

    // updatedAt / nicknameLower는 DataSource에서 일괄 처리
    await _ds.updateUserProfile(m);
  }

  @override
  Future<void> updateUserStats(String uid, domain.UserStats s) async {
    // 부분 업데이트 전용 — DTO 변환만 해서 전달
    final stats = dto.UserStats(
      postsCount: s.postsCount,
      commentsCount: s.commentsCount,
      empathyReceived: s.empathyReceived,
      punchReceived: s.punchReceived,
    );
    await _ds.updateUserStats(uid, stats);
  }

  @override
  Future<String> uploadProfileImage(String uid, File file) async {
    final url = await _storageDs.uploadProfileImage(uid, file);
    return url ?? '';
  }

  @override
  Future<bool> isNicknameDuplicate(String nickname) async {
    return _ds.existsNicknameLower(nickname);
  }
}
