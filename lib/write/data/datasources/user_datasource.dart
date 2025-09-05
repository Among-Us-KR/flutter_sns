import '../models/users_model.dart' as dto;

/// users 컬렉션용 추상 데이터소스
abstract class UserDatasource {
  Future<void> createUser(dto.UsersModel user);
  Future<dto.UsersModel?> getUser(String uid);
  Future<void> updateUserProfile(dto.UsersModel user);
  Future<void> updateUserStats(String uid, dto.UserStats stats);
  Future<bool> existsNicknameLower(String nickname);

  // 내가 쓴 글 수
  Future<void> incrementPostsCount(String uid);
  Future<void> decrementPostsCount(String uid);

  // 내가 쓴 댓글 수
  Future<void> incrementMyCommentsCount(String uid);
  Future<void> decrementMyCommentsCount(String uid);

  // 내가 쓴 공감 수
  Future<void> incrementMyLikesCount(String uid);
  Future<void> decrementMyLikesCount(String uid);

  // ✅ 받은 댓글 수 (공감으로 변경)
  Future<void> incrementCommentsReceived(String uid);
  Future<void> decrementCommentsReceived(String uid);

  // ✅ 받은 공감 수 (팩폭으로 변경)
  Future<void> incrementLikesReceived(String uid);
  Future<void> decrementLikesReceived(String uid);

  // 통계 실시간 스트림
  Stream<dto.UserStats> getUserStatsStream(String uid);
}
