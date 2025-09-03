import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sns/write/data/models/users_model.dart';

abstract class UserDatasource {
  Future<UsersModel?> getUser(String uid);
  Future<void> updateUser(UsersModel user);
}

class FirebaseUserDatasource implements UserDatasource {
  final FirebaseFirestore _firestore;

  FirebaseUserDatasource(this._firestore);

  @override
  Future<UsersModel?> getUser(String uid) async {
    final docSnapshot = await _firestore.collection('users').doc(uid).get();
    if (!docSnapshot.exists) {
      return null;
    }
    return UsersModel.fromJson(docSnapshot.data()!);
  }

  @override
  Future<void> updateUser(UsersModel user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toJson());
  }
}
