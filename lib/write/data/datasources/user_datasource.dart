import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/users_model.dart' as dto;

/// users 컬렉션용 추상 데이터소스
abstract class UserDatasource {
  Future<void> createUser(dto.UsersModel user);
  Future<dto.UsersModel?> getUser(String uid);
  Future<void> updateUserProfile(dto.UsersModel user); // 프로필 필드 업데이트
  Future<void> updateUserStats(
    String uid,
    dto.UserStats stats,
  ); // stats만 부분 업데이트
  Future<bool> existsNicknameLower(String nicknameLower);
  Future<void> incrementUserPostsCount(String uid);
  Future<void> decrementUserPostsCount(String uid);
}

/// Firestore 구현체
class FirebaseUserDatasource implements UserDatasource {
  final FirebaseFirestore _firestore;
  FirebaseUserDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('users');

  /// 최초 생성: 문서 id == uid, 서버시간 세팅, nicknameLower 동기화
  @override
  Future<void> createUser(dto.UsersModel user) async {
    final data = user.toJson()
      ..['uid'] = user.uid
      ..['nicknameLower'] = user.nickname.trim().toLowerCase()
      ..['createdAt'] = FieldValue.serverTimestamp()
      ..['updatedAt'] = FieldValue.serverTimestamp();

    await _col.doc(user.uid).set(data);
  }

  @override
  Future<dto.UsersModel?> getUser(String uid) async {
    final doc = await _col.doc(uid).get();
    if (!doc.exists) return null;
    return dto.UsersModel.fromJson(doc.data()!);
  }

  /// 프로필 업데이트: 서버시간 + nicknameLower 동기화
  @override
  Future<void> updateUserProfile(dto.UsersModel user) async {
    final data = user.toJson()
      ..['nicknameLower'] = user.nickname.trim().toLowerCase()
      ..['updatedAt'] = FieldValue.serverTimestamp();

    await _col.doc(user.uid).update(data);
  }

  /// 통계만 부분 업데이트 (문서 전체 덮지 않음)
  @override
  Future<void> updateUserStats(String uid, dto.UserStats stats) async {
    await _col.doc(uid).update({
      'stats.postsCount': stats.postsCount,
      'stats.commentsCount': stats.commentsCount,
      'stats.empathyReceived': stats.empathyReceived,
      'stats.punchReceived': stats.punchReceived,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 닉네임 중복(대소문자 무시)
  @override
  Future<bool> existsNicknameLower(String nicknameLower) async {
    final lower = nicknameLower.trim().toLowerCase();
    final snap = await _col
        .where('nicknameLower', isEqualTo: lower)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  @override
  Future<void> decrementUserPostsCount(String uid) async {
    await _col.doc(uid).update({
      'stats.postsCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> incrementUserPostsCount(String uid) async {
    await _col.doc(uid).update({
      'stats.postsCount': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
