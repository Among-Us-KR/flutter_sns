import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sns/write/core/services/nickname_validator.dart';
import 'package:flutter_sns/write/domain/repository/users_repository.dart';
import 'package:flutter_sns/write/domain/entities/users.dart' as domain;
import 'package:flutter_sns/write/data/datasources/user_datasource.dart';
import 'package:flutter_sns/write/data/datasources/firebase_storage_datasource.dart';
import 'package:flutter_sns/write/data/models/users_model.dart' as dto;

class UserRepositoryImpl implements UserRepository {
  final UserDatasource _ds;
  final FirebaseStorageDataSource _storageDs;
  final FirebaseFirestore _firestore;

  UserRepositoryImpl(this._ds, this._storageDs, this._firestore);

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
        likesCount: m.stats.likesCount,
        commentsReceived: m.stats.commentsReceived,
        likesReceived: m.stats.likesReceived,
      ),
      pushNotifications: m.pushNotifications,
      createdAt: m.createdAt,
      updatedAt: m.updatedAt,
      reportCount: m.reportCount,
    );
  }

  @override
  Future<void> updateUserProfile(domain.User u) async {
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
        likesCount: u.stats.likesCount,
        // DTO 필드와 일치하도록 명확하게 변환
        commentsReceived: u.stats.commentsReceived,
        likesReceived: u.stats.likesReceived,
      ),
      pushNotifications: u.pushNotifications,
      createdAt: u.createdAt,
      updatedAt: u.updatedAt,
      reportCount: u.reportCount,
    );
    await _ds.updateUserProfile(m);
  }

  @override
  Future<void> updateUserStats(String uid, domain.UserStats s) async {
    final stats = dto.UserStats(
      postsCount: s.postsCount,
      commentsCount: s.commentsCount,
      likesCount: s.likesCount,
      // DTO 필드와 일치하도록 명확하게 변환
      commentsReceived: s.commentsReceived,
      likesReceived: s.likesReceived,
    );
    await _ds.updateUserStats(uid, stats);
  }

  @override
  Future<String> uploadProfileImage(String uid, File file) async {
    final url = await _storageDs.uploadProfileImage(uid, file);
    return url;
  }

  @override
  Future<bool> isNicknameDuplicate(String nickname) async {
    final lowerNickname = NicknamePolicy.normalizedLower(nickname);
    return _ds.existsNicknameLower(lowerNickname);
  }

  @override
  Future<void> updateDenormalizedUserData({
    required String uid,
    required String newNickname,
    required String? newProfileImageUrl,
  }) async {
    final batch = _firestore.batch();

    final postCollection = _firestore.collection('posts');
    final userPostsQuery = await postCollection
        .where('authorId', isEqualTo: uid)
        .get();
    for (var doc in userPostsQuery.docs) {
      batch.update(doc.reference, {
        'author.nickname': newNickname,
        'author.profileImageUrl': newProfileImageUrl,
      });
    }

    final commentsCollection = _firestore.collection('comments');
    final userCommentsQuery = await commentsCollection
        .where('userId', isEqualTo: uid)
        .get();
    for (var doc in userCommentsQuery.docs) {
      batch.update(doc.reference, {
        'author.nickname': newNickname,
        'author.profileImageUrl': newProfileImageUrl,
      });
    }

    await batch.commit();
  }

  @override
  Stream<domain.UserStats> getUserStatsStream(String uid) {
    return _ds.getUserStatsStream(uid).map((dtoStats) {
      return domain.UserStats(
        postsCount: dtoStats.postsCount,
        likesCount: dtoStats.likesCount,
        commentsCount: dtoStats.commentsCount,
        commentsReceived: dtoStats.commentsReceived,
        likesReceived: dtoStats.likesReceived,
      );
    });
  }
}
