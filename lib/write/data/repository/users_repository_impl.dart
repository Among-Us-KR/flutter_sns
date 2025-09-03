import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_sns/write/data/datasources/firebase_user_datasource.dart';
import 'package:flutter_sns/write/data/models/users_model.dart' as model;
import 'package:flutter_sns/write/domain/entities/users.dart' as entity;
import 'package:flutter_sns/write/domain/repository/users_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDatasource _userDatasource;
  final FirebaseStorage _storage;

  UserRepositoryImpl(this._userDatasource, this._storage);

  @override
  Future<entity.User> getUserProfile(String uid) async {
    try {
      final userModel = await _userDatasource.getUser(uid);
      if (userModel == null) {
        throw Exception('User not found.');
      }
      return _toEntity(userModel);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  @override
  Future<void> updateUserProfile(entity.User user) async {
    try {
      final userModel = _toModel(user);
      await _userDatasource.updateUser(userModel);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  @override
  Future<void> updateUserStats(String uid, entity.UserStats stats) async {
    try {
      final userModel = await _userDatasource.getUser(uid);
      if (userModel != null) {
        final updatedStats = userModel.stats.copyWith(
          postsCount: stats.postsCount,
          commentsCount: stats.commentsCount,
          empathyReceived: stats.empathyReceived,
          punchReceived: stats.punchReceived,
        );
        final updatedUserModel = userModel.copyWith(stats: updatedStats);
        await _userDatasource.updateUser(updatedUserModel);
      }
    } catch (e) {
      throw Exception('Failed to update user stats: $e');
    }
  }

  @override
  Future<String> uploadProfileImage(String uid, String imagePath) async {
    try {
      final file = File(imagePath);
      final ref = _storage.ref().child('profile_images/$uid.jpg');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  // 데이터 모델(DTO)과 엔티티 간 변환 메서드
  entity.User _toEntity(model.UsersModel userModel) {
    return entity.User(
      uid: userModel.uid,
      email: userModel.email,
      nickname: userModel.nickname,
      profileImageUrl: userModel.profileImageUrl,
      privacyConsent: entity.PrivacyConsent(
        agreedAt: userModel.privacyConsent.agreedAt,
        version: userModel.privacyConsent.version,
        ipAddress: userModel.privacyConsent.ipAddress,
      ),
      stats: entity.UserStats(
        postsCount: userModel.stats.postsCount,
        commentsCount: userModel.stats.commentsCount,
        empathyReceived: userModel.stats.empathyReceived,
        punchReceived: userModel.stats.punchReceived,
      ),
      pushNotifications: userModel.pushNotifications,
      createdAt: userModel.createdAt,
      updatedAt: userModel.updatedAt,
      reportCount: userModel.reportCount,
    );
  }

  model.UsersModel _toModel(entity.User user) {
    return model.UsersModel(
      uid: user.uid,
      email: user.email,
      nickname: user.nickname,
      profileImageUrl: user.profileImageUrl,
      privacyConsent: model.PrivacyConsent(
        agreedAt: user.privacyConsent.agreedAt,
        version: user.privacyConsent.version,
        ipAddress: user.privacyConsent.ipAddress,
      ),
      stats: model.UserStats(
        postsCount: user.stats.postsCount,
        commentsCount: user.stats.commentsCount,
        empathyReceived: user.stats.empathyReceived,
        punchReceived: user.stats.punchReceived,
      ),
      pushNotifications: user.pushNotifications,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      reportCount: user.reportCount,
    );
  }
}
