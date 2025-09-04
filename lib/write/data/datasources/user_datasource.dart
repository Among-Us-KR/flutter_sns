import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/users_model.dart' as dto;

/// users 컬렉션용 추상 데이터소스
abstract class UserDatasource {
  Future<void> createUser(dto.UsersModel user);
  Future<dto.UsersModel?> getUser(String uid);
  Future<void> updateUserProfile(dto.UsersModel user);
  Future<void> updateUserStats(
    String uid,
    dto.UserStats stats,
  ); // <- 추가 및 이름 통일
  Future<bool> existsNicknameLower(String nickname);
  Future<void> incrementUserPostsCount(String uid);
  Future<void> decrementUserPostsCount(String uid);
  Future<void> incrementEmpathyCount(String userId);
  Future<void> decrementEmpathyCount(String userId);
  Future<void> incrementPunchCount(String userId);
  Future<void> decrementPunchCount(String userId);
}

/// Firestore 구현체
class FirebaseUserDatasource implements UserDatasource {
  final FirebaseFirestore _firestore;

  FirebaseUserDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('users');

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

  @override
  Future<void> updateUserProfile(dto.UsersModel user) async {
    // 1. DTO의 toJson() 메서드를 호출하여 업데이트할 데이터를 가져옵니다.
    //    (이때, 'nicknameLower' 필드가 자동으로 포함됩니다.)
    final data = user.toJson();

    // 2. 서버 타임스탬프를 사용하여 'updatedAt' 필드를 갱신합니다.
    data['updatedAt'] = FieldValue.serverTimestamp();

    // 3. 'uid' 필드는 문서 ID로 사용되므로 업데이트 데이터에서 제거합니다.
    data.remove('uid');

    // 4. Firestore 문서에 업데이트를 적용합니다.
    await _col.doc(user.uid).update(data);
  }

  @override
  Future<void> updateUserStats(String uid, dto.UserStats stats) async {
    // <- 이름 통일
    await _col.doc(uid).update({
      'stats.postsCount': stats.postsCount,
      'stats.commentsCount': stats.commentsCount,
      'stats.empathyReceived': stats.empathyReceived,
      'stats.punchReceived': stats.punchReceived,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<bool> existsNicknameLower(String nickname) async {
    final lower = nickname.trim().toLowerCase();
    final snap = await _col
        .where('nicknameLower', isEqualTo: lower)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  @override
  Future<void> incrementUserPostsCount(String uid) async {
    await _col.doc(uid).update({
      'stats.postsCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> decrementUserPostsCount(String uid) async {
    await _col.doc(uid).update({
      'stats.postsCount': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> incrementEmpathyCount(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'stats.empathyReceived': FieldValue.increment(1),
    });
  }

  @override
  Future<void> decrementEmpathyCount(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'stats.empathyReceived': FieldValue.increment(-1),
    });
  }

  @override
  Future<void> incrementPunchCount(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'stats.punchReceived': FieldValue.increment(1),
    });
  }

  @override
  Future<void> decrementPunchCount(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'stats.punchReceived': FieldValue.increment(-1),
    });
  }
}
