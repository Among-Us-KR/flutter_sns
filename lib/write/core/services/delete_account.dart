import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<void> _deleteAccount(BuildContext context) async {
  try {
    final callable = FirebaseFunctions.instance.httpsCallable(
      'deleteUserAccount',
    );
    final result = await callable();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.data['message'] ?? '회원 탈퇴 완료')),
      );
      context.goNamed('login');
    }
  } catch (e) {
    print('회원 탈퇴 실패: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('회원 탈퇴 실패: $e')));
    }
  }
}
