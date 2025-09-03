// 사용자 알림 설정 UI 스위치
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/push_notification_provider.dart';

class NotificationToggle extends ConsumerWidget {
  const NotificationToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return const SizedBox();

    final isEnabled = ref.watch(pushNotificationProvider);

    return SwitchListTile(
      title: const Text('댓글 알림 받기'),
      value: isEnabled,
      onChanged: (value) async {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'pushNotifications': value});

        ref.read(pushNotificationProvider.notifier).state = value;
      },
    );
  }
}
