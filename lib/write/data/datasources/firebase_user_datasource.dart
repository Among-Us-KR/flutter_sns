import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sns/write/data/datasources/user_datasource.dart';
import 'package:flutter_sns/write/data/models/users_model.dart' as dto;

/// Firestore users 컬렉션용 데이터소스
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
    final json = doc.data()!;
    return dto.UsersModel.fromJson(json);
  }

  @override
  Future<void> updateUserProfile(dto.UsersModel user) async {
    final data = user.toJson();
    data['nicknameLower'] = (user.nickname).toLowerCase();
    data['updatedAt'] = FieldValue.serverTimestamp();
    data.remove('uid');
    await _col.doc(user.uid).update(data);
  }

  @override
  Future<bool> existsNicknameLower(String nickname) async {
    final lower = nickname.toLowerCase();
    final snap = await _col
        .where('nicknameLower', isEqualTo: lower)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  @override
  Future<void> incrementPostsCount(String uid) async {
    final userRef = _col.doc(uid);
    return _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final currentCount = userSnapshot.data()?['stats.postsCount'] ?? 0;
      final newCount = currentCount + 1;
      if (newCount < 0) return;
      transaction.update(userRef, {'stats.postsCount': newCount});
    });
  }

  @override
  Future<void> decrementPostsCount(String uid) async {
    final userRef = _col.doc(uid);
    return _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final currentCount = userSnapshot.data()?['stats.postsCount'] ?? 0;
      final newCount = currentCount - 1;
      if (newCount < 0) return;
      transaction.update(userRef, {'stats.postsCount': newCount});
    });
  }

  @override
  Future<void> incrementMyCommentsCount(String uid) async {
    final userRef = _col.doc(uid);
    return _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final currentCount = userSnapshot.data()?['stats.commentsCount'] ?? 0;
      final newCount = currentCount + 1;
      if (newCount < 0) return;
      transaction.update(userRef, {'stats.commentsCount': newCount});
    });
  }

  @override
  Future<void> decrementMyCommentsCount(String uid) async {
    final userRef = _col.doc(uid);
    return _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final currentCount = userSnapshot.data()?['stats.commentsCount'] ?? 0;
      final newCount = currentCount - 1;
      if (newCount < 0) return;
      transaction.update(userRef, {'stats.commentsCount': newCount});
    });
  }

  @override
  Future<void> incrementMyLikesCount(String uid) async {
    final userRef = _col.doc(uid);
    return _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final currentCount = userSnapshot.data()?['stats.likesCount'] ?? 0;
      final newCount = currentCount + 1;
      if (newCount < 0) return;
      transaction.update(userRef, {'stats.likesCount': newCount});
    });
  }

  @override
  Future<void> decrementMyLikesCount(String uid) async {
    final userRef = _col.doc(uid);
    return _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final currentCount = userSnapshot.data()?['stats.likesCount'] ?? 0;
      final newCount = currentCount - 1;
      if (newCount < 0) return;
      transaction.update(userRef, {'stats.likesCount': newCount});
    });
  }

  @override
  Future<void> incrementLikesReceived(String uid) async {
    final userRef = _col.doc(uid);
    return _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final currentCount = userSnapshot.data()?['stats.likesReceived'] ?? 0;
      final newCount = currentCount + 1;
      if (newCount < 0) return;
      transaction.update(userRef, {'stats.likesReceived': newCount});
    });
  }

  @override
  Future<void> decrementLikesReceived(String uid) async {
    final userRef = _col.doc(uid);
    return _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final currentCount = userSnapshot.data()?['stats.likesReceived'] ?? 0;
      final newCount = currentCount - 1;
      if (newCount < 0) return;
      transaction.update(userRef, {'stats.likesReceived': newCount});
    });
  }

  @override
  Future<void> incrementCommentsReceived(String uid) async {
    final userRef = _col.doc(uid);
    return _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final currentCount = userSnapshot.data()?['stats.commentsReceived'] ?? 0;
      final newCount = currentCount + 1;
      if (newCount < 0) return;
      transaction.update(userRef, {'stats.commentsReceived': newCount});
    });
  }

  @override
  Future<void> decrementCommentsReceived(String uid) async {
    final userRef = _col.doc(uid);
    return _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final currentCount = userSnapshot.data()?['stats.commentsReceived'] ?? 0;
      final newCount = currentCount - 1;
      if (newCount < 0) return;
      transaction.update(userRef, {'stats.commentsReceived': newCount});
    });
  }

  @override
  Future<void> updateUserStats(String uid, dto.UserStats stats) async {
    await _col.doc(uid).update({
      'stats.postsCount': stats.postsCount,
      'stats.commentsCount': stats.commentsCount,
      'stats.likesCount': stats.likesCount,
      'stats.commentsReceived': stats.commentsReceived,
      'stats.likesReceived': stats.likesReceived,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<dto.UserStats> getUserStatsStream(String uid) {
    return _col.doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return const dto.UserStats();
      }
      final userData = snapshot.data();
      final statsData = userData?['stats'];
      if (statsData == null) {
        return const dto.UserStats();
      }
      return dto.UserStats.fromJson(statsData);
    });
  }
}
