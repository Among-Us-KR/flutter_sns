import 'dart:io';

import 'package:flutter_sns/write/domain/entities/users.dart';

abstract class UserRepository {
  // 현재 사용자의 프로필 정보를 가져옵니다.
  Future<User> getUserProfile(String uid);

  // 사용자의 프로필 정보를 업데이트합니다.
  Future<void> updateUserProfile(User user);

  // 사용자의 특정 통계(게시글 수, 공감 수 등)를 업데이트합니다.
  Future<void> updateUserStats(String uid, UserStats stats);

  // 사용자의 프로필 이미지를 업로드하고 URL을 반환합니다.
  Future<String> uploadProfileImage(String uid, File file);

  /// 닉네임 중복 여부를 확인합니다.
  Future<bool> isNicknameDuplicate(String nickname);
}
