import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountService {
  static Future<String> deleteAccount(BuildContext context) async {
    // 현재 로그인된 사용자 확인
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('⚠️ deleteAccount 호출 시점: 로그인된 사용자가 없습니다.');
      throw Exception('로그인된 사용자가 없습니다.');
    } else {
      print('✅ deleteAccount 호출: 로그인된 사용자 UID = ${user.uid}');
    }

    try {
      // 🔑 최신 토큰 강제 갱신
      final idToken = await user.getIdToken(true);
      print('✅ 최신 ID Token 가져옴 (앞 20자리): $idToken...');

      // Functions 호출
      final callable = FirebaseFunctions.instanceFor(
        region: 'us-central1',
      ).httpsCallable('deleteUserAccount');

      final result = await callable();

      print('✅ Cloud Function 응답: ${result.data}');
      return (result.data is Map && result.data['message'] is String)
          ? result.data['message'] as String
          : '회원 탈퇴가 완료되었습니다.';
    } catch (e) {
      print('❌ 회원 탈퇴 실패 (Cloud Functions 호출 에러): $e');
      rethrow;
    }
  }
}
