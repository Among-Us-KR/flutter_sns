import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sns/write/data/models/users_model.dart';

/// Firestore users 컬렉션용 데이터소스
class FirebaseUserDatasource {
  final FirebaseFirestore _firestore;

  FirebaseUserDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('users');

  /// 최초 생성: 문서 id == uid, 데이터에도 uid 포함, 서버시간 세팅
  Future<void> createUser(UsersModel user) async {
    final uid = user.uid;
    final data = user.toJson();

    // 닉네임 소문자 필드(중복 체크용) 보강
    data['uid'] = uid;
    data['nicknameLower'] = (user.nickname).toLowerCase();

    // 서버 시간
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();

    await _col.doc(uid).set(data);
  }

  /// 조회
  Future<UsersModel?> getUser(String uid) async {
    final doc = await _col.doc(uid).get();
    if (!doc.exists) return null;
    final json = doc.data()!;
    // Firestore Timestamp 허용 (UsersModel.fromJson에서 처리)
    return UsersModel.fromJson(json);
  }

  /// 업데이트: 서버시간 + nicknameLower 동기화
  Future<void> updateUser(UsersModel user) async {
    final data = user.toJson();
    data['nicknameLower'] = (user.nickname).toLowerCase();
    data['updatedAt'] = FieldValue.serverTimestamp();

    await _col.doc(user.uid).update(data);
  }

  /// 닉네임 중복 체크(대소문자 무시)
  Future<bool> isNicknameDuplicate(String nickname) async {
    final lower = nickname.toLowerCase();
    final snap = await _col
        .where('nicknameLower', isEqualTo: lower)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }
}
